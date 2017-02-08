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
    
    var id: Int
    var name: String
    var posts: [Post] = []
    var contacts: [Contact] = []
    var reports: [Report] = []
    var reportsMode: ReportsMode
    var action: Action
    
    init(dictionary: [String: AnyObject]) {
        id = dictionary["id"] as! Int
        name = dictionary["name"] as! String
        reportsMode = ReportsMode(rawValue: dictionary["reportsMode"] as! Int)!
        action = Action.change
        
        if let contactsDictionaries = dictionary["contacts"] as? [[String: AnyObject]] {
            for contactDictionary in contactsDictionaries {
                let contact = Contact(dictionary: contactDictionary)
                contacts.append(contact)
            }
        }
        
        if let postsDictionaries = dictionary["posts"] as? [[String: AnyObject]] {
            for postDictionary in postsDictionaries {
                let post = Post(dictionary: postDictionary)
                posts.append(post)
            }
        }
        
        if let reportsDictionaries = dictionary["reports"] as? [[String: AnyObject]] {
            for reportsDictionary in reportsDictionaries {
                let report = Report(dictionary: reportsDictionary)
                reports.append(report)
            }
        }
    }
    
    init(name: String, posts: [Post], contacts: [Contact], reports: [Report]) {
        self.name = name
        self.posts = posts
        self.contacts = contacts
        self.reports = reports
        self.reportsMode = ReportsMode.defaultMode
        self.action = Action.add
        self.id = kIdNewUser
    }
    
    func toDictionary() -> [String: AnyObject] {
        var dictionary: [String: AnyObject] = [:]
        dictionary["id"] = id as AnyObject?
        dictionary["fio"] = name as AnyObject?
        dictionary["action"] = action.rawValue as AnyObject?
        var contactsDictionary: [String: String] = [:]
        
        for contact in contacts {
            contactsDictionary[String(contact.type.rawValue)] = contact.value
        }
        
        dictionary["contacts"] = contactsDictionary as AnyObject?
        
        var postIds: [Int] = []
        
        for post in posts {
            postIds.append(post.id)
        }
        
        dictionary["postIds"] = postIds as AnyObject?
        
        var reportIds: [Int] = []
        
        for report in reports {
            reportIds.append(report.id)
        }
        
        var reportsDictionary: [String: AnyObject] = [:]
        reportsDictionary["mode"] = reportsMode.rawValue as AnyObject?
        reportsDictionary["reportIds"] = reportIds as AnyObject?
        
        dictionary["reports"] = reportsDictionary as AnyObject?
        
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
}
