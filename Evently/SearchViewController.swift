//
//  SearchViewController.swift
//  Evently
//
//  Created by Pieter De Vries on 1/12/20.
//  Copyright © 2020 Pieter De Vries. All rights reserved.
//

import UIKit
import MapKit

class SearchViewController: UIViewController, UISearchBarDelegate, MKLocalSearchCompleterDelegate, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate {
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    var resultAddress: String = ""
    
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var SearchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchCompleter.delegate = self
        SearchBar.delegate = self
        navigationController?.delegate = self
        
        searchCompleter.queryFragment = "Current Location"
        
        SearchBar.becomeFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        searchCompleter.queryFragment = searchText
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
           searchResults = completer.results
           searchResultsTableView.reloadData()
    }
   
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
       // handle error
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let searchResult = searchResults[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let completion = searchResults[indexPath.row]
        
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            let coordinate = response?.mapItems[0].placemark.coordinate
            print(String(describing: coordinate))
           
            let name = ((response?.mapItems[0].placemark.name)!)
            let address = ((response?.mapItems[0].placemark.addressDictionary?["Street"])!) as! String
            
            if(name != address)
            {
                 self.resultAddress += name + " - "
            }
            
            self.resultAddress += address
            self.resultAddress += ", " + ((response?.mapItems[0].placemark.locality)!)
            self.resultAddress += ", " + (response?.mapItems[0].placemark.administrativeArea)!
            self.resultAddress += ", " + (response?.mapItems[0].placemark.postalCode)!
            
            if let navController = self.navigationController {
                navController.popViewController(animated: true)
            }
        }
    }
}

extension SearchViewController {
    func navigationController(_ navigationController:
        UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        (viewController as? NewEventViewController)?.resultAddress = self.resultAddress // Here you pass the to your original view controller
    }
}
