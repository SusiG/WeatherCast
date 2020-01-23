

import UIKit

class CitiesWeatherViewController: UIViewController {
    
    @IBOutlet weak var citiesWeatherTableView: UITableView!
    
    var selectedCities : [City] = []
    var weatherData = [[ForecastWeather]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.citiesWeatherTableView.register(UINib(nibName: "WeatherForecastTableViewCell", bundle: nil), forCellReuseIdentifier: "WeatherForecastTableViewCell")
    }
    
    private func addHeaderView(section: Int) -> UIView {
        let headerView = UIView()
        let width = self.citiesWeatherTableView.frame.width
        headerView.frame = CGRect(x: 0, y: 0, width: width, height: 50)
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: headerView.frame.width, height: headerView.frame.height)
        label.text = self.selectedCities[section].cityName ?? ""
        headerView.addSubview(label)
        headerView.backgroundColor = .white
        label.textAlignment = .center
        return headerView
    }
}

extension CitiesWeatherViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return selectedCities.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = addHeaderView(section: section)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherData[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: WeatherForecastTableViewCell = self.citiesWeatherTableView.dequeueReusableCell(withIdentifier: "WeatherForecastTableViewCell", for: indexPath) as! WeatherForecastTableViewCell
        cell.configureCell(data: self.weatherData[indexPath.section][indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}
