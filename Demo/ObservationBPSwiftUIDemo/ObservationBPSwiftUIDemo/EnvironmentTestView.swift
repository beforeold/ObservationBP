//
//  SwiftUIView.swift
//
//
//  Created by beforeold on 11/20/23.
//

import SwiftUI
import ObservationBP

@Observable class TestEnvModel {
  var name: String = "beforeold"

  var isPresented = false
}

struct TestEnvKey: EnvironmentKey {
  static var defaultValue: TestEnvModel = .init()
}

extension EnvironmentValues {
  var testEnv: TestEnvModel {
    get {
      self[TestEnvKey.self]
    }

    set {
      self[TestEnvKey.self] = newValue
    }
  }
}

struct TestEnvSubView: View {
  @Environment(\.testEnv) var model

  var body: some View {
    ObservationView {
      bodyBP
    }
  }

  @ViewBuilder var bodyBP: some View {
    @BindableBP var model = model

    VStack(spacing: 30) {
      Text("name: \(model.name)")

      Button("plus name") {
        model.name += "_1"
      }

      Button("shows sheet") {
        model.isPresented = true
      }
    }
    .sheet(isPresented: $model.isPresented) {
      Text("sheet")
    }
  }
}

struct EnvironmentTestView: View {
  let model: TestEnvModel = {
    let model = TestEnvModel()
    model.name = "beforeold_1"

    return model
  }()

  var body: some View {
    TestEnvSubView()
      .environment(\.testEnv, model)
  }
}

#Preview {
  EnvironmentTestView()
    .preferredColorScheme(.dark)
}
