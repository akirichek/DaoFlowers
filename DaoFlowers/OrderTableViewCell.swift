//
//  OrderTableViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/12/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell {

    @IBOutlet weak var clientLabel: UILabel!
    @IBOutlet weak var truckLabel: UILabel!
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var fbOrdLabel: UILabel!
    @IBOutlet weak var fbDifLabel: UILabel!
    @IBOutlet weak var checkmarkImageView: UIImageView!
    
    var order: Order! {
        didSet {
            populateView()
        }
    }
    
    func populateView() {
        clientLabel.text = order.clientLabel
        truckLabel.text = order.truck.name
        pointLabel.text = order.outPoint.name
        fbOrdLabel.text = String(order.orderedFb)
        let fbDif: Double = order.orderedFb - order.confirmedFb
        
        if fbDif == 0 {
            fbDifLabel.text = String(fbDif)
            fbDifLabel.textColor = UIColor.black
            checkmarkImageView.isHidden = false
        } else {
            fbDifLabel.text = "-\(fbDif)"
            fbDifLabel.textColor = UIColor(red: 202/255, green: 5/255, blue: 15/255, alpha: 1)
            checkmarkImageView.isHidden = true
        }
    }
}
