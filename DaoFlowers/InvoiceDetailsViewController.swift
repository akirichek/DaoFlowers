//
//  InvoiceDetailsViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/17/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class InvoiceDetailsViewController: BaseViewController, PageViewerDataSource {
    
    @IBOutlet weak var pageViewerContainerView: UIView!
    var pageViewer: PageViewer!
    var invoice: Document!
    var invoiceDetails: InvoiceDetails!
    
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pageViewerContainerView.frame = self.contentViewFrame()
        let pageViewer = NSBundle.mainBundle().loadNibNamed("PageViewer", owner: self, options: nil).first as! PageViewer
        pageViewer.frame = self.pageViewerContainerView.bounds
        pageViewer.dataSource = self
        pageViewer.viewWillTransitionToSize = self.contentViewFrame().size
        self.pageViewerContainerView.addSubview(pageViewer)
        self.pageViewer = pageViewer
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.viewWillTransitionToSize = size
        self.pageViewerContainerView.frame = self.contentViewFrame()
        self.pageViewer.viewWillTransitionToSize = self.contentViewFrame().size
        self.pageViewer.reloadData()
    }
    
    // MARK: - Private Methods
    
    func fetchInvoiceDetailsForPageViewAtIndex(index: Int) {
        ApiManager.fetchInvoiceDetails(invoice, user: User.currentUser()!) { (invoiceDetails, error) in
            if let invoiceDetails = invoiceDetails {
                if let pageView = self.pageViewer.pageAtIndex(index) as? InvoiceDetailsGeneralViewPage {
                    pageView.invoiceD
                    self.invoiceDetails = invoiceDetails
                }
            } else {
                Utils.showError(error!, inViewController: self)
            }
        }
        
//        
//        ApiManager.fetchInvoices(User.currentUser()!) { (invoices, error) in
//            if let invoices = invoices {
//                if let pageView = self.pageViewer.pageAtIndex(index) as? DocumentsPageView {
//                    pageView.invoicesMode = true
//                    pageView.documents = Utils.sortedDocuments(invoices)
//                    self.invoices = invoices
//                }
//            } else {
//                Utils.showError(error!, inViewController: self)
//            }
//        }
    }
//
//    func fetchPrealertsForPageViewIndex(index: Int) {
//        ApiManager.fetchPrealerts(User.currentUser()!) { (prealerts, error) in
//            if let prealerts = prealerts {
//                if let pageView = self.pageViewer.pageAtIndex(index) as? DocumentsPageView {
//                    pageView.invoicesMode = false
//                    pageView.documents = Utils.sortedDocuments(prealerts)
//                    self.prealerts = prealerts
//                }
//            } else {
//                Utils.showError(error!, inViewController: self)
//            }
//        }
//    }
    
    // MARK: - PageViewerDataSource
    
    func pageViewerNumberOfPages(pageViewer: PageViewer) -> Int {
        return 3
    }
    
    func pageViewer(pageViewer: PageViewer, headerForItemAtIndex index: Int) -> String {
        return ["GENERAL", "AVERAGE PRICES", "STATISTICS OF FULFILMENT"][index]
    }
    
    func pageViewer(pageViewer: PageViewer, pageForItemAtIndex index: Int, reusableView: UIView?) -> UIView {
        var pageView: DocumentsPageView! = reusableView as? DocumentsPageView
        
        if pageView == nil {
            pageView = NSBundle.mainBundle().loadNibNamed("InvoiceDetailsGeneralViewPage", owner: self, options: nil).first as! InvoiceDetailsGeneralViewPage
            //pageView.delegate = self
        }
        
        pageView.viewWillTransitionToSize = self.viewWillTransitionToSize
        
        
//        if index == 0 {
//            if let invoices = self.invoices {
//                pageView.invoicesMode = true
//                pageView.documents = Utils.sortedDocuments(invoices)
//            } else {
//                fetchInvoicesForPageViewIndex(index)
//            }
//        } else if index == 1 {
//            if let prealerts = self.prealerts {
//                pageView.invoicesMode = false
//                pageView.documents = Utils.sortedDocuments(prealerts)
//            } else {
//                fetchPrealertsForPageViewIndex(index)
//            }
//        }
        
        self.view.endEditing(true)
        
        return pageView!
    }
        
}
