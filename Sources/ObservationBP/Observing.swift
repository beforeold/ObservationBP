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
public struct Observing<Value: AnyObject & Observable>: DynamicProperty {
    // instance keep, like @StateObject  https://gist.github.com/Amzd/8f0d4d94fcbb6c9548e7cf0c1493eaff
    @State private var storage = Storage<Value>()
    private let tracker = Tracker()
    private let state = ObservingState()
    private var thunk: () -> Value

    public var id: String? {
        set {
            tracker.id = newValue
        }
        get {
            tracker.id
        }
    }

    @MainActor
    public var wrappedValue: Value {
        set {
            storage.value = newValue
        }
        get {
            ensureStorageValue()
            if !tracker.isRunning {
                tracker.open {
                    if !state.didUpdate {
                        state.didUpdate = true
                        // print("🌝update", self.id)

                        Task { @MainActor in
                            _storage.wrappedValue = Storage<Value>(value: storage.value)
                        }
                    }
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

    public func update() {
        // print("🌞updated", id)
        state.didUpdate = false
    }

    private func ensureStorageValue() {
        if storage.value == nil {
            storage.value = thunk()
        }
    }
}

extension Observing: Equatable {
    public static func == (lhs: Observing<Value>, rhs: Observing<Value>) -> Bool {
        lhs.ensureStorageValue()
        rhs.ensureStorageValue()
        return lhs.storage.value === rhs.storage.value
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

private final class Storage<Value: AnyObject> {
    var value: Value?

    init(value: Value? = nil) {
        self.value = value
    }
}

private final class ObservingState {
    var didUpdate = false
}

private weak var previousTracker: Tracker?

private final class Tracker {
    private(set) var isRunning = false
    private var previous: UnsafeMutableRawPointer?
    private var accessList: ObservationTracking._AccessList?
    private var onChange: (() -> @Sendable () -> Void)?

    var id: String?

    deinit {
        if isRunning {
            isRunning = false
            _ThreadLocal.value = previous
            if previousTracker === self {
                previousTracker = nil
            }
        }
    }

    @MainActor
    func open(onChange: @autoclosure @escaping () -> @Sendable () -> Void) {
        guard !isRunning else { return }
        isRunning = true
        self.onChange = onChange

        if let previous = previousTracker {
            previous.close()
            previousTracker = nil
        }

        // print("  >>> open", id)

        accessList = ObservationTracking._AccessList?.none
        withUnsafeMutablePointer(to: &accessList) { ptr in
            self.previous = _ThreadLocal.value
            _ThreadLocal.value = UnsafeMutableRawPointer(ptr)
        }
        previousTracker = self

        DispatchQueue.main.async { [weak self] in
            self?.close()
        }
    }

    @MainActor
    func close() {
        guard isRunning else { return }
        // print("  <<< close", id)
        // print("      <<<", accessList?.entries.values.map(\.properties))

        withUnsafeMutablePointer(to: &accessList) { ptr in
            if let scoped = ptr.pointee, let previous = self.previous {
                if var prevList = previous.assumingMemoryBound(to: ObservationTracking._AccessList?.self).pointee {
                    prevList.merge(scoped)
                    previous.assumingMemoryBound(to: ObservationTracking._AccessList?.self).pointee = prevList
                } else {
                    previous.assumingMemoryBound(to: ObservationTracking._AccessList?.self).pointee = scoped
                }
            }
        }
        _ThreadLocal.value = previous

        if let accessList, let onChange {
            ObservationTracking._installTracking(accessList, onChange: onChange())
        }
        previous = nil
        onChange = nil
        isRunning = false
        if previousTracker === self {
            previousTracker = nil
        }
    }
}
