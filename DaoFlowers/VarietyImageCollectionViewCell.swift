//
//  VarietyImageCollectionViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/29/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class VarietyImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var plantationView: UIView!
    @IBOutlet weak var plantationLabel: UILabel!
    
    var image: Variety.Image! {
        didSet {
           populateView()
        }
    }
    
    func populateView() {
        imageView.image = nil
        imageView.af_setImage(withURL: URL(string: image.imgUrl)!)
        
        if let plantName = image.plantName {
            plantationView.isHidden = false
            
            let string = "Photo from plantation:  " + plantName
            let planNameFontAttr = [NSForegroundColorAttributeName: UIColor.white]
            let plantationAttrString = NSMutableAttributedString(string: string, attributes: planNameFontAttr)
            let range = NSRange(location: 24, length: plantName.characters.count)
            plantationAttrString.addAttributes([NSForegroundColorAttributeName: K.Colors.MainBlue, NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightSemibold)],
                                              range: range)
            plantationLabel.attributedText = plantationAttrString
        } else {
            plantationView.isHidden = true
        }
    }
}
