//
//  EnvironmentDemoCollectionViewLayout.swift
//  Thunderboard
//
//  Copyright © 2016 Silicon Labs. All rights reserved.
//

import UIKit

class EnvironmentDemoCollectionViewLayout : UICollectionViewLayout {

    private var cache = [UICollectionViewLayoutAttributes]()
    private var contentHeight = CGFloat(0.0)
    private var contentWidth: CGFloat {
        let insets = collectionView!.contentInset
        return CGRectGetWidth(collectionView!.bounds) - (insets.left + insets.right)
    }
    
    override func prepareLayout() {
        super.prepareLayout()

        if cache.isEmpty {

            let numberOfColumns = 2
            let columnWidth = contentWidth / CGFloat(numberOfColumns)

            var position = [
                CGPoint(x: 0, y: 0),
                CGPoint(x: columnWidth, y: 0),
            ]

            var column = 0
            for item in 0 ..< collectionView!.numberOfItemsInSection(0) {
                
                let indexPath = NSIndexPath(forItem: item, inSection: 0)

                let height = columnWidth + 40
                let frame = CGRect(x: position[column].x, y: position[column].y, width: columnWidth, height: height)

                let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                attributes.frame = frame
                cache.append(attributes)

                contentHeight = max(contentHeight, CGRectGetMaxY(frame))
                position[column].y = position[column].y + height
                
                column = column >= (numberOfColumns - 1) ? 0 : (column + 1)
            }
        }
    }
    
    override func collectionViewContentSize() -> CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }

    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cache {
            if CGRectIntersectsRect(attributes.frame, rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
}
