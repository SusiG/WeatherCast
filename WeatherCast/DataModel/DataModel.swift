

import Foundation


// MARK: - CityData
struct CityData: Codable {
    let id: Int
    let name, country: String
    let coord: Coord
}

// MARK: - Coord
struct Coord: Codable {
    let lon, lat: Double
}

struct City {
    var cityName: String?
    var countryCode: String?
    var coor: Coord
}
