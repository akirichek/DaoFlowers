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
        static let BaseUrl = "https://daoflowers.com:7443"
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
        static let LightGrey = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        static let DarkGrey = UIColor(red: 117/255, green: 117/255, blue: 117/255, alpha: 1)
    }
}

enum MenuSection: Int {
    case Varieties, Plantations
}