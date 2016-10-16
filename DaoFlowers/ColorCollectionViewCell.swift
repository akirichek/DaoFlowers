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
    var color: Color! {
        didSet {
            populateView()
        }
    }
    
    func populateView() {
        self.containerView.layer.cornerRadius = 5
        nameLabel.text = color.name
        
        if color.sortsCount == 1 {
            sortsCountLabel.text = "\(color.sortsCount) sort"
        } else {
            sortsCountLabel.text = "\(color.sortsCount) sorts"
        }
        
        imageView.image = nil
        if let imageUrl = color.imageUrl {
            imageView.af_setImageWithURL(NSURL(string: imageUrl)!)
        }
    }
}
