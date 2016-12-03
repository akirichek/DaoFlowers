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
    var viewWillTransitionToSize = UIScreen.mainScreen().bounds.size
    var spinner = RBHUD()
    var plantations: [Plantation]? {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Override Methods
    
    override func awakeFromNib() {
        let nib = UINib(nibName:"PlantationCollectionViewCell", bundle: nil)
        self.collectionView.registerNib(nib, forCellWithReuseIdentifier: "PlantationCollectionViewCellIdentifier")
        contentAvailableForCustomersLabel.text = CustomLocalisedString("Content available only for customers")
        registrationButton.setTitle(CustomLocalisedString("GO TO REGISTRATION"), forState: .Normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.plantations == nil {
            self.collectionView.hidden = true
            //self.spinner.showLoader(self, withTitle: nil, withSubTitle: nil, withProgress: true)
        }
    }
    
    // MARK: - Action Methods
    
    @IBAction func registrationButtonClicked(sender: UIButton) {
        viewController.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.Registration, sender: self)
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfRows = 0
        if self.plantations == nil {
            self.setNeedsLayout()
        } else {
            numberOfRows = self.plantations!.count
        }
        return numberOfRows
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PlantationCollectionViewCellIdentifier", forIndexPath: indexPath) as! PlantationCollectionViewCell
        cell.plantation = self.plantations![indexPath.row]
        cell.numberLabel.text = String(indexPath.row + 1)
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        viewController.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.PlantationDetails,
                                                  sender: indexPath.row)
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
}
