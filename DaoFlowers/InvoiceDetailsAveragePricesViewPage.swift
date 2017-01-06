//
//  InvoiceDetailsAveragePricesViewPage.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/24/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class InvoiceDetailsAveragePricesViewPage: UIView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var sizeTableView: UITableView!
    @IBOutlet weak var stemsTableView: UITableView!
    @IBOutlet weak var totalInfoPortraitContainerView: UIView!
    @IBOutlet weak var totalInfoLandscapeContainerView: UIView!
    @IBOutlet weak var sizeHeaderView: UIView!
    @IBOutlet weak var stemsHeaderView: UIView!
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet var invoiceDateLabels: [UILabel]!
    @IBOutlet var clientLabels: [UILabel]!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var spinner = RBHUD()
    var viewWillTransitionToSize = UIScreen.main.bounds.size {
        didSet {
            self.sizeTableView.reloadData()
            self.stemsTableView.reloadData()
            self.adjustViewSize()
        }
    }
    var invoice: Document!
    var invoiceDetails: InvoiceDetails? {
        didSet {
            self.sizeTableView.reloadData()
            self.stemsTableView.reloadData()
            self.adjustViewSize()
            self.populateInfoView()
        }
    }
    
    // MARK: - Override Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        var nib = UINib(nibName:"InvoiceDetailsAveragePricesSizeTableViewCell", bundle: nil)
        self.sizeTableView.register(nib, forCellReuseIdentifier: "InvoiceDetailsAveragePricesSizeTableViewCellIdentifier")
        nib = UINib(nibName:"InvoiceDetailsAveragePricesStemTableViewCell", bundle: nil)
        self.stemsTableView.register(nib, forCellReuseIdentifier: "InvoiceDetailsAveragePricesStemTableViewCellIdentifier")
        nib = UINib(nibName:"InvoiceDetailsAveragePricesTotalStemsTableViewCell", bundle: nil)
        self.stemsTableView.register(nib, forCellReuseIdentifier: "InvoiceDetailsAveragePricesTotalStemsTableViewCellIdentifier")
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
        var sizeTableViewFrame = sizeTableView.frame
        var stemsTableViewFrame = stemsTableView.frame
        var sizeHeaderViewFrame = sizeHeaderView.frame
        var stemsHeaderViewFrame = stemsHeaderView.frame
        
        if viewWillTransitionToSize.width < viewWillTransitionToSize.height {
            totalInfoPortraitContainerView.isHidden = false
            totalInfoLandscapeContainerView.isHidden = true
            
            sizeHeaderViewFrame.origin.y = totalInfoPortraitContainerView.frame.origin.y + totalInfoPortraitContainerView.frame.height + 8
            sizeHeaderViewFrame.size.height = 34
            topContainerViewFrame.size.height = sizeHeaderViewFrame.height + sizeHeaderViewFrame.origin.y
            sizeTableViewFrame.origin.y = topContainerViewFrame.origin.y + topContainerViewFrame.height
            sizeTableViewFrame.size.height = sizeTableView.contentSize.height
            
            stemsHeaderViewFrame.origin.y = sizeTableViewFrame.origin.y + sizeTableViewFrame.height + 10
            stemsTableViewFrame.origin.y = stemsHeaderViewFrame.origin.y + stemsHeaderViewFrame.height
            stemsTableViewFrame.size.height = stemsTableView.contentSize.height
        } else {
            totalInfoPortraitContainerView.isHidden = true
            totalInfoLandscapeContainerView.isHidden = false
            totalInfoLandscapeContainerView.frame.size.width = self.frame.width - 10
            
            sizeHeaderViewFrame.origin.y = totalInfoLandscapeContainerView.frame.origin.y + totalInfoLandscapeContainerView.frame.height + 8
            sizeHeaderViewFrame.size.height = 20
            topContainerViewFrame.size.height = sizeHeaderViewFrame.height + sizeHeaderViewFrame.origin.y
            sizeTableViewFrame.origin.y = topContainerViewFrame.origin.y + topContainerViewFrame.height
            sizeTableViewFrame.size.height = sizeTableView.contentSize.height
            
            stemsHeaderViewFrame.origin.y = sizeTableViewFrame.origin.y + sizeTableViewFrame.height + 10
            stemsTableViewFrame.origin.y = stemsHeaderViewFrame.origin.y + stemsHeaderViewFrame.height
            stemsTableViewFrame.size.height = stemsTableView.contentSize.height
        }
        
        topContainerView.frame = topContainerViewFrame
        sizeTableView.frame = sizeTableViewFrame
        stemsTableView.frame = stemsTableViewFrame
        sizeHeaderView.frame = sizeHeaderViewFrame
        stemsHeaderView.frame = stemsHeaderViewFrame
        
        self.scrollView.contentSize = CGSize(width: 320, height: stemsTableViewFrame.origin.y + stemsTableViewFrame.height)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRowsInSection = 0
        
        if invoiceDetails != nil {
            switch tableView {
            case sizeTableView:
                numberOfRowsInSection = invoiceDetails!.statistic.averagePrices.count
            case stemsTableView:
                numberOfRowsInSection = invoiceDetails!.statistic.stems.count + 1
            default:
                break
            }
        }
        
        return numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentifier: String = ""
        
        switch tableView {
        case sizeTableView:
            cellIdentifier = "InvoiceDetailsAveragePricesSizeTableViewCellIdentifier"
        case stemsTableView:
            if indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
                cellIdentifier = "InvoiceDetailsAveragePricesTotalStemsTableViewCellIdentifier"
            } else {
                cellIdentifier = "InvoiceDetailsAveragePricesStemTableViewCellIdentifier"
            }
        default:
            break
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! InvoiceDetailsAveragePricesTableViewCell
        cell.invoiceDetails = invoiceDetails
        
        switch tableView {
        case sizeTableView:
            cell.invoiceDetailsStatisticAveragePrice = invoiceDetails!.statistic.averagePrices[indexPath.row]
        case stemsTableView:
            if indexPath.row == self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1 {
                cell.populateTotalStemsCellView()
            } else {
                cell.invoiceDetailsStatisticStem = invoiceDetails!.statistic.stems[indexPath.row]
            }
        default:
            break
        }
        
        return cell
    }
}
