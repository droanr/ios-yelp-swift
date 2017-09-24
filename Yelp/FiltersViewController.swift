//
//  FiltersViewController.swift
//  Yelp
//
//  Created by drishi on 9/21/17.
//  Copyright © 2017 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    @objc optional func filtersViwController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String:AnyObject], selectedCategories: [Int:Bool])
}

class FiltersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SwitchCellDelegate {

    @IBOutlet weak var filtersTableView: UITableView!
    
    var categories: [Filter]!
    var switchStates = [Int:Bool]()
    weak var delegate: FiltersViewControllerDelegate!
    
    
    @IBAction func onCancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        categories = Filter.getCategoryFilters()
        filtersTableView.delegate = self
        filtersTableView.dataSource = self
    }
    
    
    @IBAction func onSearch(_ sender: Any) {
        var filters = [String: AnyObject]()
        var selectedCategories = [String]()
        for (row, isSelected) in switchStates {
            if isSelected {
                selectedCategories.append(categories[row].code!)
            }
        }
        
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories as AnyObject
        }
        
        delegate?.filtersViwController?(filtersViewController: self, didUpdateFilters: filters, selectedCategories: self.switchStates)
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell", for: indexPath) as! SwitchCell
        
        cell.switchLabel.text = categories[indexPath.row].name
        cell.onSwitch.isOn = switchStates[indexPath.row] ?? false
        cell.delegate = self
        return cell
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = filtersTableView.indexPath(for: switchCell)!
        switchStates[indexPath.row] = value
        print("Filters view controller got the switch event")
        
    }
    
}
