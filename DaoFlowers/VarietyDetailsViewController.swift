//
//  VarietyDetailsViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/22/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class VarietyDetailsViewController: BaseViewController, PageViewerDataSource, VarietyDetailsSimilarVarietiesViewDelegate {

    @IBOutlet weak var pageViewerContainerView: UIView!
    
    var pageViewer: PageViewer!
    var variety: Variety!
    var similarVarieties: [Variety]?
    var plantationsGrowers: [Plantation]?
    var varietyDetailsGeneralInfoView: VarietyDetailsGeneralInfoView!
    
    // MARK: Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "\(variety.name) (\(variety.flower.name))"
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let page = self.pageViewer.pageAtIndex(0) as? VarietyDetailsGeneralInfoView {
            page.variety = self.variety
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController = segue.destinationViewController
        if let varietyImageViewerViewController = destinationViewController as? VarietyImageViewerViewController {
            varietyImageViewerViewController.images = variety.images!
            
            if let indexOfCurrentPage = sender as? Int {
                varietyImageViewerViewController.indexOfCurrentPage = indexOfCurrentPage
            }
        } else if let plantationDetailsViewController = destinationViewController as? PlantationDetailsViewController {
            let index = sender as! Int
            plantationDetailsViewController.plantation = plantationsGrowers![index]
        }
    }

    // MARK: Private Methods
    
    func fetchGeneralInfo() {
        ApiManager.fetchGeneralInfoForVariety(self.variety, user: User.currentUser()) { (success, error) in
            if success {
                let page = self.pageViewer.pageAtIndex(0) as! VarietyDetailsGeneralInfoView
                page.variety = self.variety
            } else {
                Utils.showError(error!, inViewController: self)
            }
        }
    }
    
    func fetchPlantationsGrowers() {
        if let user = User.currentUser() {
            ApiManager.fetchPlantationsGrowersByVariety(self.variety, user: user) { (plantations, error) in
                if let plantations = plantations {
                    self.plantationsGrowers = plantations
                    if let page = self.pageViewer.pageAtIndex(1) as? VarietyDetailsPlantationsGrowersView {
                        page.plantations = plantations
                    }
                } else {
                    Utils.showError(error!, inViewController: self)
                }
            }
        } else {
            
        }
    }
    
    func fetchSimilarVarieties() {
        ApiManager.fetchSimilarVarieties(self.variety) { (varieties, error) in
            if let varieties = varieties {
                self.similarVarieties = varieties
                let page = self.pageViewer.pageAtIndex(2) as! VarietyDetailsSimilarVarietiesView
                page.varieties = varieties
            } else {
                Utils.showError(error!, inViewController: self)
            }
        }
    }
    
    // MARK: PageViewerDataSource
    
    func pageViewerNumberOfPages(pageViewer: PageViewer) -> Int {
        return 3
    }
    
    func pageViewer(pageViewer: PageViewer, headerForItemAtIndex index: Int) -> String {
        let header: String
        switch index {
            case 0:
                header = CustomLocalisedString("GENERAL INFO")
            case 1:
                header = CustomLocalisedString("PLANTATIONS - GROWERS")
            case 2:
                header = CustomLocalisedString("SIMILAR VARIETIES")
            default:
                header = ""
        }
        return header
    }
    
    func pageViewer(pageViewer: PageViewer, pageForItemAtIndex index: Int, reusableView: UIView?) -> UIView {
        var pageView: UIView!
        switch index {
        case 0:
            pageView = LanguageManager.loadNibNamed("VarietyDetailsGeneralInfoView", owner: self, options: nil).first as? UIView
        case 1:
            pageView =   NSBundle.mainBundle().loadNibNamed("VarietyDetailsPlantationsGrowersView", owner: self, options: nil).first as? UIView
        case 2:
            pageView =   NSBundle.mainBundle().loadNibNamed("VarietyDetailsSimilarVarietiesView", owner: self, options: nil).first as? UIView
        default:
            break
        }
        
        if let varietyDetailsGeneralInfoView = pageView as? VarietyDetailsGeneralInfoView {
            varietyDetailsGeneralInfoView.viewController = self
            if varietyDetailsGeneralInfoView.variety == nil {
                self.fetchGeneralInfo()
            }
        } else if let varietyDetailsPlantationsGrowersView = pageView as? VarietyDetailsPlantationsGrowersView {
            varietyDetailsPlantationsGrowersView.viewController = self
            if User.currentUser() != nil {
                if let plantations = self.plantationsGrowers {
                    varietyDetailsPlantationsGrowersView.plantations = plantations
                } else {
                    varietyDetailsPlantationsGrowersView.plantations = []
                    self.fetchPlantationsGrowers()
                }
            }
        } else if let similarVarietiesView = pageView as? VarietyDetailsSimilarVarietiesView {
            similarVarietiesView.delegate = self
            if let varieties = self.similarVarieties {
                similarVarietiesView.varieties = varieties
            } else {
                similarVarietiesView.varieties = []
                self.fetchSimilarVarieties()
            }
        }
        
        return pageView!
    }
    
    // MARK: VarietyDetailsSimilarVarietiesView
    
    func varietyDetailsSimilarVarietiesView(varietyDetailsSimilarVarietiesView: VarietyDetailsSimilarVarietiesView,
                                            didSelectVariety variety: Variety) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let varietyDetailsViewController = storyboard.instantiateViewControllerWithIdentifier(K.Storyboard.ViewControllerIdentifier.VarietyDetails) as! VarietyDetailsViewController
        varietyDetailsViewController.variety = variety
        self.navigationController?.pushViewController(varietyDetailsViewController, animated: true)
    }
}
