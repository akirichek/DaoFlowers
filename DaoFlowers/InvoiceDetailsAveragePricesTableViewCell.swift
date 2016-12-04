//
//  InvoiceDetailsAveragePricesTableViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/24/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class InvoiceDetailsAveragePricesTableViewCell: UITableViewCell {

    
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var flowerLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var avgPriceLabel: UILabel!
    @IBOutlet weak var stemsLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    var invoiceDetails: InvoiceDetails!
    var invoiceDetailsStatisticAveragePrice: InvoiceDetails.Statistic.AveragePrice! {
        didSet {
            populateAveragePriceCellView()
        }
    }
    var invoiceDetailsStatisticStem: InvoiceDetails.Statistic.Stem! {
        didSet {
            populateStemCellView()
        }
    }
    
    func populateAveragePriceCellView() {
        let flower = invoiceDetails.flowerById(invoiceDetailsStatisticAveragePrice.flowerTypeId)!
        let country = invoiceDetails.countryById(invoiceDetailsStatisticAveragePrice.countryId)!
        let size = invoiceDetails.flowerSizeById(invoiceDetailsStatisticAveragePrice.flowerSizeId)!
        flowerLabel.text = flower.name
        countryLabel.text = country.abr
        sizeLabel.text = size.name
        avgPriceLabel.text = String(invoiceDetailsStatisticAveragePrice.averagePrice)
    }
    
    func populateStemCellView() {
        let flower = invoiceDetails.flowerById(invoiceDetailsStatisticStem.flowerTypeId)!
        let country = invoiceDetails.countryById(invoiceDetailsStatisticStem.countryId)!
        flowerLabel.text = flower.name
        countryLabel.text = country.abr
        stemsLabel.text = String(invoiceDetailsStatisticStem.stems)
    }
    
    func populateTotalStemsCellView() {
        totalLabel.text = CustomLocalisedString("total stems")
        stemsLabel.text = String(invoiceDetails.totalStems)
    }
}
