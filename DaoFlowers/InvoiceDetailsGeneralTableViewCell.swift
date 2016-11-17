//
//  InvoiceDetailsGeneralTableViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/17/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class InvoiceDetailsGeneralTableViewCell: UITableViewCell {
    
    @IBOutlet weak var flowerLabel: UILabel!
    @IBOutlet weak var varietyLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var stemsLabel: UILabel!
    @IBOutlet weak var stemPriceLabel: UILabel!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var fbLabel: UILabel!
    
    var document: Document! {
        didSet {
            populateView()
        }
    }
    
}
