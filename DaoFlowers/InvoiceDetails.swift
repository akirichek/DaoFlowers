//
//  InvoiceDetails.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/17/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Foundation

struct InvoiceDetails {
    var totalFb: Double
    var totalPrice: Double
    var totalStems: Int
    var heads: [Head]
    var varieties: [Variety]
    var flowers: [Flower]
    var flowerSizes: [Flower.Size]
    var plantations: [Plantation]
    var countries: [Country]
    var orderStatistic: OrderStatistic
    var statistic: Statistic
    
    init(dictionary: [String: AnyObject]) {
        let totalDictionary = dictionary["total"] as! [String: AnyObject]
        totalFb = totalDictionary["fb"] as! Double
        totalPrice = totalDictionary["price"] as! Double
        totalStems = totalDictionary["stems"] as! Int
        
        heads = []
        for headDictionary in dictionary["heads"] as! [[String: AnyObject]] {
            heads.append(Head(dictionary: headDictionary))
        }
        
        varieties = []
        for flowerSorts in dictionary["flowerSorts"] as! [[String: AnyObject]] {
            varieties.append(Variety(dictionary: flowerSorts))
        }
        
        flowerSizes = []
        for flowerSize in dictionary["flowerSizes"] as! [[String: AnyObject]]  {
            flowerSizes.append(Flower.Size(dictionary: flowerSize))
        }
        
        flowers = []
        for flowerType in dictionary["flowerTypes"] as! [[String: AnyObject]]  {
            flowers.append(Flower(dictionary: flowerType))
        }
        
        plantations = []
        for plantation in dictionary["plantations"] as! [[String: AnyObject]]  {
            plantations.append(Plantation(dictionary: plantation))
        }
        
        countries = []
        for country in dictionary["countries"] as! [[String: AnyObject]]   {
            countries.append(Country(dictionary: country))
        }
        
        orderStatistic = OrderStatistic(dictionary: dictionary["orderStatistic"] as! [String: AnyObject])
        statistic = Statistic(dictionary: dictionary["statistic"] as! [String: AnyObject])
        self.sortOrderStatistic()
    }
    
    struct Head {
        var awb: String
        var clientId: Int
        var countryId: Int
        var fb: Int
        var flowerTypeId: Int
        var id: Int
        var invoiceId: Int
        var label: String
        var pieces: String
        var plantationId: Int
        var rows: [Row]
        var totalFb: Double
        var totalPrice: Double
        var totalStems: Int
        
