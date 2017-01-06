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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateLabel.text = dateFormatter.string(from: document.date as Date)
        
        let locale = Locale(identifier: LanguageManager.languageCode())
        dateFormatter.locale = locale
        dateFormatter.dateFormat = "EEEE"
        dayOfWeekLabel.text = "[\(dateFormatter.string(from: document.date as Date).lowercased())]"
        
        downloadButton.isHidden = (document.zipFile.characters.count == 0)
    }
    
    @IBAction func downloadButtonClicked(_ sender: UIButton) {
        delegate?.documentTableViewCell(self, didDownloadDocument: document)
    }
}

protocol DocumentTableViewCellDelegate: NSObjectProtocol {
    func documentTableViewCell(_ cell: DocumentTableViewCell, didDownloadDocument document: Document)
}
