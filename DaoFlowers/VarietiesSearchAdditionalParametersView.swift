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
    
    var viewWillTransitionToSize = UIScreen.mainScreen().bounds.size
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
        let cellNib = UINib(nibName: "VarietiesSearchAdditionalParametersTableViewCell", bundle: nil)
        flowersTableView.registerNib(cellNib, forCellReuseIdentifier: "VarietiesSearchAdditionalParametersTableViewCellIdentifier")
        colorsTableView.registerNib(cellNib, forCellReuseIdentifier: "VarietiesSearchAdditionalParametersTableViewCellIdentifier")
        breedersTableView.registerNib(cellNib, forCellReuseIdentifier: "VarietiesSearchAdditionalParametersTableViewCellIdentifier")
    }
    
    func adjustShadowForView(view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.shadowColor = UIColor.blackColor().CGColor
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "VarietiesSearchAdditionalParametersTableViewCellIdentifier"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! VarietiesSearchAdditionalParametersTableViewCell

        switch tableView {
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
        case self.colorsTableView:
            if indexPath.row == 0 {
                cell.nameLabel?.text = "All"
                if self.selectedColors.count == 0 {
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                } else {
                    cell.accessoryType = UITableViewCellAccessoryType.None
                }
            } else {
                let color = self.colorsSearchParams[indexPath.row - 1]
                cell.nameLabel?.text = color.name
                if self.selectedColors.contains({$0.id == color.id}) {
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                } else {
                    cell.accessoryType = UITableViewCellAccessoryType.None
                }
            }
        case self.breedersTableView:
            if indexPath.row == 0 {
                cell.nameLabel?.text = "All"
                if self.selectedBreeders.count == 0 {
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                } else {
                    cell.accessoryType = UITableViewCellAccessoryType.None
                }
            } else {
                let breeder = self.breedersSearchParams[indexPath.row - 1]
                cell.nameLabel?.text = breeder.name
                if self.selectedBreeders.contains({$0.id == breeder.id}) {
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
        case self.colorsTableView:
            if indexPath.row == 0 {
                self.selectedColors.removeAll()
            } else {
                let color = self.colorsSearchParams[indexPath.row - 1]
                if cell.accessoryType == UITableViewCellAccessoryType.Checkmark {
                    let index: Int = self.selectedColors.indexOf({$0.id == color.id})!
                    self.selectedColors.removeAtIndex(index)
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
                if cell.accessoryType == UITableViewCellAccessoryType.Checkmark {
                    let index: Int = self.selectedBreeders.indexOf({$0.id == breeder.id})!
                    self.selectedBreeders.removeAtIndex(index)
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
