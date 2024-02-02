//
//  iClimateApp.swift
//  iClimate
//
//  Created by Sagar Modi on 08/01/2024.
//

import SwiftUI
import BackgroundTasks
import GooglePlaces

@main
struct iClimateApp: App {
    private var vm = ForecastViewModel()
    
    init(){
        if let key = Bundle.main.infoDictionary?["PLACES_API_KEY"] as? String {
            GMSPlacesClient.provideAPIKey(key)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ClimateTabView()
                    .environment(\.managedObjectContext, vm.container.viewContext)
        }
        .backgroundTask(.appRefresh("forecastNotification")) {
            vm.scheduleForecastNotification()
            await vm.getDataForNotification()
        }
    }
}
