//
//  Variety.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/16/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Foundation

struct Variety {
    var id: Int
    var name: String
    var abr: String
    var imageUrl: String
    var smallImageUrl: String
    var invoicesDone: Double
    var purchasePercent: Double
    var flower: Flower
    var color: Color
    var sizeFrom: SizeFrom
    var sizeTo: SizeTo
    
    struct SizeFrom {
        var id: Int
        var name: String
    }
    
    struct SizeTo {
        var id: Int
        var name: String
    }
}
