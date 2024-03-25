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
    } onChange: { [_token = UncheckedSendable(self._token)] in
      _token.value.wrappedValue += 1
    }
  }
}

/// inspired by swift-perceptiable
/// Support explicit animations in SwiftUI by mbrandonw · Pull Request #52 · pointfreeco/swift-perception
/// https://github.com/pointfreeco/swift-perception/pull/52/commits
private struct UncheckedSendable<A>: @unchecked Sendable {
  let value: A
  init(_ value: A) {
    self.value = value
  }
}
