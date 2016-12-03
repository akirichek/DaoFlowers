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
    
    weak var delegate: DocumentTableViewCellDelegate?
    
    var document: Document! {
        didSet {
            populateView()
        }
    }
    
    func populateView() {
        clientLabel.text = document.label
        fileNameLabel.text = document.number
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateLabel.text = dateFormatter.stringFromDate(document.date)
        
        let locale = NSLocale(localeIdentifier: LanguageManager.languageCode())
        dateFormatter.locale = locale
        dateFormatter.dateFormat = "EEEE"
        dayOfWeekLabel.text = "[\(dateFormatter.stringFromDate(document.date).lowercaseString)]"
        
        downloadButton.hidden = (document.zipFile.characters.count == 0)
    }
    
    @IBAction func downloadButtonClicked(sender: UIButton) {
        delegate?.documentTableViewCell(self, didDownloadDocument: document)
    }
}

protocol DocumentTableViewCellDelegate: NSObjectProtocol {
    func documentTableViewCell(cell: DocumentTableViewCell, didDownloadDocument document: Document)
}
