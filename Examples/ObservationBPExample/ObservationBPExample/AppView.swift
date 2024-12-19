import SwiftUI

struct AppView: View {
  var body: some View {
    NavigationView {
      Form {
        NavigationLink("ContentView") {
          ContentView()
        }

        NavigationLink("OCObserable") {
          AnotherContentView()
        }
      }
    }
  }
}

#Preview {
  AppView()
}
