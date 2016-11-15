//
//  ApiManager+Orders.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/12/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Alamofire

extension ApiManager {
    
    static func fetchCurrentOrders(user: User, completion: (orders: [Order]?, error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.CurrentOrdersPath
        Alamofire.request(.GET, url, headers:["Authorization": user.token]).responseJSON { response in
            if response.result.isSuccess {
                var orders: [Order] = []
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    for ordersDictionary in json["orders"] as! [[String: AnyObject]] {
                        orders.append(Order(dictionary: ordersDictionary))
                    }
                }
                completion(orders: orders, error: nil)
            } else {
                print("Error: \(response.result.error)")
                completion(orders: nil, error: response.result.error)
            }
        }
    }
    
    static func fetchDetailsForOrder(order: Order, user: User, completion: (orderDetails: [OrderDetails]?, error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.CurrentOrdersPath + "/\(order.headId)"
        Alamofire.request(.GET, url, headers:["Authorization": user.token]).responseJSON { response in
            if response.result.isSuccess {
                var orderDetails: [OrderDetails] = []
                if let json = response.result.value {
                    //print("JSON: \(json)")
                    for orderDetailsDictionary in json["rows"] as! [[String: AnyObject]] {
                        orderDetails.append(OrderDetails(dictionary: orderDetailsDictionary))
                    }
                }
                orderDetails = Utils.sortedOrderDetailsByName(orderDetails)
                completion(orderDetails: orderDetails, error: nil)
            } else {
                print("Error: \(response.result.error)")
                completion(orderDetails: nil, error: response.result.error)
            }
        }
    }
}
