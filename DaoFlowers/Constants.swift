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
        static let ProductionBaseUrl = "https://daoflowers.com:7443"
        static let DevelopmentBaseUrl = "http://77.91.147.26:9000"
        static let BaseUrl = ProductionBaseUrl
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
        static let PlantationsSearchParametersPath = "/catalog/search/plantations/params"
        static let SearchPlantationsPath = "/catalog/search/plantations"
        static let CurrentOrdersPath = "/orders/current"
        struct Documents {
            static let Invoices = "/documents/invoices"
            static let Prealerts = "/documents/prealerts"
            static let Unzip = "/documents/unzip"
            static let Claims = "/documents/claims"
            static let ClaimDetails = "/documents/claims/details"
            static let ClaimSubjects = "/documents/claims/subjects"
            static let IsClaimEditingAllowed = "/documents/claims/isEditingAllowed"
        }
        struct Support {
            static let OrderCallback = "/support/callback"
            static let SendComment = "/support/comment"
            static let SignUpRequest = "/support/registration"
        }
        struct Profile {
            static let Customer = "/profile"
            static let EmployeesParams = "/profile/employees/params"
            static let UserAndChildren = "/profile/userAndChildren"
            static let RemoveChanges = "/profile/%d/removeChanges"
        }
    }
    
    struct Storyboard {
        struct SegueIdentifier {
            static let UserProfile = "UserProfileViewControllerSegueIdentifier"
            static let AddStaff = "AddStaffSegueIdentifier"
            static let Flowers = "FlowersViewControllerSegueIdentifier"
            static let Plantations = "PlantationsViewControllerSegueIdentifier"
            static let Countries = "CountriesViewControllerSegueIdentifier"
            static let Colors = "ColorsViewControllerSegueIdentifier"
            static let Varieties = "VarietiesViewControllerSegueIdentifier"
            static let VarietyDetails = "VarietyDetailsViewControllerSegueIdentifier"
            static let Login = "LoginViewControllerSegueIdentifier"
            static let Settings = "SettingsViewControllerSegueIdentifier"
            static let PlantationDetails = "PlantationDetailsViewControllerSegueIdentifier"
            static let CurrentOrders = "CurrentOrdersViewControllerSegueIdentifier"
            static let OrderDetails = "OrderDetailsViewControllerSegueIdentifier"
            static let Documents = "DocumentsViewControllerSegueIdentifier"
            static let InvoiceDetails = "InvoiceDetailsSegueIdentifier"
            static let Contacts = "ContactsViewControllerSegueIdentifier"
            static let VarietyImageViewer = "VarietyImageViewerViewControllerSegueIdentifier"
            static let Registration = "RegistrationSegueIdentifier"
            static let OrderCallback = "OrderCallbackSegueIdentifier"
            static let SendComment = "SendCommentSegueIdentifier"
            static let Claims = "ClaimsSegueIdentifier"
            static let About = "AboutSegueIdentifier"
            static let ClaimDetails = "ClaimDetailsSegueIdentifier"
            static let ImageViewer = "ImageViewerViewControllerSegueIdentifier"
            static let AddClaim = "AddClaimSegueIdentifier"
            static let InvoiceClaims = "InvoiceClaimsSegueIdentifier"
            static let PhotosViewer = "PhotosViewerSegueIdentifier"
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
