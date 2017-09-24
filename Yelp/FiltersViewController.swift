//
//  FiltersViewController.swift
//  Yelp
//
//  Created by drishi on 9/21/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    @objc optional func filtersViwController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String:AnyObject], selectedCategories: [Int:Bool], deals: Bool, distanceSelected: String, sortSelected: Int)
}

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate {

    @IBOutlet weak var filtersTableView: UITableView!
    
    var allFilters: [[Filter]]!
    var categories: [Filter]!
    var dealFilter: [Filter]!
    var distanceFilters: [Filter]!
    var sortFilters: [Filter]!
    
    var dealSelected: Bool!
    var distanceSelected: String!
    var sortSelected: Int!
    var switchStates = [Int:Bool]()
    weak var delegate: FiltersViewControllerDelegate!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return allFilters.count
    }
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        categories = Filter.getCategoryFilters()
        dealFilter = Filter.getDealFilter()
        distanceFilters = Filter.getDistanceFilters()
        sortFilters = Filter.getSortFilters()
        allFilters = [[Filter]]()
        allFilters.append(dealFilter)
        allFilters.append(distanceFilters)
        allFilters.append(sortFilters)
        allFilters.append(categories)
        filtersTableView.delegate = self
        filtersTableView.dataSource = self
    }
    
    
    @IBAction func onSearch(_ sender: Any) {
        var filters = [String: AnyObject]()
        var selectedCategories = [String]()
        
        for (row, isSelected) in switchStates {
            if isSelected {
                selectedCategories.append(categories[row].code as! String)
            }
        }
        
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories as AnyObject
        }
        
        if distanceSelected == nil {
            self.distanceSelected = ""
        }
        
        if sortSelected == nil {
            self.sortSelected = -1
        }
        
        delegate?.filtersViwController?(filtersViewController: self, didUpdateFilters: filters, selectedCategories: self.switchStates, deals: self.dealSelected!, distanceSelected: self.distanceSelected!, sortSelected: self.sortSelected!)
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allFilters[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
        var filters = allFilters[indexPath.section]
        cell.delegate = self
        switch(indexPath.section) {
        case 0:
            cell.switchLabel.text = filters[indexPath.row].name
            cell.onSwitch.isOn = dealSelected
        
        case 1:
            cell.switchLabel.text = filters[indexPath.row].name
            if self.distanceSelected != nil && self.distanceFilters[indexPath.row].code as! String == self.distanceSelected {
                cell.onSwitch.isOn = true
            } else {
                cell.onSwitch.isOn = false
            }
        case 2:
            cell.switchLabel.text = filters[indexPath.row].name
            let sortMode = self.sortFilters[indexPath.row].code as! YelpSortMode
            if self.sortSelected != nil && sortMode.rawValue == self.sortSelected {
                cell.onSwitch.isOn = true
            } else {
                cell.onSwitch.isOn = false
            }
        case 3:
            cell.switchLabel.text = filters[indexPath.row].name
            cell.onSwitch.isOn = switchStates[indexPath.row] ?? false
            
        default:
            cell.switchLabel.text = "foo"
            cell.onSwitch.isOn = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case 0:
            return ""
            
        case 1:
            return "Distance"
        
        case 2:
            return "Sort By"
        case 3:
            return "Categories"
            
        default :return ""
            
        }
    }

    func tableView (tableView:UITableView , heightForHeaderInSection section:Int)->Float
    {
        return 10.0
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = filtersTableView.indexPath(for: switchCell)!
        if indexPath.section == 0 {
            self.dealSelected = value
        } else if indexPath.section == 1 {
            if value == true {
                self.distanceSelected = distanceFilters[indexPath.row].code as! String
                disableOtherRowsInSection(row: indexPath.row, section:indexPath.section)
            } else {
                self.distanceSelected = ""
            }
        } else if indexPath.section == 2 {
            if value == true {
                let sortMode = self.sortFilters[indexPath.row].code as! YelpSortMode
                self.sortSelected = sortMode.rawValue
                disableOtherRowsInSection(row: indexPath.row, section: indexPath.section)
            } else {
                self.sortSelected = -1
            }
        
        } else if indexPath.section == 3 {
            switchStates[indexPath.row] = value
        }
        print("Filters view controller got the switch event")
        
    }
    
    func disableOtherRowsInSection(row: Int!, section:Int!) {
        let total = stride(from: 0, to:self.allFilters[section].count, by:1)
        var rowsToDisable = Array(Set(Array(total)).subtracting(Set([row])))
        for row in rowsToDisable {
            var cell = filtersTableView.cellForRow(at: IndexPath(row:row, section:section)) as? SwitchCell
            if cell != nil {
                cell?.onSwitch.isOn = false
            }
            
        }
    }
    
}
