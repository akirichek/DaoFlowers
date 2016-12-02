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
    var selectedColor: Color!
    var pageViewStates: [Int: VarietiesPageViewState] = [:]
    var needsSelectPageView: Bool = true
    
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
        self.title = flower.name
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.viewWillTransitionToSize = size
        self.pageViewerContainerView.frame = self.contentViewFrame()
        if let page = self.pageViewer.pageAtIndex(self.pageViewer.indexOfCurrentPage) as? ColorsPageView {
            page.viewWillTransitionToSize = size
            page.reloadData()
        }
        self.pageViewer.viewWillTransitionToSize = self.contentViewFrame().size
        self.pageViewer.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController = segue.destinationViewController
        if let varietyDetailsViewController = destinationViewController as? VarietyDetailsViewController {
            varietyDetailsViewController.variety = self.selectedVariety
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if needsSelectPageView {
            let index = colors.indexOf({$0.id == self.selectedColor.id})!
            self.pageViewer.selectPageAtIndex(index)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        needsSelectPageView = false
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
    
    @IBAction func infoButtonClicked(sender: UIBarButtonItem) {
        let hintView = NSBundle.mainBundle().loadNibNamed("VarietiesListHintView", owner: self, options: nil).first as! AHintView
        hintView.frame = self.view.bounds
        self.view.addSubview(hintView)
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
        
        pageView.viewWillTransitionToSize = self.viewWillTransitionToSize
        
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
            if pageViewState.varieties == nil {
                self.fetchVarietiesForPageViewState(pageViewState)
            }
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
