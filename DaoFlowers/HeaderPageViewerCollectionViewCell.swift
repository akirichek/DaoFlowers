//
//  HeaderPageViewerCollectionViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/18/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class HeaderPageViewerCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var headerHighlightView: HeaderPageViewerHighlightView!
    
    
    func selectCellWithMultiplier(_ multiplier: CGFloat, directionRight: Bool) {
        if multiplier > 0.5 {
            self.textLabel.backgroundColor = UIColor(red: 179/255, green: 213/255, blue: 232/255, alpha: 1)
            self.textLabel.textColor = UIColor(red: 0, green: 105/255, blue: 169/255, alpha: 1)
        }
        
        self.headerHighlightView.selectedMultiplier = multiplier
        self.headerHighlightView.selectedRightPart = !directionRight
        self.headerHighlightView.setNeedsDisplay()
    }
    
    func deselectCellWithMultiplier(_ multiplier: CGFloat, directionRight: Bool) {
        if multiplier > 0.5 {
            self.textLabel.backgroundColor = UIColor.clear
            self.textLabel.textColor = UIColor.darkGray
        }
        
        self.headerHighlightView.selectedMultiplier = 1 - multiplier
        self.headerHighlightView.selectedRightPart = directionRight
        self.headerHighlightView.setNeedsDisplay()
    }
}
