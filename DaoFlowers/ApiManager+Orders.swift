//
//  ApiManager+Orders.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/12/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import Alamofire

extension ApiManager {
    
    static func fetchCurrentOrders(_ user: User, count: Int?, completion: @escaping (_ orders: [Order]?, _ error: NSError?) -> ()) {
        let url = K.Api.BaseUrl + K.Api.OrdersPath
        var params: [String: AnyObject] = [:]
        params["from"] = Utils.string(from: Date(), monthDelta: -1) as AnyObject
        params["to"] = Utils.string(from: Date(), monthDelta: +2) as AnyObject
        params["orders_count"] = count as AnyObject?
        Alamofire.request(url, method: .get, parameters: params, headers: ["Authorization": user.token]).responseJSON { response in
            print("\(#function) \(params) json \(response.result.value)")
            if response.result.isSuccess {
                var orders: [Order] = []
                if let json = response.result.value as? [String: AnyObject] {
                    let users = json["users"] as! [[String: AnyObject]]
                    let points = json["points"] as! [[String: AnyObject]]
                    let trucks =  json["trucks"] as! [[String: AnyObject]]
                    
                    for orderDictionary in json["orders"] as! [[String: AnyObject]] {
                        var orderDictionary = orderDictionary
                        
                        //set user
                        let userDictionary = users.first(where: { ($0["id"] as! Int) == (orderDictionary["clientId"] as! Int) })!
                        let user = User(dictionary: userDictionary)
                        orderDictionary["clientLabel"] = user.name as AnyObject?
                        
                        //set out point
                        let outPointDictionary = points.first(where: { ($0["id"] as! Int) == (orderDictionary["outPointId"] as! Int) })!
                        orderDictionary["outPoint"] = outPointDictionary as AnyObject?
                        
                        //set truck
                        let truckDictionary = trucks.first(where: { ($0["id"] as! Int) == (orderDictionary["truckId"] as! Int) })!
                        orderDictionary["truck"] = truckDictionary as AnyObject?
                        
                        orders.append(Order(dictionary: orderDictionary))
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
                    print("JSON: \(json)")
                    
                    let flowerSizes = json["flowerSizes"] as! [[String: AnyObject]]
                    let flowerSorts = json["flowerSorts"] as! [[String: AnyObject]]
                    let flowerTypes = json["flowerTypes"] as! [[String: AnyObject]]
                    
                    if let orderDetailsDictionaries = json["orderDetails"] as? [String: AnyObject] {
                        for orderDetailsDictionary in orderDetailsDictionaries["rows"] as! [[String: AnyObject]] {
                            var orderDetailsDictionary = orderDetailsDictionary
                            
                            //set floser size
                            let flowerSizeDictionary = flowerSizes.first(where: { ($0["id"] as! Int) == (orderDetailsDictionary["flowerSizeId"] as! Int) })!
                            orderDetailsDictionary["flowerSize"] = flowerSizeDictionary as AnyObject?
            
                            //set flower sort
                            let flowerSortDictionary = flowerSorts.first(where: { ($0["id"] as! Int) == (orderDetailsDictionary["flowerSortId"] as! Int) })!
                            orderDetailsDictionary["flowerSort"] = flowerSortDictionary as AnyObject?
                            
                            //set flower type
                            let flowerTypeDictionary = flowerTypes.first(where: { ($0["id"] as! Int) == (orderDetailsDictionary["flowerTypeId"] as! Int) })!
                            orderDetailsDictionary["flowerType"] = flowerTypeDictionary as AnyObject?
                            
                            orderDetails.append(OrderDetails(dictionary: orderDetailsDictionary))
                        }
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
