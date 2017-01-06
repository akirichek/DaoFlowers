//
//  ApiManager+Support.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 12/1/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Alamofire

extension ApiManager {
    
    static func orderCallback(name: String?, company: String?, country: String?, city: String?, phone: String?, viber: String?, whatsApp: String?, skype: String?, email: String?, comment: String?, completion: @escaping (_ success: Bool, _ error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.Support.OrderCallback
        
        var parameters: [String: String] = [:]
        parameters["name"] = name
        parameters["company"] = company
        parameters["country"] = country
        parameters["city"] = city
        parameters["phone"] = phone
        parameters["viber"] = viber
        parameters["whatsApp"] = whatsApp
        parameters["skype"] = skype
        parameters["email"] = email
        parameters["comment"] = comment
        
        let headers: [String: String] = ["DaoUserAgentFlowers": "ios"]
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers:headers).response { response in
            print(response.request)
            print(response.response)
            print(response.data)
            print(response.error)
            if response.response?.statusCode == 200 {
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }
    
    static func sendComment(name: String?, company: String?, city: String?, workPhone: String?, mobilePhone: String?, email: String?, viber: String?, whatsApp: String?, skype: String?, comment: String, subject: String?, completion: @escaping (_ success: Bool, _ error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.Support.SendComment
        
        var parameters: [String: String] = [:]
        parameters["name"] = name
        parameters["company"] = company
        parameters["city"] = city
        parameters["workPhone"] = workPhone
        parameters["mobilePhone"] = mobilePhone
        parameters["email"] = email
        parameters["viber"] = viber
        parameters["whatsApp"] = whatsApp
        parameters["skype"] = skype
        parameters["comment"] = comment
        parameters["subject"] = subject
        
        let headers: [String: String] = ["DaoUserAgentFlowers": "ios"]
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { response in
            print(response.request)
            print(response.response)
            print(response.data)
            print(response.error)
            if response.response?.statusCode == 200 {
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }
    
    static func sendSignUpRequest(name: String, country: String, city: String, phone: String?, viber: String?, whatsApp: String?, skype: String?, email: String, aboutCompany: String?, completion: @escaping (_ success: Bool, _ error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.Support.SignUpRequest
        
        var parameters: [String: String] = [:]
        parameters["name"] = name
        parameters["country"] = country
        parameters["city"] = city
        parameters["phone"] = phone
        parameters["viber"] = viber
        parameters["whatsApp"] = whatsApp
        parameters["skype"] = skype
        parameters["email"] = email
        parameters["aboutCompany"] = aboutCompany
        
        let headers: [String: String] = ["DaoUserAgentFlowers": "ios"]
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response { response in
            print(response.request)
            print(response.response)
            print(response.data)
            print(response.error)
            if response.response?.statusCode == 200 {
                completion(true, nil)
            } else {
                completion(false, nil)
            }
        }
    }
}
