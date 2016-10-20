//
//  HeaderFlagView.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/19/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class HeaderFlagView: UIView {
    
    var selectedMultiplier: CGFloat = 1.0
    var selectedRightPart: Bool = true
    
    override func drawRect(rect: CGRect) {
        UIColor.clearColor().setFill()
        UIRectFill(rect)
        
        let selectedWidth = round(rect.width * self.selectedMultiplier)
        let originX = self.selectedRightPart ? rect.width - selectedWidth : 0
        let rectIntersection = CGRectIntersection(CGRectMake(originX, 0, selectedWidth, rect.height), rect);
        
        K.Colors.MainBlue.setFill()
        UIRectFill(rectIntersection)
    }
}
