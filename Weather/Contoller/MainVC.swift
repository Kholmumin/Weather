//
//  MainVC.swift
//  Weather
//
//  Created by Kholmumin Tursinboev on 19/04/22.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreData

class MainVC: UIViewController {
    
    @IBOutlet weak var citynameTxf: UITextField!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    @IBOutlet weak var speedLbl: UILabel!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var tempLbl: UILabel!
    
    var data = [Temp]()
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nav()
        context = appdelegate.persistentContainer.viewContext
    }
    
    
    
    
    @IBAction func showPressed(_ sender: Any) {
        if let all = citynameTxf.text{
            if all.isEmpty{
                alerts(title: "Enter city name", message: "Please enter city name", actionTitle: "Cancel", style: .destructive)
            }else{
                getWeather(cityName: all)
            }
        }
    }
    
    //MARK: Functions
    
    func alerts(title:String,message:String,actionTitle:String,style:UIAlertAction.Style){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: actionTitle, style: style)
        alert.addAction(action)
        present(alert, animated: true)
    }
    
    @objc func rightTapped(){
        let vc = SavedVC(nibName: "SavedVC", bundle: nil)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func leftTapped(){
        if !citynameTxf.text!.isEmpty && !nameLbl.text!.isEmpty{
            addWeather()
            alerts(title: "Saved", message: "Data is successfully saved", actionTitle: "Ok", style: .default)
        }else{
            alerts(title: "Enter city name", message: "Please enter city name", actionTitle: "Cancel", style: .destructive)
        }
    }
    
    func nav(){
        title = "Weather"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .organize, target: self, action: #selector(rightTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(leftTapped))
    }
    
    func getWeather(cityName:String){
        loading.startAnimating()
        AF.request("https://api.openweathermap.org/data/2.5/weather", method: .get, parameters: ["q":cityName,"appid":"b07a547eac54a94140f5a62624aa26c4"]).response { response in
            self.loading.stopAnimating()
            if response.response?.statusCode == 200{
                if let data = response.data{
                    let json  = JSON(data)
                    
                    let name  = json["name"].stringValue
                    let desc  = json["weather"][0]["description"].stringValue
                    let speed = json["wind"]["speed"].doubleValue
                    let temp  = json["main"]["temp"].doubleValue
                    
                    self.nameLbl.text  = name
                    self.descLbl.text  = desc
                    
                    if temp != 0{
                        self.tempLbl.text  = String("\(temp - 255) C")
                    }else{
                        self.tempLbl.text  = String("")
                    }
                    if speed != 0{
                        self.speedLbl.text = String(speed)
                    }else{
                        self.speedLbl.text  = String("")
                    }
                } else{
                    print(response.error.debugDescription)
                }
            }else if response.response?.statusCode == 404 {
                self.alerts(title: "Can not found  city name", message: "Please enter  correct city name", actionTitle: "Cancel", style: .destructive)
            }
           
        }
    }
    
    func addWeather() {
        guard let entity = NSEntityDescription.entity(forEntityName: "Temp", in: context) else { print("Could not find an entity"); return}
        let temp = NSManagedObject(entity: entity, insertInto: context)
        temp.setValue(nameLbl.text, forKey: "name")
        temp.setValue(speedLbl.text, forKey: "speed")
        temp.setValue(descLbl.text, forKey: "desc")
        temp.setValue(tempLbl.text, forKey: "temp")
    }
}
