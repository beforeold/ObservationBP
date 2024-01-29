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

public extension View {
  func withObservation() -> some View {
    let modifier = ObservationViewModifier {
      self
    }
    return self.modifier(modifier)
  }
}

public struct ObservationViewModifier<Content2: View>: ViewModifier {

  @State private var token: Int = 0

  private let contentMaker: () -> Content2

  public init(
    @ViewBuilder _ contentMaker: @escaping () -> Content2
  ) {
    self.contentMaker = contentMaker
  }

  public func body(content: Content) -> some View {
    _ = token
    return withObservationTracking {
      contentMaker()
    } onChange: {
      token += 1
    }
  }
}
