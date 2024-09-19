import SwiftUI

public protocol ViewBP: View {
  associatedtype BodyBP : View

  @ViewBuilder @MainActor var bodyBP: Self.BodyBP { get }
}

public extension ViewBP {
  @MainActor var body: some View {
    ObservationView {
      bodyBP
    }
  }
}
