//
//  EnvironmentTestView.swift
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

struct SettingsKey: EnvironmentKey {
  static var defaultValue: TestEnvModel = .init()
}

extension EnvironmentValues {
  var settings: TestEnvModel {
    get {
      self[SettingsKey.self]
    }

    set {
      self[SettingsKey.self] = newValue
    }
  }
}

struct TestEnvSubView: View {
  @Environment(\.settings) var model

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
      .environment(\.settings, model)
  }
}

#Preview {
  EnvironmentTestView()
    .preferredColorScheme(.dark)
}
