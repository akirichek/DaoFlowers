//
//  Plantation.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/23/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Foundation

struct Plantation {
    var brand: String
    var fbSum: Double!
    var id: Int
    var imageUrl: String?
    var name: String
    var posInList: Int!
    var countryName: String?
    var varieties: [Variety]?
    var isActive: Bool
    
    init(id: Int, brand: String, name: String) {
        self.id = id
        self.brand = brand
        self.name = name
        self.isActive = true
    }
    
    init(dictionary: [String: AnyObject]) {
        brand = dictionary["brand"] as! String
        fbSum = dictionary["fbSum"] as? Double
        id = dictionary["id"] as! Int
        imageUrl = dictionary["imgUrl"] as? String
        name = dictionary["name"] as! String
        posInList = dictionary["posInList"] as? Int
        if let active = dictionary["active"] as? NSNumber {
            self.isActive = active.boolValue
        } else {
            self.isActive = false
        }
    }
}
