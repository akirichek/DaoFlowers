//
//  ClaimsViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 3/27/17.
//  Copyright © 2017 Dao Flowers. All rights reserved.
//

import UIKit

class ClaimsViewController: BaseViewController, PageViewerDataSource, PageViewerDelegate, ClaimsPageViewDelegate {

    @IBOutlet weak var pageViewerContainerView: UIView!
    
    var pageViewer: PageViewer!
    var claims: [Claim]?
    var users: [User]?
    var fromDate: Date?
    var toDate: Date?
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = CustomLocalisedString("Claims")
        self.pageViewerContainerView.frame = self.contentViewFrame()
        let pageViewer = Bundle.main.loadNibNamed("PageViewer", owner: self, options: nil)?.first as! PageViewer
        pageViewer.frame = self.pageViewerContainerView.bounds
        pageViewer.dataSource = self
        pageViewer.delegate = self
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
        if let claimDetailsViewController = destinationViewController as? ClaimDetailsViewController {
            claimDetailsViewController.claim = sender as? Claim
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        claims = nil
        pageViewer.reloadData()
    }
    
    // MARK: - Private Methods
    
    func fetchClaimsForPageViewIndex(_ index: Int) {
        if fromDate == nil {
            toDate = Date()
            var dateToComponents = Calendar.current.dateComponents([.day, .month, .year], from: toDate!)
            dateToComponents.calendar = Calendar.current
            dateToComponents.month! -= 12
            var dateFromComponents = Calendar.current.dateComponents([.day, .month, .year], from: dateToComponents.date!)
            dateFromComponents.calendar =  Calendar.current
            fromDate = dateFromComponents.date
        }
        
        RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
        ApiManager.fetchClaims(User.currentUser()!, fromDate: fromDate!, toDate: toDate!) { (claims, users, error) in
            RBHUD.sharedInstance.hideLoader()
            if let claims = claims {
                if let pageView = self.pageViewer.pageAtIndex(index) as? ClaimsPageView {
                    pageView.users = users!
                    pageView.claims = claims
                    pageView.fromDate = self.fromDate!
                    pageView.toDate = self.toDate!
                    self.claims = claims
                    self.users = users
                }
            } else {
                Utils.showError(error!, inViewController: self)
            }
        }
    }
    
    // MARK: - Actions
    
    @IBAction func filterButtonClicked(_ sender: UIBarButtonItem) {
        if let pageView = self.pageViewer.pageAtIndex(0) as? ClaimsPageView {
            pageView.filterViewAppears = !pageView.filterViewAppears
        }
    }
    
    // MARK: - PageViewerDataSource
    
    func pageViewerNumberOfPages(_ pageViewer: PageViewer) -> Int {
        return 2
    }
    
    func pageViewer(_ pageViewer: PageViewer, headerForItemAtIndex index: Int) -> String {
        return [CustomLocalisedString("PROCESSED"), CustomLocalisedString("LOCAL DRAFT")][index]
    }
    
    func pageViewer(_ pageViewer: PageViewer, pageForItemAtIndex index: Int, reusableView: UIView?) -> UIView {
        var pageView: ClaimsPageView! = reusableView as? ClaimsPageView
        if pageView == nil {
            pageView = Bundle.main.loadNibNamed("ClaimsPageView", owner: self, options: nil)?.first as! ClaimsPageView
            pageView.delegate = self
        }
        
        pageView.viewWillTransitionToSize = self.viewWillTransitionToSize
        
        if index == 0 {
            if let claims = self.claims {
                pageView.users = users!
                pageView.claims = claims
            } else {
                fetchClaimsForPageViewIndex(index)
            }
        } else if index == 1 {
            pageView.users = [User.currentUser()!]
            pageView.claims = DataManager.fetchClaims()
        }
        
        self.view.endEditing(true)
        
        return pageView!
    }
    
    // MARK: - PageViewerDelegate
    
    func pageViewer(_ pageViewer: PageViewer, didSelectPageAtIndex index: Int) {
        if index == 0 {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "icon_filter"),
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(ClaimsViewController.filterButtonClicked(_:)))
        } else {
            navigationItem.rightBarButtonItem = nil
        }
    }
    
    // MARK: - ClaimsPageViewDelegate
    
    func claimsPageViewDidAddButtonClicked(_ claimsPageView: ClaimsPageView) {
        performSegue(withIdentifier: K.Storyboard.SegueIdentifier.Documents, sender: self)
    }
    
    func claimsPageView(_ claimsPageView: ClaimsPageView, didSelectFromDate fromDate: Date, toDate: Date) {
        self.fromDate = fromDate
        self.toDate = toDate
        fetchClaimsForPageViewIndex(0)
    }
    
    func claimsPageView(_ claimsPageView: ClaimsPageView, didSelectClaim claim: Claim) {
        performSegue(withIdentifier: K.Storyboard.SegueIdentifier.ClaimDetails, sender: claim)
    }
}
