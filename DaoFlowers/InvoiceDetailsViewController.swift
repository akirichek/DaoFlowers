//
//  InvoiceDetailsViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/17/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class InvoiceDetailsViewController: BaseViewController, PageViewerDataSource, InvoiceDetailsGeneralFilterViewDelegate {
    
    @IBOutlet weak var pageViewerContainerView: UIView!
    @IBOutlet weak var filterButton: UIBarButtonItem!
    var pageViewer: PageViewer!
    var invoice: Document!
    var invoiceDetails: InvoiceDetails!
    var filteredInvoiceDetails: InvoiceDetails!
    var filterView: InvoiceDetailsGeneralFilterView!
    var filterViewState: InvoiceDetailsGeneralFilterViewState = InvoiceDetailsGeneralFilterViewState()
    
    
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
        if let filterView = self.filterView {
            filterView.viewWillTransitionToSize = size
        }
    }
    
    // MARK: - Private Methods
    
    func fetchInvoiceDetailsForPageViewAtIndex(index: Int) {
        ApiManager.fetchInvoiceDetails(invoice, user: User.currentUser()!) { (invoiceDetails, error) in
            if let invoiceDetails = invoiceDetails {
                if let pageView = self.pageViewer.pageAtIndex(index) as? InvoiceDetailsGeneralViewPage {
                    pageView.invoice = self.invoice
                    pageView.invoiceDetails = invoiceDetails
                    self.invoiceDetails = invoiceDetails
                    self.filteredInvoiceDetails = invoiceDetails
                }
            } else {
                Utils.showError(error!, inViewController: self)
            }
        }
    }
    
    func filterInvoiceDetails() {
        filteredInvoiceDetails = invoiceDetails
        
        if let selectedCountry = filterViewState.selectedCountry {
            filteredInvoiceDetails.heads = invoiceDetails.heads.filter({$0.countryId == selectedCountry.id})
        }
        
        if let selectedPlantation = filterViewState.selectedPlantation {
            filteredInvoiceDetails.heads = invoiceDetails.heads.filter({$0.plantationId == selectedPlantation.id})
        }
        
        if let selectedFlower = filterViewState.selectedFlower {
            filteredInvoiceDetails.heads = invoiceDetails.heads.filter({$0.flowerTypeId == selectedFlower.id})
        }
        
        if let selectedAwb = filterViewState.selectedAwb {
            filteredInvoiceDetails.heads = invoiceDetails.heads.filter({$0.awb == selectedAwb})
        }
        
        var filteredHeads: [InvoiceDetails.Head] = []
        for head in filteredInvoiceDetails.heads {
            var filteredHead = head
            if let selectedVariety = filterViewState.selectedVariety {
                filteredHead.rows = head.rows.filter({$0.flowerSortId == selectedVariety.id})
            }
            if let selectedSize = filterViewState.selectedSize {
                filteredHead.rows = head.rows.filter({$0.flowerSizeId == selectedSize.id})
            }
            
            if filteredHead.rows.count > 0 {
                filteredHeads.append(filteredHead)
            }
        }
        filteredInvoiceDetails.heads = filteredHeads
        
        if let pageView = self.pageViewer.pageAtIndex(0) as? InvoiceDetailsGeneralViewPage {
            pageView.invoice = self.invoice
            pageView.invoiceDetails = filteredInvoiceDetails
        }
        
        if filterViewState.selectedCountry == nil &&
            filterViewState.selectedPlantation == nil &&
            filterViewState.selectedFlower == nil &&
            filterViewState.selectedAwb == nil &&
            filterViewState.selectedVariety == nil &&
            filterViewState.selectedSize == nil {
            self.filterButton.tintColor = UIColor.whiteColor()
        } else {
            self.filterButton.tintColor = UIColor(red: 237/255, green: 221/255, blue: 6/255, alpha: 1)
        }
    }
    
    // MARK: - Actions
        
    @IBAction func iconFilterClicked(sender: UIBarButtonItem) {
        if filterView == nil {
            filterView = NSBundle.mainBundle().loadNibNamed("InvoiceDetailsGeneralFilterView", owner: self, options: nil).first as! InvoiceDetailsGeneralFilterView
            filterView.frame = self.view.bounds
            filterView.viewWillTransitionToSize = self.viewWillTransitionToSize
            filterView.invoiceDetails = invoiceDetails
            filterView.delegate = self
        }
        
        filterView.state = filterViewState
        self.view.addSubview(filterView)
    }
    
    // MARK: - PageViewerDataSource
    
    func pageViewerNumberOfPages(pageViewer: PageViewer) -> Int {
        return 3
    }
    
    func pageViewer(pageViewer: PageViewer, headerForItemAtIndex index: Int) -> String {
        return ["GENERAL", "AVERAGE PRICES", "STATISTICS OF FULFILMENT"][index]
    }
    
    func pageViewer(pageViewer: PageViewer, pageForItemAtIndex index: Int, reusableView: UIView?) -> UIView {
        var pageView: InvoiceDetailsGeneralViewPage! = reusableView as? InvoiceDetailsGeneralViewPage
        
        if pageView == nil {
            pageView = NSBundle.mainBundle().loadNibNamed("InvoiceDetailsGeneralViewPage", owner: self, options: nil).first as! InvoiceDetailsGeneralViewPage
            //pageView.delegate = self
        }
        
        pageView.viewWillTransitionToSize = self.viewWillTransitionToSize
        
        
        switch index {
        case 0:
            if let invoiceDetails = self.filteredInvoiceDetails {
                pageView.invoice = invoice
                pageView.invoiceDetails = invoiceDetails
            } else {
                fetchInvoiceDetailsForPageViewAtIndex(index)
            }
        case 1:
            break
        case 2:
            break
        default:
            break
        }
        
        self.view.endEditing(true)
        
        return pageView!
    }
    
    // MARK: - InvoiceDetailsGeneralFilterViewDelegate
    
    func invoiceDetailsGeneralFilterViewDidFilter(invoiceDetailsGeneralFilterView: InvoiceDetailsGeneralFilterView,
                                                  withState state: InvoiceDetailsGeneralFilterViewState) {
        filterViewState = state
        filterInvoiceDetails()
    }
}
