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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.viewWillTransitionToSize = size
        if self.collectionView != nil {
            self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination
        if let plantationsViewController = destinationViewController as? PlantationsViewController {
            let cell = sender as! UICollectionViewCell
            let indexPath = self.collectionView.indexPath(for: cell)!
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return countries.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CountryCollectionViewCellIdentifier", for: indexPath) as! CountryCollectionViewCell
        cell.country = self.countries[indexPath.row]
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: K.Storyboard.SegueIdentifier.Plantations,
                                        sender: collectionView.cellForItem(at: indexPath))
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
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
