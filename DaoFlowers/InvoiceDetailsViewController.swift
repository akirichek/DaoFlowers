//
//  InvoiceDetailsViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/17/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class InvoiceDetailsViewController: BaseViewController, PageViewerDataSource, PageViewerDelegate, InvoiceDetailsGeneralFilterViewDelegate {
    
    @IBOutlet weak var pageViewerContainerView: UIView!
    var filterButton: UIBarButtonItem!
    var pageViewer: PageViewer!
    var invoice: Document!
    var invoiceDetails: InvoiceDetails!
    var filteredInvoiceDetails: InvoiceDetails!
    var filterView: InvoiceDetailsGeneralFilterView!
    var filterViewState: InvoiceDetailsGeneralFilterViewState = InvoiceDetailsGeneralFilterViewState()
    var selectedIndexOfPage = 0
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pageViewerContainerView.frame = self.contentViewFrame()
        let pageViewer = NSBundle.mainBundle().loadNibNamed("PageViewer", owner: self, options: nil).first as! PageViewer
        pageViewer.frame = self.pageViewerContainerView.bounds
        pageViewer.dataSource = self
        pageViewer.delegate = self
        pageViewer.viewWillTransitionToSize = self.contentViewFrame().size
        pageViewer.reloadData()
        self.pageViewerContainerView.addSubview(pageViewer)
        self.pageViewer = pageViewer
        adjustBarButtonItems()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.viewWillTransitionToSize = size
        self.pageViewer.viewWillTransitionToSize = self.contentViewFrame().size
        self.pageViewerContainerView.frame = self.contentViewFrame()
        self.pageViewer.reloadData()
        if let filterView = self.filterView {
            filterView.viewWillTransitionToSize = size
        }
    }
    
    // MARK: - Private Methods
    
    func adjustBarButtonItems() {
        var buttons: [UIBarButtonItem] = []
        if invoice.zipFile.characters.count > 0 {
            let downloadButton = UIBarButtonItem(image: UIImage(named: "icon_download")!, style: .Plain, target: self, action: #selector(InvoiceDetailsViewController.downloadButtonClicked(_:)))
            buttons.append(downloadButton)
        }
        
        if selectedIndexOfPage == 0 {
            filterButton = UIBarButtonItem(image: UIImage(named: "icon_filter")!, style: .Plain, target: self, action: #selector(InvoiceDetailsViewController.filterButtonClicked(_:)))
            buttons.append(filterButton)
        }
        
        self.navigationItem.rightBarButtonItems = buttons
    }
    
    func fetchInvoiceDetailsForPageViewAtIndex(index: Int) {
        ApiManager.fetchInvoiceDetails(invoice, user: User.currentUser()!) { (invoiceDetails, error) in
            if let invoiceDetails = invoiceDetails {
                self.invoiceDetails = invoiceDetails
                self.filteredInvoiceDetails = invoiceDetails
                if let pageView = self.pageViewer.pageAtIndex(index) as? InvoiceDetailsGeneralViewPage {
                    pageView.viewWillTransitionToSize = self.viewWillTransitionToSize
                    pageView.invoice = self.invoice
                    pageView.invoiceDetails = invoiceDetails
                } else if let pageView = self.pageViewer.pageAtIndex(index) as? InvoiceDetailsAveragePricesViewPage {
                    pageView.viewWillTransitionToSize = self.viewWillTransitionToSize
                    pageView.invoice = self.invoice
                    pageView.invoiceDetails = invoiceDetails
                } else if let pageView = self.pageViewer.pageAtIndex(index) as? InvoiceDetailsStatisticsViewPage {
                    pageView.viewWillTransitionToSize = self.viewWillTransitionToSize
                    pageView.invoice = self.invoice
                    pageView.invoiceDetails = invoiceDetails
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
        
    func filterButtonClicked(sender: UIBarButtonItem) {
        if filterView == nil {
            filterView = LanguageManager.loadNibNamed("InvoiceDetailsGeneralFilterView", owner: self, options: nil).first as! InvoiceDetailsGeneralFilterView
            filterView.frame = self.view.bounds
            filterView.viewWillTransitionToSize = self.viewWillTransitionToSize
            filterView.invoiceDetails = invoiceDetails
            filterView.delegate = self
        }
        
        filterView.state = filterViewState
        self.view.addSubview(filterView)
    }
    
    func downloadButtonClicked(sender: UIBarButtonItem) {
        let message = CustomLocalisedString("Do you want to start download document")
        let alertController = UIAlertController(title: CustomLocalisedString("Downloading"),
                                                message: "\(message) \(invoice.fileName) ?",
                                                preferredStyle: .Alert)
        let yesAlertAction = UIAlertAction(title: CustomLocalisedString("YES"), style: .Default) { alertAction in
            ApiManager.sharedInstance.downloadDocument(self.invoice, user: User.currentUser()!) { (error) in
                if let error = error {
                    Utils.showError(error, inViewController: self)
                }
            }
        }
        let noAlertAction = UIAlertAction(title: CustomLocalisedString("NO"), style: .Default, handler: nil)
        alertController.addAction(noAlertAction)
        alertController.addAction(yesAlertAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - PageViewerDataSource
    
    func pageViewerNumberOfPages(pageViewer: PageViewer) -> Int {
        return 3
    }
    
    func pageViewer(pageViewer: PageViewer, headerForItemAtIndex index: Int) -> String {
        return [CustomLocalisedString("GENERAL"), CustomLocalisedString("AVERAGE PRICES"), CustomLocalisedString("STATISTICS OF FULFILMENT")][index]
    }
    
    func pageViewer(pageViewer: PageViewer, pageForItemAtIndex index: Int, reusableView: UIView?) -> UIView {
        let nibName: String
        switch index {
        case 0:
            nibName = "InvoiceDetailsGeneralViewPage"
        case 1:
            nibName = "InvoiceDetailsAveragePricesViewPage"
        case 2:
            nibName = "InvoiceDetailsStatisticsViewPage"
        default:
            nibName = ""
        }
        
        let pageView = NSBundle.mainBundle().loadNibNamed(nibName, owner: self, options: nil).first as! UIView
        
        if let invoiceDetails = self.filteredInvoiceDetails {
            if let generalPageView = pageView as? InvoiceDetailsGeneralViewPage {
                generalPageView.viewWillTransitionToSize = self.viewWillTransitionToSize
                generalPageView.invoice = invoice
                generalPageView.invoiceDetails = invoiceDetails
            } else if let averagePricesViewPage = pageView as? InvoiceDetailsAveragePricesViewPage {
                averagePricesViewPage.viewWillTransitionToSize = self.viewWillTransitionToSize
                averagePricesViewPage.invoice = invoice
                averagePricesViewPage.invoiceDetails = invoiceDetails
            } else if let statisticsPageView = pageView as? InvoiceDetailsStatisticsViewPage {
                statisticsPageView.viewWillTransitionToSize = self.viewWillTransitionToSize
                statisticsPageView.invoice = invoice
                statisticsPageView.invoiceDetails = invoiceDetails
            }
        } else {
            fetchInvoiceDetailsForPageViewAtIndex(index)
        }
        
        return pageView
    }
    
    // MARK: - PageViewerDelegate
    
    func pageViewer(pageViewer: PageViewer, didSelectPageAtIndex index: Int) {
        selectedIndexOfPage = index
        adjustBarButtonItems()
    }
    
    // MARK: - InvoiceDetailsGeneralFilterViewDelegate
    
    func invoiceDetailsGeneralFilterViewDidFilter(invoiceDetailsGeneralFilterView: InvoiceDetailsGeneralFilterView,
                                                  withState state: InvoiceDetailsGeneralFilterViewState) {
        filterViewState = state
        filterInvoiceDetails()
    }
}
