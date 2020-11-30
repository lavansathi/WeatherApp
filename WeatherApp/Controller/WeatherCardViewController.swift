//
//  MasterSplitViewController.swift
//  WeatherApp
//
//  Created by Julie Dittmann Weimar Andersen on 23/10/2020.
//  Copyright © 2020 WeatherApp. All rights reserved.
//

import UIKit

class WeatherCardViewController: UITableViewController {
    
    let session = URLSession(configuration: .default)
    let jsonDecoder = JSONDecoder()
    let api = URLBase()
    var weatherList : WeatherList? = nil
    let iconHelper = IconHelper()
    let mock = ["2615876","2616015","524901"]

    override func viewDidLoad() {
        super.viewDidLoad()
        getWeatherData()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func reloadData(_ sender: Any) {
        getWeatherData()
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.weatherList != nil {
            return (weatherList?.list.count)!
        }
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath) as! WeatherTableViewCell
        if let result = self.weatherList{
            let cityName = result.list[indexPath.item].name
            let cityCountry = result.list[indexPath.item].sys.country
            cell.CityUILabel.text = "\(cityName), \(cityCountry)"
            cell.WeatherDescriptionUILabel.text = result.list[indexPath.item].weather[0].weatherDescription
            cell.WeatherDescriptionImageView.image = UIImage(named: iconHelper.iconHelper(weatherDescription: result.list[indexPath.item].weather[0].main))
            cell.CurrentTempUILabel.text = "\(Int(result.list[indexPath.item].main.temp))°"
            cell.MaxTempUILabel.text = "\(Int(result.list[indexPath.item].main.tempMax))°"
            cell.MinTempUILabel.text = "\(Int(result.list[indexPath.item].main.tempMin))°"
        }
        return cell
    }
    
    func getWeatherData() {
        let urlstring = api.weatherListUrl(id: self.mock)
        print(urlstring)
        if let url = URL(string: urlstring){
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let task = session.dataTask(with: request, completionHandler: {(data, response, error) in DispatchQueue.main.async {
                
                if error != nil{
                    self.showError(description: "Something went wrong. Try again.")
                    print("1")
                    return
                }
                
                if let response1 = response as? HTTPURLResponse{
                    if response1.statusCode == 400 {
                        self.showError(description: "Invalid currency. Try another.")
                        print("2")
                        return
                    }
                }
                
              
                if let weatherData = data, let weatherList1 = try? self.jsonDecoder.decode(WeatherList.self, from: weatherData){
                    self.weatherList = weatherList1
                    self.tableView.reloadData()
                    print("hello")
                } else {
                    self.showError(description: "Something went wrong. Try again.")
                    
                    if let response1 = response as? HTTPURLResponse{
                        print("\(response1.statusCode)")
                        
                    }

                }
                
                }})
            
            task.resume()
        }
        
    }
    
    
    func showError(description: String){
        let alert = UIAlertController(title: "Error", message: description, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title:"Ok", style: UIAlertAction.Style.default, handler: {_ in self.navigationController?.popViewController(animated: true)}))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "weatherSeg"){
            if let destination = segue.destination as? ForecastViewController {
                if (weatherList != nil){
                    destination.currentWeather = (weatherList?.list[(self.tableView.indexPathForSelectedRow?.item)!])!
                }
                
            }
        }
    }
}