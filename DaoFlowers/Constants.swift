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
        static let AuthorizePath = "/authorize"
        static let SimilarVarietiesPath = "/catalog/flowers/details/similar"
        static let PlantationsGrowersPath = "/catalog/flowers/details/growers"
        static let GeneralInfoPath = "/catalog/flowers/details/general"
        static let SearchFlowersPath = "/catalog/search/flowers"
        static let FlowersSearchParametersPath = "/catalog/search/flowers/params"
    }
    
    struct Storyboard {
        struct SegueIdentifier {
            static let Flowers = "FlowersViewControllerSegueIdentifier"
            static let Plantations = "PlantationsViewControllerSegueIdentifier"
            static let Colors = "ColorsViewControllerSegueIdentifier"
            static let Varieties = "VarietiesViewControllerSegueIdentifier"
            static let VarietyDetails = "VarietyDetailsViewControllerSegueIdentifier"
            static let Login = "LoginViewControllerSegueIdentifier"
        }
        
        struct ViewControllerIdentifier {
            static let VarietyDetails = "VarietyDetailsViewControllerIdentifier"
        }
    }
    
    struct Colors {
        static let MainBlue = UIColor(red: 0/255, green: 125/255, blue: 196/255, alpha: 1)
        static let LightGrey = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        static let DarkGrey = UIColor(red: 117/255, green: 117/255, blue: 117/255, alpha: 1)
    }
    
    struct UserDefaultKey {
        static let Login = "LoginUserDefaultKey"
    }
}

enum MenuSection: String {
    case UserProfile = "User Profile"
    case Varieties = "Varieties"
    case Plantations = "Plantations"
    case Documents = "Documents"
    case Claims = "Claims"
    case CurrentOrders = "Current Orders"
    case Contacts = "Contacts"
    case Settings = "Settings"
    case Login = "Log in"
    case Logout = "Log out"
    case About = "About"
}