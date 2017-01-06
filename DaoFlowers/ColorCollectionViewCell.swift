//
//  ColorCollectionViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/16/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class ColorCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sortsCountLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    
    var flower: Flower!
    var color: Color! {
        didSet {
            populateView()
        }
    }
    
    func populateView() {
        self.containerView.layer.cornerRadius = 5
        nameLabel.text = color.name
        
        if let sortsCount = color.sortsCount {
            sortsCountLabel.text = "\(sortsCount) \(CustomLocalisedString("VarietiesCount"))"
//            if sortsCount == 1 {
//                sortsCountLabel.text = "\(sortsCount) sort"
//            } else {
//                sortsCountLabel.text = "\(sortsCount) sorts"
//            }
        }
        
        imageView.image = UIImage(named: flower.defaultImage)
        
        if let imageUrl = color.imageUrl {
            imageView.af_setImage(withURL: URL(string: imageUrl)!)
        }
    }
}
