//
//  ContentView.swift
//  S4AEnvironmentalMonitor
//
//  Created by Carl Peto on 05/08/2019.
//  Copyright © 2019 Carl Peto. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello World")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
