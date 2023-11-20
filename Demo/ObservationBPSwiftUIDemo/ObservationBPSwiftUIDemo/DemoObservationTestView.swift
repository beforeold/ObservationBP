//
//  DemoObservationTestView.swift
//  ObservationBPSwiftUIDemo
//
//  Created by Brook_Mobius on 11/20/23.
//

import SwiftUI
import ObservationBP

@Observable private class Model {
  var name: String = "brook"
  var height: Double = 186
}

private let model = Model()

struct DemoObservationTestView: View {
  var body: some View {
    Text("test")
      .onAppear {
        test()
      }
  }

  private func test() {
    withObservationTracking {
      print("apply name: \(model.name)")
    } onChange: {
      print("onChange name: \(model.name)")
    }

    print("will set height")
    model.height += 0.001
    print("did set height")

    print("will set name 1")
    model.name = "xipingping"
    print("did set name 1")

    print("will set name 2")
    model.name = "brook"
    print("will set name 2")
  }
}

#Preview {
  DemoObservationTestView()
    .preferredColorScheme(.dark)
}
