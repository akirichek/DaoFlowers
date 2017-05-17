//
//  MenuTableViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/25/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var customerLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let shortVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let version = Bundle.main.infoDictionary?["CFBundleVersion"] as! String

        if versionLabel != nil {
            versionLabel.text = "\(shortVersion) (\(version))"
        }
    }
}
