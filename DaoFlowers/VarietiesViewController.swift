//
//  VarietiesViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/16/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class VarietiesViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var flower: Flower!
    var color: Color!
    var varieties: [Variety] = []
    
    //MARK: Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ApiManager.fetchVarietiesByFlower(flower, color: color) { (varieties, error) in
            if let varieties = varieties {
                self.varieties = varieties
                self.tableView.reloadData()
            } else {
                Utils.showError(error!, inViewController: self)
            }
        }
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.varieties.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VarietyTableViewCellIdentifier",
                                                               forIndexPath: indexPath) as! VarietyTableViewCell
        cell.variety  = self.varieties[indexPath.row]
        cell.numberLabel.text = String(indexPath.row + 1)
        
        return cell
    }
    
    // MARK: UITableViewDelegate
}
