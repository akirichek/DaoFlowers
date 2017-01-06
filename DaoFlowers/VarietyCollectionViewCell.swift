//
//  VarietyCollectionViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/25/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class VarietyCollectionViewCell: UICollectionViewCell {
    
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
        self.resetView()
        
        nameLabel.text = "\(variety.name) (\(variety.abr))"
        
        if let sizeFrom = variety.sizeFrom {
            if let sizeTo = variety.sizeTo {
                sizeLabel.text = "\(sizeFrom.name) - \(sizeTo.name)"
            }
        }
        
        if let purchasePercent = variety.purchasePercent {
            let rounded = Double(round(10000 * purchasePercent) / 10000)
            purchasePercentLabel.text = String(rounded) + "%"
            
            nameLabel.textColor = K.Colors.MainBlue
            sizeLabel.textColor = K.Colors.MainBlue
            purchasePercentLabel.textColor = K.Colors.MainBlue
        } else {
            nameLabel.textColor = K.Colors.DarkGrey
            sizeLabel.textColor = K.Colors.DarkGrey
            purchasePercentLabel.textColor = K.Colors.DarkGrey
        }
        
        if let imageUrl = variety.smallImageUrl {
            varietyImageView.af_setImage(withURL: URL(string: imageUrl)!)
        } else {
            varietyImageView.image = UIImage(named: variety.flower.defaultImage)
        }
    }
    
    func resetView() {
        nameLabel.text = ""
        sizeLabel.text = ""
        purchasePercentLabel.text = ""
        varietyImageView.image = nil
    }
}
