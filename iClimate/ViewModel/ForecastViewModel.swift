//
//  ForecastViewModel.swift
//  iClimate
//
//  Created by Sagar Modi on 11/01/2024.
//

import Foundation
import Observation
import SwiftUI
import BackgroundTasks
import AVFoundation
import NotificationCenter
import CoreData
import CoreLocation

@Observable
final class ForecastViewModel {
    private let service: ForecastServiceType
    private let locationService = LocationService()
    let container: NSPersistentContainer
    let entity = "CityEntity"
    var cities: [CityEntity] = []
    var climateData: ForecastData?
    var hData: [HourlyData] = []
    var dData: [DailyData] = []
    var isLoading: Bool = true
    var min: Double = 0.0
    var max: Double = 0.0
    var current: Double = 0.0
    var feelsLike: Double = 0.0
    var precepitation: Double = 0.0
    var pressure: Double = 0.0
    var humidity: Int = 0
    var snow: Double = 0.0
    var gust: Double = 0.0
    var wind: Double = 0.0
    var locationName: String = ""
    var climateCondition: String = ""
    var climateIcon: String = "sun.max.fill"
    var primaryColor = Color.white
    var secondaryColor = Color.white
    var tertiaryColor = Color.white
    var isDay: Bool = true
    var code: Int = 0
    var defaultLat: Double = 0.0
    var defaultLng: Double = 0.0
    var text: String = ""
    var tempUnit: Bool = false
    var notification: Bool = false
    
