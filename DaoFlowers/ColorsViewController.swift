//
//  ColorsViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/16/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit
import RBHUD

class ColorsViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var flower: Flower!
    var colors: [Color] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
        ApiManager.fetchColorsByFlower(self.flower, completion: { (colors, error) in
            RBHUD.sharedInstance.hideLoader()
            if let colors = colors {
                self.colors = colors
                self.collectionView.reloadData()
            } else {
                Utils.showError(error!, inViewController: self)
            }            
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationViewController = segue.destinationViewController
        if let varietiesViewController = destinationViewController as? VarietiesViewController {
            varietiesViewController.flower = self.flower
            varietiesViewController.colors = self.colors
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ColorsCollectionViewCellIdentifier", forIndexPath: indexPath) as! ColorCollectionViewCell
        cell.color = self.colors[indexPath.row]
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.Varieties,
                                        sender: collectionView.cellForItemAtIndexPath(indexPath))
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let columnCount: Int
        
        if self.view.bounds.width < self.view.bounds.height {
            columnCount = 2
        } else {
            columnCount = 4
        }
        
        let width = collectionView.frame.size.width / CGFloat(columnCount)
        
        return CGSize(width: width, height: width)
    }
}
