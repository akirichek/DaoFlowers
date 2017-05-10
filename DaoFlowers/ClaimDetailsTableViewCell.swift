//
//  ClaimDetailsTableViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 4/25/17.
//  Copyright © 2017 Dao Flowers. All rights reserved.
//

import UIKit

class ClaimDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var flowerLabel: UILabel!
    @IBOutlet weak var varietyLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var stemsLabel: UILabel!
    @IBOutlet weak var stemPriceLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var fbLabel: UILabel!
    @IBOutlet weak var totalFbLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    @IBOutlet weak var claimStemsLabel: UILabel!
    @IBOutlet weak var claimPriceLabel: UILabel!
    
    var invoiceDetails: InvoiceDetails!
    var invoiceDetailsHead: InvoiceDetails.Head!
    var invoiceDetailsRow: InvoiceDetails.Row!
    var claim: Claim!
    var claimInvoiceRow: Claim.InvoiceRow!
    
    func populateCellView() {
        let flower = invoiceDetails.flowerById(invoiceDetailsHead.flowerTypeId)!
        flowerLabel.text = flower.name
        let variety = invoiceDetails.varietyById(invoiceDetailsRow.flowerSortId)!
        varietyLabel.text = variety.name
        let flowerSize = invoiceDetails.flowerSizeById(invoiceDetailsRow.flowerSizeId)!
        sizeLabel.text = flowerSize.name
        stemsLabel.attributedText = NSAttributedString(string: String(invoiceDetailsRow.stems), attributes:
            [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue])
        stemPriceLabel.attributedText = NSAttributedString(string: String(format: "%.3f", invoiceDetailsRow.stemPrice),
                                                           attributes:[NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue])
        costLabel.attributedText = NSAttributedString(string: String(invoiceDetailsRow.cost), attributes:
            [NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue])
        
        let fb = Double(Int(round(invoiceDetailsRow.fb * 100))) / 100
        fbLabel.text = String(fb)
    }
    
    func populateTotalView() {
        totalLabel.text = CustomLocalisedString("Total")
        stemsLabel.text = String(invoiceDetailsHead.totalStems)
        costLabel.text = String(format: "%.2f", invoiceDetailsHead.totalPrice)
        totalFbLabel.text = String(format: "%.2f", invoiceDetailsHead.totalFb)

        if claim.invoceRows.count > 0 {
            var totalClaimStems: Int = 0
            var totalClaimCost: Double = 0
            for invoiceRow in claim.invoceRows {
                totalClaimStems += invoiceRow.claimStems!
                totalClaimCost += Double(invoiceRow.claimStems!) * invoiceRow.claimPerStemPrice!
            }
            
            adjustClaimStemsLabel(withText: String(totalClaimStems))
            adjustClaimPriceLabel(withClaimPrice: totalClaimCost)
        }
    }
    
    func adjustClaimStemsLabel(withText text: String) {
        claimStemsLabel.text = text
        claimStemsLabel.sizeToFit()
        claimStemsLabel.frame.size.width += 4
        claimStemsLabel.frame.size.height += 6
        claimStemsLabel.center.x = self.stemsLabel.center.x
    }
    
    func adjustClaimPriceLabel(withClaimPrice claimPrice: Double) {
        claimPriceLabel.text = String(format: "%.2f", claimPrice)
        claimPriceLabel.sizeToFit()
        claimPriceLabel.frame.size.width += 4
        claimPriceLabel.frame.size.height += 6
        claimPriceLabel.center.x = self.costLabel.center.x
    }
    
    func populateClaimInvoiceView() {
        adjustClaimStemsLabel(withText: String(claimInvoiceRow.claimStems!))
        
        let totalPrice: Double = Double(claimInvoiceRow.claimStems!) * claimInvoiceRow.claimPerStemPrice!
        adjustClaimPriceLabel(withClaimPrice: totalPrice)
    }
}
