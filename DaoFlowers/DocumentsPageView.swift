//
//  DocumentsPageView.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/15/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class DocumentsPageView: UIView, UITableViewDelegate, UITableViewDataSource, DocumentTableViewCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    var spinner = RBHUD()
    weak var delegate: DocumentsPageViewDelegate?
    var viewWillTransitionToSize = UIScreen.main.bounds.size
    var dates: [Date]?
    var invoicesMode: Bool = true
    var documents: [Date: [Document]]? {
        didSet {
            sortDates()
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Override Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        var nib = UINib(nibName:"DocumentTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "DocumentTableViewCellIdentifier")
        
        nib = UINib(nibName:"InvoiceTableViewCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "InvoiceTableViewCellIdentifier")
        
        nib = UINib(nibName:"DateTableViewHeader", bundle: nil)
        self.tableView.register(nib, forHeaderFooterViewReuseIdentifier: "DateTableViewHeaderIdentifier")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.documents == nil {
            self.spinner.showLoader(self, withTitle: nil, withSubTitle: nil, withProgress: true)
        }
    }
    
    // MARK: - Private Methods
    
    func sortDates() {
        dates = Array(documents!.keys)
        dates!.sort(by: { (obj1, obj2) -> Bool in
            return obj1.compare(obj2) == ComparisonResult.orderedDescending
        })
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numberOfRows = 0
        if let dates = self.dates {
            self.spinner.hideLoader()
            numberOfRows = dates.count
        } else {
            self.setNeedsLayout()
        }
        
        return numberOfRows
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = dates![section]
        let documentsByDate = documents![date]!
        return documentsByDate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cellIdentifier = "DocumentTableViewCellIdentifier"
        
        if invoicesMode {
            cellIdentifier = "InvoiceTableViewCellIdentifier"
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DocumentTableViewCell
        cell.delegate = self
        let date = dates![indexPath.section]
        let documentsByDate = documents![date]!
        cell.document = documentsByDate[indexPath.row]
        
        if invoicesMode {
            cell.populateInvoiceView(withClaims: delegate!.documentsPageViewShouldDisplayClaims(self))
        } else {
            cell.fileNameLabel.isHidden = true
            cell.populateView()
        }
        
        if indexPath.section == 0 {
            cell.contentView.backgroundColor = UIColor(red: 255/255, green: 250/255, blue: 205/255, alpha: 1)
        } else {
            cell.contentView.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 22
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DateTableViewHeaderIdentifier")!
        let dateLabel = headerView.viewWithTag(1) as! UILabel
        let date = dates![section]
        let dateFormatter = DateFormatter()
        
        if invoicesMode {
            dateLabel.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightSemibold)
            let locale = Locale(identifier: LanguageManager.languageCode())
            dateFormatter.locale = locale
            dateFormatter.dateFormat = "dd-MM-yyyy [EEEE]"
        } else {
            dateFormatter.dateFormat = "dd-MM-yyyy"
        }
        
        dateLabel.text = dateFormatter.string(from: date as Date)
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let date = dates![indexPath.section]
        let documentsByDate = documents![date]!
        delegate?.documentsPageView(self, didSelectDocument: documentsByDate[indexPath.row])
    }
    
    // MARK: - DocumentTableViewCellDelegate
    
    func documentTableViewCell(_ cell: DocumentTableViewCell, didDownloadDocument document: Document) {
        let viewController = delegate as! UIViewController
        let message = CustomLocalisedString("Do you want to start download document")
        let alertController = UIAlertController(title: CustomLocalisedString("Downloading"),
                                                message: "\(message) \(document.fileName) ?", preferredStyle: .alert)
        let yesAlertAction = UIAlertAction(title: CustomLocalisedString("YES"), style: .default) { alertAction in
            ApiManager.sharedInstance.downloadDocument(document, user: User.currentUser()!) { (error) in
                if let error = error {
                    Utils.showError(error, inViewController: viewController)
                }
            }
        }
        let noAlertAction = UIAlertAction(title: CustomLocalisedString("NO"), style: .default, handler: nil)
        alertController.addAction(noAlertAction)
        alertController.addAction(yesAlertAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func documentTableViewCell(_ cell: DocumentTableViewCell, didClaimClickWithDocument document: Document) {
        delegate?.documentsPageView(self, didClickClaimWithDocument: document)
    }
}

protocol DocumentsPageViewDelegate: NSObjectProtocol {
    func documentsPageView(_ documentsPageView: DocumentsPageView, didSelectDocument document: Document)
    func documentsPageView(_ documentsPageView: DocumentsPageView, didClickClaimWithDocument document: Document)
    func documentsPageViewShouldDisplayClaims(_ documentsPageView: DocumentsPageView) -> Bool
}
