//
//  ContentView.swift
//  iClimate
//
//  Created by Sagar Modi on 08/01/2024.
//

import SwiftUI
import CoreData

struct ClimateTabView: View {
    
    var body: some View {
        TabView {
            ClimateView()
                    .tabItem {
                        Label("Climate", systemImage: "thermometer.low")
                    }.toolbarBackground(Color("SemiWhite"), for: .tabBar)
                
                Settings()
                    .tabItem {
                        Label("Settings", systemImage: "gear")
                    }.toolbarBackground(Color("SemiWhite"), for: .tabBar)
        }
    }
}

#Preview {
    ClimateTabView()
}
