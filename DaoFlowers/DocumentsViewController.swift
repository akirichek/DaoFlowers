//
//  DocumentsViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/15/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class DocumentsViewController: BaseViewController, PageViewerDataSource, DocumentsPageViewDelegate {
    
    @IBOutlet weak var pageViewerContainerView: UIView!
    var pageViewer: PageViewer!
    var invoices: [Document]?
    var prealerts: [Document]?
    var selectedInvoice: Document!
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = CustomLocalisedString("Documents")
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
        self.pageViewer.viewWillTransitionToSize = self.contentViewFrame().size
        self.pageViewerContainerView.frame = self.contentViewFrame()
        self.pageViewer.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController = segue.destinationViewController
        if let invoiceDetailsViewController = destinationViewController as? InvoiceDetailsViewController {
            invoiceDetailsViewController.invoice = self.selectedInvoice
        }
    }
    
    // MARK: - Private Methods
    
    func fetchInvoicesForPageViewIndex(index: Int) {
        ApiManager.fetchInvoices(User.currentUser()!) { (invoices, error) in
            if let invoices = invoices {
                if let pageView = self.pageViewer.pageAtIndex(index) as? DocumentsPageView {
                    pageView.invoicesMode = true
                    pageView.documents = Utils.sortedDocuments(invoices)
                    self.invoices = invoices
                }
            } else {
                Utils.showError(error!, inViewController: self)
            }
        }
    }
    
    func fetchPrealertsForPageViewIndex(index: Int) {
        ApiManager.fetchPrealerts(User.currentUser()!) { (prealerts, error) in
            if let prealerts = prealerts {
                if let pageView = self.pageViewer.pageAtIndex(index) as? DocumentsPageView {
                    pageView.invoicesMode = false
                    pageView.documents = Utils.sortedDocuments(prealerts)
                    self.prealerts = prealerts
                }
            } else {
                Utils.showError(error!, inViewController: self)
            }
        }
    }
    
    // MARK: - PageViewerDataSource
    
    func pageViewerNumberOfPages(pageViewer: PageViewer) -> Int {
        return 2
    }
    
    func pageViewer(pageViewer: PageViewer, headerForItemAtIndex index: Int) -> String {
        return [CustomLocalisedString("INVOICES"), CustomLocalisedString("PREALERTS")][index]
    }
    
    func pageViewer(pageViewer: PageViewer, pageForItemAtIndex index: Int, reusableView: UIView?) -> UIView {
        var pageView: DocumentsPageView! = reusableView as? DocumentsPageView
        if pageView == nil {
            pageView = NSBundle.mainBundle().loadNibNamed("DocumentsPageView", owner: self, options: nil).first as! DocumentsPageView
            pageView.delegate = self
        }
        
        pageView.viewWillTransitionToSize = self.viewWillTransitionToSize
        
        if index == 0 {
            if let invoices = self.invoices {
                pageView.invoicesMode = true
                pageView.documents = Utils.sortedDocuments(invoices)
            } else {
                fetchInvoicesForPageViewIndex(index)
            }
        } else if index == 1 {
            if let prealerts = self.prealerts {
                pageView.invoicesMode = false
                pageView.documents = Utils.sortedDocuments(prealerts)
            } else {
                fetchPrealertsForPageViewIndex(index)
            }
        }
        
        self.view.endEditing(true)
        
        return pageView!
    }
    
    // MARK: - DocumentsPageViewDelegate
    
    func documentsPageView(documentsPageView: DocumentsPageView, didSelectDocument document: Document) {
        if documentsPageView.invoicesMode {
            self.selectedInvoice = document
            self.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.InvoiceDetails, sender: self)
        }
    }
}
