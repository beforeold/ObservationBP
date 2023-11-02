//
//  Observing.swift
//
//  Created by wp on 2023/11/2.
//

import Combine
import Foundation
import ObservationBPLock
import SwiftUI

@propertyWrapper
public struct Observing<Value: AnyObject>: DynamicProperty {
    // instance keep, like @StateObject  https://gist.github.com/Amzd/8f0d4d94fcbb6c9548e7cf0c1493eaff
    @State private var storage = Storage<Value>()
    private var thunk: () -> Value

    public var wrappedValue: Value {
        set {
            storage.value = newValue
        }
        get {
            ensureStorageValue()
            if !storage.tracker.isRunning {
                storage.tracker.start { [weak storage] in
                    if let storage {
                        Task { @MainActor in
                            let new = Storage<Value>()
                            new.value = storage.value
                            self.storage = new
                        }
                    }
                }
                DispatchQueue.main.async { [weak storage] in
                    storage?.tracker.close()
                }
            }
            return storage.value!
        }
    }

    @MainActor
    public var projectedValue: Bindable {
        ensureStorageValue()
        return Bindable(storage: storage)
    }

    public init(wrappedValue: @autoclosure @escaping () -> Value) {
        thunk = wrappedValue
    }

    public mutating func update() {
        _storage.update()
    }

    private func ensureStorageValue() {
        if storage.value == nil {
            storage.value = thunk()
        }
    }
}

extension Observing: Equatable {
    public static func == (lhs: Observing<Value>, rhs: Observing<Value>) -> Bool {
        lhs.storage.value === rhs.storage.value
    }
}

public extension Observing {
    @dynamicMemberLookup
    struct Bindable {
        private let storage: Storage<Value>

        fileprivate init(storage: Storage<Value>) {
            self.storage = storage
        }

        @MainActor
        public subscript<V>(dynamicMember keyPath: ReferenceWritableKeyPath<Value, V>) -> Binding<V> {
            Binding {
                storage.value![keyPath: keyPath]
            } set: { newValue in
                storage.value![keyPath: keyPath] = newValue
            }
        }
    }
}

private final class Storage<Value> {
    let tracker = Tracker()
    var value: Value?
}

private weak var previousTracker: Tracker?

private final class Tracker {
    private(set) var isRunning = false
    private var previous: UnsafeMutableRawPointer?
    private var accessList: ObservationTracking._AccessList?
    private var onChange: (() -> @Sendable () -> Void)?

    deinit {
        if isRunning {
            isRunning = false
            _ThreadLocal.value = previous
            if previousTracker === self {
                previousTracker = nil
            }
        }
    }

    func start(onChange: @autoclosure @escaping () -> @Sendable () -> Void) {
        guard !isRunning else { return }
        isRunning = true
        self.onChange = onChange

        if let previous = previousTracker, previous !== self {
            previous.close()
            previousTracker = nil
        }

        withUnsafeMutablePointer(to: &accessList) { ptr in
            self.previous = _ThreadLocal.value
            _ThreadLocal.value = UnsafeMutableRawPointer(ptr)
            if let scoped = ptr.pointee, let previous = self.previous {
                if var prevList = previous.assumingMemoryBound(to: ObservationTracking._AccessList?.self).pointee {
                    prevList.merge(scoped)
                    previous.assumingMemoryBound(to: ObservationTracking._AccessList?.self).pointee = prevList
                } else {
                    previous.assumingMemoryBound(to: ObservationTracking._AccessList?.self).pointee = scoped
                }
            }
        }
        previousTracker = self
    }

    func close() {
        guard isRunning else { return }
        isRunning = false

        _ThreadLocal.value = previous
        if let accessList, let onChange {
            ObservationTracking._installTracking(accessList, onChange: onChange())
        }
        previous = nil
        onChange = nil
        if previousTracker === self {
            previousTracker = nil
        }
    }
}
