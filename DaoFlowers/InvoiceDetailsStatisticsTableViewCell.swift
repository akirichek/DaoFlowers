//
//  InvoiceDetailsStatisticsTableViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/21/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class InvoiceDetailsStatisticsTableViewCell: UITableViewCell {

    @IBOutlet weak var flowerLabel: UILabel!
    @IBOutlet weak var varietyLabel: UILabel!
    @IBOutlet weak var fbOrderLabel: UILabel!
    @IBOutlet weak var fbInvLabel: UILabel!
    @IBOutlet weak var fbDifLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    var invoiceDetails: InvoiceDetails!
    var invoiceDetailsOrderStatisticRow: InvoiceDetails.OrderStatistic.Row!
    var invoiceDetailsOrderStatisticSubtotal: InvoiceDetails.OrderStatistic.Subtotal!
    var invoiceDetailsOrderStatistic: InvoiceDetails.OrderStatistic!
    var flower: Flower!
    
    func populateCellView() {
        flowerLabel.text = flower.name
        let variety = invoiceDetails.varietyById(invoiceDetailsOrderStatisticRow.flowerSortId)!
        varietyLabel.text =  variety.name
        fbOrderLabel.text = String(invoiceDetailsOrderStatisticRow.orderFb)
        fbInvLabel.text = String(invoiceDetailsOrderStatisticRow.invoiceFb)
        fbDifLabel.text = String(invoiceDetailsOrderStatisticRow.differenceFb)
        
        if invoiceDetailsOrderStatisticRow.differenceFb > 0 {
            fbDifLabel.textColor = UIColor(red: 17/255, green: 140/255, blue: 11/255, alpha: 1)
        } else if invoiceDetailsOrderStatisticRow.differenceFb < 0 {
            fbDifLabel.textColor = UIColor(red: 202/255, green: 5/255, blue: 15/255, alpha: 1)
        } else {
            fbDifLabel.textColor = UIColor.black
        }
    }
    
    func populateSubtotalCellView() {
        totalLabel.text = CustomLocalisedString("subtotal")
        fbOrderLabel.text = String(invoiceDetailsOrderStatisticSubtotal.orderFb)
        fbInvLabel.text = String(invoiceDetailsOrderStatisticSubtotal.invoiceFb)
        fbDifLabel.text = String(format: "%.2f", invoiceDetailsOrderStatisticSubtotal.differenceFb)
        
        if invoiceDetailsOrderStatisticSubtotal.differenceFb > 0 {
            fbDifLabel.textColor = UIColor(red: 17/255, green: 140/255, blue: 11/255, alpha: 1)
        } else if invoiceDetailsOrderStatisticSubtotal.differenceFb < 0 {
            fbDifLabel.textColor = UIColor(red: 202/255, green: 5/255, blue: 15/255, alpha: 1)
        } else {
            fbDifLabel.textColor = UIColor.black
        }
    }
    
    func populateGrandTotalCellView() {
        totalLabel.text = CustomLocalisedString("GRAND TOTAL")
        fbOrderLabel.text = String(invoiceDetailsOrderStatistic.totalOrderFb)
        fbInvLabel.text = String(invoiceDetailsOrderStatistic.totalInvoiceFb)
        fbDifLabel.text = String(format: "%.2f", invoiceDetailsOrderStatistic.totalDifferenceFb)
        
        if invoiceDetailsOrderStatistic.totalDifferenceFb > 0 {
            fbDifLabel.textColor = UIColor(red: 17/255, green: 140/255, blue: 11/255, alpha: 1)
        } else if invoiceDetailsOrderStatistic.totalDifferenceFb < 0 {
            fbDifLabel.textColor = UIColor(red: 202/255, green: 5/255, blue: 15/255, alpha: 1)
        } else {
            fbDifLabel.textColor = UIColor.black
        }
    }
}
