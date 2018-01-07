//
//  OrderDetails.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/13/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Foundation

struct OrderDetails {
    var confFb: Double
    var orderFb: Double
    var flowerSize: FlowerSize
    var flowerSort: FlowerSort
    var flowerType: FlowerType
    var country: Country?
    
    struct FlowerSize {
        var id: Int
        var name: String
    }
    
    struct FlowerSort {
        var id: Int
        var abr: String
        var name: String
    }
    
    struct FlowerType {
        var id: Int
        var abr: String
        var name: String
    }
    
    init(dictionary: [String: AnyObject]) {
        confFb = dictionary["confirmedFb"] as! Double
        orderFb = dictionary["orderedFb"] as! Double

        let flowerSizeDictionary = dictionary["flowerSize"] as! [String: AnyObject]
        flowerSize = FlowerSize(id: flowerSizeDictionary["id"] as! Int,
                                name: flowerSizeDictionary["name"] as! String)
        
        let flowerSortDictionary = dictionary["flowerSort"] as! [String: AnyObject]
        flowerSort = FlowerSort(id: flowerSortDictionary["id"] as! Int,
                                abr: flowerSortDictionary["abr"] as! String,
                                name: flowerSortDictionary["name"] as! String)
        
        let flowerTypeDictionary = dictionary["flowerType"] as! [String: AnyObject]
        flowerType = FlowerType(id: flowerTypeDictionary["id"] as! Int,
                                abr: flowerTypeDictionary["abr"] as! String,
                                name: flowerTypeDictionary["name"] as! String)
        
        if let onlyCountry = dictionary["onlyCountry"] as? [String: AnyObject] {
            country = Country(dictionary: onlyCountry)
        }
    }
}
