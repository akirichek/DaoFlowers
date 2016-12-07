//
//  OrderDetailsTableViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/13/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class OrderDetailsTableViewCell: UITableViewCell {
    @IBOutlet weak var flowerLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var fbOrdLabel: UILabel!
    @IBOutlet weak var fbConfLabel: UILabel!
    @IBOutlet weak var fbDifLabel: UILabel!
    @IBOutlet weak var couLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    var orderDetails: OrderDetails! {
        didSet {
            populateView()
        }
    }
    
    var totalOrderDetails: [OrderDetails]! {
        didSet {
            populateTotalFBView()
        }
    }
    
    func populateView() {
        flowerLabel.text = orderDetails.flowerType.name + ". " + orderDetails.flowerSort.name
        sizeLabel.text = orderDetails.flowerSize.name
        fbOrdLabel.text = String(orderDetails.orderFb)
        fbConfLabel.text = String(orderDetails.confFb)
        
        let fbDif: Double = orderDetails.orderFb - orderDetails.confFb
        
        if fbDif == 0 {
            fbDifLabel.text = String(fbDif)
            fbDifLabel.textColor = UIColor.blackColor()
        } else {
            fbDifLabel.text = "-\(fbDif)"
            fbDifLabel.textColor = UIColor(red: 202/255, green: 5/255, blue: 15/255, alpha: 1)
        }

        if let country = orderDetails.country {
            couLabel.text = country.abr
        } else {
            couLabel.text = ""
        }
    }
    
    func populateTotalFBView() {
        var totalFbOrd: Double = 0
        var totalFbConf: Double = 0
        var totalFbDif: Double = 0
        
        for orderDetails in totalOrderDetails {
            totalFbOrd += orderDetails.orderFb
            totalFbConf += orderDetails.confFb
            totalFbDif += orderDetails.orderFb - orderDetails.confFb
        }
        
        fbOrdLabel.text = String(totalFbOrd)
        fbConfLabel.text = String(totalFbConf)
        
        if totalFbDif == 0 {
            fbDifLabel.text = String(totalFbDif)
            fbDifLabel.textColor = UIColor.blackColor()
        } else {
            fbDifLabel.text = "-\(totalFbDif)"
            fbDifLabel.textColor = UIColor(red: 202/255, green: 5/255, blue: 15/255, alpha: 1)
        }
        
        totalLabel.text = CustomLocalisedString("Total FB")
    }
}
