//
//  VarietiesSearchViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/25/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class VarietiesSearchViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var additionalParametersArrowImageView: UIImageView!
    @IBOutlet weak var additionalParametersContainerView: UIView!
    var viewWillTransitionToSize = UIScreen.mainScreen().bounds.size
    var searchResults: [Variety] = []
    var flowersSearchParams: [Flower]?
    var colorsSearchParams: [Color]?
    var breedersSearchParams: [Breeder]?
    
    // MARK: Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.collectionViewLayout.invalidateLayout()
        
        if self.flowersSearchParams == nil {
            self.fetchVarietiesSearchParameters()
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.viewWillTransitionToSize = size
        self.collectionView.reloadData()
    }
    
    // MARK: - Private Methods
    
    func searchVarieties() {
        let additionalParametersView = self.additionalParametersContainerView.subviews.first as? VarietiesSearchAdditionalParametersView
        
        RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
        ApiManager.searchVarietiesByTerm(self.searchBar.text!,
                                         flower: additionalParametersView?.selectedFlower,
                                         color: additionalParametersView?.selectedColor,
                                         breeder: additionalParametersView?.selectedBreeder) { (varieties, error) in
            RBHUD.sharedInstance.hideLoader()
            if let varieties = varieties {
                self.searchResults = varieties
                self.collectionView.reloadData()
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
    
    // MARK: - Actions
    
    @IBAction func searchButtonClicked(sender: UIBarButtonItem) {
        self.searchVarieties()
        self.searchBar.resignFirstResponder()
    }
    
    @IBAction func additionalParametersButtonClicked(sender: UIButton) {
        if self.additionalParametersContainerView.subviews.count == 0 {
            let additionalParametersView = NSBundle.mainBundle().loadNibNamed("VarietiesSearchAdditionalParametersView", owner: self, options: nil).first as! VarietiesSearchAdditionalParametersView
            additionalParametersView.flowersSearchParams = self.flowersSearchParams
            additionalParametersView.colorsSearchParams = self.colorsSearchParams
            additionalParametersView.breedersSearchParams = self.breedersSearchParams
            additionalParametersView.frame = self.additionalParametersContainerView.bounds
            additionalParametersView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            self.additionalParametersContainerView.addSubview(additionalParametersView)
        }
        
        if self.additionalParametersContainerView.hidden {
            self.additionalParametersArrowImageView.image = UIImage(named: "down_arrow")
        } else {
            self.additionalParametersArrowImageView.image = UIImage(named: "up_arrow")
        }
        
        self.additionalParametersContainerView.hidden = !self.additionalParametersContainerView.hidden
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("VarietyCollectionViewCellIdentifier", forIndexPath: indexPath) as! VarietyCollectionViewCell
        cell.variety = self.searchResults[indexPath.row]
        cell.numberLabel.text = String(indexPath.row + 1)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.VarietyDetails,
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
         if let varietyDetailsViewController = destinationViewController as? VarietyDetailsViewController {
            let cell = sender as! VarietyCollectionViewCell
            varietyDetailsViewController.variety = cell.variety
         }
     }
    
    // MARK: - UISearchBarDelegate

    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchVarieties()
        self.searchBar.resignFirstResponder()
    }
}
