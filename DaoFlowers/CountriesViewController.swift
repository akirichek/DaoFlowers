//
//  CountriesViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/13/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class CountriesViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var countries: [Country] = []
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Override Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = CustomLocalisedString("Plantations")
        self.fetchCountries()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.viewWillTransitionToSize = size
        if self.collectionView != nil {
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController = segue.destinationViewController
        if let plantationsViewController = destinationViewController as? PlantationsViewController {
            let cell = sender as! UICollectionViewCell
            let indexPath = self.collectionView.indexPathForCell(cell)!
            plantationsViewController.selectedCountry = self.countries[indexPath.row]
            plantationsViewController.countries = self.countries
        }
    }
    
    // MARK: Private Methods
    
    func fetchCountries() {
        RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
        ApiManager.fetchCountries { (countries, error) in
            RBHUD.sharedInstance.hideLoader()
            if let countries = countries {
                self.countries = countries
                self.collectionView.reloadData()
            } else {
                Utils.showError(error!, inViewController: self)
            }
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countries.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CountryCollectionViewCellIdentifier", forIndexPath: indexPath) as! CountryCollectionViewCell
        cell.country = self.countries[indexPath.row]
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.Plantations,
                                        sender: collectionView.cellForItemAtIndexPath(indexPath))
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let screenSize: CGSize = self.viewWillTransitionToSize
        
        let columnCount: Int
        var additionalHeight: CGFloat
        if screenSize.width < screenSize.height {
            columnCount = 2
            additionalHeight = 30
        } else {
            columnCount = 3
            additionalHeight = 0
        }
        
        let width = screenSize.width / CGFloat(columnCount)
        
        return CGSize(width: width, height: width + additionalHeight)
    }
}