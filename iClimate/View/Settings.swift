//
//  Settings.swift
//  iClimate
//
//  Created by Sagar Modi on 09/01/2024.
//

import SwiftUI
import BackgroundTasks

struct Settings: View {
    
    @AppStorage("tempUnit") var tempToggle: Bool = false
    @AppStorage("windUnit") var windToggle: Bool = false
    @AppStorage("precepUnit") var precepToggle: Bool = false
    @AppStorage("notification") var notificationToggle: Bool = false
    @State private var showAlert = false
    @State private var showMsg = false
    
    var body: some View {
        NavigationStack{
            ZStack{
                VStack(alignment: .leading, spacing: 30){
                    Section {
                        HStack(spacing: 10){
                            Image(systemName: "thermometer.low")
                                .font(.system(size: 20))
                            Spacer()
                            VStack(alignment: .leading){
                                Text("Temperature Unit")
                                Toggle(isOn: $tempToggle, label: {
                                    Text(tempToggle ? "Currently Using: Fahrenheit" : "Currently Using: Celsius")
                                })
                            }
                        }
                        
                        HStack(spacing: 10){
                            Image(systemName: "wind")
                                .font(.system(size: 20))
                            Spacer()
                            VStack(alignment: .leading){
                                Text("Wind Unit")
                                Toggle(isOn: $windToggle, label: {
                                    Text(windToggle ? "Currently Using: Miles/H" : "Currently Using: Km/H")
                                })
                            }
                        }
                        
                        HStack(spacing: 10){
                            Image(systemName: "wind")
                                .font(.system(size: 20))
                            Spacer()
                            VStack(alignment: .leading){
                                Text("Precipitation Unit")
                                Toggle(isOn: $precepToggle, label: {
                                    Text(precepToggle ? "Currently Using: Inch" : "Currently Using: MM")
                                })
                            }
                        }
                    }header: {
                        Text("Units")
                            .font(.system(size: 20))
                    }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                    
                    Section {
                        HStack(spacing: 10){
                            Image(systemName: "bell.fill")
                                .font(.system(size: 20))
                            Spacer()
                            Toggle(isOn: $notificationToggle, label: {
                                Text("Local Notification")
                            }).onChange(of: notificationToggle) { oldValue, newValue in
                                if(newValue == true){
                                    NotificationService.instance.requestAuthorization()
                                    showAlert = NotificationService.instance.showAlert ?? false
                                }else{
                                    BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: "forecastNotification")
                                }
                            }
                            .alert("Alert", isPresented: $showAlert) {
                                Button("OK") {
                                    notificationToggle = false
                                }
                            } message: {
                                Text("Please enable notifications in settings to get weather notifications.")
                            }
                            
                        }
                    }header: {
                        HStack{
                            Text("Notifications")
                                .font(.system(size: 20))
                            
                            Button {
                                showMsg = true
                            } label: {
                                Image(systemName: "questionmark.circle.fill")
                                    .font(.system(size: 20))
                            }
                            .popover(isPresented: $showMsg,content: {
                                Text("works when app is in background.")
                                    .foregroundStyle(Color.black)
                                    .padding(.horizontal)
                                    .presentationCompactAdaptation(.popover)
                            })

                        }
                    }.padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                        .toolbar{
                            ToolbarItem(placement: .principal) {
                                Text("Settings")
                                    .foregroundStyle(Color("SemiWhite"))
                                    .font(.title)
                                    .bold()
                            }
                        }
                    Spacer()
                }
                .foregroundStyle(Color("SemiWhite"))
                .font(.system(size: 14))
            }
            .padding(EdgeInsets(top: 50, leading: 10, bottom: 50, trailing: 10))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("BackgroundColor"), ignoresSafeAreaEdges: [.top,.leading,.trailing])
        }
    }
}

#Preview {
    Settings()
}
