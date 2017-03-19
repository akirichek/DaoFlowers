//
//  Document.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/15/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Foundation

struct Document {
    var id: Int
    var clientId: Int
    var date: Date
    var fb: Int
    var fileName: String
    var label: String
    var number: String?
    var zipFile: String
    
    init(dictionary: [String: AnyObject]) {
        id = dictionary["id"] as! Int
        if let userId = dictionary["userId"] as? Int {
            clientId = userId
        } else {
            clientId = dictionary["clientId"] as! Int
        }
        
        fb = dictionary["fb"] as! Int
        fileName = dictionary["fileName"] as! String
        label = dictionary["label"] as! String
        number = dictionary["number"] as? String
        zipFile = dictionary["zipFile"] as! String
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        date = dateFormatter.date(from: dictionary["date"] as! String)!
    }
}
