//
//  FlowerCollectionViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/14/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit
import AlamofireImage

class FlowerCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sortsCountLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    var flower: Flower! {
        didSet {
            populateView()
        }
    }
    
    func populateView() {
        self.containerView.layer.cornerRadius = 5
        
        nameLabel.text = flower.name
        //nameLabel.fitFontForSize(minFontSize: 5, maxFontSize: 100, accuracy: 0.5)
        
        if let sortsCount = flower.sortsCount {
            if sortsCount == 1 {
                sortsCountLabel.text = "\(sortsCount) variety"
            } else {
                sortsCountLabel.text = "\(sortsCount) varieties"
            }
        }
        
        imageView.image = nil
        if let imageUrl = flower.imageUrl {
            imageView.af_setImageWithURL(NSURL(string: imageUrl)!)
        }
    }
}
