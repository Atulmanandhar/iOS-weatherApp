//
//  ViewController.swift
//  lab3
//
//  Created by Atul Manandhar on 18/11/2023.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var imgWeather: UIImageView!
    @IBOutlet weak var labelLocation: UILabel!
    @IBOutlet weak var labelTemp: UILabel!
    @IBOutlet weak var switchTemp: UISwitch!
    
    var latitude = 0.0
    var longitude = 0.0
    
    var tempCelsius = ""
    var tempFahrenheit = ""
    
    let weatherIconsArr: [Condition] = [
        Condition(text: "sun.max.fill", code: 1000),
        Condition(text: "cloud.sun.fill", code: 1003),
        Condition(text: "cloud.fog.fill", code: 1006),
        Condition(text: "cloud.sun.fill", code: 1009),
        Condition(text: "smoke.fill", code: 1030),
        Condition(text: "cloud.rain.fill", code: 1150),
        Condition(text: "cloud.rain.fill", code: 1153),
        Condition(text: "cloud.rain.fill", code: 1168),
        Condition(text: "cloud.rain.fill", code: 1171),
        Condition(text: "cloud.rain.fill", code: 1180),
        Condition(text: "cloud.rain.fill", code: 1183),
        Condition(text: "cloud.rain.fill", code: 1186),
        Condition(text: "cloud.rain.fill", code: 1192),
        Condition(text: "cloud.rain.fill", code: 1195),
        Condition(text: "cloud.snow", code: 1219),
        Condition(text: "cloud.heavyrain", code: 1195)
    ]
    
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        txtSearch.delegate = self
        getCurrentCordinates()
    }
    
    func getCurrentCordinates() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation :CLLocation = locations[0] as CLLocation
        latitude = userLocation.coordinate.latitude
        longitude = userLocation.coordinate.longitude
        getWeatherData(query: "\(latitude),\(longitude)")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        getWeatherData(query: txtSearch.text ?? "")
        self.view.endEditing(true)
        return true
    }
    
    func createAPIUrl(query: String) -> URL? {
        let BASE_URL = "https://api.weatherapi.com/v1/"
        let API_KEY = "adefe9a29c184bfc941215756231811"
        
        guard let url = ("\(BASE_URL)current.json?key=\(API_KEY)&q=\(query)").addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        return URL(string: url)
    }
    
    func getWeatherData(query: String) {
        guard let url = createAPIUrl(query: query) else {
            print("URL Error")
            return }
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error)
            }
            
            do {
                if let weatherData = data {
                    let weatherResponse = try JSONDecoder().decode(ModelWeather.self, from: weatherData)
                    
                    DispatchQueue.main.async { [self] in
                        self.tempCelsius = "\(weatherResponse.current.temp_c)"
                        self.tempFahrenheit = "\(weatherResponse.current.temp_f)"
                        
                        self.labelTemp.text = switchTemp.isOn ? String(describing: weatherResponse.current.temp_c) + " C" : String(describing: weatherResponse.current.temp_f) + " F"
                        
                        self.labelLocation.text = weatherResponse.location.name
                        self.getImgWeather(code: weatherResponse.current.condition.code)
                    }
                }
            } catch {
                print("Error: \(error)")
            }
        }
        dataTask.resume()
        
    }
    
    func getImgWeather(code: Int) {
        let config = UIImage.SymbolConfiguration(paletteColors: [.black, .systemOrange, .systemTeal])
        self.imgWeather.preferredSymbolConfiguration = config
        
        var displayImageText = "sun.max.fill"
        
        for item in weatherIconsArr {
            if item.code == code {
                displayImageText = item.text
                break
            }
        }
        self.imgWeather.image = UIImage(systemName: displayImageText)
        self.imgWeather.addSymbolEffect(.variableColor)
    }
    
    
    
    @IBAction func btnCurrentLocationAction(_ sender: UIButton) {
        getWeatherData(query: "\(latitude),\(longitude)")
    }
    
    
    @IBAction func btnSearchAction(_ sender: UIButton) {
        self.view.endEditing(true)
        getWeatherData(query: txtSearch.text ?? "")
    }
    
    
    @IBAction func switchTempAction(_ sender: UISwitch) {
        if sender.isOn {
            labelTemp.text = "\(tempCelsius) C"
        } else {
            labelTemp.text = "\(tempFahrenheit) F"
        }
    }
    
}



struct ModelWeather: Decodable {
    let location: Location
    let current: Current
}

struct Location: Decodable {
    let name: String
}

struct Current: Decodable {
    let temp_c: Float
    let temp_f: Float
    let condition: Condition
}

struct Condition: Decodable {
    let text: String
    let code: Int
}

