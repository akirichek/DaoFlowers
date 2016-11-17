//
//  InvoiceDetailsGeneralViewPage.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/17/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class InvoiceDetailsGeneralViewPage: UIView, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var spinner = RBHUD()
    //weak var delegate: DocumentsPageViewDelegate?
    var viewWillTransitionToSize = UIScreen.mainScreen().bounds.size
    var invoicesMode: Bool = true
    var invoiceDetails: InvoiceDetails? {
        didSet {
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
        
        if self.invoiceDetails == nil {
            self.spinner.showLoader(self, withTitle: nil, withSubTitle: nil, withProgress: true)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        var numberOfRows = 0
        if let heads = self.invoiceDetails?.heads {
            self.spinner.hideLoader()
            numberOfRows = heads.count
        } else {
            self.setNeedsLayout()
        }
        
        return numberOfRows
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let head = self.invoiceDetails!.heads[section]
        let rows = head.rows
        return rows.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DocumentTableViewCellIdentifier", forIndexPath: indexPath) as! DocumentTableViewCell
        //cell.delegate = self
        let head = self.invoiceDetails!.heads[indexPath.section]
        let rows = head.rows
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
        //delegate?.documentsPageView(self, didSelectDocument: documentsByDate[indexPath.row])
    }
    
    // MARK: - DocumentTableViewCellDelegate
    
    func documentTableViewCell(cell: DocumentTableViewCell, didDownloadDocument document: Document) {
        ApiManager.downloadDocument(document, user: User.currentUser()!) { (prealerts, error) in
            
        }
    }
}
