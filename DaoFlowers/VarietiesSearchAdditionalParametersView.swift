//
//  VarietiesSearchAdditionalParametersView.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/26/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class VarietiesSearchAdditionalParametersView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var flowersTableView: UITableView!
    @IBOutlet weak var colorsTableView: UITableView!
    @IBOutlet weak var breedersTableView: UITableView!
    @IBOutlet weak var flowersTableContainerView: UIView!
    @IBOutlet weak var colorsTableContainerView: UIView!
    @IBOutlet weak var breedersTableContainerView: UIView!
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var breedersContainerViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var topContainerViewTrailingConstraint: NSLayoutConstraint!
    
    var viewWillTransitionToSize = UIScreen.main.bounds.size
    var flowersSearchParams: [Flower]!
    var colorsSearchParams: [Color]!
    var breedersSearchParams: [Breeder]!
    
    var selectedFlowers: [Flower] = []
    var selectedColors: [Color] = []
    var selectedBreeders: [Breeder] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.adjustShadowForView(flowersTableContainerView)
        self.adjustShadowForView(colorsTableContainerView)
        self.adjustShadowForView(breedersTableContainerView)
        let cellNib = UINib(nibName: "SearchAdditionalParametersTableViewCell", bundle: nil)
        flowersTableView.register(cellNib, forCellReuseIdentifier: "VarietiesSearchAdditionalParametersTableViewCellIdentifier")
        colorsTableView.register(cellNib, forCellReuseIdentifier: "VarietiesSearchAdditionalParametersTableViewCellIdentifier")
        breedersTableView.register(cellNib, forCellReuseIdentifier: "VarietiesSearchAdditionalParametersTableViewCellIdentifier")
    }
    
    func adjustShadowForView(_ view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowOffset = CGSize(width: 0, height: 10)
        view.layer.shadowRadius = 10
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        reloadView()
    }
    
    func reloadView() {
        let screenSize = self.viewWillTransitionToSize
        if screenSize.width < screenSize.height {
            breedersContainerViewLeadingConstraint.constant = 0
            topContainerViewTrailingConstraint.constant = 0
            self.constraintByIdentifier("TopContainerViewHeightConstraint")!.changeMultiplier(0.5)
        } else {
            topContainerViewTrailingConstraint.constant = screenSize.width / 3
            breedersContainerViewLeadingConstraint.constant = screenSize.width / 3 * 2
            self.constraintByIdentifier("TopContainerViewHeightConstraint")!.changeMultiplier(1)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        switch tableView {
        case self.flowersTableView:
            numberOfRows = self.flowersSearchParams.count
        case self.colorsTableView:
            numberOfRows = self.colorsSearchParams.count
        case self.breedersTableView:
            numberOfRows = self.breedersSearchParams.count
        default:
            break
        }
        return numberOfRows + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "VarietiesSearchAdditionalParametersTableViewCellIdentifier"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SearchAdditionalParametersTableViewCell

        switch tableView {
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
        case self.colorsTableView:
            if indexPath.row == 0 {
                cell.nameLabel?.text = "All"
                if self.selectedColors.count == 0 {
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                } else {
                    cell.accessoryType = UITableViewCellAccessoryType.none
                }
            } else {
                let color = self.colorsSearchParams[indexPath.row - 1]
                cell.nameLabel?.text = color.name
                if self.selectedColors.contains(where: {$0.id == color.id}) {
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                } else {
                    cell.accessoryType = UITableViewCellAccessoryType.none
                }
            }
        case self.breedersTableView:
            if indexPath.row == 0 {
                cell.nameLabel?.text = "All"
                if self.selectedBreeders.count == 0 {
                    cell.accessoryType = UITableViewCellAccessoryType.checkmark
                } else {
                    cell.accessoryType = UITableViewCellAccessoryType.none
                }
            } else {
                let breeder = self.breedersSearchParams[indexPath.row - 1]
                cell.nameLabel?.text = breeder.name
                if self.selectedBreeders.contains(where: {$0.id == breeder.id}) {
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
        case self.colorsTableView:
            if indexPath.row == 0 {
                self.selectedColors.removeAll()
            } else {
                let color = self.colorsSearchParams[indexPath.row - 1]
                if cell.accessoryType == UITableViewCellAccessoryType.checkmark {
                    let index: Int = self.selectedColors.index(where: {$0.id == color.id})!
                    self.selectedColors.remove(at: index)
                } else {
                    self.selectedColors.append(color)
                }
            }
            self.colorsTableView.reloadData()
            break
        case self.breedersTableView:
            if indexPath.row == 0 {
                self.selectedBreeders.removeAll()
            } else {
                let breeder = self.breedersSearchParams[indexPath.row - 1]
                if cell.accessoryType == UITableViewCellAccessoryType.checkmark {
                    let index: Int = self.selectedBreeders.index(where: {$0.id == breeder.id})!
                    self.selectedBreeders.remove(at: index)
                } else {
                    self.selectedBreeders.append(breeder)
                }
            }
            self.breedersTableView.reloadData()
            break
        default:
            break
        }
    }
}
