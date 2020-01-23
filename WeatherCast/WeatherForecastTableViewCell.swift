

import UIKit

class WeatherForecastTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(data: ForecastWeather) {
        if let date = data.date, let dayTemp = data.dayTemp  {
            self.dayLabel.text = date
            self.tempLabel.text = "\(Int(dayTemp))"
        }
    }
    
}
