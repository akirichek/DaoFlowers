//
//  ApiManager+Claims.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 4/12/17.
//  Copyright © 2017 Dao Flowers. All rights reserved.
//

import Alamofire

extension ApiManager {
    
    static func fetchClaims(_ user: User, fromDate: Date, toDate: Date, completion: @escaping (_ claims: [Claim]?, _ users: [User]?, _ error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.Documents.Claims
        
        let parameters =  [
            "date_from": Utils.dateToString(fromDate),
            "date_to": Utils.dateToString(toDate)
        ]
        
        Alamofire.request(url, method: .get, parameters: parameters, headers:["Authorization": user.token]).responseJSON { response in
            if response.result.isSuccess {
                var claims: [Claim] = []
                var users: [User] = []
                if let json = response.result.value as? [String: AnyObject] {
                    print("JSON: \(json)")
                                        
                    if let usersDictionaries = json["users"] as? [[String: AnyObject]] {
                        for userDictionary in usersDictionaries {
                            let user = User(dictionary: userDictionary)
                            users.append(user)
                        }
                    }

                    var plantations: [Plantation] = []
                    
                    if let plantationsDictionaries = json["plantations"] as? [[String: AnyObject]] {
                        for plantationDictionary in plantationsDictionaries {
                            let plantation = Plantation(dictionary: plantationDictionary)
                            plantations.append(plantation)
                        }
                    }
                    
                    if let claimsDictionaries = json["claims"] as? [[String: AnyObject]] {
                        for claimDictionary in claimsDictionaries {
                            var claim = Claim(dictionary: claimDictionary)
                            let userIndex = users.index(where: { $0.id == claim.userId })!
                            claim.user = users[userIndex]
                            if let plantationIndex = plantations.index(where: { $0.id == claim.plantationId }) {
                                claim.plantation = plantations[plantationIndex]
                            }
                            
                            claims.append(claim)
                        }
                    }
                }
                completion(claims, users, nil)
            } else {
                print("Error: \(response.result.error)")
                completion(nil, nil, response.result.error as NSError?)
            }
        }
    }
    
    static func fetchClaimSubjects(_ user: User, completion: @escaping (_ claimsSubjects: [Claim.Subject]?, _ error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.Documents.ClaimSubjects
        
        let parameters: [String: AnyObject] = [
            "lang_id": LanguageManager.currentLanguage().id() as AnyObject
        ]
        
        Alamofire.request(url, method: .get, parameters: parameters, headers:["Authorization": user.token]).responseJSON { response in
            if response.result.isSuccess {
                var claimsSubjects: [Claim.Subject] = []
                if let json = response.result.value as? [[String: AnyObject]] {
                    //print("JSON: \(json)")

                    for claimSubjectDictionary in json {
                        let claimSubject = Claim.Subject(dictionary: claimSubjectDictionary)
                        claimsSubjects.append(claimSubject)
                    }
                }
                completion(claimsSubjects, nil)
            } else {
                print("Error: \(response.result.error)")
                completion(nil, response.result.error as NSError?)
            }
        }
    }
    
    static func fetchClaimDetailsForClaim(_ claim: Claim, user: User, completion: @escaping (_ claim: Claim?, _ invoice: Document?, _ invoiceDetails: InvoiceDetails?, _ invoiceDetailsHead: InvoiceDetails.Head?,  _ error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.Documents.ClaimDetails
        
        let parameters =  [
            "claim_id": claim.id as AnyObject
        ]
        
        Alamofire.request(url, method: .get, parameters: parameters, headers:["Authorization": user.token]).responseJSON { response in
            print("Code: \(response.response?.statusCode)")
            if response.result.isSuccess {
                var claim: Claim?
                var invoice: Document?
                var invoiceDetails: InvoiceDetails?
                var invoiceDetailsHead: InvoiceDetails.Head?
                if let json = response.result.value as? [String: AnyObject] {
                    print("JSON: \(json)")
                    
                    var users: [User] = []
                    if let usersDictionaries = json["users"] as? [[String: AnyObject]] {
                        for userDictionary in usersDictionaries {
                            let user = User(dictionary: userDictionary)
                            users.append(user)
                        }
                    }
                    
                    var invoiceDictionary = json["invoice"] as! [String: AnyObject]
                    let user = users.first(where: { $0.id == (invoiceDictionary["userId"] as! Int) })!
                    invoiceDictionary["label"] = user.name as AnyObject?
                    invoice = Document(dictionary: invoiceDictionary)
                    invoiceDetailsHead = InvoiceDetails.Head(dictionary: json["invoiceDetailsHead"] as! [String: AnyObject])
                    invoiceDetails = InvoiceDetails(dictionary: json)
                    claim = Claim(dictionary: json)
                    claim?.userId = invoiceDictionary["userId"] as! Int
                    claim?.user = user
                }
                completion(claim, invoice, invoiceDetails, invoiceDetailsHead, nil)
            } else {
                print("Error: \(response.result.error)")
                completion(nil, nil, nil, nil, response.result.error as NSError?)
            }
        }
    }
    
    static func saveClaim(_ claim: Claim, user: User, completion: @escaping ( _ error: NSError?) -> ()) {
        var url = K.Api.BaseUrl + K.Api.Documents.ClaimDetails
        
        if claim.id != nil {
            url += "?force_timestamp=\(Int(Date().timeIntervalSince1970 * 1000.0))"
        }
        
        let jsonData = try! JSONSerialization.data(withJSONObject: claim.toDictionary(), options: .prettyPrinted)

        print(String(data: jsonData, encoding: .utf8)!)

        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(jsonData, withName: "data", fileName: "data", mimeType: "application/json")
            for photo in claim.photos {
                if photo.id == nil {
                    multipartFormData.append(UIImagePNGRepresentation(photo.image!)!,
                                             withName: "img",
                                             fileName: photo.name!,
                                             mimeType: "image/png")
                }
            }
        }, to: url, method: .post, headers: ["Authorization": user.token]) { (encodingResult) in
            switch encodingResult {
            case .success(let upload, _ , _):
                upload.responseString(completionHandler: { (response) in
                    print("reponse: \(String(data: response.data!, encoding: String.Encoding.utf8)!)")
                    //response.data
                //print("reponse1: \(
                })
                //print("reponse: \(String(data: upload.response., encoding: String.Encoding.utf8)!)")
                
                
                upload.responseJSON { response in
                    print("Code: \(response.response?.statusCode)")
                    if response.result.isSuccess {
                        if let json = response.result.value as? [String: AnyObject] {
                            print("JSON: \(json)")

                        }
                        completion(nil)
                    } else {
                        print("Error: \(response.result.error)")
                        completion(response.result.error as NSError?)
                    }
                }
            case .failure(let encodingError):
                print("encodingError: \(encodingError)")
            }
        }
    }
    
    static func removeClaim(_ claim: Claim, user: User, completion: @escaping ( _ success: Bool) -> ()) {
        let url = K.Api.BaseUrl + K.Api.Documents.ClaimDetails
        
        let parameters =  [
            "claim_id": claim.id as AnyObject,
            "force_timestamp": Int(Date().timeIntervalSince1970 * 1000.0) as AnyObject
        ]
        
        print(parameters)
        
        Alamofire.request(url, method: .delete, parameters: parameters, headers:["Authorization": user.token]).responseJSON { response in
            print("Code: \(response.response?.statusCode)")
            if response.response?.statusCode == 200 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    static func isClaimEditingAllowed(_ claim: Claim, user: User, completion: @escaping ( _ error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.Documents.IsClaimEditingAllowed
        
        let timestamp = Int(Date().timeIntervalSince1970 * 1000.0)
        
        let parameters =  [
            "claim_id": claim.id as AnyObject,
            "timestamp": timestamp as AnyObject
        ]
        
        print(parameters)
        
        Alamofire.request(url, method: .get, parameters: parameters, headers:["Authorization": user.token]).responseJSON { response in
            print("Code: \(response.response?.statusCode)")
            if response.result.isSuccess {
                if let json = response.result.value as? [String: AnyObject] {
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
