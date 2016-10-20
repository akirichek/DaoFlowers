//
//  VarietyTableViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/16/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class VarietyTableViewCell: UITableViewCell {

    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var purchasePercentLabel: UILabel!
    @IBOutlet weak var varietyImageView: UIImageView!
    
    var variety: Variety! {
        didSet {
            populateView()
        }
    }
    
    func populateView() {
        nameLabel.text = variety.name
        
        if let sizeFrom = variety.sizeFrom {
            if let sizeTo = variety.sizeTo {
                sizeLabel.text = "\(sizeFrom.name) - \(sizeTo.name)"
            }
        }
        
        if let purchasePercent = variety.purchasePercent {
            purchasePercentLabel.text = String(purchasePercent) + "%"
        }
        
        varietyImageView.image = nil
        if let imageUrl = variety.smallImageUrl {
            varietyImageView.af_setImageWithURL(NSURL(string: imageUrl)!)
        }
    }
}
