//
//  Customer.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 1/24/17.
//  Copyright © 2017 Dao Flowers. All rights reserved.
//

import Foundation

struct Customer {
    var address: String!
    var detailedAddress: String!
    var marking: String!
    var organization: String!
    var recoveryEmail: String!
    var recoveryPhone: String!
    var url: String!
    var employees: [Employee]!
    var posts: [Post] = []
    var reports: [Report] = []
    
    init() {
    }
    
    init(dictionary: [String: AnyObject]) {
        if let mainParamsCustomer = dictionary["mainParams"] as? [String: String] {
            address = mainParamsCustomer["address"]
            detailedAddress = mainParamsCustomer["detailedAddress"]
            marking = mainParamsCustomer["marking"]
            organization = mainParamsCustomer["organization"]
            recoveryEmail = mainParamsCustomer["recoveryEmail"]
            recoveryPhone = mainParamsCustomer["recoveryPhone"]
            url = mainParamsCustomer["url"]
        }
        
        
        employees = []
        if let employeesDictionaries = dictionary["employees"] as? [[String: AnyObject]] {
            for employeeDictionary in employeesDictionaries {
                let employee = Employee(dictionary: employeeDictionary)
                employees.append(employee)
            }
        }
        
        if let postsDictionaries = dictionary["posts"] as? [[String: AnyObject]] {
            for postDictionary in postsDictionaries {
                let post = Post(dictionary: postDictionary)
                posts.append(post)
            }
        }
        
        if let reportsDictionaries = dictionary["reports"] as? [[String: AnyObject]] {
            for reportDictionary in reportsDictionaries {
                let report = Report(dictionary: reportDictionary)
                reports.append(report)
            }
        }
    }

    func toDictionary() -> [String: AnyObject] {
        var dictionary: [String: AnyObject] = [:]
        
        var mainParamsCustomer: [String: String] = [:]
        if address != nil {
            mainParamsCustomer["address"] = address
        }
        
        if detailedAddress != nil {
            mainParamsCustomer["detailedAddress"] = detailedAddress
        }
        
        if marking != nil {
            mainParamsCustomer["marking"] = marking
        }
        
        if organization != nil {
            mainParamsCustomer["organization"] = organization
        }
        
        if recoveryEmail != nil {
            mainParamsCustomer["recoveryEmail"] = recoveryEmail
        }
        
        if recoveryPhone != nil {
            mainParamsCustomer["recoveryPhone"] = recoveryPhone
        }
        
        if url != nil {
            mainParamsCustomer["url"] = url
        }
        
        if mainParamsCustomer.values.count > 0 {
            dictionary["mainParamsCustomer"] = mainParamsCustomer as AnyObject?
        }
        
        if employees != nil {
            var employeesDictionaries: [[String: AnyObject]] = []
            for employee in employees {
                employeesDictionaries.append(employee.toDictionary())
            }
            
            dictionary["employees"] = employeesDictionaries as AnyObject?
        }
    
        return dictionary
    }
    
    static func differcenceBetweenCustomers(_ lhs: Customer, rhs: Customer) -> Customer {
        var result = Customer()
        
        if lhs.address != rhs.address {
            result.address = rhs.address
        }
        
        if lhs.detailedAddress != rhs.detailedAddress {
            result.detailedAddress = rhs.detailedAddress
        }
        
        if lhs.marking != rhs.marking {
            result.marking = rhs.marking
        }
        
        if lhs.organization != rhs.organization {
            result.organization = rhs.organization
        }
        
        if lhs.recoveryEmail != rhs.recoveryEmail {
            result.recoveryEmail = rhs.recoveryEmail
        }
        
        if lhs.recoveryPhone != rhs.recoveryPhone {
            result.recoveryPhone = rhs.recoveryPhone
        }
        
        if lhs.url != rhs.url {
            result.url = rhs.url
        }
        
        return result
    }
    
    func postById(_ postId: Int) -> Post {
        return posts.first(where: { $0.id == postId })!
    }
    
    func reportById(_ reportId: Int) -> Report {
        return reports.first(where: { $0.id == reportId })!
    }
    
    func postsByIds(_ postIds: [Int]) -> [Post] {
        var posts: [Post] = []
        for postId in postIds {
            posts.append(postById(postId))
        }
        return posts
    }
    
    func reportsByIds(_ reportIds: [Int]) -> [Report] {
        var reports: [Report] = []
        for reportId in reportIds {
            reports.append(reportById(reportId))
        }
        
        return reports
    }
    
    func idsFromPosts(_ posts: [Post]) -> [Int] {
        var ids: [Int] = []
        for post in posts {
            ids.append(post.id)
        }
        return ids
    }
    
    func idsFromReports(_ reports: [Report]) -> [Int] {
        var ids: [Int] = []
        for report in reports {
            ids.append(report.id)
        }
        return ids
    }
}
