//
//  File.swift
//  
//
//  Created by Brook_Mobius on 11/20/23.
//

import SwiftUI

@propertyWrapper
@dynamicMemberLookup
public struct BindableBP<Value> where Value: AnyObject, Value: Observable {
  public var wrappedValue: Value

  public init(wrappedValue: Value) {
    self.wrappedValue = wrappedValue
  }

  public var projectedValue: BindableBP<Value> {
    self
  }

  public subscript<Subject>(
    dynamicMember keyPath: ReferenceWritableKeyPath<Value, Subject>
  ) -> Binding<Subject> {
    return Binding<Subject>(
      get: {
        return self.wrappedValue[keyPath: keyPath]
      },
      set: { value in
        self.wrappedValue[keyPath: keyPath] = value
      }
    )
  }
}

