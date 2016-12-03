//
//  ApiManager+Documents.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/15/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Alamofire

extension ApiManager: NSURLSessionDownloadDelegate {
    
    static func fetchInvoices(user: User, completion: (invoices: [Document]?, error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.Documents.Invoices
        Alamofire.request(.GET, url,  parameters: datesParams(), headers:["Authorization": user.token]).responseJSON { response in
            if response.result.isSuccess {
                var invoices: [Document] = []
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    for invoicesDictionary in json as! [[String: AnyObject]] {
                        invoices.append(Document(dictionary: invoicesDictionary))
                    }
                }
                completion(invoices: invoices, error: nil)
            } else {
                print("Error: \(response.result.error)")
                completion(invoices: nil, error: response.result.error)
            }
        }
    }
    
    static func fetchInvoiceDetails(invoice: Document, user: User, completion: (invoiceDetails: InvoiceDetails?, error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.Documents.Invoices + "/" + String(invoice.id) + "/" + String(invoice.clientId)
        let parameters = [
            "invoice_id": invoice.id,
            "client_id": invoice.clientId,
        ]
        Alamofire.request(.GET, url,  parameters: parameters, headers:["Authorization": user.token]).responseJSON { response in
            if response.result.isSuccess {
                var invoiceDetails: InvoiceDetails?
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    invoiceDetails = InvoiceDetails(dictionary: json as! [String : AnyObject])
                }
                completion(invoiceDetails: invoiceDetails, error: nil)
            } else {
                print("Error: \(response.result.error)")
                completion(invoiceDetails: nil, error: response.result.error)
            }
        }
    }
    
    static func fetchPrealerts(user: User, completion: (prealerts: [Document]?, error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.Documents.Prealerts
        Alamofire.request(.GET, url,  parameters: datesParams(), headers:["Authorization": user.token]).responseJSON { response in
            if response.result.isSuccess {
                var prealerts: [Document] = []
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    for prealertsDictionary in json as! [[String: AnyObject]] {
                        prealerts.append(Document(dictionary: prealertsDictionary))
                    }
                }
                completion(prealerts: prealerts, error: nil)
            } else {
                print("Error: \(response.result.error)")
                completion(prealerts: nil, error: response.result.error)
            }
        }
    }
    
    static func datesParams() -> [String: AnyObject] {
        let dateNow = NSDate()
        let dateToComponents = NSCalendar.currentCalendar().components([.Day, .Month, .Year],
                                                                       fromDate: dateNow)
        dateToComponents.calendar =  NSCalendar.currentCalendar()
        let dateTo = "\(dateToComponents.year)-\(dateToComponents.month)-\(dateToComponents.day)"
        dateToComponents.month -= 3
        
        let dateFromComponents = NSCalendar.currentCalendar().components([.Day, .Month, .Year],
                                                                         fromDate: dateToComponents.date!)
        dateFromComponents.calendar =  NSCalendar.currentCalendar()
        let dateFrom = "\(dateFromComponents.year)-\(dateFromComponents.month)-\(dateFromComponents.day)"
        
        return [
            "date_from": dateFrom,
            "date_to": dateTo
        ]
    }

    func downloadDocument(document: Document, user: User, completion: (error: NSError?) -> ()) {
        self.downloadDocumentCompletion = completion
        self.document = document
        let backgroundSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("backgroundSession")
        self.backgroundSession = NSURLSession(configuration: backgroundSessionConfiguration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        let url = NSURL(string: K.Api.BaseUrl + K.Api.Documents.Unzip + "?doc=\(document.zipFile)")!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "GET"
        request.setValue(user.token, forHTTPHeaderField: "Authorization")
        downloadTask = backgroundSession.downloadTaskWithRequest(request)
        downloadTask.resume()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }

    // MARK: - NSURLSessionDownloadDelegate

    func URLSession(session: NSURLSession,
                    downloadTask: NSURLSessionDownloadTask,
                    didFinishDownloadingToURL location: NSURL){
        let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentDirectoryPath:String = path[0]
        let fileManager = NSFileManager()
        let destinationURLForFile = NSURL(fileURLWithPath: documentDirectoryPath.stringByAppendingString("/\(document.fileName).xls"))
        do {
            try fileManager.moveItemAtURL(location, toURL: destinationURLForFile)
        } catch{
            print("An error occurred while moving file to destination url")
        }
    }
    
    func URLSession(session: NSURLSession,
                    task: NSURLSessionTask,
                    didCompleteWithError error: NSError?){
        downloadDocumentCompletion(error: error)
        downloadTask = nil
        if (error != nil) {
            print(error?.description)
        } else {
            print("The task finished transferring data successfully")
        }
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}
