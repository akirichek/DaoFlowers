//
//  ApiManager+Authorization.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/22/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Alamofire

extension ApiManager {
    
    static func loginWithUsername(username: String, andPassword password: String, completion: (user: User?, error: NSError?) -> ()) {
        let parameters: [String: AnyObject] = [
            "login": username,
            "password": password
        ]
        
        let url = K.Api.BaseUrl + K.Api.AuthorizePath
        
        Alamofire.request(.GET, url, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                var user: User?
                var error: NSError?
                if let json = response.result.value {
                    print("JSON: \(json)")
                    if let result = json["result"] as? [String: AnyObject]{
                        user = User(dictionary: result)
                    } else {
                        let errorDictionary = json["error"] as! [String: AnyObject]
                        var userInfo: [String: String] = [:]
                        userInfo[NSLocalizedDescriptionKey] = errorDictionary["msg"] as? String
                        error = NSError(domain: "", code: errorDictionary["code"] as! Int, userInfo: userInfo)
                    }
                }
                
                completion(user: user, error: error)
            } else {
                print("Error: \(response.result.error)")
                completion(user: nil, error: response.result.error)
            }
        }
    }
}