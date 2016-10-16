//
//  FitFontForSizeExentsion.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/15/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

extension UILabel {
    
    func fitFontForSize(minFontSize min : CGFloat = 5.0, maxFontSize max : CGFloat = 300.0, accuracy : CGFloat = 1.0) {
        assert(max > min)
        layoutIfNeeded() // Can be removed at your own discretion
        let constrainedSize = bounds.size
        var minFontSize = min
        var maxFontSize = max
        
        while maxFontSize - minFontSize > accuracy {
            let midFontSize : CGFloat = ((minFontSize + maxFontSize) / 2)
            font = font.fontWithSize(midFontSize)
            sizeToFit()
            let checkSize : CGSize = bounds.size
            if  checkSize.height < constrainedSize.height && checkSize.width < constrainedSize.width {
                minFontSize = midFontSize
            } else {
                maxFontSize = midFontSize
            }
        }
        font = font.fontWithSize(minFontSize)
        sizeToFit()
        layoutIfNeeded() // Can be removed at your own discretion
    }
    
}
