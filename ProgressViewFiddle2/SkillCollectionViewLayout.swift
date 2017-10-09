//
//  SkillCollectionViewLayout.swift
//  ProgressViewFiddle2
//
//  Created by Pavel Peroutka on 27/08/2017.
//  Copyright © 2017 Pavel Peroutka. All rights reserved.
//

import UIKit

class SkillCollectionViewLayout: UICollectionViewLayout, SkillCollectionVCDelegate {
    
    let largeCellLimit: CGFloat = 200
    
    var cellSpacing: CGFloat = 5.0

    public var scale: CGFloat = 1.0 {
        didSet {
            cellWidth = cellWidth * scale
        }
    }
    
    private var cellWidth: CGFloat = 100.0 {
        didSet {
            if (cellWidth >= largeCellLimit && oldValue < largeCellLimit) {
                collectionView?.reloadData()
            }
            if (cellWidth < largeCellLimit && oldValue >= largeCellLimit) {
                collectionView?.reloadData()
            }
        }
    }
    
    private var cellHeight: CGFloat = 100.0
    
    public var delegate: SkillLayoutDelegate!
    
    public var columns: Int = 0
    public var rows: Int = 0 {
        didSet {
            if let viewHeight = collectionView?.frame.height {
                let totalVerticalSpacing = CGFloat(max(rows - 1, 0)) * cellSpacing
                cellHeight = (viewHeight - totalVerticalSpacing) / CGFloat(rows)
            }
        }
    }
    
    
//    override func prepare() {
//        <#code#>
//    }
    
    override var collectionViewContentSize: CGSize {
        let totalHorizontalSpacing = CGFloat(max(columns - 1, 0)) * cellSpacing
        return CGSize(
            width: CGFloat(columns) * cellWidth + totalHorizontalSpacing,
            height: collectionView?.frame.height ?? 0
        )
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes: [UICollectionViewLayoutAttributes] = []
        
        // pricitam cellSpacing abych nenacital bunku vlevo, v pripade ze uz jsem ve spacingu vpravo od ni
        let minIndex = Int(floor(((rect.minX + cellSpacing) / (cellWidth + cellSpacing))))
        let maxIndex = Int(ceil(rect.maxX / (cellWidth + cellSpacing)))
        
        let indexPaths = delegate.collectionView(collectionView!, indexPathsForItemsBetween: minIndex, and: maxIndex)
        
        for indexPath in indexPaths {
            if let attr = layoutAttributesForItem(at: indexPath) {
                layoutAttributes.append(attr)
            }
        }
        
        return layoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        // FIXME: zkopirovano z layoutAttributesForElments, keep it DRY
        
        let gridRect = delegate.collectionView(collectionView!, gridRectForItemAt: indexPath)
        let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        let frame = CGRect(
            x: CGFloat(gridRect.x) * cellWidth + CGFloat(gridRect.x) * cellSpacing,
            y: CGFloat(gridRect.y) * cellHeight + CGFloat(gridRect.y) * cellSpacing,
            width: CGFloat(gridRect.width) * cellWidth + CGFloat(gridRect.horizontalSpaces) * cellSpacing,
            height: CGFloat(gridRect.height) * cellHeight
        )
        attr.frame = frame
        
        return attr
    }
    
    // MARK: - Implementation of SkillCollectionVCDelegate
    
    func SkillCellSize() -> CellSize {
        if cellWidth >= largeCellLimit {
            return .big
        }
        else {
            return .regular
        }
    }
    
}

protocol SkillLayoutDelegate {
    // proc takovy nazev?
    // https://stackoverflow.com/questions/45198704/why-swift-protocol-use-func-overloading-instead-on-func-with-different-names
    func collectionView(_ collectionView: UICollectionView, gridRectForItemAt indexPath: IndexPath) -> GridRect
    
    func collectionView(_ collectionView: UICollectionView, indexPathsForItemsBetween startIndex: Int, and endIndex: Int) -> [IndexPath]
}

extension Int {
    func withinBounds(_ minVal: Int, _ maxVal: Int) -> Int {
        let minBounded = Swift.max(self, minVal)
        return Swift.min(minBounded, maxVal)
    }
}

struct GridRect {
    var x: UInt
    var y: UInt
    var width: UInt
    var height: UInt
    
    var horizontalSpaces: UInt {
        return max(width - 1, 0)
    }
    
    var verticalSpaces: UInt {
        return max(height - 1, 0)
    }
}
