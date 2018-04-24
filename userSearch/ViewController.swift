//
//  ViewController.swift
//  userSearch
//
//  Created by Siddharth Kumar on 23/04/18.
//  Copyright © 2018 Siddharth Kumar. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

enum GitHub {
    static let BaseURL = "https://api.github.com/search/users?q="
    static let URLPath = "&sort=followers&order=asc"
}

class ViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    let searchController = UISearchController(searchResultsController: nil)
    let userDataModel = UserDataModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Github Users"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
    }
    
    func loadUsersData(searchString:String) {
        let completeApi = "\(GitHub.BaseURL)\(searchString)\(GitHub.URLPath)"
        Alamofire.request(completeApi, method: .get).responseJSON {
            response in
            if response.result.isSuccess {
                if let resultVal = response.result.value {
                    self.updateUsersData(json: JSON(resultVal))
                }
            }
            else {
                print("Error \(String(describing: response.result.error))")
            }
        }
    }
    
    
    func updateUsersData(json : JSON) {
        userDataModel.UsernameArray = [String]()
        userDataModel.URLArray = [String]()
        
        for obj in (json["items"].arrayValue) {
            userDataModel.UsernameArray.append(obj["login"].stringValue)
            userDataModel.URLArray.append(obj["url"].stringValue)
        }
        tableView.reloadData()
        
    }
    
}


extension ViewController: UITableViewDataSource, UITableViewDelegate{
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDataModel.UsernameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel!.text = userDataModel.UsernameArray[indexPath.row]
        cell.detailTextLabel!.text = userDataModel.URLArray[indexPath.row]
        return cell
    }

}

extension ViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        let text = searchController.searchBar.text!
        if text.count>0{
            self.loadUsersData(searchString: text)
        }
        else{
            userDataModel.UsernameArray = [String]()
            userDataModel.URLArray = [String]()
            tableView.reloadData()
        }
        
    }
}

