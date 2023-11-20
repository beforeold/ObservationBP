//
//  DemoObservationTestView.swift
//  ObservationBPSwiftUIDemo
//
//  Created by Brook_Mobius on 11/20/23.
//

import SwiftUI
//import Observation
import ObservationBP

//@available(iOS 17.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
@Observable private class Model {
  var name: String = "brook"
  var height: Double = 186
}

//@available(iOS 17.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
private let model = Model()

struct HeightView: View {
  var body: some View {
    let _ = Self._printChanges()

    ObservationView {
      VStack {
        Text("height")
        Text(model.height.description)
      }
    }
  }
}

struct DemoObservationTestView: View {
  var body: some View {
    let _ = Self._printChanges()

    ObservationView {
      VStack(spacing: 30) {
        Text("name: \(model.name)")

        HeightView()

        Button("test") {
          test()
        }
      }
    }
  }

  private func test() {
    //    withObservationTracking {
    //      print("apply name: \(model.name)")
    //    } onChange: {
    //      print("onChange name: \(model.name)")
    //
    //      DispatchQueue.main.async {
    //        print("async name: \(model.name)")
    ////        render()
    //      }
    //    }

    print("will set height")
    model.height += 0.001
    print("did set height")

    print("will set name 1")
    model.name = "xipingping"
    print("did set name 1")

    print("will set name 2")
    //    model.name = "adam"
    print("did set name 2")
  }
}

#Preview {
  DemoObservationTestView()
    .preferredColorScheme(.dark)
}
