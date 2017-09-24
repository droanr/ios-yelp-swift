//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FiltersViewControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var businesses: [Business]!
    var selectedCategories: [Int:Bool]!
    var dealSelected: Bool!
    var distanceSelected: String!
    var sortSelected: Int!
    
    var searchBar = UISearchBar()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar = UISearchBar()
        self.searchBar.sizeToFit()
        self.searchBar.delegate = self
        navigationItem.titleView = self.searchBar
        /*
        var filtersButton = navigationItem.rightBarButtonItem as! UIButton
        filtersButton.layer.borderColor = UIColor.white as! CGColor
        filtersButton.layer.borderWidth = 1.0
        filtersButton.layer.cornerRadius = 5
        */
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 120
        
        self.selectedCategories = [Int:Bool]()
        self.dealSelected = false
        
        Business.searchWithTerm(term: "Restaurants", completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            self.tableView.reloadData()
            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                }
            }
            
            }
        )
        
        /* Example of Yelp search with more search options specified
         Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
         self.businesses = businesses
         
         for business in businesses {
         print(business.name!)
         print(business.address!)
         }
         }
         */
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        Business.searchWithTerm(term: searchText) {(businesses: [Business]!, error: Error!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        cell.business = businesses[indexPath.row]
        return cell
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigationController = segue.destination as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        filtersViewController.delegate = self
        filtersViewController.switchStates = selectedCategories
        filtersViewController.dealSelected = dealSelected
        filtersViewController.distanceSelected = distanceSelected
        filtersViewController.sortSelected = self.sortSelected
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject], selectedCategories:[Int:Bool], deals:Bool, distanceSelected:String?, sortSelected:Int) {
        let categories = filters["categories"] as? [String]
        self.selectedCategories = selectedCategories
        self.dealSelected = deals
        self.distanceSelected = distanceSelected
        self.sortSelected = sortSelected
        Business.searchWithTerm(term: "Restaurants", sort: sortSelected, categories: categories, deals: deals, distance: distanceSelected) { (businesses: [Business]!, error: Error!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        }
    }
}
