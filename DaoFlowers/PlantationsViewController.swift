//
//  PlantationsViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/6/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class PlantationsViewController: BaseViewController, PageViewerDataSource, PlantationsPageViewDelegate {
    
    @IBOutlet weak var pageViewerContainerView: UIView!
    var pageViewer: PageViewer!
    
    var countries: [Country] = []
    var selectedCountry: Country!
    var pageViewStates: [Int: PlantationsPageViewState] = [:]
    var needsSelectPageView: Bool = true
    var selectedPlantation: Plantation!
    
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
        if let page = self.pageViewer.pageAtIndex(self.pageViewer.indexOfCurrentPage) as? PlantationsPageView {
            page.viewWillTransitionToSize = size
            page.reloadData()
        }
        self.pageViewer.viewWillTransitionToSize = self.contentViewFrame().size
        self.pageViewer.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController = segue.destinationViewController
        if let plantationDetailsViewController = destinationViewController as? PlantationDetailsViewController {
            plantationDetailsViewController.plantation = self.selectedPlantation
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if needsSelectPageView {
            let index = countries.indexOf({$0.id == self.selectedCountry.id})!
            self.pageViewer.selectPageAtIndex(index)
        }
    }

    override func viewDidAppear(animated: Bool) {
        needsSelectPageView = false
    }
    
    // MARK: - Actions
    
    @IBAction func searchButtonClicked(sender: UIBarButtonItem) {
        if let page = self.pageViewer.pageAtIndex(pageViewer.indexOfCurrentPage) as? PlantationsPageView {
            let indexOfCurrentPage = pageViewer.indexOfCurrentPage
            var pageViewState = pageViewStates[indexOfCurrentPage]!
            pageViewState.filter = !pageViewState.filter
            page.state = pageViewState
            page.reloadData()
            pageViewStates[indexOfCurrentPage] = pageViewState
        }
    }
    
    // MARK: - Private Methods
    
    func fetchPlantationsForPageViewState(pageViewState: PlantationsPageViewState) {
        ApiManager.fetchPlantationsByCountry(countries[pageViewState.index]) { (plantations, error) in
            if let plantations = plantations {
                if let page = self.pageViewer.pageAtIndex(pageViewState.index) as? PlantationsPageView {
                    var state = pageViewState
                    state.plantations = plantations
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
        return self.countries.count
    }
    
    func pageViewer(pageViewer: PageViewer, headerForItemAtIndex index: Int) -> String {
        return self.countries[index].name
    }
    
    func pageViewer(pageViewer: PageViewer, pageForItemAtIndex index: Int, reusableView: UIView?) -> UIView {
        var pageView: PlantationsPageView! = reusableView as? PlantationsPageView
        
        if pageView == nil {
            pageView = NSBundle.mainBundle().loadNibNamed("PlantationsPageView", owner: self, options: nil).first as! PlantationsPageView
            pageView.delegate = self
        }
        
        pageView.viewWillTransitionToSize = self.viewWillTransitionToSize
        
        var pageViewState: PlantationsPageViewState!
        if self.pageViewStates[index] == nil {
            pageViewState = PlantationsPageViewState(filter: false,
                                                     assortment: .ByPercentsOfPurchase,
                                                     searchString: "",
                                                     plantations: nil,
                                                     country: self.countries[index],
                                                     index: index)
            self.pageViewStates[index] = pageViewState
            self.fetchPlantationsForPageViewState(pageViewState)
        } else {
            pageViewState = self.pageViewStates[index]
            if pageViewState.plantations == nil {
                self.fetchPlantationsForPageViewState(pageViewState)
            }
        }
        
        pageView.state = pageViewState
        pageView.reloadData()
 
        self.view.endEditing(true)
        
        return pageView!
    }
    
    // MARK: - PlantationsPageViewDelegate
    
    func plantationsPageView(plantationsPageView: PlantationsPageView, didSelectPlantation plantation: Plantation) {
        self.selectedPlantation = plantation
        self.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.PlantationDetails, sender: self)
    }
    
    func plantationsPageView(plantationsPageView: PlantationsPageView, didChangeState state: PlantationsPageViewState) {
        let indexOfCurrentPage = pageViewer.indexOfCurrentPage
        self.pageViewStates[indexOfCurrentPage] = state
    }
}

