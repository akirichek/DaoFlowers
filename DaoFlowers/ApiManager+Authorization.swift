//
//  ApiManager+Authorization.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/22/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Alamofire

extension ApiManager {
    
    static func loginWithUsername(_ username: String, andPassword password: String, completion: @escaping (_ user: User?, _ error: NSError?) -> ()) {
        let parameters: [String: AnyObject] = [
            "login": username as AnyObject,
            "password": password as AnyObject
        ]
        
        let url = K.Api.BaseUrl + K.Api.AuthorizePath
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON { response in
            if response.result.isSuccess {
                var user: User?
                var error: NSError?
                if let json = response.result.value as? [String: AnyObject] {
                    print("JSON: \(json)")
                    if let result = json["result"] as? [String: AnyObject] {
                        user = User(dictionary: result)
                    } else {
                        let errorDictionary = json["error"] as! [String: AnyObject]
                        var userInfo: [String: String] = [:]
                        userInfo[NSLocalizedDescriptionKey] = errorDictionary["msg"] as? String
                        error = NSError(domain: "", code: errorDictionary["code"] as! Int, userInfo: userInfo)
                    }
                }
                
                completion(user, error)
            } else {
                print("Error: \(response.result.error)")
                completion(nil, response.result.error as NSError?)
            }
        }
    }
}
