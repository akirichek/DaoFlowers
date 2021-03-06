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
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var infoContainerView: UIView!
    @IBOutlet weak var topContainerPortraitView: UIView!
    @IBOutlet weak var topContainerLandscapeView: UIView!
    @IBOutlet var clientLabels: [UILabel]!
    @IBOutlet var dateLabels: [UILabel]!
    @IBOutlet var truckLabels: [UILabel]!
    @IBOutlet var pointLabels: [UILabel]!
    @IBOutlet var checkmarkImageViews: [UIImageView]!
    @IBOutlet weak var flowerLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var fbOrdLabel: UILabel!
    @IBOutlet weak var fbConfLabel: UILabel!
    @IBOutlet weak var fbDiffLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    
    var order: Order!
    var totalOrderDetails: [OrderDetails] = []
    
    // MARK: Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = CustomLocalisedString("Order Details")
        flowerLabel.text = CustomLocalisedString("flower")
        sizeLabel.text = CustomLocalisedString("size")
        fbOrdLabel.text = CustomLocalisedString("fb ord")
        fbConfLabel.text = CustomLocalisedString("fb conf")
        fbDiffLabel.text = CustomLocalisedString("fb diff")
        countryLabel.text = CustomLocalisedString("cou")
        infoContainerView.layer.cornerRadius = 5
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateLabels.forEach { $0.text = dateFormatter.string(from: order.headDate as Date) }
        clientLabels.forEach { $0.text = order.clientLabel }
        truckLabels.forEach { $0.text = order.truck.name }
        pointLabels.forEach { $0.text = order.outPoint.name }
        checkmarkImageViews.forEach { $0.isHidden = !(order.orderedFb - order.confirmedFb == 0) }
        fetchOrderDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustViewSize()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.tableView.reloadData()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        adjustViewSize()
    }
    
    // MARK: Private Methods
    
    func fetchOrderDetails() {
        RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
        ApiManager.fetchDetailsForOrder(order, user: User.currentUser()!) { (orderDetails, error) in
            RBHUD.sharedInstance.hideLoader()
            if let orderDetails = orderDetails {
                self.totalOrderDetails = orderDetails
                self.tableView.reloadData()
            } else {
                Utils.showError(error!, inViewController: self)
            }
        }
    }
    
    func adjustViewSize() {
        var topContainerViewFrame: CGRect
        var headerViewFrame = self.headerView.frame
        if isPortraitOrientation() {
            topContainerPortraitView.isHidden = false
            topContainerLandscapeView.isHidden = true
            topContainerViewFrame = self.topContainerPortraitView.frame
            topContainerViewFrame.origin.y = self.contentViewFrame().origin.y
            self.topContainerPortraitView.frame = topContainerViewFrame
            headerViewFrame.size.height = 40
        } else {
            topContainerPortraitView.isHidden = true
            topContainerLandscapeView.isHidden = false
            topContainerLandscapeView.frame.size.width = self.view.frame.width
            topContainerViewFrame = self.topContainerLandscapeView.frame
            topContainerViewFrame.origin.y = self.contentViewFrame().origin.y
            self.topContainerLandscapeView.frame = topContainerViewFrame
            headerViewFrame.size.height = 24
        }
        headerViewFrame.origin.y = topContainerViewFrame.origin.y + topContainerViewFrame.height
        self.headerView.frame = headerViewFrame
        
        var tableViewFrame = self.tableView.frame
        tableViewFrame.origin.y = headerViewFrame.origin.y + headerViewFrame.size.height
        tableViewFrame.size.height = self.viewWillTransitionToSize.height - tableViewFrame.origin.y
        self.tableView.frame = tableViewFrame
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return totalOrderDetails.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentifier: String
        
        if indexPath.row == totalOrderDetails.count {
            cellIdentifier = "OrderDetailsTotalTableViewCellPortraitIdentifier"
        } else {
            cellIdentifier = "OrderDetailsTableViewCellPortraitIdentifier"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! OrderDetailsTableViewCell
        
        if indexPath.row == totalOrderDetails.count {
            cell.totalOrderDetails = totalOrderDetails
        } else {
            cell.orderDetails = totalOrderDetails[indexPath.row]
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var heightForRow = tableView.rowHeight
        
        if indexPath.row < totalOrderDetails.count {
            let orderDetails = self.totalOrderDetails[indexPath.row]
            let labelWidth: CGFloat = isPortraitOrientation() ? 100 : 180
            let labelHeight: CGFloat = 20
            let text = orderDetails.flowerType.name + ". " + orderDetails.flowerSort.name
            let heightForText = Utils.heightForText(text,
                                                    havingWidth: labelWidth,
                                                    andFont: UIFont.boldSystemFont(ofSize: 12))
            
            if heightForText > labelHeight {
                heightForRow += heightForText - labelHeight
            }
        }
        
        return heightForRow
    }

}
