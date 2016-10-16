//
//  Constants.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/13/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Foundation

struct K {
    struct Api {
        static let BaseUrl = "http://77.91.147.26:9000"
        static let FlowersTypesPath = "/catalog/flowers/types"
        static let FlowersColorsPath = "/catalog/flowers/colors"
        static let VarietiesPath = "/catalog/flowers"
    }
    
    struct Storyboard {
        struct SegueIdentifier {
            static let Flowers = "FlowersViewControllerSegueIdentifier"
            static let Plantations = "PlantationsViewControllerSegueIdentifier"
            static let Colors = "ColorsViewControllerSegueIdentifier"
        }
    }
}

enum MenuSection: Int {
    case Varieties, Plantations
}