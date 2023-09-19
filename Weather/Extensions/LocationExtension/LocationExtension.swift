//
//  LocationExtension.swift
//  Weather
//
//  Created by Mohamed Hadwa on 13/09/2023.
//

import Foundation
import UIKit
import CoreLocation

extension WeatherHomeVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.currentLocation = location
            locationManger.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            getWeatherData(latitude: lat, longitude: long) { result in
                switch result {
                case .success(let weatherData):
                    let  temperatureCelsius = (weatherData.main?.temp)! - 273.15
                    let tempMax = (weatherData.main?.temp)! - 273.15
                    let tempMin = (weatherData.main?.temp)! - 273.15
                    self.cityNameLbl.text = weatherData.name
                    self.temperatureLbl.text = "\(round(temperatureCelsius * 10) / 10) °C"
                    self.tempLowLbl.text = "L: \(round(tempMin * 10) / 10 - 4) °C"
                    self.tempHighLbl.text = "H: \(round(tempMax * 10) / 10 + 2 ) °C"
                    self.windSpeedLbl.text = "wind: \(weatherData.wind?.speed ?? 10) 🌪️"
                    if let firstWeatherElement = weatherData.weather?.first {
                              let weatherDescription = firstWeatherElement.description
                        self.weatherStatusLbl.text = weatherDescription
                        self.tableView.reloadData()
                          }
                     case .failure(let error):
                    
                    self.showAlert(msg: "Error: \(error.localizedDescription)", type: "")
                }
              

            }
            // MARK: - save current location in userDefults.

            let encodedLocation = NSKeyedArchiver.archivedData(withRootObject: location)
            UserDefaults.standard.set(encodedLocation, forKey: "savedLocation")
            if let loadedLocation = UserDefaults.standard.data(forKey: "savedLocation"),
            let decodedLocation = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(loadedLocation) as? CLLocation {
                print(decodedLocation)
}

        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            locationManger.requestAlwaysAuthorization()
            locationManger.startUpdatingLocation()
        case .authorizedAlways:
            locationManger.startUpdatingLocation()
        case .denied:
            showAlert(msg: "Please allow to access to location", type: "authSettings")
        case .restricted :
            showAlert(msg: "Please allow to access to location", type: "authSettings")
        case .notDetermined :
            showAlert(msg: "Please allow to access to location", type: "authSettings")
        default:
             print("defult")
            break
        }
    }

 
}

