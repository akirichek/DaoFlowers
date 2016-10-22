//
//  ApiManager.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/14/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Alamofire

class ApiManager: NSObject {
    
    static func fetchFlowers(completion: (flowers: [Flower]?, error: NSError?) -> ()) {
        let parameters: [String: AnyObject] = [
            "exotic": 0
        ]
    
        let url = K.Api.BaseUrl + K.Api.FlowersTypesPath
            
        Alamofire.request(.GET, url, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                var flowers: [Flower] = []
                
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    for dictionary in json as! [[String: AnyObject]] {
                        let flower = Flower(id: dictionary["id"] as! Int,
                                            name: dictionary["name"] as! String,
                                            abr: dictionary["abr"] as? String,
                                            imageUrl: dictionary["imgUrl"] as? String,
                                            sortsCount: dictionary["sortsCount"] as! Int)
                        flowers.append(flower)
                    }
                }
            
                completion(flowers: flowers, error: nil)
            } else {
                print("Error: \(response.result.error)")
                completion(flowers: nil, error: response.result.error)
            }
        }
    }
    
    static func fetchColorsByFlower(flower: Flower, completion: (colors: [Color]?, error: NSError?) -> ()) {
        let parameters: [String: AnyObject] = [
            "flower_type_id": flower.id
        ]
        
        let url = K.Api.BaseUrl + K.Api.FlowersColorsPath
        
        Alamofire.request(.GET, url, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                var colors: [Color] = []
                
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    for dictionary in json as! [[String: AnyObject]] {
                        let color = Color(id: dictionary["id"] as! Int,
                            name: dictionary["name"] as! String,
                            imageUrl: dictionary["imgUrl"] as? String,
                            sortsCount: dictionary["sortsCount"] as! Int)
                        colors.append(color)
                    }
                }
                
                completion(colors: colors, error: nil)
            } else {
                print("Error: \(response.result.error)")
                completion(colors: nil, error: response.result.error)
            }
        }
    }
    
    static func fetchVarietiesByFlower(flower: Flower, color: Color, completion: (varieties: [Variety]?, error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.VarietiesPath + "/\(flower.id)/\(color.id)"
        Alamofire.request(.GET, url).responseJSON { response in
            if response.result.isSuccess {
                var varieties: [Variety] = []
                
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    for dictionary in json as! [[String: AnyObject]] {
                        var sizeFrom: Variety.SizeFrom?
                        if let sizeFromDictionary = dictionary["sizeFrom"] as? [String: AnyObject] {
                            sizeFrom = Variety.SizeFrom(id: sizeFromDictionary["id"] as! Int,
                                name: sizeFromDictionary["name"] as! String)
                        }
                        
                        var sizeTo: Variety.SizeTo?
                        if let sizeToDictionary = dictionary["sizeTo"] as? [String: AnyObject] {
                            sizeTo = Variety.SizeTo(id: sizeToDictionary["id"] as! Int,
                                name: sizeToDictionary["name"] as! String)
                        }
                        
                        let variety = Variety(id: dictionary["id"] as! Int,
                            name: dictionary["name"] as! String,
                            abr: dictionary["abr"] as! String,
                            imageUrl: dictionary["imgUrl"] as? String,
                            smallImageUrl: dictionary["smallImgUrl"] as? String,
                            invoicesDone: dictionary["invoicesDone"] as! Double,
                            purchasePercent: dictionary["purchasePercent"] as? Double,
                            flower: flower,
                            color: color,
                            sizeFrom: sizeFrom,
                            sizeTo: sizeTo)
                        
                        varieties.append(variety)
                    }
                }
                
                completion(varieties: varieties, error: nil)
            } else {
                print("Error: \(response.result.error)")
                completion(varieties: nil, error: response.result.error)
            }
        }
    }
}
