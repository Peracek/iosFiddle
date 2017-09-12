//
//  SkillCollectionViewLayout.swift
//  ProgressViewFiddle2
//
//  Created by Pavel Peroutka on 27/08/2017.
//  Copyright © 2017 Pavel Peroutka. All rights reserved.
//

import UIKit

class SkillCollectionViewLayout: UICollectionViewLayout {

    public var scale: CGFloat = 1.0 {
        didSet {
            cellWidth = cellWidth * scale
        }
    }
    
    private var cellWidth: CGFloat = 200.0
    
    private let cellHeight: CGFloat = 100.0
    
    public var delegate: SkillLayoutDelegate!
    
    public var width: Int = 0
//    override func prepare() {
//        <#code#>
//    }
    
    override var collectionViewContentSize: CGSize {
        
        return CGSize(width: CGFloat(width) * cellWidth, height: collectionView?.frame.height ?? 0)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes: [UICollectionViewLayoutAttributes] = []
        
        let minX = rect.minX
        let maxX = rect.maxX
        
        let minIndex = Int(floor(minX / cellWidth))
        let maxIndex = Int(ceil(maxX / cellWidth))
        
        let indexPaths = delegate.collectionView(collectionView!, indexPathsForItemsBetween: minIndex, and: maxIndex)
        
        for indexPath in indexPaths {
            let gridPositionAndSize = delegate.collectionView(collectionView!, positionAndSizeForItemAt: indexPath)
            let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            let frame = CGRect(
                x: gridPositionAndSize.minX * cellWidth,
                y: gridPositionAndSize.minY * cellHeight,
                width: gridPositionAndSize.width * cellWidth,
                height: gridPositionAndSize.height * cellHeight)
            attr.frame = frame
            layoutAttributes.append(attr)
        }
        return layoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        // FIXME: zkopirovano z layoutAttributesForElments, keep it DRY
        
        let gridPositionAndSize = delegate.collectionView(collectionView!, positionAndSizeForItemAt: indexPath)
        let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        let frame = CGRect(
            x: gridPositionAndSize.minX * cellWidth,
            y: gridPositionAndSize.minY * cellHeight,
            width: gridPositionAndSize.width * cellWidth,
            height: gridPositionAndSize.height * cellHeight)
        attr.frame = frame
        
        return attr
    }
    
}

protocol SkillLayoutDelegate {
    // proc takovy nazev?
    // https://stackoverflow.com/questions/45198704/why-swift-protocol-use-func-overloading-instead-on-func-with-different-names
    func collectionView(_ collectionView: UICollectionView, positionAndSizeForItemAt indexPath: IndexPath) -> CGRect
    
    func collectionView(_ collectionView: UICollectionView, indexPathsForItemsBetween startIndex: Int, and endIndex: Int) -> [IndexPath]
}

extension Int {
    func withinBounds(_ minVal: Int, _ maxVal: Int) -> Int {
        let minBounded = Swift.max(self, minVal)
        return Swift.min(minBounded, maxVal)
    }
}
