//
//  AddStaffReportTableViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 1/25/17.
//  Copyright © 2017 Dao Flowers. All rights reserved.
//

import UIKit

class AddStaffReportTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    func setReport(report: Report, isActived: Bool) {
        self.nameLabel.textColor = UIColor.black
        self.nameLabel.font = UIFont.systemFont(ofSize: 15)
        nameLabel.frame.size.width = 220
        nameLabel.frame.origin.x = 19
        if isActived {
            nameLabel.text = report.name
            self.tintColor = UIColor(red: 9/255, green: 80/255, blue: 208/255, alpha: 1)
        } else {
            self.nameLabel.textColor = UIColor.lightGray
            self.tintColor = UIColor.lightGray
        }
    }
    
    var doNotSendReports: Bool!  {
        didSet {
            self.nameLabel.text = CustomLocalisedString("Don't send reposts")
            self.nameLabel.textColor = UIColor(red: 221/255, green: 16/255, blue: 16/255, alpha: 1)
            self.nameLabel.font = UIFont.boldSystemFont(ofSize: 15)
            self.tintColor = UIColor(red: 9/255, green: 80/255, blue: 208/255, alpha: 1)
            nameLabel.frame.size.width = 225
            nameLabel.frame.origin.x = 14
        }
    }
    
    var sendAllReports: Bool! {
        didSet {
            self.nameLabel.text = CustomLocalisedString("Send all reposts")
            self.nameLabel.textColor = UIColor(red: 0/255, green: 125/255, blue: 196/255, alpha: 1)
            self.nameLabel.font = UIFont.boldSystemFont(ofSize: 15)
            self.tintColor = UIColor(red: 9/255, green: 80/255, blue: 208/255, alpha: 1)
            nameLabel.frame.size.width = 225
            nameLabel.frame.origin.x = 14
        }
    }
}
