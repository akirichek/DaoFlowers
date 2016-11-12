//
//  Country.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/6/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Foundation

struct Country {
    var id: Int
    var name: String
    var abr: String
    var imageUrl: String?
    var plantCount: Int = 0
    
    init(dictionary: [String: AnyObject]) {
        id = dictionary["id"] as! Int
        name = dictionary["name"] as! String
        abr = dictionary["abr"] as! String
        imageUrl = dictionary["imgUrl"] as? String
        if let plantCount = dictionary["plantCount"] as? Int {
            self.plantCount = plantCount
        }
    }
}