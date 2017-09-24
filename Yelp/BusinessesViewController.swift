//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MapKit

class BusinessesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FiltersViewControllerDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    var businesses: [Business]!
    var selectedCategories: [Int:Bool]!
    var dealSelected: Bool!
    var distanceSelected: String!
    var sortSelected: Int!
    var isMoreDataLoading = false
    var isShowingMapView = false
    var searchBar = UISearchBar()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar = UISearchBar()
        self.searchBar.sizeToFit()
        self.searchBar.delegate = self
        self.searchBar.placeholder = "Search For a Restaurant"
        navigationItem.titleView = self.searchBar
        let mapButton = UIBarButtonItem(title: "Map", style: UIBarButtonItemStyle.plain, target: self, action: #selector(toggleMapView))
        
        navigationItem.rightBarButtonItem = mapButton
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
        
        let centerLocation = CLLocation(latitude: 37.7833, longitude: -122.4167)
        goToLocation(location: centerLocation)
        mapView.isHidden = true
        
        self.selectedCategories = [Int:Bool]()
        self.dealSelected = false
        
        Business.searchWithTerm(term: "Restaurants", completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            self.businesses = businesses
            self.addAnnotationsForBusiness(businesses: self.businesses)
            self.tableView.reloadData()
            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                    print(business.latitude!)
                    print(business.longitude!)  
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
    
    func addAnnotationsForBusiness(businesses: [Business]!) -> Void {
        for business in businesses {
            let coordinate = CLLocationCoordinate2DMake(business.latitude!, business.longitude!)
            self.addAnnotationAtCoordinate(coordinate: coordinate)
        }
    }
    
    func goToLocation(location: CLLocation) {
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(location.coordinate, span)
        mapView.setRegion(region, animated: false)
    }
    
    // add an Annotation with a coordinate: CLLocationCoordinate2D
    func addAnnotationAtCoordinate(coordinate: CLLocationCoordinate2D) {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "An annotation!"
        mapView.addAnnotation(annotation)
    }
    
    func getSelectedCategories() -> [String] {
        var ret = [String]()
        for (index, item) in Filter.getCategoryFilters().enumerated() {
            if self.selectedCategories[index] == true {
                ret.append(item.code as! String)
            }
        }
        return ret
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = self.tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - self.tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && self.tableView.isDragging) {
                isMoreDataLoading = true
                let offset = self.businesses?.count
                if offset != nil && offset! % 20 != 0 {
                    return
                }
                Business.searchWithTerm(term: "Restaurants", sort: self.sortSelected, categories: getSelectedCategories(), deals: self.dealSelected, distance: self.distanceSelected, offset: offset) { (businesses: [Business]!, error: Error!) -> Void in
                    self.businesses = self.businesses + businesses
                    self.tableView.reloadData()
                    self.addAnnotationsForBusiness(businesses: self.businesses)
                    self.isMoreDataLoading = false
                }
            }
        }
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
    func toggleMapView(_ mapButton: UIBarButtonItem) {
        if isShowingMapView {
            self.tableView.isHidden = false
            self.mapView.isHidden = true
            isShowingMapView = false
            mapButton.title = "Map"
        } else {
            self.mapView.isHidden = false
            self.tableView.isHidden = true
            isShowingMapView = true
            mapButton.title = "List"
        }
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject], selectedCategories:[Int:Bool], deals:Bool, distanceSelected:String?, sortSelected:Int) {
        let categories = filters["categories"] as? [String]
        self.selectedCategories = selectedCategories
        self.dealSelected = deals
        self.distanceSelected = distanceSelected
        self.sortSelected = sortSelected
        Business.searchWithTerm(term: "Restaurants", sort: sortSelected, categories: categories, deals: deals, distance: distanceSelected, offset: nil) { (businesses: [Business]!, error: Error!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
            self.addAnnotationsForBusiness(businesses: self.businesses)
        }
    }
}
