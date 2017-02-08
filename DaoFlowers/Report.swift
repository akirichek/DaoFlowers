//
//  Report.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 2/1/17.
//  Copyright © 2017 Dao Flowers. All rights reserved.
//

import Foundation

struct Report {
    var id: Int
    var name: String
    
    init(dictionary: [String: AnyObject]) {
        id = dictionary["id"] as! Int
        name = dictionary["name"] as! String
    }
    
    func toDictionary() -> [String: AnyObject] {
        var dictionary: [String: AnyObject] = [:]
        dictionary["id"] = id as AnyObject?
        dictionary["name"] = name as AnyObject?
        return dictionary
    }
}
