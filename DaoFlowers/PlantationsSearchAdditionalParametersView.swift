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

    
    var viewWillTransitionToSize = UIScreen.main.bounds.size
    
    var countriesSearchParams: [Country]!
    var flowersSearchParams: [Flower]!
    
    var selectedCountries: [Country] = []
    var selectedFlowers: [Flower] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.adjustShadowForView(countriesTableContainerView)
        self.adjustShadowForView(flowersTableContainerView)

        let cellNib = UINib(nibName: "SearchAdditionalParametersTableViewCell", bundle: nil)
        countriesTableView.register(cellNib, forCellReuseIdentifier: "PlantationsSearchAdditionalParametersTableViewCellIdentifier")
        flowersTableView.register(cellNib, forCellReuseIdentifier: "PlantationsSearchAdditionalParametersTableViewCellIdentifier")
    }
    
    func adjustShadowForView(_ view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowRadius = 10
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "PlantationsSearchAdditionalParametersTableViewCellIdentifier"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SearchAdditionalParametersTableViewCell
        
        switch tableView {
        case self.countriesTableView:
            if indexPath.row == 0 {
                cell.nameLabel?.text = "All"
                if self.selectedCountries.count == 0 {
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                } else {
                    cell.accessoryType = UITableViewCellAccessoryType.none
                }
            } else {
                let country = self.countriesSearchParams[indexPath.row - 1]
                cell.nameLabel?.text = country.name
                if self.selectedCountries.contains(where: {$0.id == country.id}) {
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                } else {
                    cell.accessoryType = UITableViewCellAccessoryType.none
                }
            }
        case self.flowersTableView:
            if indexPath.row == 0 {
                cell.nameLabel?.text = "All"
                if self.selectedFlowers.count == 0 {
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                } else {
                    cell.accessoryType = UITableViewCellAccessoryType.none
                }
            } else {
                let flower = self.flowersSearchParams[indexPath.row - 1]
                cell.nameLabel?.text = flower.name
                if self.selectedFlowers.contains(where: {$0.id == flower.id}) {
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                } else {
                    cell.accessoryType = UITableViewCellAccessoryType.none
                }
            }
        default:
            break
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)!
        switch tableView {
        case self.countriesTableView:
            if indexPath.row == 0 {
                self.selectedCountries.removeAll()
            } else {
                let color = self.countriesSearchParams[indexPath.row - 1]
                if cell.accessoryType == UITableViewCellAccessoryType.checkmark {
                    let index: Int = self.selectedCountries.index(where: {$0.id == color.id})!
                    self.selectedCountries.remove(at: index)
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
                if cell.accessoryType == UITableViewCellAccessoryType.checkmark {
                    let index: Int = self.selectedFlowers.index(where: {$0.id == flower.id})!
                    self.selectedFlowers.remove(at: index)
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
