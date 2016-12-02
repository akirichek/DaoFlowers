//
//  ApiManager+Support.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 12/1/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Alamofire

extension ApiManager {
    
    static func orderCallback(name name: String, company: String, country: String, city: String, phone: String?, viber: String?, whatsApp: String?, skype: String?, email: String?, comment: String?, completion: (success: Bool, error: NSError?) -> ()) {
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
        Alamofire.request(.POST, url,  parameters: parameters, headers:headers, encoding: .JSON).response { (request, response, data, error) in
            print(request)
            print(response)
            print(data)
            print(error)
            if response?.statusCode == 200 {
                completion(success: true, error: nil)
            } else {
                completion(success: false, error: nil)
            }
        }
    }
    
    static func sendComment(name name: String, company: String, city: String, workPhone: String, mobilePhone: String, email: String, viber: String?, whatsApp: String?, skype: String?, comment: String, subject: String, completion: (success: Bool, error: NSError?) -> ()) {
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
        Alamofire.request(.POST, url,  parameters: parameters, headers:headers, encoding: .JSON).response { (request, response, data, error) in
            print(request)
            print(response)
            print(data)
            print(error)
            if response?.statusCode == 200 {
                completion(success: true, error: nil)
            } else {
                completion(success: false, error: nil)
            }
        }
    }
    
    static func sendSignUpRequest(name name: String, country: String, city: String, phone: String?, viber: String?, whatsApp: String?, skype: String?, email: String, aboutCompany: String?, completion: (success: Bool, error: NSError?) -> ()) {
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
        Alamofire.request(.POST, url,  parameters: parameters, headers:headers, encoding: .JSON).response { (request, response, data, error) in
            print(request)
            print(response)
            print(data)
            print(error)
            if response?.statusCode == 200 {
                completion(success: true, error: nil)
            } else {
                completion(success: false, error: nil)
            }
        }
    }
}
