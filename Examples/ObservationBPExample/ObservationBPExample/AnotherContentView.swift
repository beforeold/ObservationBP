import ObservationBP
import SwiftUI

@Perceptible
class TestModel {
  var name = ""
}

@Perceptible
class NewPerson {
  var name: String = ""
  var age = 0
  var isPresented = false

  init(myPerson: MYPerson) {
    self.name = myPerson.name ?? ""
    self.age = myPerson.age
    self.isPresented = myPerson.isPresented
  }
}

@Perceptible
class SwiftPerson {
  var person: MYPerson = .init()

  func update(name: String) {
    let newPerson = MYPerson()
    newPerson.age = person.age
    newPerson.name = name
    newPerson.isPresented = person.isPresented

    person = newPerson
  }
}

@Perceptible
class ParentModel {
  var model = OCObservableBP<MYPerson>(wrappedValue: .init())

  func foo() {
    model = .init(wrappedValue: .init())
    // model.wrappedValue = .init()
  }
}

struct AnotherContentView: ViewBP {
  //  @Query var models: [DataModel]

  @State private var age: Int = 5

  //  @State @OCPerceptible var model2 = MYPerson()
  //  @OCPerceptible var model = MYPerson()
  @State var model = OCObservableBP(wrappedValue: MYPerson())
  //  var model = OCPerceptible(wrappedValue: MYPerson())
  // var _model = OCPerceptible(wrappedValue: MYPerson())
  // private var __model = State(wrappedValue: OCPerceptible(wrappedValue: MYPerson()))
  //  @OCPerceptible2 var model: OCPerceptible<MYPerson>

  var bodyBP: some View {
    //    @Bindable var model = model

    let _ = Self._printChanges()

    VStack(spacing: 30) {
      Text("name: \(self.model.name ?? "null")")

      Button("Change Name") {
        withAnimation {
          let cur = model.name ?? ""
          // model.name = cur + "go_"
          model.wrappedValue.updateName(cur + "go_")
        }
      }

      SubView(model: self.model)

      Button("show detail") {
        model.isPresented = true
      }

      Button("Change Person") {
        let person = MYPerson()
        person.name = "new person"
        person.age = 666
        model.wrappedValue = person
      }
      .buttonStyle(.borderedProminent)
    }
    .padding()
    .sheet(isPresented: $model.isPresented) {
      Text("Person detail")
    }
  }
}

struct SubView: ViewBP {
  var model: OCObservableBP<MYPerson>

  var bodyBP: some View {
    let _ = Self._printChanges()

    VStack {
      Text("age: \(model.age)")

      Button("plus age") {
        model.age += 1
      }
    }
  }
}

#Preview {
  AnotherContentView()
}
