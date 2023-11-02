//
//  Observing.swift
//  ObservationBPSwiftUIDemo
//
//  Created by wp on 2023/11/2.
//

import Combine
import Foundation
import ObservationBP
import SwiftUI

/*
 @dynamicMemberLookup
 public struct Observing<Value: AnyObject>: DynamicProperty {
     // instance keep, like @StateObject
     // https://gist.github.com/Amzd/8f0d4d94fcbb6c9548e7cf0c1493eaff
     @State private var storage = Storage<Value>()

     // trigger DynamicProperty update
     // https://github.com/DmT021/ObservationBD/blob/cb4a07fe46a69a9e68099352616dc2550e8e4228/ObservationBDSwiftUISample/AutoObservingView.swift#L12
     @ObservedObject private var emitter = Emitter()
     private var thunk: () -> Value

     public var object: Value {
         ensureStorageValue()
         return storage.value!
     }

     public init(_ value: @autoclosure @escaping () -> Value) {
         self.thunk = value
     }

     public subscript<V>(dynamicMember keyPath: KeyPath<Value, V>) -> V {
         ensureStorageValue()
         return withObservationTracking {
             storage.value![keyPath: keyPath]
         } onChange: {
             Task {
                 await invalidate()
             }
         }
     }

     public subscript<V>(dynamicMember keyPath: WritableKeyPath<Value, V>) -> V {
         get {
             ensureStorageValue()
             return withObservationTracking {
                 storage.value![keyPath: keyPath]
             } onChange: {
                 Task {
                     await invalidate()
                 }
             }
         }
         nonmutating set {
             ensureStorageValue()
             storage.value![keyPath: keyPath] = newValue
         }
     }

     public mutating func update() {
         _storage.update()
     }

     private func ensureStorageValue() {
         if storage.value == nil {
             storage.value = thunk()
         }
     }

     @MainActor private func invalidate() {
         emitter.objectWillChange.send()
     }
 }
 */

@propertyWrapper
public struct Observing<Value: AnyObject>: DynamicProperty {
    // instance keep, like @StateObject
    // https://gist.github.com/Amzd/8f0d4d94fcbb6c9548e7cf0c1493eaff
    @State private var storage = Storage<Value>()

    // trigger DynamicProperty update
    // https://github.com/DmT021/ObservationBD/blob/cb4a07fe46a69a9e68099352616dc2550e8e4228/ObservationBDSwiftUISample/AutoObservingView.swift#L12
    @ObservedObject private var emitter = Emitter()
    private var thunk: () -> Value

    public var wrappedValue: Value {
        set {
            storage.value = newValue
        }
        get {
            ensureStorageValue()

            return withObservationTracking {
                storage.value!
            } onChange: {
                Task {
                    await invalidate()
                }
            }
        }
    }
    
    

    public init(wrappedValue: @autoclosure @escaping () -> Value) {
        thunk = wrappedValue
    }

//
//    public subscript<V>(dynamicMember keyPath: KeyPath<Value, V>) -> V {
//        ensureStorageValue()
//        return withObservationTracking {
//            storage.value![keyPath: keyPath]
//        } onChange: {
//            Task {
//                await invalidate()
//            }
//        }
//    }
//
//    public subscript<V>(dynamicMember keyPath: WritableKeyPath<Value, V>) -> V {
//        get {
//            ensureStorageValue()
//            return withObservationTracking {
//                storage.value![keyPath: keyPath]
//            } onChange: {
//                Task {
//                    await invalidate()
//                }
//            }
//        }
//        nonmutating set {
//            ensureStorageValue()
//            storage.value![keyPath: keyPath] = newValue
//        }
//    }

    public mutating func update() {
        _storage.update()
    }

    private func ensureStorageValue() {
        if storage.value == nil {
            storage.value = thunk()
        }
    }

    @MainActor private func invalidate() {
        emitter.objectWillChange.send()
    }
}

extension Observing: Equatable {
    public static func == (lhs: Observing<Value>, rhs: Observing<Value>) -> Bool {
        lhs.wrappedValue === rhs.wrappedValue
    }
}

private final class Storage<Value> {
    var value: Value?
}

private final class Emitter: ObservableObject {
    let objectWillChange = PassthroughSubject<Void, Never>()
}
