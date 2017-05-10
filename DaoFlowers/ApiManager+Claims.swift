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
                    
                    let usersDictionaries = json["users"] as! [[String: AnyObject]]
                    var invoiceDictionary = json["invoice"] as! [String: AnyObject]
                    let userDictionary = usersDictionaries.first(where: { ($0["id"] as! Int) == (invoiceDictionary["userId"] as! Int) })!
                    invoiceDictionary["label"] = userDictionary["name"]
                    invoice = Document(dictionary: invoiceDictionary)
                    invoiceDetailsHead = InvoiceDetails.Head(dictionary: json["invoiceDetailsHead"] as! [String: AnyObject])
                    invoiceDetails = InvoiceDetails(dictionary: json)
                    claim = Claim(dictionary: json)
                    claim?.userId = invoiceDictionary["userId"] as! Int
                }
                completion(claim, invoice, invoiceDetails, invoiceDetailsHead, nil)
            } else {
                print("Error: \(response.result.error)")
                completion(nil, nil, nil, nil, response.result.error as NSError?)
            }
        }
    }
    
    static func saveClaim(_ claim: Claim, user: User, completion: @escaping ( _ error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.Documents.ClaimDetails
//        var parameters: [String: AnyObject] = claim.toDictionary()
//        parameters["claimInvoiceId"] = invoiceDetailsHead.invoiceId as AnyObject
//        parameters["claimInvoiceHeadId"] = invoiceDetailsHead.id as AnyObject
//        
//        print(url)
//        print(parameters)
//        
//        Alamofire.request(url, method: .post, parameters: parameters, headers:["Authorization": user.token]).responseJSON { response in
//            print("Code: \(response.response?.statusCode)")
//            if response.result.isSuccess {
//                if let json = response.result.value as? [String: AnyObject] {
//                    print("JSON: \(json)")
//
//                }
//                completion(nil)
//            } else {
//                print("Error: \(response.result.error)")
//                completion(response.result.error as NSError?)
//            }
//        }
        

        
        var claimInvoiceRowJson = ""
        for i in 0..<claim.invoceRows.count {
            let claimInvoiceRow = claim.invoceRows[i]
            claimInvoiceRowJson += "{\"claimPerStemPrice\": \(claimInvoiceRow.claimPerStemPrice!), \"claimStems\": \(claimInvoiceRow.claimStems!), \"rowId\": \(claimInvoiceRow.rowId)}"
            
            if i < claim.invoceRows.count - 1 {
                claimInvoiceRowJson += ", "
            }
        }
        
        var photosJson = ""
        for i in 0..<claim.photos.count {
            let photo = claim.photos[i]
            if let photoId = photo.id {
                photosJson += "{\"photoId\": \"\(photoId)\"}"
            } else {
                photosJson += "{\"fileName\": \"\(photo.name!)\"}"
            }
            
            if i < claim.photos.count - 1 {
                photosJson += ", "
            }
        }
        
        let json = "{\"photos\": [\(photosJson)], \"status\": 2, \"claimInvoiceId\": \(invoiceDetailsHead.invoiceId), \"claimSubjectId\": \(claim.subjectId!), \"clientId\": \(claim.userId!), \"claimInvoiceHeadId\": \(invoiceDetailsHead.id), \"claimComment\": \"\(claim.comment)\", \"claimInvoiceRows\": [\(claimInvoiceRowJson)]}"
        
        print(json)
        
//        do {
//            let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
//            // here "jsonData" is the dictionary encoded in JSON data
//            
//            let decoded = try JSONSerialization.jsonObject(with: jsonData, options: [])
//            // here "decoded" is of type `Any`, decoded from JSON data
//            
//            // you can now cast it with the right type
//            if let dictFromJSON = decoded as? [String:String] {
//                print(dictFromJSON)
//            }
//        } catch {
//            print(error.localizedDescription)
//        }
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(json.data(using: .utf8)!, withName: "data", fileName: "data", mimeType: "application/json")
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
}
