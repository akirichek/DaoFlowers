//
//  UIView+ConstraintByIdentifier.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/27/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

extension UIView {
    func constraintByIdentifier(identifier: String) -> NSLayoutConstraint? {
        for constraint in self.constraints {
            print(constraint)
            if constraint.identifier == identifier {
                return constraint
            }
        }
        return nil
    }
}
