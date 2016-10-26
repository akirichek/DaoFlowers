//
//  VarietyDetailsPlantationsGrowersView.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/22/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class VarietyDetailsPlantationsGrowersView: UIView {

    @IBOutlet weak var tableView: UITableView!
    
    var spinner = RBHUD()
    var plantations: [Plantation]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    // MARK: Override Methods
    
    override func awakeFromNib() {
        let nib = UINib(nibName:"VarietyDetailsPlantationsGrowerTableViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "VarietyDetailsPlantationsGrowerTableViewCellIdentifier")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.plantations == nil {
            self.spinner.showLoader(self, withTitle: nil, withSubTitle: nil, withProgress: true)
        }
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        if self.plantations == nil {
            self.setNeedsLayout()
        } else {
            self.spinner.hideLoader()
            numberOfRows = self.plantations!.count
        }
        return numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("VarietyDetailsPlantationsGrowerTableViewCellIdentifier",
                                                               forIndexPath: indexPath) as! VarietyDetailsPlantationsGrowerTableViewCell
        cell.plantation  = self.plantations![indexPath.row]
        cell.numberLabel.text = String(indexPath.row + 1)
        
        return cell
    }
    
    // MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}