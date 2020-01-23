

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var cityTextField: UITextField! {
        didSet {
            cityTextField.delegate = self
            cityTextField.inputView = pickerView
            cityTextField.inputAccessoryView = doneToolBar
            cityTextField.tag = 0
            self.createButtonOnTextField(textField: self.cityTextField!)
        }
    }
    
    @IBOutlet weak var textFieldStackView: UIStackView!
    @IBOutlet var doneToolBar: UIToolbar!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    fileprivate let viewModelInstance = ViewModel()
    fileprivate let currentViewModel = CurrentLocationViewModel()
    var activeTextField : UITextField!
    var selectedCities: [City] = []
    var currentTag : Int = 0
    var count: Int = 0
    var responseData = [[ForecastWeather]]()
    
    private lazy var pickerView : UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        loadingView.isHidden = false
        currentTag = cityTextField.tag
        DispatchQueue.global(qos: .userInitiated).async {
            self.viewModelInstance.getDataFromJson { (success, message) in
                DispatchQueue.main.async {
                    self.loadingView.isHidden = true
                    if success {
                        DispatchQueue.main.async {
                            self.pickerView.reloadAllComponents()
                        }
                    } else {
                        self.showAlert(title: "Alert", message: message ?? "Please try again")
                    }
                }
            }
        }
    }
    
    func createTextField(tag: Int) {
        
        let textField = UITextField()
        textField.delegate = self
        textField.inputAccessoryView = self.doneToolBar
        textField.placeholder = "Enter city name"
        textField.borderStyle = .roundedRect
        textField.inputView = pickerView
        textField.tag = tag
        textField.accessibilityIdentifier = UUID().uuidString
        self.textFieldStackView.addArrangedSubview(textField)
        self.createButtonOnTextField(textField: textField)
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func createButtonOnTextField(textField: UITextField) {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "drop-down-arrow.png"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        button.frame = CGRect(x: CGFloat(textField.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
        button.addTarget(self, action: #selector(self.buttonTappedOfTextField), for: .touchUpInside)
        button.isUserInteractionEnabled = false
        textField.rightView = button
        textField.rightViewMode = .always
    }
    
    @objc func buttonTappedOfTextField(_ sender: UIButton) {
    }
    
    @IBAction func submit(_ sender: UIButton) {
        if self.selectedCities.count <= 0 {
            self.showAlert(title: "Alert", message: "Please enter city name")
            return
        }
        self.loadingView.isHidden = false
        callService()
    }
    
    func callService() {
        let dispatchGroup = DispatchGroup()
        for i in 0..<selectedCities.count {
            dispatchGroup.enter()
            currentViewModel.callServiceForForcastWeather(lat: selectedCities[i].coor.lat, long: selectedCities[i].coor.lon) { (success, forecastWeather, message) in
                DispatchQueue.global().async {
                    if success {
                        if let data = forecastWeather {
                            self.responseData.append(data)
                            dispatchGroup.leave()
                        }
                    }
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            if self.selectedCities.count == self.responseData.count {
                self.loadingView.isHidden = true
                self.performSegue(withIdentifier: "citiesForcast", sender: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? CitiesWeatherViewController {
            vc.selectedCities.removeAll()
            vc.weatherData.removeAll()
            vc.selectedCities = self.selectedCities
            vc.weatherData = self.responseData
        }
        self.selectedCities.removeAll()
        self.responseData.removeAll()
    }
    
    @IBAction func toolbarDone(_ sender: UIBarButtonItem) {
        var flag : Bool = false
        let selectedCity = viewModelInstance.cities[self.pickerView.selectedRow(inComponent: 0)]
        let selectFlag = self.selectedCities.contains(where: { (city) -> Bool in
            return city.cityName == selectedCity.cityName
        })
        if selectFlag {
            self.showAlert(title: "Alert", message: "City already exists")
            flag.toggle()
            return
        }
        if !flag {
            self.activeTextField.text = selectedCity.cityName
            if self.selectedCities.count > currentTag {
                self.selectedCities.remove(at: currentTag)
                self.selectedCities.insert(selectedCity, at: currentTag)
            } else {
                self.selectedCities.insert(selectedCity, at: currentTag)
            }
            self.activeTextField.resignFirstResponder()
            print(self.selectedCities)
        }
    }
    
    @IBAction func addCity(_ sender: UIBarButtonItem) {
        var flag : Bool = false
        self.textFieldStackView.subviews.forEach { (view) in
            if (view as? UITextField)?.text?.isEmpty ?? false {
                self.showAlert(title: "Alert", message: "Please enter city in exiting fields before adding new city")
                flag.toggle()
                return
            }
        }
        if !flag {
            count += 1
            self.createTextField(tag: count)
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        self.textFieldStackView.subviews.forEach { (view) in
            if (view as? UITextField) == self.cityTextField {
                self.cityTextField.text = ""
                return
            }
            view.removeFromSuperview()
        }
        self.count = 0
    }
}

extension ViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
        self.currentTag = self.activeTextField.tag
    }
    
}

extension ViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModelInstance.cities.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModelInstance.cities[row].cityName
    }
    
}
