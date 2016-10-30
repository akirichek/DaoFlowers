//
//  FlowersViewController.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/13/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class FlowersViewController: BaseViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var flowers: [Flower] = []
    @IBOutlet weak var collectionView: UICollectionView!
    var viewWillTransitionToSize: CGSize?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
        ApiManager.fetchFlowers { (flowers, error) in
            RBHUD.sharedInstance.hideLoader()
            if let flowers = flowers {
                self.flowers = flowers
                self.collectionView.reloadData()
            } else {
                Utils.showError(error!, inViewController: self)
            }
        }
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
        if let colorsViewController = destinationViewController as? ColorsViewController {
            let cell = sender as! UICollectionViewCell
            let indexPath = self.collectionView.indexPathForCell(cell)!
            colorsViewController.flower = self.flowers[indexPath.row]
        } else if let colorsViewController = destinationViewController as? Colors2ViewController {
            let cell = sender as! UICollectionViewCell
            let indexPath = self.collectionView.indexPathForCell(cell)!
            colorsViewController.selectedFlower = self.flowers[indexPath.row]
            colorsViewController.flowers = self.flowers
        } else if let pageViewController = destinationViewController as? PageViewController {
            let cell = sender as! UICollectionViewCell
            let indexPath = self.collectionView.indexPathForCell(cell)!
            pageViewController.currentFlower = self.flowers[indexPath.row]
            pageViewController.flowers = self.flowers
        }
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flowers.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FlowerCollectionViewCellIdentifier", forIndexPath: indexPath) as! FlowerCollectionViewCell
        cell.flower = self.flowers[indexPath.row]
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
         self.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.Colors,
                                         sender: collectionView.cellForItemAtIndexPath(indexPath))
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var screenSize: CGSize = UIScreen.mainScreen().bounds.size
        if self.viewWillTransitionToSize != nil {
            screenSize = self.viewWillTransitionToSize!
        }
        
        let columnCount: Int
        if screenSize.width < screenSize.height {
            columnCount = 2
        } else {
            columnCount = 4
        }
        
        let width = screenSize.width / CGFloat(columnCount)
        return CGSize(width: width, height: width)
    }
}
