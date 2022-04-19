//
//  SavedVC.swift
//  Weather
//
//  Created by Kholmumin Tursinboev on 19/04/22.
//

import UIKit
import CoreData

class SavedVC: UIViewController {
    
    let appdelegate = UIApplication.shared.delegate as! AppDelegate
    var context: NSManagedObjectContext!
    var data = [Temp]()
    
    @IBOutlet weak var tableView: UITableView!{
        didSet{
            tableView.delegate   = self
            tableView.dataSource = self
            tableView.register(UINib(nibName: "DataTVC", bundle: nil), forCellReuseIdentifier: "DataTVC")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSettings()
    }
    
    func initSettings(){
        title = "Saved Cities"
        context = appdelegate.persistentContainer.viewContext
        fetchWeatherData()
    }
    
    func fetchWeatherData() {
        let request = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Temp")
        do {
            if let results = try context.fetch(request) as? [Temp]{
                data = results
            }
        } catch  {}
    }
}



extension SavedVC:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DataTVC", for: indexPath) as? DataTVC else{return UITableViewCell()}
        cell.nameLbl.text = data[indexPath.row].name
        cell.tempLbl.text = data[indexPath.row].temp
        cell.speedLbl.text = data[indexPath.row].speed
        cell.descLbl.text = data[indexPath.row].desc
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
            self.deleteData(index: indexPath.row)
            self.tableView.reloadData()
        }
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeActions
    }
    
    func deleteData(index: Int) {
        let data  = data[index]
        self.context.delete(data)
        self.appdelegate.saveContext()
        self.fetchWeatherData()
    }
}





