//
//  ObservationBP+SwiftUI.swift
//
//  Created by beforeold on 11/13/23.
//

import Foundation
import SwiftUI

public struct ObservationView<Content: View>: View {

  @State private var token: Int = 0

  private let content: () -> Content

  public init(
    @ViewBuilder _ content: @escaping () -> Content
  ) {
    self.content = content
  }

  public var body: some View {
    _ = token
    return withObservationTracking {
      content()
    } onChange: {
      token += 1
    }
  }
}

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

