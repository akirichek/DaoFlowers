//
//  Update.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 5/15/17.
//  Copyright © 2017 Dao Flowers. All rights reserved.
//

import Foundation

struct Update {
    var version: String
    var date: String
    var news: [String]
    
    init(dictionary: [String: AnyObject]) {
        version = dictionary["Version"] as! String
        date = dictionary["Date"] as! String
        news = dictionary["News"] as! [String]
    }
}
