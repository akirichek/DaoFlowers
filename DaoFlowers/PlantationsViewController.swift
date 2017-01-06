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
        
        self.title = CustomLocalisedString("Plantations")
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
        if let page = self.pageViewer.pageAtIndex(self.pageViewer.indexOfCurrentPage) as? PlantationsPageView {
            page.viewWillTransitionToSize = size
            page.reloadData()
        }
        self.pageViewer.viewWillTransitionToSize = self.contentViewFrame().size
        self.pageViewerContainerView.frame = self.contentViewFrame()
        self.pageViewer.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination
        if let plantationDetailsViewController = destinationViewController as? PlantationDetailsViewController {
            plantationDetailsViewController.plantation = self.selectedPlantation
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if needsSelectPageView {
            let index = countries.index(where: {$0.id == self.selectedCountry.id})!
            self.pageViewer.selectPageAtIndex(index)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        needsSelectPageView = false
    }
    
    // MARK: - Actions
    
    @IBAction func searchButtonClicked(_ sender: UIBarButtonItem) {
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
    
    func fetchPlantationsForPageViewState(_ pageViewState: PlantationsPageViewState) {
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
    
    func pageViewerNumberOfPages(_ pageViewer: PageViewer) -> Int {
        return self.countries.count
    }
    
    func pageViewer(_ pageViewer: PageViewer, headerForItemAtIndex index: Int) -> String {
        return self.countries[index].name
    }
    
    func pageViewer(_ pageViewer: PageViewer, pageForItemAtIndex index: Int, reusableView: UIView?) -> UIView {
        var pageView: PlantationsPageView! = reusableView as? PlantationsPageView
        
        if pageView == nil {
            pageView = Bundle.main.loadNibNamed("PlantationsPageView", owner: self, options: nil)?.first as! PlantationsPageView
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
    
    func plantationsPageView(_ plantationsPageView: PlantationsPageView, didSelectPlantation plantation: Plantation) {
        self.selectedPlantation = plantation
        self.performSegue(withIdentifier: K.Storyboard.SegueIdentifier.PlantationDetails, sender: self)
    }
    
    func plantationsPageView(_ plantationsPageView: PlantationsPageView, didChangeState state: PlantationsPageViewState) {
        let indexOfCurrentPage = pageViewer.indexOfCurrentPage
        self.pageViewStates[indexOfCurrentPage] = state
    }
}

