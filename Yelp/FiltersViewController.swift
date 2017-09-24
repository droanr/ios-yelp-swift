//
//  FiltersViewController.swift
//  Yelp
//
//  Created by drishi on 9/21/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    @objc optional func filtersViwController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String:AnyObject], selectedCategories: [Int:Bool], deals: Bool)
}

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate {

    @IBOutlet weak var filtersTableView: UITableView!
    
    var allFilters: [[Filter]]!
    var categories: [Filter]!
    var dealFilter: [Filter]!
    
    var dealSelected: Bool!
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
        allFilters = [[Filter]]()
        allFilters.append(dealFilter)
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
        
        delegate?.filtersViwController?(filtersViewController: self, didUpdateFilters: filters, selectedCategories: self.switchStates, deals: self.dealSelected!)
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
            switchStates[indexPath.row] = value
        }
        print("Filters view controller got the switch event")
        
    }
    
}
