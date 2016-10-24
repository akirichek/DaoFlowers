//
//  VarietyDetailsPlantationsGrowerTableViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/23/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class VarietyDetailsPlantationsGrowerTableViewCell: UITableViewCell {
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var plantationImageView: UIImageView!
    
    var plantation: Plantation! {
        didSet {
            populateView()
        }
    }
    
    func populateView() {
        self.resetView()
        
        nameLabel.text = plantation.name
        brandLabel.text = plantation.brand
        
        if plantation.fbSum > 0 {
            nameLabel.textColor = K.Colors.MainBlue
            brandLabel.textColor = K.Colors.MainBlue
        } else {
            nameLabel.textColor = K.Colors.DarkGrey
            brandLabel.textColor = K.Colors.DarkGrey
        }
        
        if let imageUrl = plantation.imageUrl {
            if let url = NSURL(string: imageUrl) {
                plantationImageView.af_setImageWithURL(url)
            }
        }
    }
    
    func resetView() {
        nameLabel.text = ""
        brandLabel.text = ""
        plantationImageView.image = nil
    }
}
