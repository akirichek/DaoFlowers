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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = CustomLocalisedString("Varieties")
        
        RBHUD.sharedInstance.showLoader(self.view, withTitle: nil, withSubTitle: nil, withProgress: true)
        ApiManager.fetchFlowers { (flowers, error) in
            RBHUD.sharedInstance.hideLoader()
            if let flowers = flowers {
                self.flowers = flowers
                self.sortFlowers()
                self.collectionView.reloadData()
            } else {
                Utils.showError(error!, inViewController: self)
            }
        }
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
        if let colorsViewController = destinationViewController as? ColorsViewController {
            let cell = sender as! UICollectionViewCell
            let indexPath = self.collectionView.indexPath(for: cell)!
            colorsViewController.selectedFlower = self.flowers[indexPath.row]
            colorsViewController.flowers = self.flowers
        }
    }
    
    func sortFlowers() {
        flowers.sort(by: { (lhs, rhs) -> Bool in
            if (lhs.isGroup && rhs.isGroup) || (!lhs.isGroup && !rhs.isGroup) {
                if lhs.position == rhs.position {
                    return lhs.name < rhs.name
                } else {
                    return lhs.position < rhs.position
                }
            } else if lhs.isGroup {
                return false
            } else {
                return true
            }
        })
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return flowers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FlowerCollectionViewCellIdentifier", for: indexPath) as! FlowerCollectionViewCell
        cell.flower = self.flowers[indexPath.row]
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         self.performSegue(withIdentifier: K.Storyboard.SegueIdentifier.Colors,
                                         sender: collectionView.cellForItem(at: indexPath))
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenSize: CGSize = self.viewWillTransitionToSize
        
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
