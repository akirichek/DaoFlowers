//
//  Breeder.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/26/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Foundation

struct Breeder {
    var id: Int
    var name: String
    var url: String
    
    init(dictionary: [String: AnyObject]) {
        id = dictionary["id"] as! Int
        name = dictionary["name"] as! String
        url = dictionary["url"] as! String
    }
}