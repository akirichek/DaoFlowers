//
//  SimilarVarietyCollectionViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/23/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class SimilarVarietyCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    var variety: Variety! {
        didSet {
            populateView()
        }
    }
    
    func populateView() {
        self.containerView.layer.cornerRadius = 5
        nameLabel.text = "\(variety.name) (\(variety.abr))"
        imageView.image = nil
        if let imageUrl = variety.imageUrl {
            imageView.af_setImageWithURL(NSURL(string: imageUrl)!)
        } else {
            imageView.image = UIImage(named: "img_def_flower_rose")
        }
    }
}
