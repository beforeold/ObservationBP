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
    @ObservedObject private var emitter = Emitter<Value>()
    @State private var container: Container<Value>

#if DEBUG
    public var id: String {
        set {
            container.tracker.id = newValue
        }
        get {
            container.tracker.id
        }
    }
#endif

    @MainActor
    public var wrappedValue: Value {
        set {
            container.value = newValue
        }
        get {
            if !container.tracker.isRunning {
                let id = self.id
                container.tracker.open { [weak container, weak emitter] in
                    if let emitter, let container, !container.state.dirty {
                        print("🌜update", id)
                        container.state.dirty = true
                        emitter.objectWillChange.send(container.value)
                    }
                }
            }
            return container.value
        }
    }

    @MainActor
    public var projectedValue: Bindable {
        return Bindable(observing: self)
    }

    public init(wrappedValue: Value) {
        let container = Container(value: wrappedValue)
        _container = .init(initialValue: container)
//        _stateContainer = .init(initialValue: container)
    }

    public func update() {
        print("🌞updated", id)
        if container.state.dirty {
            DispatchQueue.main.async { [weak container] in
                container?.state.dirty = false
            }
        }
    }
}

extension Observing: Equatable {
    public static func == (lhs: Observing<Value>, rhs: Observing<Value>) -> Bool {
        if lhs.container.state.dirty || rhs.container.state.dirty {
            return false
        }
        return lhs.container.value === rhs.container.value
    }
}

public extension Observing {
    @dynamicMemberLookup
    struct Bindable {
        private let observing: Observing<Value>

        fileprivate init(observing: Observing<Value>) {
            self.observing = observing
        }

        @MainActor
        public subscript<V>(dynamicMember keyPath: ReferenceWritableKeyPath<Value, V>) -> Binding<V> {
            Binding {
                observing.wrappedValue[keyPath: keyPath]
            } set: { newValue in
                observing.wrappedValue[keyPath: keyPath] = newValue
            }
        }
    }
}

private final class Emitter<Value: AnyObject>: ObservableObject {
    let objectWillChange = PassthroughSubject<Value, Never>()
}

private final class Container<Value: AnyObject>: ObservableObject {
    var value: Value
    private(set) var uuid = UUID()
    private(set) var tracker = Tracker()
    private(set) var state = ObservingState()

    deinit {
        print("deinit", self)
    }

    init(value: Value) {
        self.value = value
    }
}

// private final class Storage<Value: AnyObject> {
//    private var _value: Value?
//    private var thunk: (() -> Value)?
//    var value: Value? {
//        get {
//            if _value == nil, thunk != nil {
//                _value = thunk?()
//            }
//            return _value
//        }
//        set {
//            _value = newValue
//        }
//    }
//
//    init(value: Value? = nil, thunk: (() -> Value)? = nil) {
//        self.value = value
//        self.thunk = thunk
//    }
// }

private final class ObservingState {
    var dirty = false
}

private weak var previousTracker: Tracker?

private final class TrackerOne {
    private(set) var accessList: ObservationTracking._AccessList?
    let ptr: UnsafeMutablePointer<ObservationTracking._AccessList?>

    var previous: UnsafeMutableRawPointer?
    var onChange: (() -> @Sendable () -> Void)?

    init() {
        ptr = withUnsafeMutablePointer(to: &accessList) { $0 }
    }
}

private final class Tracker {
    private(set) var isRunning = false
    private var tracker: TrackerOne?
    var id: String = ""

    deinit {
        print("deinit", id)

        if isRunning {
            isRunning = false
            _ThreadLocal.value = tracker?.previous
            tracker = nil
            if previousTracker === self {
                previousTracker = nil
            }
        }
    }

    @MainActor
    func open(onChange: @autoclosure @escaping () -> @Sendable () -> Void) {
        guard !isRunning else { return }
        isRunning = true

        if let previous = previousTracker {
            previous.close()
            previousTracker = nil
        }

        // print("  >>> open", id)

        let one = TrackerOne()
        one.onChange = onChange
        one.previous = _ThreadLocal.value
        tracker = one
        _ThreadLocal.value = UnsafeMutableRawPointer(one.ptr)

        previousTracker = self

        DispatchQueue.main.async { [weak self] in
            self?.close()
        }
    }

    @MainActor
    func close() {
        defer {
            isRunning = false
            tracker = nil
            if previousTracker === self {
                previousTracker = nil
            }
        }
        guard isRunning, let lastOne = tracker else { return }

        let accessList = lastOne.accessList
        let ptr = lastOne.ptr

        // print("  <<< close", id, accessList?.entries.values.map(\.properties))

        if let scoped = ptr.pointee, let previous = lastOne.previous {
            if var prevList = previous.assumingMemoryBound(to: ObservationTracking._AccessList?.self).pointee {
                prevList.merge(scoped)
                previous.assumingMemoryBound(to: ObservationTracking._AccessList?.self).pointee = prevList
            } else {
                previous.assumingMemoryBound(to: ObservationTracking._AccessList?.self).pointee = scoped
            }
        }
        _ThreadLocal.value = lastOne.previous

        if let accessList, let onChange = lastOne.onChange {
            ObservationTracking._installTracking(accessList, onChange: onChange())
        }
    }
}
