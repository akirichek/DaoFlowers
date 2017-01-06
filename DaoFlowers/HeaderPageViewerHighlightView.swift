//
//  HeaderFlagView.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/19/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class HeaderPageViewerHighlightView: UIView {
    
    var selectedMultiplier: CGFloat = 1.0
    var selectedRightPart: Bool = true
    
    override func draw(_ rect: CGRect) {
        UIColor.clear.setFill()
        UIRectFill(rect)
        
        let selectedWidth = round(rect.width * self.selectedMultiplier)
        let originX = self.selectedRightPart ? rect.width - selectedWidth : 0
        let rectIntersection = CGRect(x: originX, y: 0, width: selectedWidth, height: rect.height).intersection(rect);
        
        K.Colors.MainBlue.setFill()
        UIRectFill(rectIntersection)
    }
}
