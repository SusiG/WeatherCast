

import UIKit
import Alamofire

class CurrentLocationViewModel: NSObject {
    
    var forecastArray = [ForecastWeather]()
    
    func callServiceForTodayWeather(lat: Double, long: Double, completionHandler: @escaping (Bool, CurrentWeather?, String) -> Void) {
        
        let apiUrl = "http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)&appid=274e800dab1ffe5ee8d608f4295c6a38"
        
        Alamofire.request(apiUrl).responseJSON { (response) in
            let result = response.result
            switch result {
            case .success(let response):
                if let jsonData = response as? [String:Any] {
                    if let cityName = jsonData["name"] as? String, let date = jsonData["dt"] as? Double, let tempArray = jsonData["weather"] as? [[String:Any]], let weatherType = tempArray[0]["main"] as? String, let mainDic = jsonData["main"] as? [String:Any], let temp = mainDic["temp"] as? Double {
                        let date = self.dateFormatter(date: date, isToday: true)
                        let currentTep = (temp - 273.15).rounded(toPlaces: 0)
                        let weatherDetails = CurrentWeather(cityName: cityName, currentDate: date, weatherType: weatherType, currentTemp: currentTep)
                        completionHandler(true, weatherDetails, "")
                    }
                    completionHandler(false, nil, "Invalid Data")
                }
                completionHandler(false, nil, "Invalid Data")
            case .failure(let error):
                completionHandler(false, nil, error.localizedDescription)
            }
        }
    }
    
    func callServiceForForcastWeather(lat: Double, long: Double, completionHandler: @escaping (Bool, [ForecastWeather]?, String) -> Void) {

        let apiUrl = "http://api.openweathermap.org/data/2.5/forecast/daily?lat=\(lat)&lon=\(long)&cnt=6&appid=7c609f73c5df2dff2f32e3e3cc33cd23"
        
        Alamofire.request(apiUrl).responseJSON { (response) in
            let result = response.result
            switch result {
            case .success(let response):
                if let dictionary = response as? Dictionary<String, AnyObject> {
                    if let list = dictionary["list"] as? [Dictionary<String, AnyObject>] {
                        for item in list {
                            if let tempVar = item["temp"] as? [String:Any], let temperature = tempVar["day"] as? Double, let tempDate = item["dt"] as? Double{
                                let dayTem = (temperature - 273.15).rounded(toPlaces: 0)
                                let date = self.dateFormatter(date: tempDate, isToday: false)
                                self.forecastArray.append(ForecastWeather(date: date, dayTemp: dayTem))
                            }
                        }
                        self.forecastArray.remove(at: 0)
                        completionHandler(true, self.forecastArray, "")
                        self.forecastArray.removeAll()
                    }
                }
                completionHandler(false, nil, "Invalid data")
            case .failure(let error):
                completionHandler(false, nil, error.localizedDescription)
            }
        }
    }
    
    func dateFormatter(date: Double, isToday: Bool = false) -> String {
        let convertedDate = Date(timeIntervalSince1970: date)
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        if isToday {
            return dateFormatter.string(from: convertedDate)
        }
        let dayOfWeek = String(convertedDate.dayOfTheWeek())
        return String(dayOfWeek.prefix(3))
    }
}
