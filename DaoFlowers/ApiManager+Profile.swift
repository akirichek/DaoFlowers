//
//  ApiManager+Profile.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 12/1/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Alamofire

extension ApiManager {
    
    static func fetchProfileByUser(_ user: User, completion: @escaping (_ invoices: [Document]?, _ error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.Profile.Info + "/\(user.roleId)"
        let parameters: [String: AnyObject] = [
            "user_id": user.roleId as AnyObject,
            "lang_id": user.langId as AnyObject
        ]
        
        let headers: [String: String] = ["DaoUserAgentFlowers": "ios", "Authorization": user.token]
        Alamofire.request(url, method: .get, parameters: parameters, headers:headers).responseJSON { response in
            if response.result.isSuccess {
                let invoices: [Document] = []
                if let json = response.result.value {
                    print("JSON: \(json)")
//                    for invoicesDictionary in json as! [[String: AnyObject]] {
//                        invoices.append(Document(dictionary: invoicesDictionary))
//                    }
                }
                completion(invoices, nil)
            } else {
                print("Error: \(response.result.error)")
                completion(nil, response.result.error as NSError?)
            }
        }
    }
}
