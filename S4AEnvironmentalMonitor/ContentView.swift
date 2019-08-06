//
//  ContentView.swift
//  S4AEnvironmentalMonitor
//
//  Created by Carl Peto on 05/08/2019.
//  Copyright © 2019 Carl Peto. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var environmentValues: EnvironmentModel

    var body: some View {
        HStack() {
            Spacer()
            VStack(alignment: .leading) {
                Spacer()
                Text("Temperature:\n\(environmentValues.temperatureDescription)").lineLimit(0)
                Spacer()
                Text("Humidity:\n\(environmentValues.humidityDescription)").lineLimit(0)
                Spacer()
            }
            .font(.title)
            .foregroundColor(Color.white)
            Spacer()
        }
        .background(Color(hue: 0.73, saturation: 0.753, brightness: 0.45))

    }
}


#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let environmentModel = EnvironmentModel()
        environmentModel.temperature = 11
        environmentModel.humidityPct = 22
        return ContentView(environmentValues: environmentModel)
    }
}
#endif
