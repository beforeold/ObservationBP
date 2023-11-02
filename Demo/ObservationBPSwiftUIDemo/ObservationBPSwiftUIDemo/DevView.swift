//
//  DevView.swift
//  ObservationBPSwiftUIDemo
//
//  Created by winddpan on 2023/10/20.
//

import ObservationBP
import SwiftUI

struct DevView: View {
    //   @Bindable  private var personx = Person(name: "Tom", age: 12)

    @Observing private var person = Person(name: "Tom", age: 12)

//    private var refreshing = Refreshing(wrappedValue: "aaa")
    @State private var randomColor = Color(
        red: .random(in: 0 ... 1),
        green: .random(in: 0 ... 1),
        blue: .random(in: 0 ... 1)
    )

    var body: some View {
        if #available(iOS 15.0, *) {
            let _ = Self._printChanges()
        }
        VStack {
            Text(person.name)
            Text("\(person.age)")

//            TextField(text: $personx.name) {
//                Text("xx")
//            }
//            Text(test.wrappedValue)
//                .background(Color.yellow)

            LazyView {
                VStack {
                    Text(person.testGet ?? "null")
                        .background(Color.yellow)

                    Text(person.testGet2)
                        .background(Color.yellow)

//                    Text(refreshing.wrappedValue)
//                        .background(Color.yellow)
                }
            }

            VStack {
                PersonNameView(person: person)
                PersonAgeView(person: person)
            }
            .padding()

            HStack {
                Button("+") { person.age += 1 }
                Button("-") { person.age -= 1 }
                Button("name") { person.name += "@" }
            }
        }
        .padding()
        .background(randomColor)
        .onAppear(perform: {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                test.wrappedValue = "456"
                person.testGet = "456"
//                refreshing.wrappedValue = "bbbb"
            }
        })
    }
}

private struct PersonNameView: View {
    @Observing private var person: Person
    fileprivate init(person: Person) {
        _person = .init(wrappedValue: person)
    }

    var body: some View {
        if #available(iOS 15.0, *) {
            let _ = Self._printChanges()
        }
        Text(person.name)
    }
}

private struct PersonAgeView: View {
    @Observing private var person: Person
    fileprivate init(person: Person) {
        _person = .init(wrappedValue: person)
    }

    var body: some View {
        if #available(iOS 15.0, *) {
            let _ = Self._printChanges()
        }
        if Bool.random() {
            return Text("\(person.age)")
                .background(Color.red)
        } else {
            return Text("\(person.age) 999")
                .background(Color.blue)
        }
    }
}

#Preview {
    DevView()
}
