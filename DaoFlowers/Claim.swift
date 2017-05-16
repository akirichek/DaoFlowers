//
//  Claim.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 4/17/17.
//  Copyright © 2017 Dao Flowers. All rights reserved.
//

import Foundation
import CoreData

struct Claim {
    var id: Int?
    var photos: [Photo] = []
    var plantationId: Int = 0
    var status: Status
    var stems: Int = 0
    var sum: Double = 0
    var date: Date
    var userId: Int!
    var comment: String = ""
    var plantation: Plantation?
    var user: User!
    var subjectId: Int?
    var invoiceRows: [InvoiceRow] = []
    var objectID: NSManagedObjectID?
    var invoiceId: Int
    var invoiceHeadId: Int
    
    init(user: User, date: Date, invoiceId: Int, invoiceHeadId: Int) {
        self.status = .New
        self.date = date
        self.user = user
        self.userId = user.id
        self.invoiceId = invoiceId
        self.invoiceHeadId = invoiceHeadId
    }
    
    init(dictionary: [String: AnyObject]) {
        if let comment = dictionary["comment"] as? String {
            self.comment = comment
        } else {
            self.comment = dictionary["claimComment"] as! String
        }
        
        id = dictionary["id"] as? Int
        
        if let photoUrls = dictionary["photoUrls"] as? [String] {
            for photoUrl in photoUrls {
                photos.append(Photo(url: photoUrl))
            }
        }
        
        if let photosDictionaries = dictionary["photos"] as? [[String: AnyObject]] {
            for photoDictionary in photosDictionaries {
                photos.append(Photo(dictionary: photoDictionary))
            }
        }
        
        if let plantationId = dictionary["plantationId"] as? Int {
            self.plantationId = plantationId
        }
        if let status = Status(rawValue: dictionary["status"] as! Int) {
            self.status = status
        } else {
            self.status = .InProcess
        }
        if let stems = dictionary["stems"] as? Int {
            self.stems = stems
        }
        if let sum = dictionary["sum"] as? Double {
            self.sum = sum
        }
        
        var unixDate: Int! =  dictionary["unixDate"] as? Int
        if unixDate == nil {
            unixDate = dictionary["timestamp"] as! Int
        }
        date = Date(timeIntervalSince1970: TimeInterval(unixDate/1000))
        if let userId = dictionary["userId"] as? Int {
            self.userId = userId
        }
        
        subjectId = dictionary["claimSubjectId"] as? Int
        
        if let claimInvoiceRowsDictionaries = dictionary["claimInvoiceRows"] as? [[String: AnyObject]] {
            for claimInvoiceRowDictionary in claimInvoiceRowsDictionaries {
                let invoceRow = InvoiceRow(dictionary: claimInvoiceRowDictionary)
                invoiceRows.append(invoceRow)
            }
        }
        
        if let invoiceDetailsHeadDictionary = dictionary["invoiceDetailsHead"] as? [String: AnyObject] {
            invoiceId = invoiceDetailsHeadDictionary["invoiceId"] as! Int
            invoiceHeadId = invoiceDetailsHeadDictionary["id"] as! Int
        } else {
            invoiceId = dictionary["invoiceId"] as! Int
            invoiceHeadId = dictionary["invoiceHeadId"] as! Int
        }
    }
    
    func toDictionary() -> [String: AnyObject] {
        var dictionary: [String: AnyObject] = [:]
        dictionary["status"] = 2 as AnyObject
        dictionary["claimInvoiceId"] = invoiceId as AnyObject
        dictionary["claimSubjectId"] = subjectId as AnyObject
        dictionary["clientId"] = userId as AnyObject
        dictionary["claimInvoiceHeadId"] = invoiceHeadId as AnyObject
        dictionary["claimComment"] = comment as AnyObject
        
        var claimInvoiceRows: [[String: AnyObject]] = []
        for invoceRows in invoiceRows {
            claimInvoiceRows.append(invoceRows.toDictionary())
        }
        
        dictionary["claimInvoiceRows"] = claimInvoiceRows as AnyObject
        
        var photosDictionaries: [[String: AnyObject]] = []
        for photo in photos {
            var photoDictionary: [String: AnyObject] = [:]
            if let photoId = photo.id {
                photoDictionary["photoId"] = photoId as AnyObject
            } else {
                photoDictionary["fileName"] = photo.name as AnyObject
            }
            photosDictionaries.append(photoDictionary)
        }
        
        dictionary["photos"] = photosDictionaries as AnyObject
        
        if let id = id {
            dictionary["claimId"] = id as AnyObject
        }
    
        return dictionary
    }
    
    enum Status: Int {
        case New = 1
        case Sent = 2
        case InProcess = 3
        case Confirmed = 4
        case LocalDraft = 5
        
        func toString() -> String {
            var string = ""
            
            switch self {
            case .New:
                string = "NEW CLAIM"
            case .Sent:
                string = "SENT"
            case .InProcess:
                string = "IN PROCESS"
            case .Confirmed:
                string = "CONFIRMED"
            case .LocalDraft:
                string = "LOCAL DRAFT"
            }
            
            return string
        }
    }
    
    struct Subject {
        var id: Int
        var name: String
        
        init(dictionary: [String: AnyObject]) {
            id = dictionary["id"] as! Int
            name = dictionary["name"] as! String
        }
    }
    
    func stemsCount() -> Int {
        var count = 0
        for claimInvoiceRow in invoiceRows {
            count += claimInvoiceRow.claimStems!
        }
        return count
    }
    
    func calculateSum() -> Double {
        var sum: Double = 0.0
        for invoiceRow in invoiceRows {
            sum += invoiceRow.claimPerStemPrice! * Double(invoiceRow.claimStems!)
        }
        
        return sum
    }
    
    struct InvoiceRow {
        var claimPerStemPrice: Double?
        var claimStems: Int?
        var rowId: Int
        
        init(dictionary: [String: AnyObject]) {
            claimPerStemPrice = dictionary["claimPerStemPrice"] as? Double
            claimStems = dictionary["claimStems"] as? Int
            rowId = dictionary["rowId"] as! Int
        }
        
        init(rowId: Int, claimPerStemPrice: Double? = nil, claimStems: Int? = nil) {
            self.rowId = rowId
            self.claimPerStemPrice = claimPerStemPrice
            self.claimStems = claimStems
        }
        
        func toDictionary() -> [String: AnyObject] {
            var dictionary: [String: AnyObject] = [:]
            dictionary["claimPerStemPrice"] = claimPerStemPrice as AnyObject?
            dictionary["claimStems"] = claimStems as AnyObject?
            dictionary["rowId"] = rowId as AnyObject?
            return dictionary
        }
    }
}
