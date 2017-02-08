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
    var employees: [Employee] = []
    
    init(dictionary: [String: AnyObject]) {
        if let mainParamsCustomer = dictionary["mainParamsCustomer"] as? [String: String] {
            address = mainParamsCustomer["address"]
            detailedAddress = mainParamsCustomer["detailedAddress"]
            marking = mainParamsCustomer["marking"]
            organization = mainParamsCustomer["organization"]
            recoveryEmail = mainParamsCustomer["recoveryEmail"]
            recoveryPhone = mainParamsCustomer["recoveryPhone"]
            url = mainParamsCustomer["url"]
        }
        
        if let employeesDictionaries = dictionary["employees"] as? [[String: AnyObject]] {
            for employeeDictionary in employeesDictionaries {
                let employee = Employee(dictionary: employeeDictionary)
                employees.append(employee)
            }
        }
    }

    func toDictionary() -> [String: AnyObject] {
        var dictionary: [String: AnyObject] = [:]
        
        var mainParamsCustomer: [String: String] = [:]
        mainParamsCustomer["address"] = address
        mainParamsCustomer["detailedAddress"] = detailedAddress
        mainParamsCustomer["marking"] = marking
        mainParamsCustomer["organization"] = organization
        mainParamsCustomer["recoveryEmail"] = recoveryEmail
        mainParamsCustomer["recoveryPhone"] = recoveryPhone
        mainParamsCustomer["url"] = url
        dictionary["mainParamsCustomer"] = mainParamsCustomer as AnyObject?
        
        var employeesDictionaries: [[String: AnyObject]] = []
        
        for employee in employees {
            employeesDictionaries.append(employee.toDictionary())
        }
        
        dictionary["employees"] = employeesDictionaries as AnyObject?
        return dictionary
    }
}
