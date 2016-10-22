//
//  VarietiesPageView.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/20/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit
import RBHUD

class VarietiesPageView: UIView, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    var spinner = RBHUD()
    var delegate: VarietiesPageViewDelegate?
    var varieties: [Variety] = [] {
        didSet {
            self.reloadData()
        }
    }
    
    // MARK: Public Methods
    
    func reloadData() {
        self.tableView.reloadData()
        self.tableView.contentOffset = CGPointZero
    }
    
    // MARK: Override Methods
    
    override func awakeFromNib() {
        let nib = UINib(nibName:"VarietyTableViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "VarietyTableViewCellIdentifier")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.varieties.count == 0 {
            self.spinner.showLoader(self, withTitle: nil, withSubTitle: nil, withProgress: true)
        }
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.varieties.count ==  0 {
            self.setNeedsLayout()
        } else {
            self.spinner.hideLoader()
        }
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

protocol VarietiesPageViewDelegate: NSObjectProtocol {
    
}
