//
//  OrderDetailsViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/13/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class OrderDetailsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerLandscapeView: UIView!
    @IBOutlet weak var headerPortraitView: UIView!
    
    var order: Order!
    var orderDetails: [OrderDetails] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        labelsPickerView = createPickerViewForTextField(labelTextField)
//        datesPickerView = createPickerViewForTextField(dateTextField)
        fetchOrderDetails()
    }
    
    func fetchOrderDetails() {
        RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
        ApiManager.fetchDetailsForOrder(order, user: User.currentUser()!) { (orderDetails, error) in
            RBHUD.sharedInstance.hideLoader()
            if let orderDetails = orderDetails {
                self.orderDetails = orderDetails
                self.tableView.reloadData()
            } else {
                Utils.showError(error!, inViewController: self)
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderDetails.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellIdentifier: String
        if self.isPortraitOrientation() {
            cellIdentifier = "OrderDetailsTableViewCellPortraitIdentifier"
        } else {
            cellIdentifier = "CurrentOrderTableViewCellLandscapeIdentifier"
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! OrderDetailsTableViewCell
        cell.orderDetails = orderDetails[indexPath.row]
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        var heightForRow = tableView.rowHeight
//        
//        if isPortraitOrientation() {
//            let order = filteredOrders[indexPath.row]
//            let truckLabelWidth: CGFloat = 90
//            let truckLabelHeight: CGFloat = 16
//            let heightForText = Utils.heightForText(order.truck.name,
//                                                    havingWidth: truckLabelWidth,
//                                                    andFont: UIFont.systemFontOfSize(12))
//            
//            if heightForText > truckLabelHeight {
//                heightForRow += heightForText - truckLabelHeight
//            }
//        }
//        
//        return heightForRow
//    }

}
