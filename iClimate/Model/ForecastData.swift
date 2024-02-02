import Foundation

struct ForecastData: Codable {
    let latitude, longitude, generationtimeMS: Double
    let utcOffsetSeconds: Int
    let timezone, timezoneAbbreviation: String
    let elevation: Int
    let currentUnits: CurrentUnits
    let current: Current
    let hourlyUnits: HourlyUnits
    let hourly: Hourly
    let dailyUnits: DailyUnits
    let daily: Daily

    enum CodingKeys: String, CodingKey {
        case latitude, longitude
        case generationtimeMS = "generationtime_ms"
        case utcOffsetSeconds = "utc_offset_seconds"
        case timezone
        case timezoneAbbreviation = "timezone_abbreviation"
        case elevation
        case currentUnits = "current_units"
        case current
        case hourlyUnits = "hourly_units"
        case hourly
        case dailyUnits = "daily_units"
        case daily
    }
}

// MARK: - Current
struct Current: Codable {
    let time: String
    let interval: Int
    let temperature2M: Double
    let relativeHumidity2M: Int
    let apparentTemperature: Double
    let isDay: Int
    let precipitation, rain, showers, snowfall: Double
    let weatherCode: Int
    let pressureMsl: Double
    let windSpeed10M: Double
    let windGusts10M: Double

    enum CodingKeys: String, CodingKey {
        case time, interval
        case temperature2M = "temperature_2m"
        case relativeHumidity2M = "relative_humidity_2m"
        case apparentTemperature = "apparent_temperature"
        case isDay = "is_day"
        case precipitation, rain, showers, snowfall
        case weatherCode = "weather_code"
        case pressureMsl = "pressure_msl"
        case windSpeed10M = "wind_speed_10m"
        case windGusts10M = "wind_gusts_10m"
    }
}

// MARK: - CurrentUnits
struct CurrentUnits: Codable {
    let time, interval, temperature2M, relativeHumidity2M: String
    let apparentTemperature, isDay, precipitation, rain: String
    let showers, snowfall, weatherCode, pressureMsl: String
    let windSpeed10M, windGusts10M: String

    enum CodingKeys: String, CodingKey {
        case time, interval
        case temperature2M = "temperature_2m"
        case relativeHumidity2M = "relative_humidity_2m"
        case apparentTemperature = "apparent_temperature"
        case isDay = "is_day"
        case precipitation, rain, showers, snowfall
        case weatherCode = "weather_code"
        case pressureMsl = "pressure_msl"
        case windSpeed10M = "wind_speed_10m"
        case windGusts10M = "wind_gusts_10m"
    }
}

// MARK: - Daily
struct Daily: Codable {
    let time: [String]
    let weatherCode: [Int]
    let temperature2MMax, temperature2MMin: [Double]

    enum CodingKeys: String, CodingKey {
        case time
        case weatherCode = "weather_code"
        case temperature2MMax = "temperature_2m_max"
        case temperature2MMin = "temperature_2m_min"
    }
}

// MARK: - DailyUnits
struct DailyUnits: Codable {
    let time, weatherCode, temperature2MMax, temperature2MMin: String

    enum CodingKeys: String, CodingKey {
        case time
        case weatherCode = "weather_code"
        case temperature2MMax = "temperature_2m_max"
        case temperature2MMin = "temperature_2m_min"
    }
}

// MARK: - Hourly
struct Hourly: Codable {
    let time: [String]
    let temperature2M: [Double]
    let weatherCode: [Int]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2M = "temperature_2m"
        case weatherCode = "weather_code"
    }
}

// MARK: - HourlyUnits
struct HourlyUnits: Codable {
    let time, temperature2M, weatherCode: String

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2M = "temperature_2m"
        case weatherCode = "weather_code"
    }
}

struct HourlyData: Codable, Hashable {
    let time: String
    let temp: Double
    let isDay: Bool
    let wCode: Int
}

struct DailyData: Codable, Hashable {
    let time: String
    let minTemp: Double
    let maxTemp: Double
    let wCode: Int
}
