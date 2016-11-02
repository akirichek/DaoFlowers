//
//  VarietyDetailsViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/22/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class VarietyDetailsViewController: UIViewController, PageViewerDataSource, VarietyDetailsSimilarVarietiesViewDelegate {

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
        let pageViewer = NSBundle.mainBundle().loadNibNamed("PageViewer", owner: self, options: nil).first as! PageViewer
        pageViewer.dataSource = self
        pageViewer.translatesAutoresizingMaskIntoConstraints = false
        self.pageViewerContainerView.addSubview(pageViewer)
        self.pageViewer = pageViewer
        self.adjustConstraints()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.pageViewer.viewWillTransitionToSize = size
        self.pageViewer.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let page = self.pageViewer.pageAtIndex(0) as? VarietyDetailsGeneralInfoView {
            page.variety = self.variety
        }
    }

    // MARK: Private Methods
    
    func adjustConstraints() {
        let leadingConstraint = NSLayoutConstraint(item: self.pageViewer,
                                                   attribute: NSLayoutAttribute.Leading,
                                                   relatedBy: NSLayoutRelation.Equal,
                                                   toItem: self.pageViewerContainerView,
                                                   attribute: NSLayoutAttribute.Leading,
                                                   multiplier: 1,
                                                   constant: 0)
        let trailingConstraint = NSLayoutConstraint(item: self.pageViewer,
                                                    attribute: NSLayoutAttribute.Trailing,
                                                    relatedBy: NSLayoutRelation.Equal,
                                                    toItem: self.pageViewerContainerView,
                                                    attribute: NSLayoutAttribute.Trailing,
                                                    multiplier: 1,
                                                    constant: 0)
        let topConstraint = NSLayoutConstraint(item: self.pageViewer,
                                               attribute: NSLayoutAttribute.Top,
                                               relatedBy: NSLayoutRelation.Equal,
                                               toItem: self.pageViewerContainerView,
                                               attribute: NSLayoutAttribute.Top,
                                               multiplier: 1,
                                               constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: self.pageViewer,
                                                  attribute: NSLayoutAttribute.Bottom,
                                                  relatedBy: NSLayoutRelation.Equal,
                                                  toItem: self.pageViewerContainerView,
                                                  attribute: NSLayoutAttribute.Bottom,
                                                  multiplier: 1,
                                                  constant: 0)
        NSLayoutConstraint.activateConstraints([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
    }
    
    func fetchGeneralInfo() {
        ApiManager.fetchGeneralInfoForVariety(self.variety) { (success, error) in
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
                header = "GENERAL INFO"
            case 1:
                header = "PLANTATIONS - GROWERS"
            case 2:
                header = "SIMILAR VARIETIES"
            default:
                header = ""
        }
        return header
    }
    
    func pageViewer(pageViewer: PageViewer, pageForItemAtIndex index: Int, reusableView: UIView?) -> UIView {
        let nibName: String
        switch index {
        case 0:
            nibName = "VarietyDetailsGeneralInfoView"
        case 1:
            nibName = "VarietyDetailsPlantationsGrowersView"
        case 2:
            nibName = "VarietyDetailsSimilarVarietiesView"
        default:
            nibName = ""
        }
        
        var pageView =  NSBundle.mainBundle().loadNibNamed(nibName, owner: self, options: nil).first as? UIView
        if let varietyDetailsGeneralInfoView = pageView as? VarietyDetailsGeneralInfoView {
            if varietyDetailsGeneralInfoView.variety == nil {
                self.fetchGeneralInfo()
            }
        } else if let varietyDetailsPlantationsGrowersView = pageView as? VarietyDetailsPlantationsGrowersView {
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
