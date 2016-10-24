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
    let menuItems: [String]
    
    required init?(coder aDecoder: NSCoder) {
        menuItems = ["Varieties", "Plantation", "Login"]
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.menuItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuTableViewCellIdentifier", forIndexPath: indexPath)
        cell.textLabel?.text = self.menuItems[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let menuSection = MenuSection(rawValue: indexPath.row)!
        self.delegate?.menuViewController(self, didSelectMenuSection: menuSection)
    }

}

protocol MenuViewControllerDelegate: NSObjectProtocol {
    func menuViewController(menuViewController: MenuViewController, didSelectMenuSection menuSection: MenuSection)
}
