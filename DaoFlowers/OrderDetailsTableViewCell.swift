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
    
    var orderDetails: OrderDetails! {
        didSet {
            populateView()
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
}
