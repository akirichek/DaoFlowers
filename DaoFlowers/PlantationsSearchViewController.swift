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
        self.collectionView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.collectionViewLayout.invalidateLayout()
        
        if self.countriesSearchParams == nil {
            self.fetchPlantationsSearchParameters()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
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
                    self.collectionView.isHidden = true
                    self.hintLabel.text = CustomLocalisedString("Search result is empty")
                } else {
                    self.collectionView.isHidden = false
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
    
    func animateAdditionalParametersView(show: Bool) {
        if self.additionalParametersContainerView.subviews.count == 0 {
            let additionalParametersView = Bundle.main.loadNibNamed("PlantationsSearchAdditionalParametersView", owner: self, options: nil)?.first as! PlantationsSearchAdditionalParametersView
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
        
        self.additionalParametersOverlayView.isHidden = !show
    }
    
    // MARK: - Actions
    
    @IBAction func searchButtonClicked(_ sender: UIBarButtonItem) {
        self.searchPlantations()
        self.searchBar.resignFirstResponder()
        animateAdditionalParametersView(show: false)
    }
    
    @IBAction func additionalParametersButtonClicked(_ sender: UIButton) {
        animateAdditionalParametersView(show: self.additionalParametersOverlayView.isHidden)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantationCollectionViewCellIdentifier", for: indexPath) as! PlantationCollectionViewCell
        cell.plantation = self.searchResults[indexPath.row]
        cell.numberLabel.text = String(indexPath.row + 1)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: K.Storyboard.SegueIdentifier.PlantationDetails,
                                        sender: collectionView.cellForItem(at: indexPath))
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination
        if let plantationDetailsViewController = destinationViewController as? PlantationDetailsViewController {
            let cell = sender as! PlantationCollectionViewCell
            plantationDetailsViewController.plantation = cell.plantation
        }
    }
    
    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchPlantations()
        self.searchBar.resignFirstResponder()
        animateAdditionalParametersView(show: false)
    }
}
