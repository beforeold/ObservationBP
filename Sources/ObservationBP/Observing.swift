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
    @ObservedObject private var emitter: Emitter<Value>
    private let tracker = Tracker()
    private let state = ObservingState()
    private var storage: Storage<Value> {
        emitter.storage
    }

#if DEBUG
    public var id: String? {
        set {
            tracker.id = newValue
        }
        get {
            tracker.id
        }
    }
#endif

    @MainActor
    public var wrappedValue: Value {
        set {
            storage.value = newValue
        }
        get {
            if !tracker.isRunning {
                tracker.open { [weak state, weak emitter] in
                    if let state, !state.dirty {
                        state.dirty = true
                        emitter?.invalidate()
                    }
                }
            }
            return storage.value!
        }
    }

    @MainActor
    public var projectedValue: Bindable {
        return Bindable(storage: storage)
    }

    public init(wrappedValue: @autoclosure @escaping () -> Value) {
        let storage = Storage<Value>(thunk: wrappedValue)
        _emitter = .init(initialValue: Emitter(storage: storage))
    }

    public func update() {
        // print("🌞updated", id)
        if state.dirty {
            DispatchQueue.main.async { [weak state] in
                state?.dirty = false
            }
        }
    }
}

extension Observing: Equatable {
    public static func == (lhs: Observing<Value>, rhs: Observing<Value>) -> Bool {
        if lhs.state.dirty || rhs.state.dirty {
            return false
        }
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

private final class Emitter<Value: AnyObject>: ObservableObject {
    let objectWillChange = PassthroughSubject<Storage<Value>, Never>()
    let storage: Storage<Value>

    init(storage: Storage<Value>) {
        self.storage = storage
    }

    func invalidate() {
        objectWillChange.send(storage)
    }
}

private final class Storage<Value: AnyObject> {
    private var _value: Value?
    private var thunk: (() -> Value)?
    var value: Value? {
        get {
            if _value == nil, thunk != nil {
                _value = thunk?()
            }
            return _value
        }
        set {
            _value = newValue
        }
    }

    init(value: Value? = nil, thunk: (() -> Value)? = nil) {
        self.value = value
        self.thunk = thunk
    }
}

private final class ObservingState {
    var dirty = false
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
