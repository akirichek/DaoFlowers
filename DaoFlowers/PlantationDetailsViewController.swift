//
//  PlantationDetailsViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/9/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class PlantationDetailsViewController: BaseViewController, PageViewerDataSource, VarietiesByPlantationPageViewDelegate {
    
    @IBOutlet weak var pageViewerContainerView: UIView!
    @IBOutlet weak var infoContainerView: UIView!
    @IBOutlet weak var farmLabel: UILabel!
    @IBOutlet weak var brandLabel: UILabel!
    @IBOutlet weak var countryLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var farmStringLabel: UILabel!
    @IBOutlet weak var brandStringLabel: UILabel!
    @IBOutlet weak var countryStringLabel: UILabel!
    @IBOutlet weak var contentAvailableForCustomers: UILabel!
    
    var pageViewer: PageViewer!
    var plantation: Plantation!
    var varieties: [Int:[Variety]] = [:]
    var flowers: [Flower] = []
    var colors: [Color] = []
    var selectedColor: Color?
    var pageViewStates: [Int: VarietiesByPlantationPageViewState] = [:]
    var hintView: AHintView?
    
    // MARK: - Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentAvailableForCustomers.text = CustomLocalisedString("Content available only for customers")
        farmStringLabel.text = CustomLocalisedString("Farm name")
        brandStringLabel.text = CustomLocalisedString("Brand")
        countryStringLabel.text = CustomLocalisedString("Country")
        
        self.topContainerView.frame = self.topContainerViewFrame()
        self.pageViewerContainerView.frame = self.pageViewerFrame()
        let pageViewer = Bundle.main.loadNibNamed("PageViewer", owner: self, options: nil)?.first as! PageViewer
        pageViewer.frame = self.pageViewerContainerView.bounds
        pageViewer.dataSource = self
        pageViewer.viewWillTransitionToSize = self.pageViewerFrame().size
        self.pageViewerContainerView.addSubview(pageViewer)
        self.pageViewer = pageViewer
        self.title = "\(plantation.name) (\(plantation.brand))"
        self.fetchPlantationDetails()
        self.infoContainerView.layer.cornerRadius = 5
        populateInfoView()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.viewWillTransitionToSize = size
        self.topContainerView.frame = self.topContainerViewFrame()
        if let page = self.pageViewer.pageAtIndex(self.pageViewer.indexOfCurrentPage) as? VarietiesByPlantationPageView {
            page.viewWillTransitionToSize = size
            page.reloadData()
        }
        self.pageViewer.viewWillTransitionToSize = self.pageViewerFrame().size
        self.pageViewerContainerView.frame = self.pageViewerFrame()
        self.pageViewer.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination
        if let varietyDetailsViewController = destinationViewController as? VarietyDetailsViewController {
            varietyDetailsViewController.variety = sender as! Variety
        }
    }
    
    // MARK: - Actions
    
    @IBAction func searchButtonClicked(_ sender: UIBarButtonItem) {
        if let page = self.pageViewer.pageAtIndex(pageViewer.indexOfCurrentPage) as? VarietiesByPlantationPageView {
            let indexOfCurrentPage = pageViewer.indexOfCurrentPage
            var pageViewState = pageViewStates[indexOfCurrentPage]!
            pageViewState.filter = !pageViewState.filter
            page.state = pageViewState
            page.reloadData()
            pageViewStates[indexOfCurrentPage] = pageViewState
        }
    }
    
    @IBAction func infoButtonClicked(_ sender: UIBarButtonItem) {
        if self.hintView?.superview == nil {
            self.hintView = LanguageManager.loadNibNamed("VarietiesListHintView", owner: self, options: nil).first as? AHintView
            self.hintView!.frame = self.view.bounds
            self.view.addSubview(hintView!)
        }
    }
    
    // MARK: - Private Methods
    
    func populateInfoView() {
        farmLabel.text = plantation.name
        brandLabel.text = plantation.brand
        countryLabel.text = plantation.countryName
        if let imageUrl = plantation.imageUrl {
            if let url = URL(string: imageUrl) {
                logoImageView.af_setImage(withURL: url)
            }
        }
    }
    
    func fetchPlantationDetails() {
        RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
        ApiManager.fetchPlantationDetails(self.plantation, user: User.currentUser()) { (plantationDetails, error) in
            RBHUD.sharedInstance.hideLoader()
            if let plantationDetails = plantationDetails {
                self.plantation = plantationDetails
                self.populateInfoView()
                if User.currentUser() != nil {
                    let varieties = plantationDetails.varieties!
                    for variety in varieties {
                        if var varietiesByFlower = self.varieties[variety.flower.id] {
                            varietiesByFlower.append(variety)
                            self.varieties[variety.flower.id] = varietiesByFlower
                        } else {
                            self.varieties[variety.flower.id] = [variety]
                            self.flowers.append(variety.flower)
                        }
                        
                        if self.colors.index(where: {$0.id == variety.color.id}) == nil {
                            if variety.color.id == -1 {
                                self.colors.insert(variety.color, at: 0)
                            } else {
                                self.colors.append(variety.color)
                            }
                        }
                    }
                    self.pageViewer.reloadData()
                } else {
                    self.pageViewerContainerView.isHidden = true
                }

            } else {
                Utils.showError(error!, inViewController: self)
            }
        }
    }

    func pageViewerFrame() -> CGRect {
        let contentViewFrame = self.contentViewFrame()
        let topContainerViewFrame = self.topContainerView.frame
        let pageViewerFrame = CGRect(x: contentViewFrame.origin.x, y: contentViewFrame.origin.y + topContainerViewFrame.height, width: contentViewFrame.width, height: contentViewFrame.height - topContainerViewFrame.height)
        return pageViewerFrame
    }
    
    func topContainerViewFrame() -> CGRect {
        var topContainerViewFrame = self.topContainerView.frame
        topContainerViewFrame.origin.y = self.contentViewFrame().origin.y
        return topContainerViewFrame
    }
    
    // MARK: - PageViewerDataSource
    
    func pageViewerNumberOfPages(_ pageViewer: PageViewer) -> Int {
        return self.flowers.count
    }
    
    func pageViewer(_ pageViewer: PageViewer, headerForItemAtIndex index: Int) -> String {
        return self.flowers[index].name
    }
    
    func pageViewer(_ pageViewer: PageViewer, pageForItemAtIndex index: Int, reusableView: UIView?) -> UIView {
        var pageView: VarietiesByPlantationPageView! = reusableView as? VarietiesByPlantationPageView
        
        if pageView == nil {
            pageView = Bundle.main.loadNibNamed("VarietiesByPlantationPageView", owner: self, options: nil)?.first as! VarietiesByPlantationPageView
            pageView.delegate = self
        }
        
        pageView.viewWillTransitionToSize = self.viewWillTransitionToSize
        
        var pageViewState: VarietiesByPlantationPageViewState!
        if self.pageViewStates[index] == nil {
            pageViewState = VarietiesByPlantationPageViewState(filter: false,
                                                   searchString: "",
                                                   varieties: varieties[flowers[index].id],
                                                   selectedColor: nil,
                                                   colors: self.colors,
                                                   index: index)
            self.pageViewStates[index] = pageViewState
        } else {
            pageViewState = self.pageViewStates[index]
        }
        
        pageView.state = pageViewState
        pageView.reloadData()
        
        self.view.endEditing(true)

        
        return pageView!
    }
    
    // MARK: - VarietiesByPlantationPageViewDelegate
    
    func varietiesByPlantationPageView(_ varietiesByPlantationPageView: VarietiesByPlantationPageView, didSelectVariety variety: Variety) {
        self.performSegue(withIdentifier: K.Storyboard.SegueIdentifier.VarietyDetails, sender: variety)
    }
    
    func varietiesByPlantationPageView(_ varietiesByPlantationPageView: VarietiesByPlantationPageView, didChangeState state: VarietiesByPlantationPageViewState) {
        let indexOfCurrentPage = pageViewer.indexOfCurrentPage
        self.pageViewStates[indexOfCurrentPage] = state
    }
}
