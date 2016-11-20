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
    
    func totalStemsInHead(head: Head) -> Int {
        var totalStems = 0
        for row in head.rows {
            totalStems += row.stems
        }
        
        return totalStems
    }
    
    func totalCostInHead(head: Head) -> Double {
        var totalCost: Double = 0
        for row in head.rows {
            totalCost += row.cost
        }
        
        return totalCost
    }
    
    func totalFbInHead(head: Head) -> Double {
        var totalFb: Double = 0
        for row in head.rows {
            totalFb += row.fb
        }
        
        return totalFb
    }
}