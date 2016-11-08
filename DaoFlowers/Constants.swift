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
        static let CountriesPath = "/catalog/countries"
        static let PlantationsPath = "/catalog/plantations"
    }
    
    struct Storyboard {
        struct SegueIdentifier {
            static let Flowers = "FlowersViewControllerSegueIdentifier"
            static let Plantations = "PlantationsViewControllerSegueIdentifier"
            static let Countries = "CountriesViewControllerSegueIdentifier"
            static let Colors = "ColorsViewControllerSegueIdentifier"
            static let Varieties = "VarietiesViewControllerSegueIdentifier"
            static let VarietyDetails = "VarietyDetailsViewControllerSegueIdentifier"
            static let Login = "LoginViewControllerSegueIdentifier"
            static let Settings = "SettingsViewControllerSegueIdentifier"
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
    
    struct UserDefaultsKey {
        static let Login = "LoginUserDefaultsKey"
        static let Language = "LanguageUserDefaultsKey"
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

enum VarietiesAssortmentType: String {
    case ByName = "by name"
    case ByPercentsOfPurchase = "by % of purchase"
    case BoughtLastMonth = "bought last month, FB"
}

enum PlantationsAssortmentType: String {
    case ByName = "by name"
    case ByActivePlantations = "active plantations"
    case ByPercentsOfPurchase = "by % of purchase"
}

enum Language: String {
    case English = "English"
    case Russian = "Русский"
    case Spanish = "Español"
    
    func flagImageName() -> String {
        var flagImageName: String!
        switch self {
        case .English:
            flagImageName = "flag_uk"
        case .Russian:
            flagImageName = "flag_russia"
        case .Spanish:
            flagImageName = "flag_spain"
        }
        
        return flagImageName
    }
    
    func code() -> String {
        var flagImageName: String!
        switch self {
        case .English:
            flagImageName = "en"
        case .Russian:
            flagImageName = "ru"
        case .Spanish:
            flagImageName = "es"
        }
        
        return flagImageName
    }
}

func CustomLocalisedString(key: String, comment: String) -> String {
    return LanguageManager.getTranslationForKey(key)
}