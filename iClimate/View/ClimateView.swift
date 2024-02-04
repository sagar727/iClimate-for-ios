//
//  ClimateView.swift
//  iClimate
//
//  Created by Sagar Modi on 09/01/2024.
//

import SwiftUI
import CoreLocationUI

struct ClimateView: View {
    
    private let vm = ForecastViewModel()
    @State var locationService = LocationService()
    @State var progress: Double = 0.0
    @State private var networkMonitor = NetworkMonitor()
    @AppStorage("tempUnit") var tempToggle: Bool = false
    @AppStorage("windUnit") var windToggle: Bool = false
    @AppStorage("precepUnit") var precepToggle: Bool = false
    @AppStorage("latitude") var lat: Double = 0.0
    @AppStorage("longitude") var lng: Double = 0.0
    @State var isCityListShowing: Bool = false
    @State var cityText: String = ""
    
    var body: some View {
        NavigationStack{
            ZStack{
                if networkMonitor.isConnected {
                    VStack{
                        if(vm.isLoading){
                            ProgressView()
                        }else{
                            HStack(alignment:.top){
                                Button(action: {
                                    Task{
                                        vm.isLoading = true
                                        try? await Task.sleep(nanoseconds: 5_000_000_000)
                                        if(locationService.location == nil){
                                            vm.isLoading = false
                                        }
                                        guard let loc = locationService.location else {
                                            return}
                                        await vm.getClimateData(lat: loc.latitude, lng: loc.longitude)
                                        vm.reverseGeocoding(latitude: loc.latitude, longitude: loc.longitude)
                                        progress = vm.getProgressPercentage(min: vm.min, max: vm.max, current: vm.current)
                                    }
                                    
                                }, label: {
                                    Image(systemName: "location.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(Color(UIColor.systemBlue))
                                })
                                
                                Spacer()
                                Text(String(format: "Feels like\n %.1f \(tempToggle ? "°F" : "°C")", vm.feelsLike))
                            }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                            
                            ZStack(alignment: .top) {
                                Circle()
                                    .trim(from: 0, to: 0.5)
                                    .fill(Color("ListBackgroundColor"))
                                    .rotationEffect(Angle(degrees: 180))
                                    .frame(width: .none, height: 300)
                                
                                Circle()
                                    .trim(from: 0, to: progress)
                                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                                    .rotationEffect(Angle(degrees: 180))
                                    .animation(.linear, value: progress)
                                    .frame(width: .none, height: 300)
                                
                                VStack{
                                    Text(String(format: "%.1f \(tempToggle ? "°F" : "°C")", vm.current))
                                        .font(.system(size: 24))
                                        .padding(EdgeInsets(top: 7, leading: 0, bottom: 0, trailing: 0))
                                    Image(systemName: vm.climateIcon)
                                        .foregroundStyle(vm.primaryColor,vm.secondaryColor,vm.tertiaryColor)
                                        .font(.system(size: 40))
                                        .foregroundStyle(Color.white)
                                        .padding(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0))
                                    Text(vm.climateCondition)
                                        .font(.system(size: 18))
                                        .padding(EdgeInsets(top: 5, leading: 0, bottom: 10, trailing: 0))
                                    HStack{
                                        VStack(alignment:.center){
                                            Text("Min")
                                                .font(.system(size: 16))
                                            Text(String(format: "%.1f \(tempToggle ? "°F" : "°C")", vm.min))
                                                .font(.system(size: 16))
                                        }
                                        Spacer()
                                        Text(vm.locationName)
                                            .font(.system(size: 16))
                                            .frame(width: 200)
                                            .lineLimit(2)
                                        Spacer()
                                        VStack(alignment:.trailing){
                                            Text("Max")
                                                .font(.system(size: 16))
                                            Text(String(format: "%.1f \(tempToggle ? "°F" : "°C")", vm.max))
                                                .font(.system(size: 16))
                                        }
                                    }
                                }
                            }.padding(EdgeInsets(top: 60, leading: 20, bottom: 20, trailing: 20))
                                .frame(height: 150)
                               
                            ScrollView(.vertical, showsIndicators: false){
                                VStack{
                                    ListHeader(iconName: "clock.fill", title: "Hourly Forecast")
                                    Path{ path in
                                        path.move(to: CGPoint(x: 0, y: 0))
                                        path.addLine(to: CGPoint(x: .max, y: 0))
                                    }.stroke(Color("SemiWhite"))
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing:10){
                                            ForEach(vm.hData, id: \.self){ data in
                                                HourlyForecastRow(hourly: data)
                                            }
                                        }
                                    }
                                }
                                .background(Color("ListBackgroundColor"))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                                
                                VStack{
                                    ListHeader(iconName: "calendar", title: "7 Days Forecast")
                                    Path{ path in
                                        path.move(to: CGPoint(x: 0, y: 0))
                                        path.addLine(to: CGPoint(x: .max, y: 0))
                                    }.stroke(Color("SemiWhite"))
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing:10){
                                            ForEach(vm.dData, id: \.self){ data in
                                                DailyForecastRow(daily: data)
                                            }
                                        }
                                    }
                                }
                                .background(Color("ListBackgroundColor"))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding(EdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0))
                                
                                HStack(spacing:10){
                                    UnitView(icon: "drop.fill", titleText: "Precipitation", unitText: "\(vm.precepitation) \(precepToggle ? "Inch" : "mm")")
                                    
                                    UnitView(icon: "gauge.with.dots.needle.bottom.50percent", titleText: "Pressure", unitText: "\(vm.pressure) hPa")
                                    
                                    UnitView(icon: "humidity", titleText: "Humidity", unitText: "\(vm.humidity) %")
                                }.padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                                
                                HStack(spacing:10){
                                    UnitView(icon: "snowflake", titleText: "Snow", unitText: "\(vm.snow) inch")
                                    
                                    UnitView(icon: "wind", titleText: "Wind Gust", unitText: "\(vm.gust) \(windToggle ? "mp/h" : "km/h")")
                                    
                                    UnitView(icon: "wind.circle", titleText: "Wind Speed", unitText: "\(vm.wind) \(windToggle ? "mp/h" : "km/h")")
                                }.padding(EdgeInsets(top: 10, leading: 0, bottom: 30, trailing: 0))
                                Spacer()
                            }
                        }
                    }
                    .fullScreenCover(isPresented: $isCityListShowing, onDismiss: {
                        if(lat != 0.0 && lng != 0.0){
                            vm.isLoading = true
                            Task{
                                await vm.getClimateData(lat: lat, lng: lng)
                                vm.reverseGeocoding(latitude: lat, longitude: lng)
                                progress = vm.getProgressPercentage(min: vm.min, max: vm.max, current: vm.current)
                                lat = 0.0
                                lng = 0.0
                            }
                        }
                    }){
                        CityListView(progress: progress, cityText: $cityText, isCityListShowing: $isCityListShowing)
                    }
                    .toolbar {
                        Button("Cities") {
                            isCityListShowing = true
                        }
                        .buttonStyle(BorderedButtonStyle())
                        .background(Color(UIColor.systemBlue))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                    }
                    .foregroundStyle(Color("SemiWhite"))
                    .onAppear(){
                        Task{
                            vm.getDefaultCity()
                            vm.scheduleForecastNotification()
                            vm.isLoading = true
                            if(vm.defaultLat != 0.0 && vm.defaultLng != 0.0){
                                await vm.getClimateData(lat: vm.defaultLat, lng: vm.defaultLng)
                            }else{
                                try? await Task.sleep(nanoseconds: 5_000_000_000)
                                if(locationService.location == nil){
                                    vm.isLoading = false
                                    
                                }
                                guard let loc = locationService.location else {
                                    return}
                                await vm.getClimateData(lat: loc.latitude, lng: loc.longitude)
                                vm.reverseGeocoding(latitude: loc.latitude, longitude: loc.longitude)
                                vm.addCity(name: vm.locationName, lat: loc.latitude, lng: loc.longitude)
                            }
                            progress = vm.getProgressPercentage(min: vm.min, max: vm.max, current: vm.current)
                        }
                    }
                } else {
                    ContentUnavailableView("No Internet Connection", systemImage: "wifi.exclamationmark", description: Text("Please check your connection and try again."))
                }
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("BackgroundColor"), ignoresSafeAreaEdges: [.top,.leading,.trailing])
        }
    }
}

