//
//  Order.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/12/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Foundation

struct Order {
    var clientLabel: String
    var confirmedFb: Double
    var headDate: Date
    var headId: Int
    var isCompleted: Bool
    var orderedFb: Double
    var ordersDate: Date
    var ordersId: Int
    var outPoint: OutPoint
    var truck: Truck
    
    struct OutPoint {
        var id: Int
        var name: String
    }
    
    struct Truck {
        var id: Int
        var name: String
    }
    
    init(dictionary: [String: AnyObject]) {
        clientLabel = dictionary["clientLabel"] as! String
        confirmedFb = dictionary["confirmedFb"] as! Double
        headId = dictionary["headId"] as! Int
        isCompleted = dictionary["isCompleted"] as! Bool
        orderedFb = dictionary["orderedFb"] as! Double
        ordersId = dictionary["ordersId"] as! Int
        
        let outPointDictionary = dictionary["outPoint"] as! [String: AnyObject]
        outPoint = OutPoint(id: outPointDictionary["id"] as! Int,
                            name: outPointDictionary["name"] as! String)
        let truckDictionary = dictionary["truck"] as! [String: AnyObject]
        truck = Truck(id: truckDictionary["id"] as! Int,
                            name: truckDictionary["name"] as! String)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        headDate = dateFormatter.date(from: dictionary["headDate"] as! String)!
        ordersDate = dateFormatter.date(from: dictionary["ordersDate"] as! String)!
    }
}
