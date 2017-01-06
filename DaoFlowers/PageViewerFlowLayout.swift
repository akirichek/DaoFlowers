//
//  PageViewerFlowLayout.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/20/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

open class PageViewerFlowLayout: UICollectionViewFlowLayout {
    
    fileprivate var lastCollectionViewSize: CGSize = CGSize.zero
    
    open var scalingOffset: CGFloat = 200
    open var minimumScaleFactor: CGFloat = 0.9
    open var velocity: CGFloat = 0.2
    open var scaleItems: Bool = true
    
    static func configureLayout(_ collectionView: UICollectionView) -> PageViewerFlowLayout {
        let layout = PageViewerFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = layout
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
            
        return layout
    }
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if !self.scaleItems || self.collectionView == nil {
            return super.layoutAttributesForElements(in: rect)
        }
        
        let superAttributes = super.layoutAttributesForElements(in: rect)
        
        if superAttributes == nil {
            return nil
        }
        
        let contentOffset = self.collectionView!.contentOffset
        let size = self.collectionView!.bounds.size
        
        let visibleRect = CGRect(x: contentOffset.x, y: contentOffset.y, width: size.width, height: size.height)
        let visibleCenterX = visibleRect.midX
        
        var newAttributesArray = Array<UICollectionViewLayoutAttributes>()
        
        for (_, attributes) in superAttributes!.enumerated() {
            let newAttributes = attributes.copy() as! UICollectionViewLayoutAttributes
            newAttributesArray.append(newAttributes)
            let distanceFromCenter = visibleCenterX - newAttributes.center.x
            let absDistanceFromCenter = min(abs(distanceFromCenter), self.scalingOffset)
            var scale = absDistanceFromCenter * (self.velocity - 1) / self.scalingOffset + 1
            var alpha = absDistanceFromCenter * (0.00001 - 1) / self.scalingOffset + 1
            
            if alpha < 0.7 {
                alpha = 0.7
            }
            
            if scale < self.minimumScaleFactor {
                scale = self.minimumScaleFactor
            }
            
            newAttributes.transform3D = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
            newAttributes.alpha = alpha
        }
        
        return newAttributesArray;
    }
}
