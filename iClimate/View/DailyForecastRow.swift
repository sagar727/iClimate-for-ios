//
//  DailyForecastRow.swift
//  iClimate
//
//  Created by Sagar Modi on 12/01/2024.
//

import SwiftUI

struct DailyForecastRow: View {
    let daily: DailyData
    @AppStorage("tempUnit") var tempToggle: Bool = false
    
    var body: some View {
        VStack {
            Text(daily.time)
                .font(.system(size: 16))
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
            
            weatherImage(code: daily.wCode)
                .font(.system(size: 26))
            
            Text(String(format: "Min %.1f °", daily.minTemp))
                .font(.system(size: 16))
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
            
            Text(String(format: "Max %.1f °", daily.maxTemp))
                .font(.system(size: 16))
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 10, trailing: 10))
        }
        .foregroundStyle(Color("SemiWhite"))
        .background(Color("ListBackgroundColor"))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct weatherImage: View {
    let code: Int
    
    var body: some View {
        switch code {
        case 0, 1:
            Image(systemName: "sun.max.fill")
                .foregroundStyle(.yellow)
        case 2:
            Image(systemName: "cloud.sun.fill")
                .foregroundStyle(.white, .yellow)
        case 3:
            Image(systemName: "sun.haze.fill")
                .foregroundStyle(.white, .yellow)
        case 45, 48:
            Image(systemName: "cloud.fog.fill")
                .foregroundStyle(.white)
        case 51, 53, 55, 56, 57:
            Image(systemName: "cloud.drizzle.fill")
                .foregroundStyle(.white, .blue)
        case 61:
            Image(systemName: "cloud.sun.rain.fill")
                .foregroundStyle(.white, .yellow, .blue)
        case 63:
            Image(systemName: "cloud.rain.fill")
                .foregroundStyle(.white, .blue)
        case 65, 66, 67, 82:
            Image(systemName: "cloud.heavyrain.fill")
                .foregroundStyle(.white, .blue)
        case 71, 73, 85:
            Image(systemName: "sun.snow.fill")
                .foregroundStyle(.white, .yellow)
        case 75, 86:
            Image(systemName: "cloud.snow.fill")
                .foregroundStyle(.white)
        case 77:
            Image(systemName: "cloud.hail.fill")
                .foregroundStyle(.white)
        case 80, 81:
            Image(systemName: "cloud.sun.rain.fill")
                .foregroundStyle(.white, .yellow, .blue)
        case 95, 96, 99:
            Image(systemName: "cloud.bolt.rain.fill")
                .foregroundStyle(.white, .blue)
        default:
            Image(systemName: "sun.max.fill")
        }
    }
}

#Preview {
    DailyForecastRow(daily: DailyData(time: "", minTemp: 0.0, maxTemp: 0.0, wCode: 0))
}
