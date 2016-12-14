//
//  PlantationsSearchViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 11/8/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class PlantationsSearchViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var additionalParametersArrowImageView: UIImageView!
    @IBOutlet weak var additionalParametersContainerView: UIView!
    @IBOutlet weak var additionalParametersOverlayView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var additionalParametersLabel: UILabel!
    @IBOutlet weak var hintLabel: UILabel!
    
    var searchResults: [Plantation] = []
    var countriesSearchParams: [Country]?
    var flowersSearchParams: [Flower]?
    
    // MARK: Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        additionalParametersLabel.text = CustomLocalisedString("AdditionalParameters")
        searchBar.placeholder = CustomLocalisedString("Plantation name or brand")
        self.containerView.frame = self.contentViewFrame()
        hintLabel.text = CustomLocalisedString("Here will be displayed results of the search")
        self.collectionView.hidden = true
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.collectionViewLayout.invalidateLayout()
        
        if self.countriesSearchParams == nil {
            self.fetchPlantationsSearchParameters()
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.viewWillTransitionToSize = size
        self.containerView.frame = self.contentViewFrame()
        self.collectionView.reloadData()
        let additionalParametersView = self.additionalParametersContainerView.subviews.first as? VarietiesSearchAdditionalParametersView
        additionalParametersView?.viewWillTransitionToSize = size
        additionalParametersView?.reloadView()
    }
    
    // MARK: - Private Methods
    
    func searchPlantations() {
        let additionalParametersView = self.additionalParametersContainerView.subviews.first as? PlantationsSearchAdditionalParametersView
        RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
        ApiManager.searchPlantationsByTerm(self.searchBar.text!, countries: additionalParametersView?.selectedCountries, flowers: additionalParametersView?.selectedFlowers) { (plantations, error) in
            RBHUD.sharedInstance.hideLoader()
            if let plantations = plantations {
                self.searchResults = plantations
                self.collectionView.reloadData()
                if plantations.count == 0 {
                    self.collectionView.hidden = true
                    self.hintLabel.text = CustomLocalisedString("Search result is empty")
                } else {
                    self.collectionView.hidden = false
                }
            } else {
                Utils.showError(error!, inViewController: self)
            }
        }
    }
    
    func fetchPlantationsSearchParameters() {
        RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
        ApiManager.fetchPlantationsSearchParameters { (searchParams, error) in
            RBHUD.sharedInstance.hideLoader()
            if let searchParams = searchParams {
                let (countries, flowers) = searchParams
                self.countriesSearchParams = countries
                self.flowersSearchParams = flowers
            } else {
                Utils.showError(error!, inViewController: self)
            }
        }
    }
    
    func animateAdditionalParametersView(show show: Bool) {
        if self.additionalParametersContainerView.subviews.count == 0 {
            let additionalParametersView = NSBundle.mainBundle().loadNibNamed("PlantationsSearchAdditionalParametersView", owner: self, options: nil).first as! PlantationsSearchAdditionalParametersView
            additionalParametersView.countriesSearchParams = self.countriesSearchParams
            additionalParametersView.flowersSearchParams = self.flowersSearchParams
            additionalParametersView.frame = self.additionalParametersContainerView.bounds
            self.additionalParametersContainerView.addSubview(additionalParametersView)
        }
        
        if show {
            self.additionalParametersArrowImageView.image = UIImage(named: "up_arrow")
        } else {
            self.additionalParametersArrowImageView.image = UIImage(named: "down_arrow")
        }
        
        self.additionalParametersOverlayView.hidden = !show
    }
    
    // MARK: - Actions
    
    @IBAction func searchButtonClicked(sender: UIBarButtonItem) {
        self.searchPlantations()
        self.searchBar.resignFirstResponder()
        animateAdditionalParametersView(show: false)
    }
    
    @IBAction func additionalParametersButtonClicked(sender: UIButton) {
        animateAdditionalParametersView(show: self.additionalParametersOverlayView.hidden)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PlantationCollectionViewCellIdentifier", forIndexPath: indexPath) as! PlantationCollectionViewCell
        cell.plantation = self.searchResults[indexPath.row]
        cell.numberLabel.text = String(indexPath.row + 1)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.PlantationDetails,
                                        sender: collectionView.cellForItemAtIndexPath(indexPath))
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenSize = self.viewWillTransitionToSize
        let columnCount: Int
        if screenSize.width < screenSize.height {
            columnCount = 1
        } else {
            columnCount = 2
        }
        
        let width = screenSize.width / CGFloat(columnCount)
        return CGSize(width: width, height: 60)
    }
    
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController = segue.destinationViewController
        if let plantationDetailsViewController = destinationViewController as? PlantationDetailsViewController {
            let cell = sender as! PlantationCollectionViewCell
            plantationDetailsViewController.plantation = cell.plantation
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchPlantations()
        self.searchBar.resignFirstResponder()
        animateAdditionalParametersView(show: false)
    }
}
