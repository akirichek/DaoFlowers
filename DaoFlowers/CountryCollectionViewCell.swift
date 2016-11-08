//
//  CountryCollectionViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/6/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class CountryCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var plantCountLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    var country: Country! {
        didSet {
            populateView()
        }
    }
    
    func populateView() {
        self.containerView.layer.cornerRadius = 5
        nameLabel.text = country.name
        
        if country.plantCount == 1 {
            plantCountLabel.text = "\(country.plantCount) plantation"
        } else {
            plantCountLabel.text = "\(country.plantCount) plantations"
        }
        
        imageView.image = nil
        imageView.af_setImageWithURL(NSURL(string: country.imageUrl)!)
    }
}
