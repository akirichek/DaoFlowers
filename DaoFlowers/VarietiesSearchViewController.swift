//
//  VarietiesSearchViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/25/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class VarietiesSearchViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var additionalParametersArrowImageView: UIImageView!
    @IBOutlet weak var additionalParametersContainerView: UIView!
    @IBOutlet weak var additionalParametersOverlayView: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var additionalParametersLabel: UILabel!
    @IBOutlet weak var hintLabel: UILabel!

    var searchResults: [Variety] = []
    var flowersSearchParams: [Flower]?
    var colorsSearchParams: [Color]?
    var breedersSearchParams: [Breeder]?
    
    // MARK: Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        additionalParametersLabel.text = CustomLocalisedString("AdditionalParameters")
        searchBar.placeholder = CustomLocalisedString("VarietyOrAbr")
        self.containerView.frame = self.contentViewFrame()
        hintLabel.text = CustomLocalisedString("Here will be displayed results of the search")
        self.collectionView.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.collectionViewLayout.invalidateLayout()
        
        if self.flowersSearchParams == nil {
            self.fetchVarietiesSearchParameters()
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
    
    func searchVarieties() {
        let additionalParametersView = self.additionalParametersContainerView.subviews.first as? VarietiesSearchAdditionalParametersView
        
        RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
        ApiManager.searchVarietiesByTerm(self.searchBar.text!,
                                         flowers: additionalParametersView?.selectedFlowers,
                                         colors: additionalParametersView?.selectedColors,
                                         breeders: additionalParametersView?.selectedBreeders) { (varieties, error) in
            RBHUD.sharedInstance.hideLoader()
            if let varieties = varieties {
                self.searchResults = varieties
                self.collectionView.reloadData()
                if varieties.count == 0 {
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
    
    func fetchVarietiesSearchParameters() {
        RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
        ApiManager.fetchVarietiesSearchParameters { (searchParams, error) in
            RBHUD.sharedInstance.hideLoader()
            if let searchParams = searchParams {
                let (flowers, colors, breeders) = searchParams
                self.flowersSearchParams = flowers
                self.colorsSearchParams = colors
                self.breedersSearchParams = breeders
            } else {
                Utils.showError(error!, inViewController: self)
            }
        }
    }
    
    func animateAdditionalParametersView(show: Bool) {
        if self.additionalParametersContainerView.subviews.count == 0 {
            let additionalParametersView = Bundle.main.loadNibNamed("VarietiesSearchAdditionalParametersView", owner: self, options: nil)?.first as! VarietiesSearchAdditionalParametersView
            additionalParametersView.flowersSearchParams = self.flowersSearchParams
            additionalParametersView.colorsSearchParams = self.colorsSearchParams
            additionalParametersView.breedersSearchParams = self.breedersSearchParams
            additionalParametersView.frame = self.additionalParametersContainerView.bounds
            additionalParametersView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
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
        self.searchVarieties()
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VarietyCollectionViewCellIdentifier", for: indexPath) as! VarietyCollectionViewCell
        cell.variety = self.searchResults[indexPath.row]
        cell.numberLabel.text = String(indexPath.row + 1)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: K.Storyboard.SegueIdentifier.VarietyDetails,
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
         if let varietyDetailsViewController = destinationViewController as? VarietyDetailsViewController {
            let cell = sender as! VarietyCollectionViewCell
            varietyDetailsViewController.variety = cell.variety
         }
     }
    
    // MARK: - UISearchBarDelegate

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchVarieties()
        self.searchBar.resignFirstResponder()
        animateAdditionalParametersView(show: false)
    }
}
