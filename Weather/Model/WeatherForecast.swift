//
//  WeatherForecast.swift
//  Weather
//
//  Created by Mohamed Hadwa on 16/09/2023.
//

import Foundation

struct WeatherForecastResponse: Codable {
    let list: [WeatherForecast]
}

struct WeatherForecast: Codable {
    let dt: TimeInterval
    let main: Mains
    let weather: [WeatherElements]
}

struct Mains: Codable {
    let temp: Double
    // Add other relevant properties
}

struct WeatherElements: Codable {
    let main: String
    let description: String
    let icon: String
    // Add other relevant properties
}