#Preview {
    ClimateView()
}

struct ListHeader: View {
    let iconName: String
    let title: String
    var body: some View {
        HStack(alignment:.center){
            Image(systemName: iconName)
                .font(.system(size: 20))
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 0))
            Spacer()
            Text(title)
                .font(.system(size: 22))
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
            Spacer()
        }
    }
}

struct UnitView: View {
    let icon: String
    let titleText: String
    let unitText: String
    
    var body: some View {
        VStack(spacing:10){
            Image(systemName: icon)
                .font(.system(size: 30))
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0))
            Text(titleText)
                .font(.system(size: 16))
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            Text(unitText)
                .font(.system(size: 16))
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
        }.frame(maxWidth: 120, maxHeight: 120)
            .background(Color("ListBackgroundColor"))
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct CityListView: View {
    private let vm = ForecastViewModel()
    @State var progress: Double
    @Binding var cityText: String
    @Binding var isCityListShowing: Bool
    @State var searchActive: Bool = false
    @State var selectedCity: PlaceResult?
    @State var searchResult: [PlaceResult] = []
    @State var isAlert: Bool = false
    @AppStorage("latitude") var lat: Double = 0.0
    @AppStorage("longitude") var lng: Double = 0.0
    var body: some View {
        NavigationStack{
            VStack(alignment:.leading,spacing: 20){
                VStack{
                    VStack(spacing:0) {
                        HStack{
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(Color.gray)
                            
                            TextField("Search City", text: $cityText)
                                .onChange(of: cityText, {
                                    let delay = 0.8
                                    DispatchQueue.main.asyncAfter(deadline: .now() + delay){
                                        if(cityText != ""){
                                            searchResult.removeAll()
                                            GooglePlacesManager.shared.findPlaces(query: cityText){ places in
                                                searchResult.append(contentsOf: places)
                                            }
                                        }else{
                                            searchResult.removeAll()
                                        }
                                    }
                                })
                        }
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                        .background(Color.white)
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                        
                        if(!searchResult.isEmpty){
                            ScrollView {
                                VStack(spacing:15) {
                                    ForEach(searchResult, id: \.self){ result in
                                        Text(result.city)
                                            .foregroundStyle(Color.black)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding(.leading)
                                            .onTapGesture {
                                                selectedCity = PlaceResult(city: result.city, lat: result.lat, long: result.long)
                                                searchResult.removeAll()
                                                cityText = ""
                                            }
                                        
                                        Divider()
                                    }
                                }
                                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                                .background(Color.white)
                                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                            }
                        }
                    }
                    
                    HStack{
                        if(!((selectedCity?.city.isEmpty) == nil)){
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundStyle(Color.red)
                                .font(.system(size: 24))
                            Text(selectedCity?.city ?? "")
                                .font(.system(size: 26))
                            Spacer()
                        }
                    }
                    .padding()
                    
                    if(!((selectedCity?.city.isEmpty) == nil)) {
                        Button("Add City") {
                            if(!vm.cities.contains(where: {$0.name == selectedCity?.city ?? ""})){
                                vm.addCity(name: selectedCity?.city ?? "", lat: selectedCity?.lat ?? 0.0, lng: selectedCity?.long ?? 0.0)
                                selectedCity = nil
                            }else{
                                isAlert.toggle()
                            }
                        }.alert("City already added in Favorite.", isPresented: $isAlert, actions: {
                            Button("Ok", role: .cancel) {
                                selectedCity = nil
                            }
                        })
                        .buttonStyle(BorderedButtonStyle())
                        .background(Color("ListBackgroundColor"))
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 10))
                    }
                    
                    HStack(alignment:.center){
                        Spacer()
                        Text("Your Favorite Cities")
                            .font(.system(size: 22))
                            .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                        Spacer()
                    }
                    .background(Color("ListBackgroundColor"))
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                    
                    List{
                        ForEach(vm.cities, id: \.self){ city in
                            CityRow(cityText: city.name ?? "", isDefault: city.isDefault)
                                .listRowBackground(Color("ListBackgroundColor"))
                                .swipeActions(edge:.trailing, allowsFullSwipe: true){
                                    Button(action: {
                                        vm.delete(city: city)
                                    }, label: {
                                        Label(title: {
                                            Text("Delete")
                                        }, icon: {
                                            Image(systemName: "trash.fill")
                                        })
                                    })
                                    .tint(Color.red)
                                    Button(action: {
                                        vm.delete(city: city)
                                    }, label: {
                                        Text("Delete")
                                    })
                                    .tint(Color.red)
                                }
                                .swipeActions(edge:.leading,allowsFullSwipe: true){
                                    Button(action: {
                                        vm.update(city: city)
                                        lat = city.lat
                                        lng = city.lng
                                    }, label: {
                                        Label(title: {
                                            Text("Set Default")
                                        }, icon: {
                                            Image(systemName: "checkmark.square.fill")
                                        })
                                    })
                                    .tint(Color.green)
                                    Button(action: {
                                        vm.update(city: city)
                                        lat = city.lat
                                        lng = city.lng
                                    }, label: {
                                        Text("Set Default")
                                    })
                                    .tint(Color.green)
                                }
                                .onTapGesture {
                                    lat = city.lat
                                    lng = city.lng
                                    vm.isLoading = true
                                    isCityListShowing = false
                                }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color("BackgroundColor"))
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("BackgroundColor"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        isCityListShowing = false
                    }, label: {
                        Image(systemName: "xmark")
                            .padding()
                    })
                }
            }
        }
    }
}
