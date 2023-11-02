//
//  DevView.swift
//  ObservationBPSwiftUIDemo
//
//  Created by winddpan on 2023/10/20.
//

import ObservationBP
import SwiftUI

struct DevView: View {
    @Observing
    private var person = Person(name: "Tom", age: 12)

    init() {
//        _person.rT.id = "DevView"
    }

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

            TextField("123", text: $person.name)
                .background(Color.yellow)

//            LazyView {
//                VStack {
//                    Text(person.testGet ?? "null")
//                        .background(Color.yellow)
//
//                    Text(person.testGet2)
//                        .background(Color.yellow)
//                }
//            }

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
                person.testGet = "456"
            }
        })
    }
}

private struct PersonNameView: View {
    @Observing private var person: Person
    fileprivate init(person: Person) {
        _person = .init(wrappedValue: person)
//        _person.rT.id = "PersonNameView"
    }

    var body: some View {
        if #available(iOS 15.0, *) {
            let _ = Self._printChanges()
        }
        Text(person.name)
    }
}

private var count: Int = 1

private struct PersonAgeView: View {
    @Observing private var person: Person

    fileprivate init(person: Person) {
        _person = .init(wrappedValue: person)
//        _person.rT.id = "PersonAgeView"
    }

    var body: some View {
        if #available(iOS 15.0, *) {
            let _ = Self._printChanges()
        }
        let _ = count += 1

        Group {
            if #available(iOS 15.0, *) {
                let _ = Self._printChanges()
            }
            if count % 2 == 0 {
                Text("\(person.age)")
                    .background(Color.red)
            } else {
                Text("\(person.age) xxx")
                    .background(Color.blue)
            }
        }
    }
}

#Preview {
    DevView()
}
