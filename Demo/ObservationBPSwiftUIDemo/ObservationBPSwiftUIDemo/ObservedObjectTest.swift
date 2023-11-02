//
//  ObservedObjectTest.swift
//  ObservationBPSwiftUIDemo
//
//  Created by wp on 2023/11/2.
//

import ObservationBP
import SwiftUI

struct ObservedObjectTest: View {
    @State var count = 0

    var body: some View {
        VStack {
            Text("刷新 CounterView 计数 :\(count)")
            Button("刷新") {
                count += 1
            }

            CountViewState()
                .padding()

            CountViewObserved()
                .padding()
        }
    }
}

class StateObjectClass: ObservableObject {
    let type: String
    let id: Int
    @Published var count = 0
    init(type: String) {
        self.type = type
        id = Int.random(in: 0 ... 1000)
        print("type:\(type) id:\(id) init")
    }

    deinit {
        print("type:\(type) id:\(id) deinit")
    }
}

@Observable class ObservableClass {
    let type: String
    let id: Int
    var count = 0

    init(type: String) {
        self.type = type
        id = Int.random(in: 0 ... 1000)
        print("type:\(type) id:\(id) init")
    }

    func haha() {}

    deinit {
        print("type:\(type) id:\(id) deinit")
    }
}

struct CountViewState: View {
//    @StateObject var state = StateObjectClass(type: "StateObject")
//    var state = StateObject(wrappedValue: StateObjectClass(type: "StateObject"))
//    var state = Observing(ObservableClass(type: "StateObject"))
    @Observing var state = ObservableClass(type: "StateObject")

    var body: some View {
        VStack {
            Text("@StateObject count :\(state.count)")
            Button("+1") {
                state.count += 1
            }
        }
    }
}

struct CountViewObserved: View {
//    @ObservedObject var state = StateObjectClass(type: "Observed")
//    var state = StateObject(wrappedValue: StateObjectClass(type: "Observed"))
//    var state = Observing(ObservableClass(type: "Observed"))
    @Observing var state = ObservableClass(type: "Observed")

    var body: some View {
        VStack {
            Text("@Observed count :\(state.count)")
            Button("+1") {
                state.count += 1
            }
        }
    }
}

#Preview {
    ObservedObjectTest()
}
