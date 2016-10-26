//
//  Variety.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/16/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Foundation

class Variety: NSObject {
    
    var id: Int
    var name: String
    var abr: String
    var imageUrl: String?
    var smallImageUrl: String?
    var invoicesDone: Double
    var purchasePercent: Double?
    var flower: Flower
    var color: Color
    var sizeFrom: SizeFrom?
    var sizeTo: SizeTo?
    var breeder: Breeder?
    var liveDaysFrom: Int?
    var liveDaysTo: Int?
    var productiveFrom: Int?
    var productiveTo: Int?
    var images: [String]?
    
    struct SizeFrom {
        var id: Int
        var name: String
    }
    
    struct SizeTo {
        var id: Int
        var name: String
    }
    
    init(dictionary: [String: AnyObject]) {
        if let sizeFromDictionary = dictionary["sizeFrom"] as? [String: AnyObject] {
            sizeFrom = Variety.SizeFrom(id: sizeFromDictionary["id"] as! Int,
                                        name: sizeFromDictionary["name"] as! String)
        }
        
        if let sizeToDictionary = dictionary["sizeTo"] as? [String: AnyObject] {
            sizeTo = Variety.SizeTo(id: sizeToDictionary["id"] as! Int,
                                    name: sizeToDictionary["name"] as! String)
        }
        
        id = dictionary["id"] as! Int
        name = dictionary["name"] as! String
        abr = dictionary["abr"] as! String
        imageUrl = dictionary["imgUrl"] as? String
        smallImageUrl = dictionary["smallImgUrl"] as? String
        invoicesDone = dictionary["invoicesDone"] as! Double
        purchasePercent = dictionary["purchasePercent"] as? Double
        flower = Flower(dictionary: dictionary["flowerType"] as! [String: AnyObject])
        color = Color(dictionary: dictionary["color"] as! [String: AnyObject])
    }
    
    func addGeneralInfoFromDictionary(dictionary: [String: AnyObject]) {
        let generalInfo = dictionary["general"] as! [String: AnyObject]
        liveDaysFrom = generalInfo["liveDaysFrom"] as? Int
        liveDaysTo = generalInfo["liveDaysTo"] as? Int
        productiveFrom = generalInfo["productiveFrom"] as? Int
        productiveTo = generalInfo["productiveTo"] as? Int
        
        if let breeder = generalInfo["breeder"] as? [String: AnyObject] {
            self.breeder = Breeder(dictionary: breeder)
        }
        
        var images: [String] = []
        for image in dictionary["images"] as! [[String: AnyObject]] {
            if let imageUrl = image["imgUrl"] as? String {
                images.append(imageUrl)
            }
        }
        self.images = images
    }
}
