//
//  DocumentTableViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/15/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class DocumentTableViewCell: UITableViewCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dayOfWeekLabel: UILabel!
    @IBOutlet weak var clientLabel: UILabel!
    @IBOutlet weak var fileNameLabel: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var fbLabel: UILabel!
    @IBOutlet weak var claimCountLabel: UILabel!
    @IBOutlet weak var claimImageView: UIImageView!
    @IBOutlet weak var claimButton: UIButton!
    
    weak var delegate: DocumentTableViewCellDelegate?
    
    var document: Document!
    
    func populateView() {
        clientLabel.text = document.label
        fileNameLabel.text = document.number
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateLabel.text = dateFormatter.string(from: document.date as Date)
        
        let locale = Locale(identifier: LanguageManager.languageCode())
        dateFormatter.locale = locale
        dateFormatter.dateFormat = "EEEE"
        dayOfWeekLabel.text = "[\(dateFormatter.string(from: document.date as Date).lowercased())]"
        
        downloadButton.isHidden = (document.zipFile.characters.count == 0)
    }
    
    func populateInvoiceView(withClaims: Bool) {
        clientLabel.text = document.label
        fileNameLabel.text = document.number
        fbLabel.text = String(format: "%.2f fb", document.fb)
        
        if withClaims {
            let localClaims = DataManager.fetchClaims()
            let localClaimsByDocument = localClaims.filter({ $0.invoiceId == document.id })
            let claimsCount = document.claims.count + localClaimsByDocument.count
            claimCountLabel.text = "\(claimsCount)"
            claimCountLabel.isHidden = false
            claimImageView.isHidden = false
            claimButton.isHidden = false
            
            if claimsCount == 0 {
                claimCountLabel.isHidden = true
                claimImageView.isHidden = true
                claimButton.isHidden = true
            }
        } else {
            claimCountLabel.isHidden = true
            claimImageView.isHidden = true
            claimButton.isHidden = true
        }
    }
    
    @IBAction func downloadButtonClicked(_ sender: UIButton) {
        delegate?.documentTableViewCell(self, didDownloadDocument: document)
    }

    @IBAction func claimButtonClicked(_ sender: UIButton) {
        delegate?.documentTableViewCell(self, didClaimClickWithDocument: document)
    }
}

protocol DocumentTableViewCellDelegate: NSObjectProtocol {
    func documentTableViewCell(_ cell: DocumentTableViewCell, didDownloadDocument document: Document)
    func documentTableViewCell(_ cell: DocumentTableViewCell, didClaimClickWithDocument document: Document)
}
