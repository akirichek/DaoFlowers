//
//  ApiManager+Profile.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 12/1/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Alamofire

extension ApiManager {
    
    static func fetchCustomerByUser(_ user: User, completion: @escaping (_ customer: Customer?, _ error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.Profile.Customer + "/\(user.id!)"
        let parameters: [String: AnyObject] = [
            "user_id": user.id as AnyObject,
            "lang_id": LanguageManager.currentLanguage().id() as AnyObject
        ]
        
        let headers: [String: String] = ["DaoUserAgentFlowers": "ios", "Authorization": user.token]
        Alamofire.request(url, method: .get, parameters: parameters, headers:headers).responseJSON { response in
            if response.result.isSuccess {
                var customer: Customer? = nil
                if let json = response.result.value {
                    print("JSON: \(json)")
                    if let customerDictionary = json as? [String: AnyObject] {
                        customer = Customer(dictionary: customerDictionary)
                    }
                }
                completion(customer, nil)
            } else {
                print("Error: \(response.result.error)")
                completion(nil, response.result.error as NSError?)
            }
        }
    }
    
    static func saveCustomer(customer: Customer, byUser user: User, completion: @escaping (_ customer: Customer?, _ error: NSError?) -> ()) {
        
        let url = K.Api.BaseUrl + K.Api.Profile.Customer + "/\(user.id!)"
        var parameters: [String: AnyObject] = [
            "user_id": user.id as AnyObject,
            "lang_id": LanguageManager.currentLanguage().id() as AnyObject
            
        ]
        
        let customerDictionary = customer.toDictionary()
        
        for key in customerDictionary.keys {
            parameters[key] = customerDictionary[key]
        }
        
        print(url)
        print(parameters)
        
        let headers: [String: String] = ["DaoUserAgentFlowers": "ios", "Authorization": user.token]
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers:headers).responseJSON { response in
            print("Code: \(response.response?.statusCode)")
            if response.result.isSuccess {
                if let json = response.result.value {
                    print("JSON: \(json)")
                }
                completion(customer, nil)
            } else {
                print("Error: \(response.result.error)")
                completion(nil, response.result.error as NSError?)
            }
        }
    }
    
    static func fetchEmployeesParamsWithUser(_ user: User, completion: @escaping (_ posts: [Post]?, _ reports: [Report]?, _ error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.Profile.EmployeesParams
        let parameters: [String: AnyObject] = [
            "user_id": user.id as AnyObject,
            "lang_id": LanguageManager.currentLanguage().id() as AnyObject
        ]
        
        let headers: [String: String] = ["DaoUserAgentFlowers": "ios", "Authorization": user.token]
        Alamofire.request(url, method: .get, parameters: parameters, headers:headers).responseJSON { response in
            if response.result.isSuccess {
                var posts: [Post] = []
                var reports: [Report] = []
                if let json = response.result.value as? [String: AnyObject]{
                    print("JSON: \(json)")
                    for postDictionary in json["posts"] as! [[String: AnyObject]] {
                        let post = Post(dictionary: postDictionary)
                        posts.append(post)
                    }
                    for reportDictionary in json["reports"] as! [[String: AnyObject]] {
                        let report = Report(dictionary: reportDictionary)
                        reports.append(report)
                    }
                }
                completion(posts, reports, nil)
            } else {
                print("Error: \(response.result.error)")
                completion(nil, nil, response.result.error as NSError?)
            }
        }
    }
    
    static func fetchUserAndChildrenWithUser(_ user: User, completion: @escaping (_ user: User?, _ error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.Profile.UserAndChildren
        let headers: [String: String] = ["DaoUserAgentFlowers": "ios", "Authorization": user.token]
        Alamofire.request(url, method: .get, headers:headers).responseJSON { response in
            if response.result.isSuccess {
                if let json = response.result.value {
                    print("JSON: \(json)")
                    if let resultDictionary = json as? [String: AnyObject] {
                        if let userDictionary = resultDictionary["user"] as? [String: AnyObject] {
                            user.id = userDictionary["id"] as? Int
                        }
                        for slaveDictionary in resultDictionary["slaves"] as! [[String: AnyObject]] {
                            let slave = User(dictionary: slaveDictionary)
                            user.addSlave(slave: slave)
                        }
                    }
                }
                completion(user, nil)
            } else {
                print("Error: \(response.result.error)")
                completion(nil, response.result.error as NSError?)
            }
        }
    }
    
    static func removeChangesWithUser(_ user: User, completion: @escaping (_ error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + String(format: K.Api.Profile.RemoveChanges, user.id!)
        let headers: [String: String] = ["DaoUserAgentFlowers": "ios", "Authorization": user.token]
        Alamofire.request(url, method: .post, headers:headers).responseJSON { response in
            if response.result.isSuccess {
                if let json = response.result.value {
                    print("JSON: \(json)")
                }
                completion(nil)
            } else {
                print("Error: \(response.result.error)")
                completion(response.result.error as NSError?)
            }
        }
    }
}
