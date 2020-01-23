
import UIKit
import CoreLocation
import Alamofire

class CurrentLocationViewController: UIViewController {
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var currentDateLabel: UILabel!
    @IBOutlet weak var weatherTypeLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var forecastTableView: UITableView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noDataView: UIView!
    
    let viewModelInstance = CurrentLocationViewModel()
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var forecastDetails: [ForecastWeather] = [] {
        didSet {
            DispatchQueue.main.async {
                self.forecastTableView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noDataView.isHidden = false
        loadingView.isHidden = true
        setUpDelegates()
        setupLocation()
        self.navigationController?.isNavigationBarHidden = true
        self.forecastTableView.register(UINib(nibName: "WeatherForecastTableViewCell", bundle: nil), forCellReuseIdentifier: "WeatherForecastTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            self.checkUsersLocationServicesAuthorization()
        }
    }
    
    func setUpDelegates() {
        locationManager.delegate = self
        forecastTableView.delegate = self
        forecastTableView.dataSource = self
    }
    
    func setupLocation() {
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func checkUsersLocationServicesAuthorization(){
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                self.locationManager.delegate = self
                locationManager.requestWhenInUseAuthorization()
                break
            case .restricted, .denied:
                let alert = UIAlertController(title: "Allow Location Access", message: "App needs access to your location. Turn on Location Services in your device settings.", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Settings", style: UIAlertAction.Style.default, handler: { action in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        })
                    }
                }))
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                break
            case .authorizedWhenInUse, .authorizedAlways:
                currentLocation = locationManager.location
                self.downloadData()
                break
            @unknown default:
                break
            }
        }
    }
    
    func downloadData() {
        self.loadingView.isHidden = false
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        viewModelInstance.callServiceForTodayWeather(lat: currentLocation.coordinate.latitude, long: currentLocation.coordinate.longitude) { (success, weatherDetails, message)  in
            DispatchQueue.global().async {
                if success {
                    if let data = weatherDetails {
                        self.updateUI(data: data)
                        dispatchGroup.leave()
                    }
                }
            }
        }
        dispatchGroup.enter()
        viewModelInstance.callServiceForForcastWeather(lat: currentLocation.coordinate.latitude, long: currentLocation.coordinate.longitude) { (success, weatherDetails, message) in
            DispatchQueue.global().async {
                if success {
                    if let data = weatherDetails {
                        self.forecastDetails = data
                        dispatchGroup.leave()
                    }
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            if self.forecastDetails.count != 0 {
                self.loadingView.isHidden = true
                self.noDataView.isHidden = true
                return
            }
            self.noDataView.isHidden = false
            self.showAlert(title: "Error", message: "Please try again.")
        }
    }
    
    func updateUI(data: CurrentWeather) {
        DispatchQueue.main.async {
            self.cityNameLabel.text = data.cityName ?? ""
            self.currentDateLabel.text = "Today, \(data.currentDate ?? "")"
            self.weatherTypeLabel.text = data.weatherType ?? ""
            self.tempLabel.text = "\(Int(data.currentTemp ?? 0.0))"
        }
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Okay", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension CurrentLocationViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.checkUsersLocationServicesAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.currentLocation = locations[0] as CLLocation
    }
}

extension CurrentLocationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.forecastDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: WeatherForecastTableViewCell = self.forecastTableView.dequeueReusableCell(withIdentifier: "WeatherForecastTableViewCell", for: indexPath) as! WeatherForecastTableViewCell
        cell.configureCell(data: self.forecastDetails[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
