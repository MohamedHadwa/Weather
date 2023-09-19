//
//  WeatherHomeVC.swift
//  Weather
//
//  Created by Mohamed Hadwa on 11/09/2023.
//

import UIKit
import CoreLocation
import Alamofire

class WeatherHomeVC: UIViewController{
    // MARK: - IBOutlets.
    @IBOutlet weak var cityNameLbl: UILabel!
    @IBOutlet weak var temperatureLbl: UILabel!
    @IBOutlet weak var weatherStatusLbl: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var tempLowLbl: UILabel!
    @IBOutlet weak var tempHighLbl: UILabel!
    @IBOutlet weak var windSpeedLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    // MARK: - Private Variables.
        let apiKey = "464fa400745dca5db96e007833db8f57"
        let locationManger = CLLocationManager()
        var currentLocation: CLLocation = CLLocation()
        let searchController = UISearchController(searchResultsController: nil)
        var searchHistory: [String] = []
        var weatherForecasts: [WeatherForecastResponse] = []

    // MARK: - View Lifecycle
       override func viewDidLoad() {
           super.viewDidLoad()
           
           setupMapViewAndLocationDelegates()
           configureSearchController()
           displaySearchHistory()
           setupTableView()

        //   tableView.reloadData()

       }
    // MARK: - Private Functions.

      func setupMapViewAndLocationDelegates(){
           locationManger.delegate = self
           locationManger.requestWhenInUseAuthorization()
           locationManger.startUpdatingLocation()
        
       }
    
    func configureSearchController() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search in Cities"
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self

    }
    func setupTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: "SearchHistoryCell")

    }
    
   }

 
// MARK: - WeatherHomeVC Delegate & DataSource.

extension WeatherHomeVC :UISearchResultsUpdating , UISearchBarDelegate  {
    
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.isActive {
            tableView.isHidden = false
        }
        else{
            tableView.isHidden = true
        }

    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            getWeatherDataCity(for: searchText) { result in
                switch result {
                case .success(let weatherData):
                    self.saveSearchQuery(query: weatherData.name ?? "tanta")
                    self.searchHistory.append(weatherData.name ?? "")
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
                    }
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                }
            }
            
        }
    }
    func saveSearchQuery(query: String) {
        var previousSearches = UserDefaults.standard.array(forKey: "searchHistory") as? [String] ?? []
        previousSearches.append(query)
        UserDefaults.standard.set(previousSearches, forKey: "searchHistory")
        tableView.reloadData()

    }
    func retrieveSearchHistory() -> [String] {
        return UserDefaults.standard.array(forKey: "searchHistory") as? [String] ?? []
    }

    func displaySearchHistory() {
        searchHistory = retrieveSearchHistory()
            tableView.reloadData()

    }
}

// MARK: - APi.
extension WeatherHomeVC  {
    func getWeatherData(latitude: Double, longitude: Double, completion: @escaping (Result<Weather, Error>) -> Void) {
        let url = "https://api.openweathermap.org/data/2.5/weather"
        let parameters: [String: Any] = [
            "lat": latitude,
            "lon": longitude,
            "appid": apiKey
        ]
        AF.request(url, method: .get, parameters: parameters).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let weatherData = try JSONDecoder().decode(Weather.self, from: data)
                    completion(.success(weatherData))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
   
    func getWeatherDataCity(for city: String, completion: @escaping (Result<Weather, Error>) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?q=\(city)&APPID=\(apiKey)"
        AF.request(urlString, method: .get).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let weatherData = try decoder.decode(Weather.self, from: data)
                    completion(.success(weatherData))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    // MARK: -  API for next 5 days.

    func fetchWeatherForecast(latitude: Double, longitude: Double, completion: @escaping (Result<WeatherForecast, Error>) -> Void) {
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)"
        
        AF.request(urlString).responseData { response in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    print(String(data: data, encoding: .utf8) ?? "")

                    let weatherForecast = try decoder.decode(WeatherForecastResponse.self, from: data)
                 //   completion(.success(weatherForecast))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

}
extension WeatherHomeVC : UITableViewDelegate ,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistory.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchHistoryCell", for: indexPath)
        let searchText = searchHistory[indexPath.row]
        cell.textLabel?.text = searchText
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedSearchText = searchHistory[indexPath.row]
            searchController.searchBar.text = selectedSearchText
            tableView.deselectRow(at: indexPath, animated: true)
        
    }
    func removeSearchQueryFromHistory(queryToRemove: String) {
        // Retrieve the existing search history from UserDefaults
        if var searchHistory = UserDefaults.standard.stringArray(forKey: "searchHistory") {
         tableView.reloadData()
            if let indexToRemove = searchHistory.firstIndex(of: queryToRemove) {
                searchHistory.remove(at: indexToRemove)
                UserDefaults.standard.set(searchHistory, forKey: "searchHistory")

            }
           // tableView.reloadData()

        }
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let queryToRemove = searchHistory[indexPath.row]
            
            // Remove the query from UserDefaults and update the UI
            removeSearchQueryFromHistory(queryToRemove: queryToRemove)
            searchHistory = retrieveSearchHistory()
            tableView.reloadData()
        }
    }


}

