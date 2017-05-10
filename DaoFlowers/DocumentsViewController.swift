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
        
        if navigationController?.viewControllers[0] != self {
            navigationItem.leftBarButtonItem = nil
        }
        
        self.title = CustomLocalisedString("Documents")
        self.pageViewerContainerView.frame = self.contentViewFrame()
        let pageViewer = Bundle.main.loadNibNamed("PageViewer", owner: self, options: nil)?.first as! PageViewer
        pageViewer.frame = self.pageViewerContainerView.bounds
        pageViewer.dataSource = self
        pageViewer.viewWillTransitionToSize = self.contentViewFrame().size
        self.pageViewerContainerView.addSubview(pageViewer)
        self.pageViewer = pageViewer
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.viewWillTransitionToSize = size
        self.pageViewer.viewWillTransitionToSize = self.contentViewFrame().size
        self.pageViewerContainerView.frame = self.contentViewFrame()
        self.pageViewer.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination
        if let invoiceDetailsViewController = destinationViewController as? InvoiceDetailsViewController {
            invoiceDetailsViewController.invoice = self.selectedInvoice
        }
    }
    
    // MARK: - Private Methods
    
    func fetchInvoicesForPageViewIndex(_ index: Int) {
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
    
    func fetchPrealertsForPageViewIndex(_ index: Int) {
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
    
    func pageViewerNumberOfPages(_ pageViewer: PageViewer) -> Int {
        return 2
    }
    
    func pageViewer(_ pageViewer: PageViewer, headerForItemAtIndex index: Int) -> String {
        return [CustomLocalisedString("INVOICES"), CustomLocalisedString("PREALERTS")][index]
    }
    
    func pageViewer(_ pageViewer: PageViewer, pageForItemAtIndex index: Int, reusableView: UIView?) -> UIView {
        var pageView: DocumentsPageView! = reusableView as? DocumentsPageView
        if pageView == nil {
            pageView = Bundle.main.loadNibNamed("DocumentsPageView", owner: self, options: nil)?.first as! DocumentsPageView
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
    
    func documentsPageView(_ documentsPageView: DocumentsPageView, didSelectDocument document: Document) {
        if documentsPageView.invoicesMode {
            self.selectedInvoice = document
            self.performSegue(withIdentifier: K.Storyboard.SegueIdentifier.InvoiceDetails, sender: self)
        }
    }
}
