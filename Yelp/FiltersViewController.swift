    //
//  FiltersViewController.swift
//  Yelp
//
//  Created by drishi on 9/21/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    @objc optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String:AnyObject], selectedCategories: [Int:Bool], deals: Bool, distanceSelected: String, sortSelected: Int)
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
    var isDistanceMenuShowing = false
    var isSortMenuShowing = false
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.row == 0 && indexPath.section == 1 {
            if isDistanceMenuShowing {
                isDistanceMenuShowing = false
                filtersTableView.reloadData()
                //toggleOtherRowsInSection(row: indexPath.row, section: indexPath.section, value: false)
            } else {
                isDistanceMenuShowing = true
                filtersTableView.reloadData()
                //toggleOtherRowsInSection(row: indexPath.row, section: indexPath.section, value: true)
            }
        }
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
        
        delegate?.filtersViewController?(filtersViewController: self, didUpdateFilters: filters, selectedCategories: self.switchStates, deals: self.dealSelected!, distanceSelected: self.distanceSelected!, sortSelected: self.sortSelected!)
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section) {
        case 1:
            if !isDistanceMenuShowing {
                return 1
            } else {
                return allFilters[section].count
            }
        default:
            return allFilters[section].count
        }
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
            if indexPath.row == 0 {
                cell.onSwitch.isHidden = true
                if self.distanceSelected != nil && self.distanceSelected != "" {
                    cell.switchLabel.text = Filter.getNameForCode(filters: filters, code: self.distanceSelected)
                }
                break
            }
            if self.distanceSelected != nil && self.distanceFilters[indexPath.row].code as! String == self.distanceSelected {
                cell.onSwitch.isOn = true
                self.updateFirstRowText(section: indexPath.section, text: self.distanceFilters[indexPath.row].name)

            } else {
                cell.onSwitch.isOn = false
            }
        case 2:
            cell.switchLabel.text = filters[indexPath.row].name
            /*if indexPath.row == 0 {
                cell.onSwitch.isHidden = true
                if self.sortSelected != nil && self.distanceSelected != "" {
                    cell.switchLabel.text = Filter.getNameForCode(filters: filters, code: self.sortSelected)
                }
                break
            }*/
            let sortMode = self.sortFilters[indexPath.row].code as! YelpSortMode
            if self.sortSelected != nil && sortMode.rawValue == self.sortSelected {
                cell.onSwitch.isOn = true
            } else {
                cell.onSwitch.isOn = false
            }
        case 3:
            cell.switchLabel.text = filters[indexPath.row].name
            cell.onSwitch.isOn = switchStates[indexPath.row] ?? false
            cell.onSwitch.isHidden = false
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
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.systemFont(ofSize: 20)
        header.textLabel?.text = header.textLabel?.text?.capitalized
        header.textLabel?.textColor = UIColor.black
    }

    func tableView (tableView:UITableView , heightForHeaderInSection section:Int)->Float
    {
        return 8.0
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = filtersTableView.indexPath(for: switchCell)!
        if indexPath.section == 0 {
            self.dealSelected = value
        } else if indexPath.section == 1 {
            if value == true {
                self.distanceSelected = distanceFilters[indexPath.row].code as! String
                updateFirstRowText(section: indexPath.section, text: distanceFilters[indexPath.row].name as! String)
                disableOtherRowsInSection(row: indexPath.row, section:indexPath.section)
                //toggleOtherRowsInSection(row: 0, section: indexPath.section, value: false)
            } else {
                self.distanceSelected = ""
                updateFirstRowText(section: indexPath.section, text: distanceFilters[0].name as! String)
                //toggleOtherRowsInSection(row: 0, section: indexPath.section, value: false)
            }
            isDistanceMenuShowing = false
            filtersTableView.reloadData()
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
        let total = stride(from: 1, to:self.allFilters[section].count, by:1)
        var rowsToDisable = Array(Set(Array(total)).subtracting(Set([row])))
        for row in rowsToDisable {
            var cell = filtersTableView.cellForRow(at: IndexPath(row:row, section:section)) as? SwitchCell
            if cell != nil {
                cell?.onSwitch.isOn = false
                //cell?.isHidden = false
            }
        }
    }
    
    func toggleOtherRowsInSection(row: Int!, section:Int, value: Bool!) {
        let total = stride(from: 1, to:self.allFilters[section].count, by:1)
        var rowsToDisable = Array(Set(Array(total)).subtracting(Set([row])))
        for row in rowsToDisable {
            var cell = filtersTableView.cellForRow(at: IndexPath(row:row, section:section)) as? SwitchCell
            if cell != nil {
                /*
                if value {
                   cell?.frame.size.height = 80
                } else{
                    cell?.frame.size.height = 0
                }*/
                cell?.isHidden = !value
            }
        }
    }
    
    func updateFirstRowText(section:Int!, text: String!) {
        var cell = filtersTableView.cellForRow(at: IndexPath(row:0, section:section)) as? SwitchCell
        cell?.switchLabel.text = text
    }
    
}
