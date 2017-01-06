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
    var viewWillTransitionToSize = UIScreen.main.bounds.size {
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
        self.tableView.register(nib, forCellReuseIdentifier: "InvoiceDetailsStatisticsTableViewCellIdentifier")
        nib = UINib(nibName:"InvoiceDetailsStatisticsTotalTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "InvoiceDetailsStatisticsTotalTableViewCellIdentifier")        
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        let dateString = dateFormatter.string(from: invoice.date as Date)
        let locale = Locale(identifier: LanguageManager.languageCode())
        dateFormatter.locale = locale
        dateFormatter.dateFormat = "EEE"
        let weekdayString = dateFormatter.string(from: invoice.date as Date).lowercased()
        invoiceDateLabels.forEach { $0.text = "\(dateString) [\(weekdayString)]" }
        clientLabels.forEach { $0.text = invoice.label }
    }
    
    func adjustViewSize() {
        var topContainerViewFrame = topContainerView.frame
        var tableViewFrame = tableView.frame
        var headerViewFrame = headerView.frame
        
        if viewWillTransitionToSize.width < viewWillTransitionToSize.height {
            totalInfoPortraitContainerView.isHidden = false
            totalInfoLandscapeContainerView.isHidden = true
            
            headerViewFrame.origin.y = totalInfoPortraitContainerView.frame.origin.y + totalInfoPortraitContainerView.frame.height + 8
            headerViewFrame.size.height = 34
            topContainerViewFrame.size.height = headerViewFrame.height + headerViewFrame.origin.y
            tableViewFrame.origin.y = topContainerViewFrame.origin.y + topContainerViewFrame.height
            tableViewFrame.size.height = viewWillTransitionToSize.height - tableViewFrame.origin.y - 104
        } else {
            totalInfoPortraitContainerView.isHidden = true
            totalInfoLandscapeContainerView.isHidden = false

            headerViewFrame.origin.y = totalInfoLandscapeContainerView.frame.origin.y + totalInfoLandscapeContainerView.frame.height + 8
            headerViewFrame.size.height = 20
            topContainerViewFrame.size.height = headerViewFrame.height + headerViewFrame.origin.y
            tableViewFrame.origin.y = topContainerViewFrame.origin.y + topContainerViewFrame.height
            tableViewFrame.size.height = viewWillTransitionToSize.height - tableViewFrame.origin.y - 72
        }
        
        topContainerView.frame = topContainerViewFrame
        tableView.frame = tableViewFrame
        headerView.frame = headerViewFrame
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numberOfRows = 0
        if let rowsGroupedByFlowerTypeId = self.invoiceDetails?.orderStatistic.rowsGroupedByFlowerTypeId {
            self.spinner.hideLoader()
            numberOfRows = rowsGroupedByFlowerTypeId.count
        } else {
            self.setNeedsLayout()
        }
        
        return numberOfRows + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRowsInSection = 0
        if section == self.numberOfSections(in: tableView) - 1 {
            numberOfRowsInSection = 1
        } else {
            let rowsGroupedByFlowerTypeId = self.invoiceDetails!.orderStatistic.rowsGroupedByFlowerTypeId[section]
            numberOfRowsInSection = Array(rowsGroupedByFlowerTypeId.values)[0].count + 1
        }
        
        return numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentifier: String

        if indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
            cellIdentifier = "InvoiceDetailsStatisticsTotalTableViewCellIdentifier"
        } else {
            cellIdentifier = "InvoiceDetailsStatisticsTableViewCellIdentifier"
        }

        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! InvoiceDetailsStatisticsTableViewCell
        cell.invoiceDetails = invoiceDetails
        cell.invoiceDetailsOrderStatistic = self.invoiceDetails!.orderStatistic
        
        if indexPath.section == self.numberOfSections(in: tableView) - 1 {
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var heightForRow: CGFloat = 18
        if indexPath.section == self.numberOfSections(in: tableView) - 1 {
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
                                                              andFont: UIFont.systemFont(ofSize: 12))
                let variety = self.invoiceDetails!.varietyById(row.flowerSortId)!
                let heightForVarietyName = Utils.heightForText(variety.name,
                                                               havingWidth: varietyLabelWidth,
                                                               andFont: UIFont.systemFont(ofSize: 12))

                if heightForVarietyName > labelHeight || heightForFlowerName > labelHeight {
                    heightForRow = 32
                }
            }
        }
        
        return heightForRow
    }
}
