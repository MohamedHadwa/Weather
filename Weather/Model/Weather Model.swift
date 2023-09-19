//
//  Weather Model.swift
//  Weather
//
//  Created by Mohamed Hadwa on 11/09/2023.
//

import Foundation


struct Weather: Codable {
    var coord: Coord?
    var weather: [WeatherElement]?
    var base: String?
    var main: Main?
    var visibility: Int?
    var wind: Wind?
    var clouds: Clouds?
    var dt: Int?
    var sys: Sys?
    var timezone, id: Int?
    var name: String?
    var cod: Int?
}

// MARK: - Clouds
struct Clouds: Codable {
    var all: Int?
}

// MARK: - Coord
struct Coord: Codable {
    var lon, lat: Double?
}

// MARK: - Main
struct Main: Codable {
    var temp, feelsLike, tempMin, tempMax: Double?
    var pressure, humidity, seaLevel, grndLevel: Int?

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
    }
}

// MARK: - Sys
struct Sys: Codable {
    var type, id: Int?
    var country: String?
    var sunrise, sunset: Int?
}

// MARK: - WeatherElement
struct WeatherElement: Codable {
    var id: Int?
    var main  : String?
    var  description  : String?
    var icon: String?
}

// MARK: - Wind
struct Wind: Codable {
    var speed: Double?
    var deg: Int?
    var gust: Double?
}
