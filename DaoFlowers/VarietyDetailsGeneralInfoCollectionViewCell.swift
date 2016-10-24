//
//  VarietyDetailsGeneralInfoCollectionViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/24/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class VarietyDetailsGeneralInfoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    var imageUrl: String! {
        didSet {
            populateView()
        }
    }
    
    func populateView() {
        self.containerView.layer.cornerRadius = 5
        imageView.image = nil
        imageView.af_setImageWithURL(NSURL(string: imageUrl)!)
    }
}
