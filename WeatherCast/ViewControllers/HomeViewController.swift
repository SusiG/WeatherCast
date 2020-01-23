

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.title = "Weather Report"
    }
    
    
    @IBAction func differentCitiesWeatherClicked(_ sender: UIButton) {
        self.performSegue(withIdentifier: "differentCities", sender: nil)
    }
    
    @IBAction func currentWeather(_ sender: UIButton) {
        self.performSegue(withIdentifier: "currentCity", sender: nil)
    }
}
