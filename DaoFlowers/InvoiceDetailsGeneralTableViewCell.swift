//
//  InvoiceDetailsGeneralTableViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/17/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class InvoiceDetailsGeneralTableViewCell: UITableViewCell {
    
    @IBOutlet weak var flowerLabel: UILabel!
    @IBOutlet weak var varietyLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var stemsLabel: UILabel!
    @IBOutlet weak var stemPriceLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    @IBOutlet weak var fbLabel: UILabel!
    @IBOutlet weak var totalSizeLabel: UILabel!
    @IBOutlet weak var totalCostLabel: UILabel!
    @IBOutlet weak var totalFbLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!

    @IBOutlet weak var awbLabel: UILabel!
    @IBOutlet weak var plantationLabel: UILabel!
    @IBOutlet weak var clientLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var piecesLabel: UILabel!
    
    var invoiceDetails: InvoiceDetails!
    var invoiceDetailsHead: InvoiceDetails.Head!
    var invoiceDetailsRow: InvoiceDetails.Row!
    
    func populateCellView() {
        let flower = invoiceDetails.flowerById(invoiceDetailsHead.flowerTypeId)!
        flowerLabel.text = flower.name
        let variety = invoiceDetails.varietyById(invoiceDetailsRow.flowerSortId)!
        varietyLabel.text = variety.name
        let flowerSize = invoiceDetails.flowerSizeById(invoiceDetailsRow.flowerSizeId)!
        sizeLabel.text = flowerSize.name
        stemsLabel.text = String(invoiceDetailsRow.stems)
        stemPriceLabel.text = String(format: "%.3f $", invoiceDetailsRow.stemPrice)
        costLabel.text = String(invoiceDetailsRow.cost) + " $"
        
        let fb = Double(Int(round(invoiceDetailsRow.fb * 100))) / 100
        fbLabel.text = String(fb)
    }
    
    func populateHeaderView() {
        awbLabel.text = invoiceDetailsHead.awb
        let plantation = invoiceDetails.plantationById(invoiceDetailsHead.plantationId)!
        if plantation.name == plantation.brand {
            plantationLabel.text = plantation.name
        } else {
            let planNameFontAttr = [NSFontAttributeName: UIFont.systemFont(ofSize: 12, weight: UIFontWeightSemibold)]
            let plantationString = "\(plantation.name) [\(plantation.brand)]"
            let plantationAttrString = NSMutableAttributedString(string: plantationString, attributes: planNameFontAttr)
            let range = NSRange(location: plantation.name.characters.count + 1, length: plantation.brand.characters.count + 2)
            plantationAttrString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 12), range: range)
            plantationLabel.attributedText = plantationAttrString
        }
        
        clientLabel.text = invoiceDetails.userById(invoiceDetailsHead.clientId)?.name
        let country = invoiceDetails.countryById(invoiceDetailsHead.countryId)!
        countryLabel.text = country.abr
        piecesLabel.text = invoiceDetailsHead.pieces.replacingOccurrences(of: ";", with: " ")
    }
    
    func populateTotalView() {
        totalLabel.text = CustomLocalisedString("Total")
        totalSizeLabel.text = String(invoiceDetailsHead.totalStems)
        totalCostLabel.text = String(format: "%.2f $", invoiceDetailsHead.totalPrice)
        totalFbLabel.text = String(format: "%.2f", invoiceDetailsHead.totalFb)
    }
}
