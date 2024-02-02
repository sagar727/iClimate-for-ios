//
//  ForecastService.swift
//  iClimate
//
//  Created by Sagar Modi on 08/01/2024.
//

import Foundation
import SwiftUI

protocol ForecastServiceType {
    func retrieve(lat:Double,lng:Double) async throws -> ForecastData
}

final class ForecastService: ForecastServiceType {
    
    private struct APIConstants {
        static let baseUrl = "https://api.open-meteo.com/v1/"
        static let validEndPoint = "\(baseUrl)forecast"
    }
    
    func retrieve(lat:Double,lng:Double) async throws -> ForecastData {
        
        @AppStorage("tempUnit") var tempToggle: Bool = false
        @AppStorage("windUnit") var windToggle: Bool = false
        @AppStorage("precepUnit") var precepToggle: Bool = false
        
        guard var urlComponents = URLComponents(string: APIConstants.validEndPoint) else {
            throw ApiError.invalidRequest("Invalid request baseUrl path")
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "latitude", value: String(lat)),
            URLQueryItem(name: "longitude", value: String(lng)),
            URLQueryItem(name: "current", value: "temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,rain,showers,snowfall,weather_code,pressure_msl,wind_speed_10m,wind_gusts_10m"),
            URLQueryItem(name: "hourly", value: "temperature_2m,weather_code"),
            URLQueryItem(name: "daily", value: "weather_code,temperature_2m_max,temperature_2m_min"),
            URLQueryItem(name: "temperature_unit", value: tempToggle ? "fahrenheit":"celsius"),
            URLQueryItem(name: "wind_speed_unit", value: windToggle ? "mph":"kmh"),
            URLQueryItem(name: "precipitation_unit", value: precepToggle ? "inch":"mm"),
            URLQueryItem(name: "timezone", value: "auto"),
        ]

        guard let url = urlComponents.url else{
            throw ApiError.invalidRequest("Invalid url request")
        }
        
        let request = createUrlRequest(url:url)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let statusCode = (response as? HTTPURLResponse)?.statusCode else{
            throw ApiError.invalidResponse("Invalid response")
        }
        
        if statusCode > 299 {
            throw ApiError.invalidResponse("server error \(statusCode)")
        }
        
        return try JSONDecoder().decode(ForecastData.self, from: data)
    }
    
    private func createUrlRequest(url: URL) -> URLRequest{
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        return request
    }
}


/** https://api.open-meteo.com/v1/forecast?
 latitude=49.2827&longitude=123.1207&
 current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,precipitation,rain,showers,snowfall,weather_code,pressure_msl,wind_speed_10m,wind_gusts_10m&
 hourly=temperature_2m,weather_code&
 daily=weather_code,temperature_2m_max,temperature_2m_min&
 temperature_unit=fahrenheit&
 wind_speed_unit=mph&
 precipitation_unit=inch&
 timezone=auto
**/
