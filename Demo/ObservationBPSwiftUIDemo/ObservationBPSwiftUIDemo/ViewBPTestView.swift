//
//  ViewBPTestView.swift
//  ObservationBPSwiftUIDemo
//
//  Created by beforeold on 11/20/23.
//

import SwiftUI
import ObservationBP

@Observable class ViewBPModel {
  var name: String = "hello"
}

struct ViewBPTestView: ViewBP {
  let model: ViewBPModel = .init()

  var bodyBP: some View {
    VStack {
      Text("name: \(model.name)")

      Button("change name") {
        model.name = "beforeold"
      }
    }
  }
}

#Preview {
  ViewBPTestView()
    .preferredColorScheme(.dark)
}
