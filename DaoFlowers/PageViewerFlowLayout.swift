//
//  PageViewerFlowLayout.swift
//  DaoFlowers
//
//  Created by Artem Kirichek on 10/20/16.
//  Copyright © 2016 Dao Flowers. All rights reserved.
//

import UIKit

public class PageViewerFlowLayout: UICollectionViewFlowLayout {
    
    private var lastCollectionViewSize: CGSize = CGSizeZero
    
    public var scalingOffset: CGFloat = 200
    public var minimumScaleFactor: CGFloat = 0.9
    public var velocity: CGFloat = 0.2
    public var scaleItems: Bool = true
    
    static func configureLayout(collectionView: UICollectionView) -> PageViewerFlowLayout {
        let layout = PageViewerFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        collectionView.collectionViewLayout = layout
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
            
        return layout
    }
    
    public override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    public override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if !self.scaleItems || self.collectionView == nil {
            return super.layoutAttributesForElementsInRect(rect)
        }
        
        let superAttributes = super.layoutAttributesForElementsInRect(rect)
        
        if superAttributes == nil {
            return nil
        }
        
        let contentOffset = self.collectionView!.contentOffset
        let size = self.collectionView!.bounds.size
        
        let visibleRect = CGRectMake(contentOffset.x, contentOffset.y, size.width, size.height)
        let visibleCenterX = CGRectGetMidX(visibleRect)
        
        var newAttributesArray = Array<UICollectionViewLayoutAttributes>()
        
        for (_, attributes) in superAttributes!.enumerate() {
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
