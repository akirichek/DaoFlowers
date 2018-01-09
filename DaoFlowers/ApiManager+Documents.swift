//
//  ApiManager+Documents.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/15/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Alamofire

extension ApiManager: URLSessionDownloadDelegate {
    
    static func fetchInvoices(_ user: User, completion: @escaping (_ invoices: [Document]?, _ error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.Documents.Invoices
        var parameters: [String: AnyObject] = datesParams(monthCount: 5) as [String: AnyObject]
        parameters["withClaims"] = true as AnyObject
        
        Alamofire.request(url, method: .get, parameters: parameters, headers:["Authorization": user.token]).responseJSON { response in
            if response.result.isSuccess {
                var invoices: [Document] = []
                if let json = response.result.value as? [String: AnyObject]{
                    //print("JSON: \(json)")
                    let invoicesDictionaries = json["invoices"] as! [[String: AnyObject]]
                    let users = json["users"] as! [[String: AnyObject]]
                    
                    for invoiceDictionary in invoicesDictionaries {
                        var dictionary = invoiceDictionary
                        let userDictionary = users.first(where: { ($0["id"] as! Int) == (dictionary["userId"] as! Int) })!
                        let user = User(dictionary: userDictionary)
                        dictionary["label"] = user.name as AnyObject?
                        var invoice = Document(dictionary: dictionary)
                        
                        var claims: [Claim] = []
                        for claim in invoice.claims {
                            var newClaim = claim
                            newClaim.client = user
                            claims.append(newClaim)
                        }
                        
                        invoice.claims = claims
                        invoices.append(invoice)
                    }
                }
                completion(invoices, nil)
            } else {
                print("Error: \(response.result.error)")
                completion(nil, response.result.error as NSError?)
            }
        }
    }
    
    static func fetchInvoiceDetails(_ invoiceId: Int, clientId: Int, user: User, completion: @escaping (_ invoiceDetails: InvoiceDetails?, _ error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.Documents.Invoices + "/" + String(invoiceId) + "/" + String(clientId)
        let parameters = [
            "invoice_id": invoiceId,
            "client_id": clientId,
        ]

        Alamofire.request(url, method: .get, parameters: parameters, headers:["Authorization": user.token]).responseJSON { response in
            //print("Code: \(response.response?.statusCode)")
            if response.result.isSuccess {
                var invoiceDetails: InvoiceDetails?
                if let json = response.result.value {
                    print("\(#function) JSON: \(json)")
                    invoiceDetails = InvoiceDetails(dictionary: json as! [String : AnyObject])
                }
                completion(invoiceDetails, nil)
            } else {
                print("Error: \(response.result.error)")
                completion(nil, response.result.error as NSError?)
            }
        }
    }
    
    static func fetchPrealerts(_ user: User, completion: @escaping (_ prealerts: [Document]?, _ error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.Documents.Prealerts
        print(url)
        Alamofire.request(url, method: .get, parameters: datesParams(monthCount: 5), headers:["Authorization": user.token]).responseJSON { response in
            if response.result.isSuccess {
                var prealerts: [Document] = []
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    for prealertsDictionary in json as! [[String: AnyObject]] {
                        prealerts.append(Document(dictionary: prealertsDictionary))
                    }
                }
                completion(prealerts, nil)
            } else {
                print("Error: \(response.result.error)")
                completion(nil, response.result.error as NSError?)
            }
        }
    }
    
    static func datesParams(monthCount: Int) -> [String: String] {
        let dateNow = Date()
        var dateToComponents = Calendar.current.dateComponents([.day, .month, .year], from: dateNow)
        dateToComponents.calendar = Calendar.current
        let dateTo = "\(dateToComponents.year!)-\(dateToComponents.month!)-\(dateToComponents.day!)"
        dateToComponents.month! -= monthCount
        var dateFromComponents = Calendar.current.dateComponents([.day, .month, .year], from: dateToComponents.date!)
        dateFromComponents.calendar =  Calendar.current
        let dateFrom = "\(dateFromComponents.year!)-\(dateFromComponents.month!)-\(dateFromComponents.day!)"
        
        return [
            "date_from": dateFrom,
            "date_to": dateTo
        ]
    }
    
    func downloadDocument(_ document: Document, user: User, completion: @escaping (_ error: NSError?) -> ()) {
        self.downloadDocumentCompletion = completion
        self.document = document
        let backgroundSessionConfiguration = URLSessionConfiguration.background(withIdentifier: "backgroundSession")
        self.backgroundSession = Foundation.URLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        let url = URL(string: K.Api.BaseUrl + K.Api.Documents.Unzip + "?doc=\(document.zipFile)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(user.token, forHTTPHeaderField: "Authorization")
        downloadTask = backgroundSession.downloadTask(with: request)
        downloadTask.resume()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }

    // MARK: - URLSessionDownloadDelegate

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL){
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentDirectoryPath:String = path[0]
        let fileManager = FileManager()
        let destinationURLForFile = URL(fileURLWithPath: documentDirectoryPath + "/\(document.fileName).xls")
        do {
            try fileManager.moveItem(at: location, to: destinationURLForFile)
        } catch{
            print("An error occurred while moving file to destination url")
        }
    }
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?){
        downloadDocumentCompletion(error as? NSError)
        downloadTask = nil
        if (error != nil) {
            print(error?.localizedDescription)
        } else {
            print("The task finished transferring data successfully")
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
