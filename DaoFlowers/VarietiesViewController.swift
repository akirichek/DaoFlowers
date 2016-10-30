//
//  VarietiesViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/16/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class VarietiesViewController: BaseViewController, PageViewerDataSource, VarietiesPageViewDelegate {
    
    @IBOutlet weak var pageViewerContainerView: UIView!
    var pageViewer: PageViewer!
    
    var flower: Flower!
    var colors: [Color] = []
    var selectedVariety: Variety!
    var pageViewStates: [Int: VarietiesPageViewState] = [:]
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pageViewer = NSBundle.mainBundle().loadNibNamed("PageViewer", owner: self, options: nil).first as! PageViewer
        pageViewer.dataSource = self
        pageViewer.translatesAutoresizingMaskIntoConstraints = false
        self.pageViewerContainerView.addSubview(pageViewer)
        self.pageViewer = pageViewer
        self.adjustConstraintsForItem(self.pageViewer, toItem: self.pageViewerContainerView)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.pageViewer.viewWillTransitionToSize = size
        self.pageViewer.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController = segue.destinationViewController
        if let varietyDetailsViewController = destinationViewController as? VarietyDetailsViewController {
            varietyDetailsViewController.variety = self.selectedVariety
        }
    }
    
    // MARK: - Actions
    
    @IBAction func searchButtonClicked(sender: UIBarButtonItem) {
        if let page = self.pageViewer.pageAtIndex(pageViewer.indexOfCurrentPage) as? VarietiesPageView {
            let indexOfCurrentPage = pageViewer.indexOfCurrentPage
            var pageViewState = pageViewStates[indexOfCurrentPage]!
            pageViewState.filter = !pageViewState.filter
            page.state = pageViewState
            page.reloadData()
            pageViewStates[indexOfCurrentPage] = pageViewState
        }
    }
    
    // MARK: - Private Methods
    
    func fetchVarietiesForPageViewState(pageViewState: VarietiesPageViewState) {
        ApiManager.fetchVarietiesByFlower(self.flower, color: pageViewState.color) { (varieties, error) in
            if let varieties = varieties {
                if let page = self.pageViewer.pageAtIndex(pageViewState.index) as? VarietiesPageView {
                    var state = pageViewState
                    state.varieties = varieties
                    page.state = state
                    page.reloadData()
                    self.pageViewStates[state.index] = state
                }
            } else {
                Utils.showError(error!, inViewController: self)
            }
        }
    }
    
    // MARK: - PageViewerDataSource
    
    func pageViewerNumberOfPages(pageViewer: PageViewer) -> Int {
        return self.colors.count
    }
    
    func pageViewer(pageViewer: PageViewer, headerForItemAtIndex index: Int) -> String {
        return self.colors[index].name
    }
    
    func pageViewer(pageViewer: PageViewer, pageForItemAtIndex index: Int, reusableView: UIView?) -> UIView {
        var pageView: VarietiesPageView! = reusableView as? VarietiesPageView
        
        if pageView == nil {
            pageView = NSBundle.mainBundle().loadNibNamed("VarietiesPageView", owner: self, options: nil).first as! VarietiesPageView
            pageView.delegate = self
        }
        
        var pageViewState: VarietiesPageViewState!
        if self.pageViewStates[index] == nil {
            pageViewState = VarietiesPageViewState(filter: false,
                                                   assortment: .ByPercentsOfPurchase,
                                                   searchString: "",
                                                   varieties: nil,
                                                   color: self.colors[index],
                                                   index: index)
            self.pageViewStates[index] = pageViewState
            self.fetchVarietiesForPageViewState(pageViewState)
        } else {
            pageViewState = self.pageViewStates[index]
        }
        
        pageView.state = pageViewState
        pageView.reloadData()
        
        self.view.endEditing(true)
        
        return pageView!
    }
    
    // MARK: - VarietiesPageViewDelegate
    
    func varietiesPageView(varietiesPageView: VarietiesPageView, didSelectVariety variety: Variety) {
        self.selectedVariety = variety
        self.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.VarietyDetails, sender: self)
    }
    
    func varietiesPageView(varietiesPageView: VarietiesPageView, didChangeState state: VarietiesPageViewState) {
        let indexOfCurrentPage = pageViewer.indexOfCurrentPage
        self.pageViewStates[indexOfCurrentPage] = state
    }
}
