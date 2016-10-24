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
                        let flower = Flower(dictionary: dictionary)
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
                        let color = Color(dictionary: dictionary)
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
                        let variety = Variety(dictionary: dictionary)
                        varieties.append(variety)
                    }
                }
                varieties = Utils.sortedVarieties(varieties)
                completion(varieties: varieties, error: nil)
            } else {
                print("Error: \(response.result.error)")
                completion(varieties: nil, error: response.result.error)
            }
        }
    }
    
    static func fetchSimilarVarieties(variety: Variety, completion: (varieties: [Variety]?, error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.SimilarVarietiesPath + "/\(variety.id)"
        Alamofire.request(.GET, url).responseJSON { response in
            if response.result.isSuccess {
                var varieties: [Variety] = []
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    for dictionary in json as! [[String: AnyObject]] {
                        let variety = Variety(dictionary: dictionary)
                        varieties.append(variety)
                    }
                }
                varieties = Utils.sortedVarieties(varieties)
                completion(varieties: varieties, error: nil)
            } else {
                print("Error: \(response.result.error)")
                completion(varieties: nil, error: response.result.error)
            }
        }
    }
    
    static func fetchPlantationsGrowersByVariety(variety: Variety, user: User, completion: (plantations: [Plantation]?, error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.PlantationsGrowersPath + "/\(variety.id)"
        Alamofire.request(.GET, url, headers:["Authorization": user.token]).responseJSON { response in
            if response.result.isSuccess {
                var plantations: [Plantation] = []
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    for dictionary in json as! [[String: AnyObject]] {
                        let plantation = Plantation(dictionary: dictionary)
                        plantations.append(plantation)
                    }
                }
                completion(plantations: plantations, error: nil)
            } else {
                print("Error: \(response.result.error)")
                completion(plantations: nil, error: response.result.error)
            }
        }
    }
    
    static func fetchGeneralInfoForVariety(variety: Variety, completion: (success: Bool, error: NSError?) -> ()) {
        print(variety)
        let url = K.Api.BaseUrl + K.Api.GeneralInfoPath + "/\(variety.id)"
        Alamofire.request(.GET, url).responseJSON { response in
            if response.result.isSuccess {
                if let json = response.result.value {
                    print("JSON: \(json)")
                    variety.addGeneralInfoFromDictionary(json as! [String: AnyObject])
                }
                completion(success: true, error: nil)
            } else {
                print("Error: \(response.result.error)")
                completion(success: false, error: response.result.error)
            }
        }
    }
}
