//
//  ViewBP.swift
//
//
//  Created by Brook_Mobius on 11/20/23.
//

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
