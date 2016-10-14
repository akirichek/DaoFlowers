//
//  Constants.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/13/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Foundation

struct K {
    struct Storyboard {
        struct SegueIdentifier {
            static let Varieties = "VarietiesViewControllerSegueIdentifier"
            static let Plantations = "PlantationsViewControllerSegueIdentifier"
        }
    }
}

enum MenuSection: Int {
    case Varieties, Plantations
}