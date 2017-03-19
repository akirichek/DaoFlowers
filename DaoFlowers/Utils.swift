//
//  Utils.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/16/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class Utils: NSObject {
    
    static func showError(_ error: NSError, inViewController viewController: UIViewController)  {
        self.showErrorWithMessage(error.localizedDescription, inViewController: viewController)
    }
     
    static func showErrorWithMessage(_ message: String, inViewController viewController: UIViewController) {
        UIAlertView(title: CustomLocalisedString("Error"), message: message, delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    static func showSuccessWithMessage(_ message: String, inViewController viewController: UIViewController) {
        UIAlertView(title: CustomLocalisedString("Success"), message: message, delegate: nil, cancelButtonTitle: "OK").show()
    }

    static func sortedVarietiesByName(_ varieties: [Variety]) -> [Variety] {
        var array = varieties
        array.sort(by: { (obj1, obj2) -> Bool in
            return obj1.name < obj2.name
        })
        
        return array
    }
    
    static func sortedVarietiesByPercentsOfPurchase(_ varieties: [Variety]) -> [Variety] {
        var array = varieties
        array.sort(by: { (obj1, obj2) -> Bool in
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
    
    
    static func sortedVarietiesByBoughtLastMonth(_ varieties: [Variety]) -> [Variety] {
        var array = varieties
        array.sort(by: { (obj1, obj2) -> Bool in
            return obj1.invoicesDone > obj2.invoicesDone
        })
        
        return array
    }
    
    
    static func sortedVarieties(_ varieties: [Variety], byAssortmentType assortmentType: VarietiesAssortmentType) -> [Variety] {
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
    
    static func sortedPlantations(_ plantations: [Plantation], byAssortmentType assortmentType: PlantationsAssortmentType) -> [Plantation] {
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
    
    static func sortedPlantationsByName(_ plantations: [Plantation]) -> [Plantation] {
        var array = plantations
        array.sort(by: { (obj1, obj2) -> Bool in
            return obj1.name.lowercased() < obj2.name.lowercased()
        })
        
        return array
    }
    
    static func sortedFlowersByName(_ flowers: [Flower]) -> [Flower] {
        var array = flowers
        array.sort(by: { (obj1, obj2) -> Bool in
            return obj1.name.lowercased() < obj2.name.lowercased()
        })
        
        return array
    }
    
    static func sortedFlowerSizesByName(_ sizes: [Flower.Size]) -> [Flower.Size] {
        var array = sizes
        array.sort(by: { (obj1, obj2) -> Bool in
            return obj1.name.lowercased() < obj2.name.lowercased()
        })
        
        return array
    }
    
    static func sortedOrderDetailsByName(_ orders: [OrderDetails]) -> [OrderDetails] {
        var array = orders
        array.sort(by: { (obj1, obj2) -> Bool in
            let str1 = obj1.flowerType.name + ". " + obj1.flowerSort.name
            let str2 = obj2.flowerType.name + ". " + obj2.flowerSort.name
            return str1.lowercased() < str2.lowercased()
        })
        
        return array
    }
    
    static func sortedPlantationsByActivePlantations(_ plantations: [Plantation]) -> [Plantation] {
        var activePlantations = sortedPlantationsByName(plantations.filter({$0.fbSum > 0}))
        let deactivePlantations = sortedPlantationsByName(plantations.filter({$0.fbSum == 0}))
        activePlantations += deactivePlantations
        return activePlantations
    }
    
    static func sortedPlantationsByPercentsOfPurchase(_ plantations: [Plantation]) -> [Plantation] {
        var array = plantations
        array.sort(by: { (obj1, obj2) -> Bool in
            return obj1.fbSum > obj2.fbSum
        })
        
        return array
    }
    
    static func heightForText(_ text: String, havingWidth widthValue: CGFloat, andFont font: UIFont) -> CGFloat{
        var size = CGSize.zero;
        let nsstring = NSString(string: text)
        let frame = nsstring.boundingRect(with: CGSize(width: widthValue, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        size = CGSize(width: frame.size.width, height: frame.size.height + 1)
        return size.height
    }
    
    static func sortedDocuments(_ documents: [Document]) -> [Date: [Document]] {
        var dictionary: [Date: [Document]] = [:]
        for document in documents {
            if var array = dictionary[document.date as Date] {
                array.append(document)
                dictionary[document.date as Date] = array
            } else {
                dictionary[document.date as Date] = [document]
            }
        }
        
        return dictionary
    }

    static func view(view: UIView,  byRoundingCorners corners: UIRectCorner) {
        let maskPath = UIBezierPath(roundedRect: view.bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: 5.0, height: 5.0))
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.path = maskPath.cgPath
        view.layer.mask = maskLayer
    }
    
    static func postsString(_ posts: [Post]) -> String{
        var postsString: String = ""
        for i in 0..<posts.count {
            postsString += "\(i + 1). " + posts[i].name
            
            if i != posts.count - 1 {
                postsString += "\n"
            }
        }
        return postsString
    }
    
    static func reportsString(_ reports: [Report]) -> String {
        var reportsString = ""
        for i in 0..<reports.count {
            reportsString += "\(i + 1). " + reports[i].name
            
            if i != reports.count - 1 {
                reportsString += "\n"
            }
        }
        
        return reportsString
    }
}
