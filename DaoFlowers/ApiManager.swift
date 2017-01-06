//
//  ApiManager.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/14/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Alamofire

class ApiManager: NSObject {
    static let sharedInstance = ApiManager()
    var downloadTask: URLSessionDownloadTask!
    var backgroundSession: Foundation.URLSession!
    var document: Document!
    var downloadDocumentCompletion: ((_ error: NSError?)->())!
    
    static func fetchFlowers(_ completion: @escaping (_ flowers: [Flower]?, _ error: NSError?) -> ()) {
        let parameters: [String: AnyObject] = [
            "exotic": 0 as AnyObject
        ]
    
        let url = K.Api.BaseUrl + K.Api.FlowersTypesPath
            
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                var flowers: [Flower] = []
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    for dictionary in json as! [[String: AnyObject]] {
                        let flower = Flower(dictionary: dictionary)
                        flowers.append(flower)
                    }
                }
                completion(flowers, nil)
            } else {
                print("Error: \(response.result.error)")
                completion(nil, response.result.error as NSError?)
            }
        }
    }
        
    static func fetchColorsByFlower(_ flower: Flower, completion: @escaping (_ colors: [Color]?, _ error: NSError?) -> ()) {
        var parameters: [String: AnyObject] = [
            "flower_type_id": flower.id as AnyObject
        ]
        
        var url = K.Api.BaseUrl + K.Api.FlowersColorsPath
        
        if flower.id == -3 {
            parameters = [
                "exotic": 1 as AnyObject
            ]
            url = K.Api.BaseUrl + K.Api.FlowersTypesPath
        }
        
        Alamofire.request(url, method: .get,parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                var colors: [Color] = []
                
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    for dictionary in json as! [[String: AnyObject]] {
                        let color = Color(dictionary: dictionary)
                        colors.append(color)
                    }
                }
                
                completion(colors, nil)
            } else {
                print("Error: \(response.result.error)")
                completion(nil, response.result.error as NSError?)
            }
        }
    }
    
    static func fetchVarietiesByFlower(_ flower: Flower, color: Color, completion: @escaping (_ varieties: [Variety]?, _ error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.VarietiesPath + "/\(flower.id)/\(color.id)"
        Alamofire.request(url, method: .get).responseJSON { response in
            if response.result.isSuccess {
                var varieties: [Variety] = []
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    for dictionary in json as! [[String: AnyObject]] {
                        let variety = Variety(dictionary: dictionary)
                        varieties.append(variety)
                    }
                }
                varieties = Utils.sortedVarietiesByPercentsOfPurchase(varieties)
                completion(varieties, nil)
            } else {
                print("Error: \(response.result.error)")
                completion(nil, response.result.error as NSError?)
            }
        }
    }
    
    static func fetchSimilarVarieties(_ variety: Variety, completion: @escaping (_ varieties: [Variety]?, _ error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.SimilarVarietiesPath + "/\(variety.id)"
        Alamofire.request(url, method: .get).responseJSON { response in
            if response.result.isSuccess {
                var varieties: [Variety] = []
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    for dictionary in json as! [[String: AnyObject]] {
                        let variety = Variety(dictionary: dictionary)
                        varieties.append(variety)
                    }
                }
                varieties = Utils.sortedVarietiesByPercentsOfPurchase(varieties)
                completion(varieties, nil)
            } else {
                print("Error: \(response.result.error)")
                completion(nil, response.result.error as NSError?)
            }
        }
    }
    
    static func fetchGeneralInfoForVariety(_ variety: Variety, user: User?, completion: @escaping (_ success: Bool, _ error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.GeneralInfoPath + "/\(variety.id)"
        var headers: [String: String] = ["DaoUserAgentFlowers":"ios"]
        if let user = user {
            headers["Authorization"] = user.token
        }
        Alamofire.request(url, method: .get, headers:headers).responseJSON { response in
            if response.result.isSuccess {
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    variety.addGeneralInfoFromDictionary(json as! [String: AnyObject])
                }
                completion(true, nil)
            } else {
                print("Error: \(response.result.error)")
                completion(false, response.result.error as NSError?)
            }
        }
    }
    
    static func searchVarietiesByTerm(_ term: String, flowers: [Flower]?, colors: [Color]?, breeders: [Breeder]?, completion: @escaping (_ varieties: [Variety]?, _ error: NSError?) -> ()) {
        var parameters: [String: AnyObject] = [
            "name_or_abr": term as AnyObject
        ]
        
        if let flowers = flowers {
            if flowers.count > 0 {
                var flowerIds: [String] = []
                for flower in flowers {
                    flowerIds.append(String(flower.id))
                }
                parameters["flower_type_ids"] = flowerIds.joined(separator: ",") as AnyObject?
            }
        }
        
        if let colors = colors {
            if colors.count > 0 {
                var colorIds: [String] = []
                for color in colors {
                    colorIds.append(String(color.id))
                }
                parameters["flower_color_ids"] = colorIds.joined(separator: ",") as AnyObject?
            }
        }
        
        if let breeders = breeders {
            if breeders.count > 0 {
                var breederIds: [String] = []
                for breeder in breeders {
                    breederIds.append(String(breeder.id))
                }
                parameters["breeder_ids"] = breederIds.joined(separator: ",") as AnyObject?
            }
        }
        
        let url = K.Api.BaseUrl + K.Api.SearchFlowersPath
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                var varieties: [Variety] = []
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    for dictionary in json as! [[String: AnyObject]] {
                        let variety = Variety(dictionary: dictionary)
                        varieties.append(variety)
                    }
                }
                varieties = Utils.sortedVarietiesByPercentsOfPurchase(varieties)
                completion(varieties, nil)
            } else {
                print("Error: \(response.result.error)")
                completion(nil, response.result.error as NSError?)
            }
        }
    }
    
    static func fetchVarietiesSearchParameters(_ completion: @escaping (_ searchParams: ([Flower], [Color], [Breeder])?, _ error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.FlowersSearchParametersPath
        Alamofire.request(url, method: .get).responseJSON { response in
            if response.result.isSuccess {
                var flowers: [Flower] = []
                var colors: [Color] = []
                var breeders: [Breeder] = []
                if let json = response.result.value as? [String: AnyObject] {
                    //print("JSON: \(json)")
                    for flowerDictionary in json["flowerTypes"] as! [[String: AnyObject]] {
                        flowers.append(Flower(dictionary: flowerDictionary))
                    }
                    
                    for colorDictionary in json["flowerColors"] as! [[String: AnyObject]] {
                        colors.append(Color(dictionary: colorDictionary))
                    }
                    
                    for breederDictionary in json["breeders"] as! [[String: AnyObject]] {
                        breeders.append(Breeder(dictionary: breederDictionary))
                    }
                }
                completion((flowers, colors, breeders), nil)
            } else {
                print("Error: \(response.result.error)")
                completion(nil, response.result.error as NSError?)
            }
        }
    }
}