    init(service: ForecastServiceType = ForecastService()){
        self.service = service
        self.tempUnit = UserDefaults.standard.bool(forKey: "tempUnit")
        self.notification = UserDefaults.standard.bool(forKey: "notification")
        container = NSPersistentContainer(name: "iClimate")
        container.loadPersistentStores { (description, error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
        fetchCities()
    }
    
    @MainActor
    func getClimateData(lat: Double, lng: Double) async {
        do{
            climateData = try await service.retrieve(lat: lat, lng: lng)
            guard let data = climateData else{
                print("error")
                return
            }
            let currTime = data.current.time
            let currentHour = Int(currTime.split(separator: "T")[1].split(separator: ":")[0])
            var j = 0
            hData.removeAll()
            data.hourly.time.indices.forEach { index in
                while(j < 24){
                    let timeText = data.hourly.time[j + currentHour!]
                    let str = timeText.split(separator: "T")[1].split(separator: ":")[0]
                    let timeInNum = Int(str)
                    
                    switch(timeInNum!) {
                    case 1...6 :
                        let t = "\(timeInNum!) AM"
                        if(currentHour == timeInNum){
                            hData.append(HourlyData(time: "Now", temp: data.hourly.temperature2M[j + currentHour!], isDay: false, wCode: data.hourly.weatherCode[j + currentHour!]))
                        }else{
                            hData.append(HourlyData(time: t, temp: data.hourly.temperature2M[j + currentHour!], isDay: false, wCode: data.hourly.weatherCode[j + currentHour!]))
                        }
                        
                    case 7...11 :
                        let t = "\(timeInNum!) AM"
                        if(currentHour == timeInNum){
                            hData.append(HourlyData(time: "Now", temp: data.hourly.temperature2M[j + currentHour!], isDay: true, wCode: data.hourly.weatherCode[j + currentHour!]))
                        }else{
                            hData.append(HourlyData(time: t, temp: data.hourly.temperature2M[j + currentHour!], isDay: true, wCode: data.hourly.weatherCode[j + currentHour!]))
                        }
                        
                    case 12 :
                        let t = "\(timeInNum!) PM"
                        if(currentHour == timeInNum){
                            hData.append(HourlyData(time: "Now", temp: data.hourly.temperature2M[j + currentHour!], isDay: true, wCode: data.hourly.weatherCode[j + currentHour!]))
                        }else{
                            hData.append(HourlyData(time: t, temp: data.hourly.temperature2M[j + currentHour!], isDay: true, wCode: data.hourly.weatherCode[j + currentHour!]))
                        }
                        
                    case 13...19 :
                        let t = "\(timeInNum! - 12) PM"
                        if(currentHour == timeInNum){
                            hData.append(HourlyData(time: "Now", temp: data.hourly.temperature2M[j + currentHour!], isDay: true, wCode: data.hourly.weatherCode[j + currentHour!]))
                        }else{
                            hData.append(HourlyData(time: t, temp: data.hourly.temperature2M[j + currentHour!], isDay: true, wCode: data.hourly.weatherCode[j + currentHour!]))
                        }
                        
                    case 20...23 :
                        let t = "\(timeInNum! - 12) PM"
                        if(currentHour == timeInNum){
                            hData.append(HourlyData(time: "Now", temp: data.hourly.temperature2M[j + currentHour!], isDay: false, wCode: data.hourly.weatherCode[j + currentHour!]))
                        }else{
                            hData.append(HourlyData(time: t, temp: data.hourly.temperature2M[j + currentHour!], isDay: false, wCode: data.hourly.weatherCode[j + currentHour!]))
                        }
                        
                    default:
                        let t = "12 AM"
                        if(currentHour == timeInNum){
                            hData.append(HourlyData(time: "Now", temp: data.hourly.temperature2M[j + currentHour!], isDay: false, wCode: data.hourly.weatherCode[j + currentHour!]))
                        }else{
                            hData.append(HourlyData(time: t, temp: data.hourly.temperature2M[j + currentHour!], isDay: false, wCode: data.hourly.weatherCode[j + currentHour!]))
                        }
                    }
                    
                    j = j + 1
                }
            }
            
            dData.removeAll()
            data.daily.time.indices.forEach { index in
                if(index == 0){
                    dData.append(DailyData(time: "TODAY", minTemp: data.daily.temperature2MMin[index], maxTemp: data.daily.temperature2MMax[index], wCode: data.daily.weatherCode[index]))
                }else if(index == 1){
                    dData.append(DailyData(time: "TOMORROW", minTemp: data.daily.temperature2MMin[index], maxTemp: data.daily.temperature2MMax[index], wCode: data.daily.weatherCode[index]))
                }else{
                    dData.append(DailyData(time: getDayName(dt:data.daily.time[index]), minTemp: data.daily.temperature2MMin[index], maxTemp: data.daily.temperature2MMax[index], wCode: data.daily.weatherCode[index]))
                }
            }
            
            min = climateData?.daily.temperature2MMin[0] ?? 0.0
            max = climateData?.daily.temperature2MMax[0] ?? 0.0
            current = climateData?.current.temperature2M ?? 0.0
            feelsLike = climateData?.current.apparentTemperature ?? 0.0
            code = climateData?.current.weatherCode ?? 0
            precepitation = climateData?.current.precipitation ?? 0.0
            pressure = climateData?.current.pressureMsl ?? 0.0
            humidity = climateData?.current.relativeHumidity2M ?? 0
            snow = climateData?.current.snowfall ?? 0.0
            gust = climateData?.current.windGusts10M ?? 0.0
            wind = climateData?.current.windSpeed10M ?? 0.0
            let dayCode = climateData?.current.isDay
            if(dayCode == 0){
                isDay = false
            }else{
                isDay = true
            }
            getWeatherCondition(code: code, isDay: isDay)
            isLoading = false
        }catch{
            print(error)
            isLoading = false
        }
    }
    
    func scheduleForecastNotification() {
        if(notification){
            isTaskAlreadyScheduled(){ isScheduled in
                if(!isScheduled){
                    let timezone = TimeZone.current
                    var cal = Calendar.current
                    cal.timeZone = timezone
                    let interval = cal.date(byAdding: .hour, value: 6, to: .now)!
                    let request = BGAppRefreshTaskRequest(identifier: "forecastNotification")
                    request.earliestBeginDate = interval
                    do{
                        try BGTaskScheduler.shared.submit(request)
                        print("task scheduled")
                    }catch(let error){
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func isTaskAlreadyScheduled(completion: @escaping (Bool) -> Void) {
        
        BGTaskScheduler.shared.getPendingTaskRequests { taskRequests in
            let isScheduled = taskRequests.contains {$0.identifier == "forecastNotification"}
            completion(isScheduled)
        }
    }
    
    //    e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"forecastNotification"]
    
    func getDataForNotification() async {
        do{
            getDefaultCity()
            if(defaultLat != 0.0 && defaultLng != 0.0){
                let climateData = try await service.retrieve(lat: defaultLat, lng: defaultLng)
                let current = climateData.current.temperature2M
                let code = climateData.current.weatherCode
                getWeatherCondition(code: code, isDay: false)
                
                let content = UNMutableNotificationContent()
                content.title = "\(current) ° \(tempUnit ? "F" : "C")"
                content.subtitle = climateCondition
                content.sound = .default
                
                let intervalTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
                let request = UNNotificationRequest(identifier: "100", content: content, trigger: intervalTrigger)
                do {
                    try await UNUserNotificationCenter.current().add(request)
                }catch(let error){
                    print(error.localizedDescription)
                }
            }
        }catch{
            print(error)
        }
    }
    
    func getWeatherCondition(code: Int, isDay: Bool){
        switch code {
        case 0:
            climateCondition = "Clear Sky"
            climateIcon = (isDay) ? "sun.max.fill":"moon.fill"
            primaryColor = (isDay) ? Color.yellow: Color.white
        case 1:
            climateCondition = "Mainly clear"
            climateIcon = (isDay) ? "sun.max.fill":"moon.fill"
            primaryColor = (isDay) ? Color.yellow: Color.white
        case 2:
            climateCondition = "Partly cloudy"
            climateIcon = (isDay) ? "cloud.sun.fill":"cloud.moon.fill"
            secondaryColor = (isDay) ? Color.yellow: Color.white
        case 3:
            climateCondition = "Overcast"
            climateIcon = (isDay) ? "sun.haze.fill":"moon.haze.fill"
            secondaryColor = (isDay) ? Color.yellow: Color.white
        case 45:
            climateCondition = "Fog"
            climateIcon = "cloud.fog.fill"
        case 48:
            climateCondition = "Depositing rime fog"
            climateIcon = "cloud.fog.fill"
        case 51:
            climateCondition = "Drizzle: Light intensity"
            climateIcon = "cloud.drizzle.fill"
            secondaryColor = Color.blue
        case 53:
            climateCondition = "Drizzle: Moderate intensity"
            climateIcon = "cloud.drizzle.fill"
            secondaryColor = Color.blue
        case 55:
            climateCondition = "Drizzle: Dense intensity"
            climateIcon = "cloud.drizzle.fill"
            secondaryColor = Color.blue
        case 56:
            climateCondition = "Freezing Drizzle: Light intensity"
            climateIcon = "cloud.drizzle.fill"
            secondaryColor = Color.blue
        case 57:
            climateCondition = "Freezing Drizzle: Dense intensity"
            climateIcon = "cloud.drizzle.fill"
            secondaryColor = Color.blue
        case 61:
            climateCondition = "Rain: Slight intensity"
            climateIcon = (isDay) ? "cloud.sun.rain.fill":"cloud.moon.rain.fill"
            secondaryColor = (isDay) ? Color.yellow: Color.white
            tertiaryColor = Color.blue
        case 63:
            climateCondition = "Rain: Moderate intensity"
            climateIcon = "cloud.rain.fill"
            secondaryColor = Color.blue
        case 65:
            climateCondition = "Rain: Heavy intensity"
            climateIcon = "cloud.heavyrain.fill"
            secondaryColor = Color.blue
        case 66:
            climateCondition = "Freezing Rain: Light intensity"
            climateIcon = "cloud.heavyrain.fill"
            secondaryColor = Color.blue
        case 67:
            climateCondition = "Freezing Rain: Heavy intensity"
            climateIcon = "cloud.heavyrain.fill"
            secondaryColor = Color.blue
        case 71:
            climateCondition = "Snow fall: Slight intensity"
            climateIcon = (isDay) ? "sun.snow.fill":"moon.snow.fill"
            secondaryColor = (isDay) ? Color.yellow: Color.white
        case 73:
            climateCondition = "Snow fall: Moderate intensity"
            climateIcon = (isDay) ? "sun.snow.fill":"moon.snow.fill"
            secondaryColor = (isDay) ? Color.yellow: Color.white
        case 75:
            climateCondition = "Snow fall: Heavy intensity"
            climateIcon = "cloud.snow.fill"
        case 77:
            climateCondition = "Snow grains"
            climateIcon = "cloud.hail.fill"
        case 80:
            climateCondition = "Rain showers: Slight intensity"
            climateIcon = (isDay) ? "cloud.sun.rain.fill":"cloud.moon.rain.fill"
            secondaryColor = (isDay) ? Color.yellow: Color.white
            tertiaryColor = Color.blue
        case 81:
            climateCondition = "Rain showers: Moderate intensity"
            climateIcon = (isDay) ? "cloud.sun.rain.fill":"cloud.moon.rain.fill"
            secondaryColor = (isDay) ? Color.yellow: Color.white
            tertiaryColor = Color.blue
        case 82:
            climateCondition = "Rain showers: Violent intensity"
            climateIcon = "cloud.heavyrain.fill"
            secondaryColor = Color.blue
        case 85:
            climateCondition = "Snow showers: Slight intensity"
            climateIcon = (isDay) ? "sun.snow.fill":"moon.snow.fill"
            secondaryColor = (isDay) ? Color.yellow: Color.white
        case 86:
            climateCondition = "Snow showers: Heavy intensity"
            climateIcon = "cloud.snow.fill"
        case 95:
            climateCondition = "Thunderstorm: Slight or moderate"
            climateIcon = "cloud.bolt.rain.fill"
            secondaryColor = Color.blue
        case 96:
            climateCondition = "Thunderstorm with slight hail"
            climateIcon = "cloud.bolt.rain.fill"
            secondaryColor = Color.blue
        case 99:
            climateCondition = "Thunderstorm with heavy hail"
            climateIcon = "cloud.bolt.rain.fill"
            secondaryColor = Color.blue
        default:
            climateCondition = ""
        }
    }
    
    func getDayName(dt: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.date(from: dt)
        let day = date!.formatted(Date.FormatStyle().weekday(.wide))
        return day.uppercased()
    }
    
    func getProgressPercentage(min: Double, max: Double, current: Double) -> Double {
        let difference = max - min
        let currentDifference = current - min
        if(difference == 0 && currentDifference == 0){
            return 0
        }
        var percentage = (currentDifference / difference) * 0.5
        if(percentage >= 0.5){
            percentage = 0.5
        }
        return percentage
    }
    
    func fetchCities() {
        let request = NSFetchRequest<CityEntity>(entityName: entity)
        do{
            cities = try container.viewContext.fetch(request)
        }catch let error {
            print(error.localizedDescription)
        }
    }
    
    func addCity(name: String, lat: Double, lng: Double) {
        let newCity = CityEntity(context: container.viewContext)
        newCity.name = name
        newCity.lat = lat
        newCity.lng = lng
        var count = 0
        fetchCities()
        cities.forEach { city in
            if(city.isDefault){
                count += 1
            }
        }
        if(count > 0){
            newCity.isDefault = false
        }else{
            newCity.isDefault = true
        }
        save()
    }
    
    func save() {
        do{
            try container.viewContext.save()
            fetchCities()
        }catch let error {
            print(error.localizedDescription)
        }
    }
    
    func delete(city: CityEntity) {
        if(city.isDefault){
            container.viewContext.delete(city)
            let request = NSFetchRequest<CityEntity>(entityName: entity)
            do{
                if let cityData = try container.viewContext.fetch(request).first{
                    cityData.isDefault = true
                }else{
                    print("city not found")
                }
            }catch let error {
                print(error.localizedDescription)
            }
        }else{
            container.viewContext.delete(city)
        }
        fetchCities()
        save()
    }
    
    func update(city: CityEntity) {
        let request = NSFetchRequest<CityEntity>(entityName: entity)
        request.predicate = NSPredicate(format: "name = %@", city.name!)
        do{
            if let cityData = try container.viewContext.fetch(request).first{
                cityData.isDefault = true
                let allCities = try container.viewContext.fetch(CityEntity.fetchRequest())
                for otherCity in allCities {
                    if(otherCity != cityData){
                        otherCity.isDefault = false
                    }
                }
                save()
            }else{
                print("city not found")
            }
            
        }catch let error {
            print(error.localizedDescription)
        }
    }
    
    func getDefaultCity() {
        let request = NSFetchRequest<CityEntity>(entityName: entity)
        request.predicate = NSPredicate(format: "isDefault = true")
        do{
            if let defaultCity = try container.viewContext.fetch(request).first {
                defaultLat = defaultCity.lat
                defaultLng = defaultCity.lng
                locationName = defaultCity.name!
            }
        }catch let error {
            print(error.localizedDescription)
        }
    }
    
    func reverseGeocoding(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: latitude, longitude: longitude)
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if error != nil {
                print(error!.localizedDescription)
                return
            }
            
            if let placemarks = placemarks, let placemark = placemarks.first {
                self.locationName = "\(placemark.locality ?? ""), \(placemark.administrativeArea ?? ""), \(placemark.country ?? "")"
            }else {
                print("no address")
            }
        }
    }
}
