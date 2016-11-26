//
//  InvoiceDetailsStatisticsViewPage.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/21/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class InvoiceDetailsStatisticsViewPage: UIView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var totalInfoPortraitContainerView: UIView!
    @IBOutlet weak var totalInfoLandscapeContainerView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet var invoiceDateLabels: [UILabel]!
    @IBOutlet var clientLabels: [UILabel]!
    
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
        var nib = UINib(nibName:"InvoiceDetailsStatisticsTableViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "InvoiceDetailsStatisticsTableViewCellIdentifier")
        nib = UINib(nibName:"InvoiceDetailsStatisticsTotalTableViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "InvoiceDetailsStatisticsTotalTableViewCellIdentifier")        
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
        invoiceDateLabels.forEach { $0.text = "\(dateString) [\(weekdayString)]" }
        clientLabels.forEach { $0.text = invoice.label }
    }
    
    func adjustViewSize() {
        var topContainerViewFrame = topContainerView.frame
        var tableViewFrame = tableView.frame
        var headerViewFrame = headerView.frame
        
        if viewWillTransitionToSize.width < viewWillTransitionToSize.height {
            totalInfoPortraitContainerView.hidden = false
            totalInfoLandscapeContainerView.hidden = true
            
            headerViewFrame.origin.y = totalInfoPortraitContainerView.frame.origin.y + totalInfoPortraitContainerView.frame.height + 8
            headerViewFrame.size.height = 34
            topContainerViewFrame.size.height = headerViewFrame.height + headerViewFrame.origin.y
            tableViewFrame.origin.y = topContainerViewFrame.origin.y + topContainerViewFrame.height
            tableViewFrame.size.height = viewWillTransitionToSize.height - tableViewFrame.origin.y - 114
        } else {
            totalInfoPortraitContainerView.hidden = true
            totalInfoLandscapeContainerView.hidden = false

            headerViewFrame.origin.y = totalInfoLandscapeContainerView.frame.origin.y + totalInfoLandscapeContainerView.frame.height + 8
            headerViewFrame.size.height = 20
            topContainerViewFrame.size.height = headerViewFrame.height + headerViewFrame.origin.y
            tableViewFrame.origin.y = topContainerViewFrame.origin.y + topContainerViewFrame.height
            tableViewFrame.size.height = viewWillTransitionToSize.height - tableViewFrame.origin.y - 82
        }
        
        topContainerView.frame = topContainerViewFrame
        tableView.frame = tableViewFrame
        headerView.frame = headerViewFrame
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var numberOfRows = 0
        if let rowsGroupedByFlowerTypeId = self.invoiceDetails?.orderStatistic.rowsGroupedByFlowerTypeId {
            self.spinner.hideLoader()
            numberOfRows = rowsGroupedByFlowerTypeId.count
        } else {
            self.setNeedsLayout()
        }
        
        return numberOfRows + 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRowsInSection = 0
        if section == self.numberOfSectionsInTableView(tableView) - 1 {
            numberOfRowsInSection = 1
        } else {
            let rowsGroupedByFlowerTypeId = self.invoiceDetails!.orderStatistic.rowsGroupedByFlowerTypeId[section]
            numberOfRowsInSection = Array(rowsGroupedByFlowerTypeId.values)[0].count + 1
        }
        
        return numberOfRowsInSection
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cellIdentifier: String

        if indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
            cellIdentifier = "InvoiceDetailsStatisticsTotalTableViewCellIdentifier"
        } else {
            cellIdentifier = "InvoiceDetailsStatisticsTableViewCellIdentifier"
        }

        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! InvoiceDetailsStatisticsTableViewCell
        cell.invoiceDetails = invoiceDetails
        cell.invoiceDetailsOrderStatistic = self.invoiceDetails!.orderStatistic
        
        if indexPath.section == self.numberOfSectionsInTableView(tableView) - 1 {
            cell.populateGrandTotalCellView()
        } else {
            let rowsGroupedByFlowerTypeId = self.invoiceDetails!.orderStatistic.rowsGroupedByFlowerTypeId[indexPath.section]
            let flowerTypeId = Array(rowsGroupedByFlowerTypeId.keys)[0]
            let rows = Array(rowsGroupedByFlowerTypeId.values)[0]
            
            if indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
                cell.invoiceDetailsOrderStatisticSubtotal = invoiceDetails!.orderStatistic.subtotalsGroupedByFlowerTypeId[flowerTypeId]
                cell.populateSubtotalCellView()
            } else {
                cell.invoiceDetailsOrderStatisticRow = rows[indexPath.row]
                cell.flower = invoiceDetails!.flowerById(flowerTypeId)
                cell.populateCellView()
            }
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var heightForRow: CGFloat = 18
        if indexPath.section == self.numberOfSectionsInTableView(tableView) - 1 {
            heightForRow = 18
        } else {
            if indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
                heightForRow = 18
            } else {
                let rowsGroupedByFlowerTypeId = self.invoiceDetails!.orderStatistic.rowsGroupedByFlowerTypeId[indexPath.section]
                let flowerTypeId = Array(rowsGroupedByFlowerTypeId.keys)[0]
                let rows = Array(rowsGroupedByFlowerTypeId.values)[0]
                let row = rows[indexPath.row]
                let flower = invoiceDetails!.flowerById(flowerTypeId)!
                
                let labelHeight: CGFloat = 21
                var flowerLabelWidth: CGFloat
                var varietyLabelWidth: CGFloat
                if viewWillTransitionToSize.width < viewWillTransitionToSize.height {
                    flowerLabelWidth = 70
                    varietyLabelWidth = 110
                } else {
                    flowerLabelWidth = 125
                    varietyLabelWidth = 124
                }
                
                let heightForFlowerName = Utils.heightForText(flower.name,
                                                              havingWidth: flowerLabelWidth,
                                                              andFont: UIFont.systemFontOfSize(12))
                let variety = self.invoiceDetails!.varietyById(row.flowerSortId)!
                let heightForVarietyName = Utils.heightForText(variety.name,
                                                               havingWidth: varietyLabelWidth,
                                                               andFont: UIFont.systemFontOfSize(12))

                if heightForVarietyName > labelHeight || heightForFlowerName > labelHeight {
                    heightForRow = 32
                }
            }
        }
        
        return heightForRow
    }
}
