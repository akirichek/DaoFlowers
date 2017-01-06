//
//  ApiManager+Orders.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/12/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Alamofire

extension ApiManager {
    
    static func fetchCurrentOrders(_ user: User, completion: @escaping (_ orders: [Order]?, _ error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.CurrentOrdersPath

        Alamofire.request(url, method: .get, headers: ["Authorization": user.token]).responseJSON { response in
            if response.result.isSuccess {
                var orders: [Order] = []
                if let json = response.result.value as? [String: AnyObject] {
                    //print("JSON: \(json)")
                    for ordersDictionary in json["orders"] as! [[String: AnyObject]] {
                        orders.append(Order(dictionary: ordersDictionary))
                    }
                }
                completion(orders, nil)
            } else {
                print("Error: \(response.result.error)")
                completion(nil, response.result.error as NSError?)
            }
        }
    }
    
    static func fetchDetailsForOrder(_ order: Order, user: User, completion: @escaping (_ orderDetails: [OrderDetails]?, _ error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.CurrentOrdersPath + "/\(order.headId)"
        Alamofire.request(url, method: .get, headers:["Authorization": user.token]).responseJSON { response in
            if response.result.isSuccess {
                var orderDetails: [OrderDetails] = []
                if let json = response.result.value as? [String: AnyObject] {
                    //print("JSON: \(json)")
                    for orderDetailsDictionary in json["rows"] as! [[String: AnyObject]] {
                        orderDetails.append(OrderDetails(dictionary: orderDetailsDictionary))
                    }
                }
                orderDetails = Utils.sortedOrderDetailsByName(orderDetails)
                completion(orderDetails, nil)
            } else {
                print("Error: \(response.result.error)")
                completion(nil, response.result.error as NSError?)
            }
        }
    }
}
