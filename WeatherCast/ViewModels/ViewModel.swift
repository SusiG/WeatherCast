

import UIKit
import Alamofire

class ViewModel: NSObject {
    
    var citiesData: [CityData] = []
    var cities: [City] = []
    var forecastArray = [ForecastWeather]()
    
    func getDataFromJson(completionHandler: (Bool, String?) -> Void) {
        do {
            if let filePath = Bundle.main.path(forResource: "city.list", ofType: "json") {
                let jsonData = try Data(contentsOf: URL(fileURLWithPath: filePath), options: .alwaysMapped)
                let result = try JSONDecoder().decode([CityData].self, from: jsonData)
                self.citiesData = result
                self.getCities()
                completionHandler(true, "")
            }
        } catch (let error) {
            completionHandler(false, error.localizedDescription)
        }
    }
    
    func getCities() {
        var citiesArray = [City]()
        self.citiesData.forEach { (city) in
            if !(city.name.isEmpty) && (city.name != "-") {
                citiesArray.append(City(cityName: city.name, countryCode: city.country, coor: city.coord))
            }
        }
        let citiesMapped = citiesArray.sorted { (lhs, rhs) -> Bool in
            return lhs.cityName ?? "" < rhs.cityName ?? ""
        }
        self.cities = citiesMapped
    }
        
}
