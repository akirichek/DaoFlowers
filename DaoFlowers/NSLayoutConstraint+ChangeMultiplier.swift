//
//  NSLayoutConstraint+ChangeMultiplier.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/27/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    func changeMultiplier(_ multiplier:CGFloat) -> NSLayoutConstraint {
        let newConstraint = NSLayoutConstraint(
            item: firstItem,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        newConstraint.isActive = true
        
        NSLayoutConstraint.deactivate([self])
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}
