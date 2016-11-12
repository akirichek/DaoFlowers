//
//  PlantationsSearchAdditionalParametersView.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/8/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class PlantationsSearchAdditionalParametersView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var countriesTableView: UITableView!
    @IBOutlet weak var flowersTableView: UITableView!
    @IBOutlet weak var countriesTableContainerView: UIView!
    @IBOutlet weak var flowersTableContainerView: UIView!

    
    var viewWillTransitionToSize = UIScreen.mainScreen().bounds.size
    
    var countriesSearchParams: [Country]!
    var flowersSearchParams: [Flower]!
    
    var selectedCountries: [Country] = []
    var selectedFlowers: [Flower] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.adjustShadowForView(countriesTableContainerView)
        self.adjustShadowForView(flowersTableContainerView)

        let cellNib = UINib(nibName: "SearchAdditionalParametersTableViewCell", bundle: nil)
        countriesTableView.registerNib(cellNib, forCellReuseIdentifier: "PlantationsSearchAdditionalParametersTableViewCellIdentifier")
        flowersTableView.registerNib(cellNib, forCellReuseIdentifier: "PlantationsSearchAdditionalParametersTableViewCellIdentifier")
    }
    
    func adjustShadowForView(view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowRadius = 10
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        switch tableView {
        case self.countriesTableView:
            numberOfRows = self.countriesSearchParams.count
        case self.flowersTableView:
            numberOfRows = self.flowersSearchParams.count
        default:
            break
        }
        return numberOfRows + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "PlantationsSearchAdditionalParametersTableViewCellIdentifier"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! SearchAdditionalParametersTableViewCell
        
        switch tableView {
        case self.countriesTableView:
            if indexPath.row == 0 {
                cell.nameLabel?.text = "All"
                if self.selectedCountries.count == 0 {
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                } else {
                    cell.accessoryType = UITableViewCellAccessoryType.None
                }
            } else {
                let country = self.countriesSearchParams[indexPath.row - 1]
                cell.nameLabel?.text = country.name
                if self.selectedCountries.contains({$0.id == country.id}) {
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                } else {
                    cell.accessoryType = UITableViewCellAccessoryType.None
                }
            }
        case self.flowersTableView:
            if indexPath.row == 0 {
                cell.nameLabel?.text = "All"
                if self.selectedFlowers.count == 0 {
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                } else {
                    cell.accessoryType = UITableViewCellAccessoryType.None
                }
            } else {
                let flower = self.flowersSearchParams[indexPath.row - 1]
                cell.nameLabel?.text = flower.name
                if self.selectedFlowers.contains({$0.id == flower.id}) {
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                } else {
                    cell.accessoryType = UITableViewCellAccessoryType.None
                }
            }
        default:
            break
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        switch tableView {
        case self.countriesTableView:
            if indexPath.row == 0 {
                self.selectedCountries.removeAll()
            } else {
                let color = self.countriesSearchParams[indexPath.row - 1]
                if cell.accessoryType == UITableViewCellAccessoryType.Checkmark {
                    let index: Int = self.selectedCountries.indexOf({$0.id == color.id})!
                    self.selectedCountries.removeAtIndex(index)
                } else {
                    self.selectedCountries.append(color)
                }
            }
            self.countriesTableView.reloadData()
            break
        case self.flowersTableView:
            if indexPath.row == 0 {
                self.selectedFlowers.removeAll()
            } else {
                let flower = self.flowersSearchParams[indexPath.row - 1]
                if cell.accessoryType == UITableViewCellAccessoryType.Checkmark {
                    let index: Int = self.selectedFlowers.indexOf({$0.id == flower.id})!
                    self.selectedFlowers.removeAtIndex(index)
                } else {
                    self.selectedFlowers.append(flower)
                }
            }
            self.flowersTableView.reloadData()
        default:
            break
        }
    }
}
