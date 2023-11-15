//
//  SomeiOS17View.swift
//  ObservationBPSwiftUIDemo
//
//  Created by beforeold on 2023/11/15.
//

import SwiftUI
import ObservationBP

@Observable class SomeViewModel {
  var name: String = ""
  
  var myName: String {
    name
  }
}

struct SomeiOS17View: View {
  var body: some View {
    Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
  }
}

#Preview {
  SomeiOS17View()
}
