//
//  ColorsCollectionViewCell.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/17/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

class ColorsCollectionViewCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var flower: Flower!
    var colors: [Color] = [] {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
//        ApiManager.fetchColorsByFlower(self.flower, completion: { (colors, error) in
//            RBHUD.sharedInstance.hideLoader()
//            if let colors = colors {
//                self.colors = colors
//                self.collectionView.reloadData()
//            } else {
//                Utils.showError(error!, inViewController: self)
//            }
//        })
//    }
//    
//    override func viewWillAppear(animated: Bool) {
//        super.viewWillAppear(animated)
//    }
//    
//    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
//        self.collectionView.collectionViewLayout.invalidateLayout()
//    }
//    
//    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        let destinationViewController = segue.destinationViewController
//        if let varietiesViewController = destinationViewController as? VarietiesViewController {
//            let cell = sender as! UICollectionViewCell
//            let indexPath = self.collectionView.indexPathForCell(cell)!
//            varietiesViewController.color = self.colors[indexPath.row]
//            varietiesViewController.flower = self.flower
//        }
//    }
    
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
    
//    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        self.performSegueWithIdentifier(K.Storyboard.SegueIdentifier.Varieties,
//                                        sender: collectionView.cellForItemAtIndexPath(indexPath))
//    }
//    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let columnCount: Int
        
        if self.bounds.width < self.bounds.height {
            columnCount = 2
        } else {
            columnCount = 4
        }
        
        let width = self.bounds.width / CGFloat(columnCount)
        
        print(width, self.bounds.width, self.bounds.height)
        
        return CGSize(width: width, height: width)
    }

}