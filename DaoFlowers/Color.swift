//
//  Color.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/16/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Foundation

struct Color {
    var id: Int
    var name: String
    var imageUrl: String?
    var sortsCount: Int?
    
    init(dictionary: [String: AnyObject]) {
        id = dictionary["id"] as! Int
        name = dictionary["name"] as! String
        imageUrl = dictionary["imgUrl"] as? String
        sortsCount = dictionary["sortsCount"] as? Int
    }
}