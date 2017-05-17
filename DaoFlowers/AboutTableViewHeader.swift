//
//  AboutTableViewHeader.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 5/15/17.
//  Copyright © 2017 Dao Flowers. All rights reserved.
//

import UIKit

class AboutTableViewHeader: UITableViewHeaderFooterView {

    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    var update: Update! {
        didSet {
            versionLabel.text = CustomLocalisedString("VERSION") + " \(update.version)"
            dateLabel.text = update.date
        }
    }
}
