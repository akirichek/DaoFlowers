//
//  MenuViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/13/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: MenuViewControllerDelegate?
    var menuItems: [[String:String]]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func reloadData() {
        self.menuItems = []
        if User.currentUser() != nil {
            self.menuItems.append(["name": MenuSection.UserProfile.rawValue, "image": "account"])
        }
        
        self.menuItems.append(["name": MenuSection.Varieties.rawValue, "image": "flower"])
        self.menuItems.append(["name": MenuSection.Plantations.rawValue, "image": "plantations"])
        
        if User.currentUser() != nil {
            self.menuItems.append(["name": MenuSection.Documents.rawValue, "image": "document"])
            self.menuItems.append(["name": MenuSection.Claims.rawValue, "image": "document"])
            self.menuItems.append(["name": MenuSection.CurrentOrders.rawValue, "image": "document"])
        }
        
        self.menuItems.append(["name": MenuSection.Contacts.rawValue, "image": "contacts"])
        self.menuItems.append(["name": MenuSection.Settings.rawValue, "image": "settings"])
        
        if User.currentUser() != nil {
            self.menuItems.append(["name": MenuSection.Logout.rawValue, "image": "logout"])
        } else {
            self.menuItems.append(["name": MenuSection.Login.rawValue, "image": "login"])
        }
        
        self.menuItems.append(["name": MenuSection.About.rawValue, "image": "help"])
        
        self.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuItems.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        if indexPath.row == 0 {
            let headerCell = tableView.dequeueReusableCellWithIdentifier("MenuHeaderTableViewCellIdentifier", forIndexPath: indexPath) as! MenuTableViewCell
            if let currentUser = User.currentUser() {
                headerCell.customerLabel.text = currentUser.name
            } else {
                headerCell.customerLabel.text = "Guest"
            }
            
            cell = headerCell
        } else {
            let sectionCell = tableView.dequeueReusableCellWithIdentifier("MenuTableViewCellIdentifier", forIndexPath: indexPath) as! MenuTableViewCell
            let menuItem = self.menuItems[indexPath.row - 1]
            sectionCell.sectionLabel.text = CustomLocalisedString(menuItem["name"]!)
            sectionCell.iconImageView?.image = UIImage(named: menuItem["image"]!)
            cell = sectionCell
        }

        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let menuItem = self.menuItems[indexPath.row - 1]
        let menuSection = MenuSection(rawValue: menuItem["name"]!)!
        self.delegate?.menuViewController(self, didSelectMenuSection: menuSection)
    }

    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let screenSize: CGSize = UIScreen.mainScreen().bounds.size
        let heightForRow: CGFloat
        
        if indexPath.row == 0 {
            heightForRow = 200
        } else {
            heightForRow = round(max(screenSize.width, screenSize.height) / 10)
        }
        
        return heightForRow
    }
}

protocol MenuViewControllerDelegate: NSObjectProtocol {
    func menuViewController(menuViewController: MenuViewController, didSelectMenuSection menuSection: MenuSection)
}
