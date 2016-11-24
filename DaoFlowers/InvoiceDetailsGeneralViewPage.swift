//
//  InvoiceDetailsGeneralViewPage.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/17/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class InvoiceDetailsGeneralViewPage: UIView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalInfoPortraitContainerView: UIView!
    @IBOutlet weak var totalInfoLandscapeContainerView: UIView!
    @IBOutlet weak var invoiceDateLabel: UILabel!
    @IBOutlet weak var invoiceNumberLabel: UILabel!
    @IBOutlet weak var clientLabel: UILabel!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var fbLabel: UILabel!
    @IBOutlet weak var stemsLabel: UILabel!
    @IBOutlet weak var headerPortraitView: UIView!
    @IBOutlet weak var headerLandscapeView: UIView!
    @IBOutlet weak var topContainerView: UIView!

    var spinner = RBHUD()
    var viewWillTransitionToSize = UIScreen.mainScreen().bounds.size {
        didSet {
            self.adjustViewSize()
            self.tableView.reloadData()
        }
    }
    var invoice: Document!
    var invoiceDetails: InvoiceDetails? {
        didSet {
            self.tableView.reloadData()
            self.populateInfoView()
        }
    }
    
    // MARK: - Override Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        var nib = UINib(nibName:"InvoiceDetailsGeneralTableViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "InvoiceDetailsGeneralTableViewCellIdentifier")
        nib = UINib(nibName:"InvoiceDetailsGeneralLandscapeTableViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "InvoiceDetailsGeneralLandscapeTableViewCellIdentifier")
        
        nib = UINib(nibName:"InvoiceDetailsGeneralHeaderTableViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "InvoiceDetailsGeneralHeaderTableViewCellIdentifier")
        nib = UINib(nibName:"InvoiceDetailsGeneralHeaderLandscapeTableViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "InvoiceDetailsGeneralHeaderLandscapeTableViewCellIdentifier")
        
        nib = UINib(nibName:"InvoiceDetailsGeneralTotalTableViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "InvoiceDetailsGeneralTotalTableViewCellIdentifier")
        
        nib = UINib(nibName:"InvoiceDetailsGeneralTotalLandscapeTableViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "InvoiceDetailsGeneralTotalLandscapeTableViewCellIdentifier")
        
        self.totalInfoPortraitContainerView.layer.cornerRadius = 5
        self.totalInfoLandscapeContainerView.layer.cornerRadius = 5
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.invoiceDetails == nil {
            self.spinner.showLoader(self, withTitle: nil, withSubTitle: nil, withProgress: true)
        }
    }
    
    // MARK: - Private Methods
    
    func populateInfoView() {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateString = dateFormatter.stringFromDate(invoice.date)
        dateFormatter.dateFormat = "EEE"
        let weekdayString = dateFormatter.stringFromDate(invoice.date).lowercaseString
        invoiceDateLabel.text = "\(dateString) [\(weekdayString)]"
        invoiceNumberLabel.text = invoice.number
        clientLabel.text = invoice.label
        totalCostLabel.text = String(format: "%.2f $", invoiceDetails!.totalPrice)
        fbLabel.text = String(format: "%.2f", invoiceDetails!.totalFb)
        stemsLabel.text = String(invoiceDetails!.totalStems)
    }
    
    func adjustViewSize() {
        var topContainerViewFrame = topContainerView.frame
        var tableViewFrame = tableView.frame
        
        if viewWillTransitionToSize.width < viewWillTransitionToSize.height {
            totalInfoPortraitContainerView.hidden = false
            totalInfoLandscapeContainerView.hidden = true
            headerPortraitView.hidden = false
            headerLandscapeView.hidden = true
            topContainerViewFrame.size.height = headerPortraitView.frame.height + headerPortraitView.frame.origin.y
            tableViewFrame.origin.y = topContainerViewFrame.origin.y + topContainerViewFrame.height
            tableViewFrame.size.height = viewWillTransitionToSize.height - tableViewFrame.origin.y - 114
        } else {
            totalInfoPortraitContainerView.hidden = true
            totalInfoLandscapeContainerView.hidden = false
            headerPortraitView.hidden = true
            headerLandscapeView.hidden = false
            topContainerViewFrame.size.height = headerLandscapeView.frame.height + headerLandscapeView.frame.origin.y
            tableViewFrame.origin.y = topContainerViewFrame.origin.y + topContainerViewFrame.height
            tableViewFrame.size.height = viewWillTransitionToSize.height - tableViewFrame.origin.y - 82
        }
        topContainerView.frame = topContainerViewFrame
        tableView.frame = tableViewFrame
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var numberOfRows = 0
        if let heads = self.invoiceDetails?.heads {
            self.spinner.hideLoader()
            numberOfRows = heads.count
        } else {
            self.setNeedsLayout()
        }
        
        return numberOfRows
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let head = self.invoiceDetails!.heads[section]
        let rows = head.rows
        return rows.count + 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellIdentifier: String
        if viewWillTransitionToSize.width < viewWillTransitionToSize.height {
            if indexPath.row == 0 {
                cellIdentifier = "InvoiceDetailsGeneralHeaderTableViewCellIdentifier"
            } else if indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
                cellIdentifier = "InvoiceDetailsGeneralTotalTableViewCellIdentifier"
            } else {
                cellIdentifier = "InvoiceDetailsGeneralTableViewCellIdentifier"
            }
        } else {
            if indexPath.row == 0 {
                cellIdentifier = "InvoiceDetailsGeneralHeaderLandscapeTableViewCellIdentifier"
            } else if indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
                cellIdentifier = "InvoiceDetailsGeneralTotalLandscapeTableViewCellIdentifier"
            } else {
                cellIdentifier = "InvoiceDetailsGeneralLandscapeTableViewCellIdentifier"
            }
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! InvoiceDetailsGeneralTableViewCell
                
        let head = self.invoiceDetails!.heads[indexPath.section]
        cell.invoiceDetails = self.invoiceDetails
        cell.invoiceDetailsHead = head
        
        if indexPath.row == 0 {
            cell.populateHeaderView()
        } else if indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
            cell.populateTotalView()
        } else {
            cell.invoiceDetailsRow = head.rows[indexPath.row - 1]
            cell.populateCellView()
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var heightForRow: CGFloat
        if indexPath.row == 0 {
            if viewWillTransitionToSize.width < viewWillTransitionToSize.height {
                heightForRow = 36
            } else {
                heightForRow = 20
            }
        } else if indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
            heightForRow = 20
        } else {
            let head = self.invoiceDetails!.heads[indexPath.section]
            let row = head.rows[indexPath.row - 1]
            let flower = self.invoiceDetails!.flowerById(head.flowerTypeId)!
            let labelHeight: CGFloat = 21
            var labelWidth: CGFloat
            if viewWillTransitionToSize.width < viewWillTransitionToSize.height {
                heightForRow = 50
                labelWidth = 90
            } else {
                heightForRow = 20
                labelWidth = 114
            }
            
            let heightForFlowerName = Utils.heightForText(flower.name,
                                                          havingWidth: labelWidth,
                                                          andFont: UIFont.systemFontOfSize(12))
            let variety = self.invoiceDetails!.varietyById(row.flowerSortId)!
            let heightForVarietyName = Utils.heightForText(variety.name,
                                                           havingWidth: labelWidth,
                                                           andFont: UIFont.systemFontOfSize(12))
            if viewWillTransitionToSize.width < viewWillTransitionToSize.height {
                if heightForVarietyName > labelHeight && heightForFlowerName > labelHeight{
                    heightForRow = 77
                } else if heightForVarietyName > labelHeight || heightForFlowerName > labelHeight {
                    heightForRow = 69
                }
            } else {
                if heightForVarietyName > labelHeight || heightForFlowerName > labelHeight {
                    heightForRow = 34
                }
            }
        }
        
        return heightForRow
    }
}