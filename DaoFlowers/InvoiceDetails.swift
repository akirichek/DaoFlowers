//
//  InvoiceDetails.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/17/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Foundation

struct InvoiceDetails {
    var heads: [Head]
    
    init(dictionary: [String: AnyObject]) {
        heads = []
        for headDictionary in dictionary["heads"] as! [[String: AnyObject]] {
            heads.append(Head(dictionary: headDictionary))
        }
    }
    
    struct Head {
        var awb: String
        var clientId: Int
        var fb: Int
        var flowerTypeId: Int
        var id: Int
        var invoiceId: Int
        var label: Int?
        var pieces: String
        var plantationId: Int
        var rows: [Row]
        
        init(dictionary: [String: AnyObject]) {
            awb = dictionary["awb"] as! String
            clientId = dictionary["clientId"] as! Int
            fb = dictionary["fb"] as! Int
            flowerTypeId = dictionary["flowerTypeId"] as! Int
            id = dictionary["id"] as! Int
            invoiceId = dictionary["invoiceId"] as! Int
            label = dictionary["label"] as? Int
            pieces = dictionary["pieces"] as! String
            plantationId = dictionary["plantationId"] as! Int
            
            rows = []
            for rowDictionary in dictionary["rows"] as! [[String: AnyObject]] {
                rows.append(Row(dictionary: rowDictionary))
            }
        }
    }
    
    struct Row {
        var fb: Double
        var flowerSizeId: Int
        var flowerSortId: Int
        var headId: Int
        var id: Int
        var price: Double
        var stemPrice: Double
        var stems: Int
        
        init(dictionary: [String: AnyObject]) {
            fb = dictionary["fb"] as! Double
            flowerSizeId = dictionary["flowerSizeId"] as! Int
            flowerSortId = dictionary["flowerSortId"] as! Int
            headId = dictionary["headId"] as! Int
            id = dictionary["id"] as! Int
            price = dictionary["price"] as! Double
            stemPrice = dictionary["stemPrice"] as! Double
            stems = dictionary["stems"] as! Int
        }
    }
}