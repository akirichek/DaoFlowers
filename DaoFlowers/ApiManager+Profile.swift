//
//  ApiManager+Profile.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 12/1/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Alamofire

extension ApiManager {
    
    static func fetchProfileByUser(user: User, completion: (invoices: [Document]?, error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.Profile.Info + "/\(user.roleId)"
        let parameters: [String: AnyObject] = [
            "user_id": user.roleId,
            "lang_id": user.langId
        ]
        
        let headers: [String: String] = ["DaoUserAgentFlowers": "ios", "Authorization": user.token]
        Alamofire.request(.GET, url, parameters: parameters, headers:headers).responseJSON { response in
            if response.result.isSuccess {
                var invoices: [Document] = []
                if let json = response.result.value {
                    print("JSON: \(json)")
//                    for invoicesDictionary in json as! [[String: AnyObject]] {
//                        invoices.append(Document(dictionary: invoicesDictionary))
//                    }
                }
                completion(invoices: invoices, error: nil)
            } else {
                print("Error: \(response.result.error)")
                completion(invoices: nil, error: response.result.error)
            }
        }
    }
}
