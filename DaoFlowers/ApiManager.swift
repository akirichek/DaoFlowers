//
//  ApiManager.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/14/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Alamofire

class ApiManager: NSObject {
    
    static func fetchFlowers(completion: (flowers: [Flower]!, error: NSError!) -> ()) {
        let parameters: [String: AnyObject] = [
            "exotic": 0
        ]
    
        let url = K.Api.BaseUrl + K.Api.FlowersTypesPath
            
        Alamofire.request(.GET, url, parameters: parameters).responseJSON { response in
        //                print("Request \(response.request)")  // original URL request
        //                print("Response \(response.response)") // URL response
        //                print("Data \(response.data)")     // server data
        //                print("Result \(response.result)")   // result of response serialization
        
            if response.result.isSuccess {
                var flowers: [Flower] = []
                
                if let json = response.result.value {
                    print("JSON: \(json)")
                    for dictionary in json as! [[String: AnyObject]] {
                        let flower = Flower(id: dictionary["id"] as! Int,
                                            name: dictionary["name"] as! String,
                                            abr: dictionary["abr"] as? String,
                                            imageUrl: dictionary["imgUrl"] as! String,
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
    
    
}
