
# Description
ObservationBP wraps swift-percetion for a better code indentation

# How to use
## ViewBP
User ```ViewBP``` protocol and ```bodyBP``` instead of WithPerceptionTracking

``` Swift
import ObservationBP
import SwiftUI

@Perceptible
final class Person {
    var name: String
    var age: Int

    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}

struct ContentView: ViewBP {
    var person: Person = Person(name: "name", age: 1)

    var bodyBP: some View {
        VStack {
            Text("Hello, \(person.name)")
        }
    }
}

```

## OCObserableBP
use the wrapper for Objective-C classes

## Acknowledgement
Great backporting of Observation framework
[swift-perception](https://github.com/pointfreeco/swift-perception)
