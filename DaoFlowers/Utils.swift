//
//  Utils.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/16/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class Utils: NSObject {
    
    static func showError(error: NSError, inViewController viewController: UIViewController)  {
        self.showErrorWithMessage(error.localizedDescription, inViewController: viewController)
    }
    
    static func showErrorWithMessage(message: String, inViewController viewController: UIViewController) {
        UIAlertView(title: "Error", message: message, delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    static func sortedVarietiesByName(varieties: [Variety]) -> [Variety] {
        var array = varieties
        array.sortInPlace({ (obj1, obj2) -> Bool in
            return obj1.name < obj2.name
        })
        
        return array
    }
    
    static func sortedVarietiesByPercentsOfPurchase(varieties: [Variety]) -> [Variety] {
        var array = varieties
        array.sortInPlace({ (obj1, obj2) -> Bool in
            if let purchasePercent1 = obj1.purchasePercent {
                if let purchasePercent2 = obj2.purchasePercent {
                    return purchasePercent1 > purchasePercent2
                } else {
                    return true
                }
            } else {
                return false
            }
        })
        
        return array
    }
    
    
    static func sortedVarietiesByBoughtLastMonth(varieties: [Variety]) -> [Variety] {
        var array = varieties
        array.sortInPlace({ (obj1, obj2) -> Bool in
            return obj1.invoicesDone > obj2.invoicesDone
        })
        
        return array
    }
    
    
    static func sortedVarieties(varieties: [Variety], byAssortmentType assortmentType: VarietiesAssortmentType) -> [Variety] {
        var array: [Variety]!
        switch assortmentType {
        case .ByName:
            array = sortedVarietiesByName(varieties)
        case .ByPercentsOfPurchase:
            array = sortedVarietiesByPercentsOfPurchase(varieties)
        case .BoughtLastMonth:
            array = sortedVarietiesByBoughtLastMonth(varieties)
        }
        
        return array
    }
    
    static func sortedPlantations(plantations: [Plantation], byAssortmentType assortmentType: PlantationsAssortmentType) -> [Plantation] {
        var array: [Plantation]!
        switch assortmentType {
        case .ByName:
            array = sortedPlantationsByName(plantations)
        case .ByActivePlantations:
            array = sortedPlantationsByActivePlantations(plantations)
        case .ByPercentsOfPurchase:
            array = sortedPlantationsByPercentsOfPurchase(plantations)
        }
        
        return array
    }
    
    static func sortedPlantationsByName(plantations: [Plantation]) -> [Plantation] {
        var array = plantations
        array.sortInPlace({ (obj1, obj2) -> Bool in
            return obj1.name.lowercaseString < obj2.name.lowercaseString
        })
        
        return array
    }
    
    static func sortedPlantationsByActivePlantations(plantations: [Plantation]) -> [Plantation] {
        return plantations
    }
    
    static func sortedPlantationsByPercentsOfPurchase(plantations: [Plantation]) -> [Plantation] {
        var array = plantations
        array.sortInPlace({ (obj1, obj2) -> Bool in
            return obj1.fbSum > obj2.fbSum
        })
        
        return array
    }
}
