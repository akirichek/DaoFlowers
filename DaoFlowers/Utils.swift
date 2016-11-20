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
    
    static func sortedFlowersByName(flowers: [Flower]) -> [Flower] {
        var array = flowers
        array.sortInPlace({ (obj1, obj2) -> Bool in
            return obj1.name.lowercaseString < obj2.name.lowercaseString
        })
        
        return array
    }
    
    static func sortedFlowerSizesByName(sizes: [Flower.Size]) -> [Flower.Size] {
        var array = sizes
        array.sortInPlace({ (obj1, obj2) -> Bool in
            return obj1.name.lowercaseString < obj2.name.lowercaseString
        })
        
        return array
    }
    
    static func sortedOrderDetailsByName(orders: [OrderDetails]) -> [OrderDetails] {
        var array = orders
        array.sortInPlace({ (obj1, obj2) -> Bool in
            let str1 = obj1.flowerType.name + ". " + obj1.flowerSort.name
            let str2 = obj2.flowerType.name + ". " + obj2.flowerSort.name
            return str1.lowercaseString < str2.lowercaseString
        })
        
        return array
    }
    
    static func sortedPlantationsByActivePlantations(plantations: [Plantation]) -> [Plantation] {
        var activePlantations = sortedPlantationsByName(plantations.filter({$0.fbSum > 0}))
        let deactivePlantations = sortedPlantationsByName(plantations.filter({$0.fbSum == 0}))
        activePlantations += deactivePlantations
        return activePlantations
    }
    
    static func sortedPlantationsByPercentsOfPurchase(plantations: [Plantation]) -> [Plantation] {
        var array = plantations
        array.sortInPlace({ (obj1, obj2) -> Bool in
            return obj1.fbSum > obj2.fbSum
        })
        
        return array
    }
    
    static func heightForText(text: String, havingWidth widthValue: CGFloat, andFont font: UIFont) -> CGFloat{
        var size = CGSizeZero;
        let nsstring = NSString(string: text)
        let frame = nsstring.boundingRectWithSize(CGSizeMake(widthValue, CGFloat.max), options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        size = CGSizeMake(frame.size.width, frame.size.height + 1)
        return size.height
    }
    
    static func sortedDocuments(documents: [Document]) -> [NSDate: [Document]] {
        var dictionary: [NSDate: [Document]] = [:]
        for document in documents {
            if var array = dictionary[document.date] {
                array.append(document)
                dictionary[document.date] = array
            } else {
                dictionary[document.date] = [document]
            }
        }
        
        return dictionary
    }
}
