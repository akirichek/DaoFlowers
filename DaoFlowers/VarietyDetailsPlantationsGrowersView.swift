//
//  VarietyDetailsPlantationsGrowersView.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/22/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class VarietyDetailsPlantationsGrowersView: UIView, UICollectionViewDataSource, UICollectionViewDelegate  {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var unavailableContentContainerView: UIView!
    @IBOutlet weak var contentAvailableForCustomersLabel: UILabel!
    @IBOutlet weak var registrationButton: UIButton!
    
    weak var viewController: UIViewController!
    var viewWillTransitionToSize = UIScreen.main.bounds.size
    var spinner = RBHUD()
    var plantations: [Plantation]? {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Override Methods
    
    override func awakeFromNib() {
        let nib = UINib(nibName:"PlantationCollectionViewCell", bundle: nil)
        self.collectionView.register(nib, forCellWithReuseIdentifier: "PlantationCollectionViewCellIdentifier")
        contentAvailableForCustomersLabel.text = CustomLocalisedString("Content available only for customers")
        registrationButton.setTitle(CustomLocalisedString("GO TO REGISTRATION"), for: UIControlState())
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.plantations == nil {
            self.collectionView.isHidden = true
            //self.spinner.showLoader(self, withTitle: nil, withSubTitle: nil, withProgress: true)
        }
    }
    
    // MARK: - Action Methods
    
    @IBAction func registrationButtonClicked(_ sender: UIButton) {
        viewController.performSegue(withIdentifier: K.Storyboard.SegueIdentifier.Registration, sender: self)
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfRows = 0
        if self.plantations == nil {
            self.setNeedsLayout()
        } else {
            numberOfRows = self.plantations!.count
        }
        return numberOfRows
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlantationCollectionViewCellIdentifier", for: indexPath) as! PlantationCollectionViewCell
        cell.plantation = self.plantations![indexPath.row]
        cell.numberLabel.text = String(indexPath.row + 1)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewController.performSegue(withIdentifier: K.Storyboard.SegueIdentifier.PlantationDetails,
                                                  sender: indexPath.row)
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
}