        init(dictionary: [String: AnyObject]) {
            awb = dictionary["awb"] as! String
            clientId = dictionary["clientId"] as! Int
            countryId = dictionary["countryId"] as! Int
            fb = dictionary["fb"] as! Int
            flowerTypeId = dictionary["flowerTypeId"] as! Int
            id = dictionary["id"] as! Int
            invoiceId = dictionary["invoiceId"] as! Int
            label = dictionary["label"] as! String
            pieces = dictionary["pieces"] as! String
            plantationId = dictionary["plantationId"] as! Int
            
            rows = []
            for rowDictionary in dictionary["rows"] as! [[String: AnyObject]] {
                rows.append(Row(dictionary: rowDictionary))
            }
            
            let totalDictionary = dictionary["total"] as! [String: AnyObject]
            totalFb = totalDictionary["fb"] as! Double
            totalPrice = totalDictionary["price"] as! Double
            totalStems = totalDictionary["stems"] as! Int
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
        var cost: Double {
            return Double(stems) * stemPrice
        }
        
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
    
    struct OrderStatistic {
        var rowsGroupedByFlowerTypeId: [[Int: [Row]]]
        var subtotalsGroupedByFlowerTypeId: [Int: Subtotal]
        var totalDifferenceFb: Double
        var totalInvoiceFb: Double
        var totalOrderFb: Double
        
        init(dictionary: [String: AnyObject]) {
            let totalDictionary = dictionary["total"] as! [String: AnyObject]
            
            totalDifferenceFb = totalDictionary["differenceFb"] as! Double
            totalInvoiceFb = totalDictionary["invoiceFb"] as! Double
            totalOrderFb = totalDictionary["orderFb"] as! Double
            
            rowsGroupedByFlowerTypeId = []
            let rowsGroupedByFlowerIdDictionary = dictionary["rowsGroupedByFlowerTypeId"] as! [String: [[String: AnyObject]]]
            for (flowerTypeId, rowsDictionary) in rowsGroupedByFlowerIdDictionary {
                var rows: [Row] = []
                for rowDictionary in rowsDictionary {
                    let row = Row(differenceFb: rowDictionary["differenceFb"] as! Double,
                                  flowerSortId: rowDictionary["flowerSortId"] as! Int,
                                  invoiceFb: rowDictionary["invoiceFb"] as! Double,
                                  orderFb: rowDictionary["orderFb"] as! Double)
                    rows.append(row)
                }
                
                var rowsGroupedByFlowerTypeId: [Int: [Row]] = [:]
                rowsGroupedByFlowerTypeId[Int(flowerTypeId)!] = rows
                self.rowsGroupedByFlowerTypeId.append(rowsGroupedByFlowerTypeId)
            }
            
            subtotalsGroupedByFlowerTypeId = [:]
            let subtotalsGroupedByFlowerIdDictionary = dictionary["subtotalsGroupedByFlowerTypeId"] as! [String: [String: AnyObject]]
            for (flowerTypeId, subtotalDictionary) in subtotalsGroupedByFlowerIdDictionary {
                let subtotal = Subtotal(differenceFb: subtotalDictionary["differenceFb"] as! Double,
                                        invoiceFb: subtotalDictionary["invoiceFb"] as! Double,
                                        orderFb: subtotalDictionary["orderFb"] as! Double)
                subtotalsGroupedByFlowerTypeId[Int(flowerTypeId)!] = subtotal
            }
        }
        
        struct Row {
            var differenceFb: Double
            var flowerSortId: Int
            var invoiceFb: Double
            var orderFb: Double
        }
        
        struct Subtotal {
            var differenceFb: Double
            var invoiceFb: Double
            var orderFb: Double
        }
    }
    
    struct Statistic {
        var averagePrices: [AveragePrice]
        var stems: [Stem]
        
        init(dictionary: [String: AnyObject]) {
            averagePrices = []
            let averagePricesDictionary = dictionary["averagePrices"] as! [[String: AnyObject]]
            for averagePriceDictionary in averagePricesDictionary {
                let averagePrice = AveragePrice(averagePrice: averagePriceDictionary["averagePrice"] as! Double,
                                                countryId: averagePriceDictionary["countryId"] as! Int,
                                                flowerSizeId: averagePriceDictionary["flowerSizeId"] as! Int,
                                                flowerTypeId: averagePriceDictionary["flowerTypeId"] as! Int)
                averagePrices.append(averagePrice)
            }
            
            stems = []
            let stemsDictionary = dictionary["stems"] as! [[String: AnyObject]]
            for stemDictionary in stemsDictionary {
                let stem = Stem(countryId: stemDictionary["countryId"] as! Int,
                                flowerTypeId: stemDictionary["flowerTypeId"] as! Int,
                                stems: stemDictionary["stems"] as! Int)
                stems.append(stem)
            }
        }
        
        struct AveragePrice {
            var averagePrice: Double
            var countryId: Int
            var flowerSizeId: Int
            var flowerTypeId: Int
        }
        
        struct Stem {
            var countryId: Int
            var flowerTypeId: Int
            var stems: Int
        }
    }
    
    func varietyById(id: Int) -> Variety? {
        for variety in varieties {
            if variety.id == id {
                return variety
            }
        }
        
        return nil
    }
    
    func flowerById(id: Int) -> Flower? {
        for flower in flowers {
            if flower.id == id {
                return flower
            }
        }
        
        return nil
    }
    
    func flowerSizeById(id: Int) -> Flower.Size? {
        for flowerSize in flowerSizes {
            if flowerSize.id == id {
                return flowerSize
            }
        }
        
        return nil
    }
    
    func plantationById(id: Int) -> Plantation? {
        for plantation in plantations {
            if plantation.id == id {
                return plantation
            }
        }
        
        return nil
    }
    
    func countryById(id: Int) -> Country? {
        for country in countries {
            if country.id == id {
                return country
            }
        }
        
        return nil
    }
    
    
    
    mutating func sortOrderStatistic() {
        var sortedOrderStatistic = self.orderStatistic
        sortedOrderStatistic.rowsGroupedByFlowerTypeId.sortInPlace { (row1, row2) -> Bool in
            let flowerTypeId1 = Int(Array(row1.keys)[0])
            let flowerTypeId2 = Int(Array(row2.keys)[0])
            return flowerTypeId1 < flowerTypeId2
        }
        
        var sortedRowsGroupedByFlowerTypeId: [[Int: [InvoiceDetails.OrderStatistic.Row]]] = []
        for dictionary in sortedOrderStatistic.rowsGroupedByFlowerTypeId {
            for (flowerTypeId, rows) in dictionary {
                var sortedRows = rows
                sortedRows.sortInPlace({ (row1, row2) -> Bool in
                    let variety1 = varietyById(row1.flowerSortId)!
                    let variety2 = varietyById(row2.flowerSortId)!
                    return variety1.name < variety2.name
                })
                
                var rowsGroupedByFlowerTypeId: [Int: [InvoiceDetails.OrderStatistic.Row]] = [:]
                rowsGroupedByFlowerTypeId[flowerTypeId] = sortedRows
                sortedRowsGroupedByFlowerTypeId.append(rowsGroupedByFlowerTypeId)
            }
        }
        
        sortedOrderStatistic.rowsGroupedByFlowerTypeId = sortedRowsGroupedByFlowerTypeId
        
        self.orderStatistic = sortedOrderStatistic
    }
}