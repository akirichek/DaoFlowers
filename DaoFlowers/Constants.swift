//
//  Constants.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/13/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

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
            static let Varieties = "VarietiesViewControllerSegueIdentifier"
        }
    }
    
    struct Colors {
        static let MainBlue = UIColor(red: 0/255, green: 125/255, blue: 196/255, alpha: 1)
    }
}

enum MenuSection: Int {
    case Varieties, Plantations
}