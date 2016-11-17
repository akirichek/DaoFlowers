//
//  ApiManager+Documents.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/15/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Alamofire

extension ApiManager {
    
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
                    print("JSON: \(json)")
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
    
    static func downloadDocument(document: Document, user: User, completion: (prealerts: [Document]?, error: NSError?) -> ()) {
        let parameters = [
            "doc": document.zipFile
        ]
        let url = K.Api.BaseUrl + K.Api.Documents.Unzip
        print(url)
        let destination = Request.suggestedDownloadDestination()
        Alamofire.download(.GET, url, parameters: parameters,  headers:["Authorization": user.token], destination: destination).response { request, response, data, error in
            print(request)
            print(response)
            print(data)
            print(error)
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
}
