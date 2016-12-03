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
    var viewWillTransitionToSize = UIScreen.mainScreen().bounds.size
    var dates: [NSDate]?
    var invoicesMode: Bool = true
    var documents: [NSDate: [Document]]? {
        didSet {
            sortDates()
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Override Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        var nib = UINib(nibName:"DocumentTableViewCell", bundle: nil)
        self.tableView.registerNib(nib, forCellReuseIdentifier: "DocumentTableViewCellIdentifier")
        
        nib = UINib(nibName:"DocumentTableViewHeader", bundle: nil)
        self.tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: "DocumentTableViewHeaderIdentifier")
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
        dates!.sortInPlace({ (obj1, obj2) -> Bool in
            return obj1.compare(obj2) == NSComparisonResult.OrderedDescending
        })
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var numberOfRows = 0
        if let dates = self.dates {
            self.spinner.hideLoader()
            numberOfRows = dates.count
        } else {
            self.setNeedsLayout()
        }
        
        return numberOfRows
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let date = dates![section]
        let documentsByDate = documents![date]!
        return documentsByDate.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DocumentTableViewCellIdentifier", forIndexPath: indexPath) as! DocumentTableViewCell
        cell.delegate = self
        let date = dates![indexPath.section]
        let documentsByDate = documents![date]!
        cell.document = documentsByDate[indexPath.row]
        cell.fileNameLabel.hidden = !invoicesMode
        
        if indexPath.section == 0 {
            cell.contentView.backgroundColor = UIColor(red: 255/255, green: 250/255, blue: 205/255, alpha: 1)
        } else {
            cell.contentView.backgroundColor = UIColor(red: 250/255, green: 250/255, blue: 250/255, alpha: 1)
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 28
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier("DocumentTableViewHeaderIdentifier")!
        let dateLabel = headerView.subviews.first as! UILabel
        let date = dates![section]
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateLabel.text = dateFormatter.stringFromDate(date)
        return headerView
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let date = dates![indexPath.section]
        let documentsByDate = documents![date]!
        delegate?.documentsPageView(self, didSelectDocument: documentsByDate[indexPath.row])
    }
    
    // MARK: - DocumentTableViewCellDelegate
    
    func documentTableViewCell(cell: DocumentTableViewCell, didDownloadDocument document: Document) {
        let viewController = delegate as! UIViewController
        let message = CustomLocalisedString("Do you want to start download document")
        let alertController = UIAlertController(title: CustomLocalisedString("Downloading"),
                                                message: "\(message) \(document.fileName) ?", preferredStyle: .Alert)
        let yesAlertAction = UIAlertAction(title: CustomLocalisedString("YES"), style: .Default) { alertAction in
            ApiManager.sharedInstance.downloadDocument(document, user: User.currentUser()!) { (error) in
                if let error = error {
                    Utils.showError(error, inViewController: viewController)
                }
            }
        }
        let noAlertAction = UIAlertAction(title: CustomLocalisedString("NO"), style: .Default, handler: nil)
        alertController.addAction(noAlertAction)
        alertController.addAction(yesAlertAction)
        viewController.presentViewController(alertController, animated: true, completion: nil)
    }
}

protocol DocumentsPageViewDelegate: NSObjectProtocol {
    func documentsPageView(documentsPageView: DocumentsPageView, didSelectDocument document: Document)
}
