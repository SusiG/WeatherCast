

import Foundation

struct CurrentWeather {
    
    var cityName: String?
    var currentDate: String?
    var weatherType: String?
    var currentTemp: Double?
    
    init(cityName: String?, currentDate: String?, weatherType: String?, currentTemp: Double?) {
        self.cityName = cityName
        self.currentDate = currentDate
        self.weatherType = weatherType
        self.currentTemp = currentTemp
    }
}

struct ForecastWeather {
    
    var date: String?
    var dayTemp: Double?
    
    init(date: String?, dayTemp: Double?) {
        self.date = date
        self.dayTemp = dayTemp
    }
}
