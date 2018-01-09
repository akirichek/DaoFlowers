//
//  PlantationCollectionViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/6/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class PlantationCollectionViewCell: UICollectionViewCell {
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
        
        if plantation.isActive {
            nameLabel.textColor = K.Colors.MainBlue
            brandLabel.textColor = K.Colors.MainBlue
        } else {
            nameLabel.textColor = K.Colors.DarkGrey
            brandLabel.textColor = K.Colors.DarkGrey
        }
        
        if let imageUrl = plantation.imageUrl {
            if let url = URL(string: imageUrl) {
                plantationImageView.af_setImage(withURL: url)
            }
        }
    }
    
    func resetView() {
        nameLabel.text = ""
        brandLabel.text = ""
        plantationImageView.image = nil
    }
}
