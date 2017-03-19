//
//  Employee.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 1/24/17.
//  Copyright © 2017 Dao Flowers. All rights reserved.
//

import Foundation

struct Employee {
    let kIdNewUser = 0;
    
    var id: Int!
    var name: String!
    var postIds: [Int]!
    var contacts: [Contact]!
    var reportIds: [Int]!
    var reportsMode: ReportsMode!
    var action: Action = Action.add
    
    init(dictionary: [String: AnyObject]) {
        id = dictionary["id"] as! Int
        name = dictionary["name"] as! String
        action = Action.change
    
        contacts = []
        if let contactsDictionaries = dictionary["contacts"] as? [[String: AnyObject]] {
            for contactDictionary in contactsDictionaries {
                let contact = Contact(dictionary: contactDictionary)
                contacts.append(contact)
            }
        }
        
        postIds = dictionary["postIds"] as! [Int]
        
        if let reportsDictionary = dictionary["reports"] as? [String: AnyObject] {
            reportsMode = ReportsMode(rawValue: reportsDictionary["mode"] as! Int)!
            reportIds = reportsDictionary["reportIds"] as! [Int]
        }
    }
    
    init() {

    }
    
    func toDictionary() -> [String: AnyObject] {
        var dictionary: [String: AnyObject] = [:]
        dictionary["action"] = action.rawValue as AnyObject?
        
        if id != nil {
            dictionary["id"] = id as AnyObject?
        }
        
        if name != nil {
            dictionary["fio"] = name as AnyObject?
        }
        
        if contacts != nil {
            var contactsDictionary: [String: String] = [:]
            
            for contact in contacts {
                contactsDictionary[String(contact.type.rawValue)] = contact.value
            }
            
            dictionary["contacts"] = contactsDictionary as AnyObject?
        }
        
        if postIds != nil {
            dictionary["postIds"] = postIds as AnyObject?
        }
        
        if reportIds != nil {
            var reportsDictionary: [String: AnyObject] = [:]
            if reportsMode != nil {
                reportsDictionary["mode"] = reportsMode.rawValue as AnyObject?
            }
            
            reportsDictionary["reportIds"] = reportIds as AnyObject?
            
            dictionary["reports"] = reportsDictionary as AnyObject?
        }
        
        return dictionary
    }
    
    struct Contact {
        var type: ContactType
        var value: String
        
        init(dictionary: [String: AnyObject]) {
            type = ContactType(rawValue: dictionary["typeId"] as! Int)!
            value = dictionary["value"] as! String
        }
        
        init(type: ContactType, value: String) {
            self.type = type
            self.value = value
        }
        
        func toDictionary() -> [String: AnyObject] {
            var dictionary: [String: AnyObject] = [:]
            dictionary["type"] = type.rawValue as AnyObject?
            dictionary["value"] = value as AnyObject?
            
            return dictionary
        }
        
        enum ContactType: Int {
            case email = 10
            case isq = 11
            case skype = 13
            case office = 14
            case fax = 15
            case mobile = 16
            case viber = 20
        }
    }
    
    func emails() -> [String] {
        var emails: [String] = []
        for contact in contacts {
            if contact.type == .email {
                emails = contact.value.components(separatedBy: ",")
                break
            }
        }
        return emails
    }
    
    func phonesMessengers() -> [Employee.Contact] {
        var phonesMessengers: [Employee.Contact] = []
        
        if let index = contacts.index(where: { $0.type == .mobile}) {
            phonesMessengers.append(contacts[index])
        }
        if let index = contacts.index(where: { $0.type == .office}) {
            phonesMessengers.append(contacts[index])
        }
        if let index = contacts.index(where: { $0.type == .fax}) {
            phonesMessengers.append(contacts[index])
        }
        if let index = contacts.index(where: { $0.type == .viber}) {
            phonesMessengers.append(contacts[index])
        }
        if let index = contacts.index(where: { $0.type == .skype}) {
            phonesMessengers.append(contacts[index])
        }
        if let index = contacts.index(where: { $0.type == .isq}) {
            phonesMessengers.append(contacts[index])
        }
        
        return phonesMessengers
    }
    
    enum Action: String {
        case delete = "delete"
        case add = "add"
        case change = "change"
    }
    
    enum ReportsMode: Int {
        case allowAll = 1
        case blockAll = -1
        case defaultMode = 0
    }
    
    static func differcenceBetweenEmployees(_ lhs: Employee, rhs: Employee) -> Employee {
        var result = Employee()

        result.id = rhs.id
        result.postIds = rhs.postIds
        result.reportIds = rhs.reportIds
        result.reportsMode = rhs.reportsMode
        result.action = rhs.action
        
        if lhs.name != rhs.name {
            result.name = rhs.name
        }
        
        var contacts: [Contact] = []
        
        for rhsContact in rhs.contacts {
            if let index = lhs.contacts.index(where: { $0.type == rhsContact.type }) {
                let lhsContact = lhs.contacts[index]
                if lhsContact.value != rhsContact.value {
                    contacts.append(rhsContact)
                }
            } else {
                contacts.append(rhsContact)
            }
        }
        
        if contacts.count > 0 {
            result.contacts = contacts
        }
        
        return result
    }
}
