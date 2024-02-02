//
//  HourlyForecastRow.swift
//  iClimate
//
//  Created by Sagar Modi on 12/01/2024.
//

import SwiftUI

struct HourlyForecastRow: View {
    let hourly: HourlyData
    @AppStorage("tempUnit") var tempToggle: Bool = false
    
    var body: some View {
        VStack(spacing:10) {
            Text(hourly.time)
                .font(.system(size: 18))
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            
            weatherIcon(code: hourly.wCode, isDay: hourly.isDay)
                .font(.system(size: 26))
            
            Text(String(format: "%.1f °", hourly.temp))
                .font(.system(size: 16))
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
        }
        .foregroundStyle(Color("SemiWhite"))
        .background(Color("ListBackgroundColor"))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct weatherIcon: View {
    let code: Int
    let isDay: Bool
    
    var body: some View {
        switch code {
        case 0, 1:
            Image(systemName: (isDay) ? "sun.max.fill":"moon.fill")
                .foregroundStyle((isDay) ? .yellow:.white)
        case 2:
            Image(systemName: (isDay) ? "cloud.sun.fill":"cloud.moon.fill")
                .foregroundStyle(.white, (isDay) ? .yellow:.white)
        case 3:
            Image(systemName: (isDay) ? "sun.haze.fill":"moon.haze.fill")
                .foregroundStyle(.white, (isDay) ? .yellow:.white)
        case 45, 48:
            Image(systemName: "cloud.fog.fill")
                .foregroundStyle(.white)
        case 51, 53, 55, 56, 57:
            Image(systemName: "cloud.drizzle.fill")
                .foregroundStyle(.white, .blue)
        case 61:
            Image(systemName: (isDay) ? "cloud.sun.rain.fill":"cloud.moon.rain.fill")
                .foregroundStyle(.white, (isDay) ? .yellow:.white, .blue)
        case 63:
            Image(systemName: "cloud.rain.fill")
                .foregroundStyle(.white, .blue)
        case 65, 66, 67, 82:
            Image(systemName: "cloud.heavyrain.fill")
                .foregroundStyle(.white, .blue)
        case 71, 73, 85:
            Image(systemName: (isDay) ? "sun.snow.fill":"moon.snow.fill")
                .foregroundStyle(.white, (isDay) ? .yellow:.white)
        case 75, 86:
            Image(systemName: "cloud.snow.fill")
                .foregroundStyle(.white)
        case 77:
            Image(systemName: "cloud.hail.fill")
                .foregroundStyle(.white)
        case 80, 81:
            Image(systemName: (isDay) ? "cloud.sun.rain.fill":"cloud.moon.rain.fill")
                .foregroundStyle(.white, (isDay) ? .yellow:.white, .blue)
        case 95, 96, 99:
            Image(systemName: "cloud.bolt.rain.fill")
                .foregroundStyle(.white, .blue)
        default:
            Image(systemName: (isDay) ? "sun.max.fill":"moon.fill")
        }
    }
}

#Preview {
    HourlyForecastRow(hourly: HourlyData(time: "2024-01-09T00:00", temp: 0.0, isDay: true, wCode: 95))
}
