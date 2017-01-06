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
    @IBOutlet var invoiceDateLabels: [UILabel]!
    @IBOutlet var invoiceNumberLabels: [UILabel]!
    @IBOutlet var clientLabels: [UILabel]!
    @IBOutlet var totalCostLabels: [UILabel]!
    @IBOutlet var fbLabels: [UILabel]!
    @IBOutlet var stemsLabels: [UILabel]!
    @IBOutlet weak var headerPortraitView: UIView!
    @IBOutlet weak var headerLandscapeView: UIView!
    @IBOutlet weak var topContainerView: UIView!

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
        var nib = UINib(nibName:"InvoiceDetailsGeneralTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "InvoiceDetailsGeneralTableViewCellIdentifier")
        nib = UINib(nibName:"InvoiceDetailsGeneralLandscapeTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "InvoiceDetailsGeneralLandscapeTableViewCellIdentifier")
        
        nib = UINib(nibName:"InvoiceDetailsGeneralHeaderTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "InvoiceDetailsGeneralHeaderTableViewCellIdentifier")
        nib = UINib(nibName:"InvoiceDetailsGeneralHeaderLandscapeTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "InvoiceDetailsGeneralHeaderLandscapeTableViewCellIdentifier")
        
        nib = UINib(nibName:"InvoiceDetailsGeneralTotalTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "InvoiceDetailsGeneralTotalTableViewCellIdentifier")
        
        nib = UINib(nibName:"InvoiceDetailsGeneralTotalLandscapeTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "InvoiceDetailsGeneralTotalLandscapeTableViewCellIdentifier")
        
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
        invoiceNumberLabels.forEach { $0.text = invoice.number }
        clientLabels.forEach { $0.text = invoice.label }
        totalCostLabels.forEach { $0.text = String(format: "%.2f $", invoiceDetails!.totalPrice) }
        fbLabels.forEach { $0.text = String(format: "%.2f", invoiceDetails!.totalFb) }
        stemsLabels.forEach { $0.text = String(invoiceDetails!.totalStems) }
    }
    
    func adjustViewSize() {
        var topContainerViewFrame = topContainerView.frame
        var tableViewFrame = tableView.frame
        
        if viewWillTransitionToSize.width < viewWillTransitionToSize.height {
            totalInfoPortraitContainerView.isHidden = false
            totalInfoLandscapeContainerView.isHidden = true
            headerPortraitView.isHidden = false
            headerLandscapeView.isHidden = true
            topContainerViewFrame.size.height = headerPortraitView.frame.height + headerPortraitView.frame.origin.y
            tableViewFrame.origin.y = topContainerViewFrame.origin.y + topContainerViewFrame.height
            tableViewFrame.size.height = viewWillTransitionToSize.height - tableViewFrame.origin.y - 104
        } else {
            totalInfoPortraitContainerView.isHidden = true
            totalInfoLandscapeContainerView.isHidden = false
            totalInfoLandscapeContainerView.frame.size.width = self.frame.width - 10
            headerPortraitView.isHidden = true
            headerLandscapeView.isHidden = false
            headerLandscapeView.frame.size.width = self.frame.width
            topContainerViewFrame.size.height = headerLandscapeView.frame.height + headerLandscapeView.frame.origin.y
            tableViewFrame.origin.y = topContainerViewFrame.origin.y + topContainerViewFrame.height
            tableViewFrame.size.height = viewWillTransitionToSize.height - tableViewFrame.origin.y - 72
        }
        topContainerView.frame = topContainerViewFrame
        tableView.frame = tableViewFrame
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numberOfRows = 0
        if let heads = self.invoiceDetails?.heads {
            self.spinner.hideLoader()
            numberOfRows = heads.count
        } else {
            self.setNeedsLayout()
        }
        
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let head = self.invoiceDetails!.heads[section]
        let rows = head.rows
        return rows.count + 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! InvoiceDetailsGeneralTableViewCell
                
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
                                                          andFont: UIFont.systemFont(ofSize: 12))
            let variety = self.invoiceDetails!.varietyById(row.flowerSortId)!
            let heightForVarietyName = Utils.heightForText(variety.name,
                                                           havingWidth: labelWidth,
                                                           andFont: UIFont.systemFont(ofSize: 12))
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
