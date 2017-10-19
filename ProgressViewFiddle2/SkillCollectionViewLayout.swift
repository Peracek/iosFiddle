//
//  SkillCollectionViewLayout.swift
//  ProgressViewFiddle2
//
//  Created by Pavel Peroutka on 27/08/2017.
//  Copyright © 2017 Pavel Peroutka. All rights reserved.
//

import UIKit

class SkillCollectionViewLayout: UICollectionViewLayout, SkillCollectionVCDelegate {
    
    let bigCellWidthBreakpoint: CGFloat = 200

    public var scale: CGFloat = 1.0
    
    private var cellWidth: CGFloat = 100.0 {
        didSet {
            if (cellWidth >= bigCellWidthBreakpoint && oldValue < bigCellWidthBreakpoint) {
                collectionView?.reloadData()
            }
            if (cellWidth < bigCellWidthBreakpoint && oldValue >= bigCellWidthBreakpoint) {
                collectionView?.reloadData()
            }
        }
    }
    
    private var layoutCache = [UICollectionViewLayoutAttributes]()
    
    private var baseSection: Int? {
        if collectionView!.numberOfSections > 0 {
            return collectionView!.numberOfSections - 1
        }
        return nil
    }
    
    private var cellHeight: CGFloat {
        // make sure it's cheap operation
        return collectionView!.frame.height / CGFloat(collectionView!.numberOfSections)
    }
    
    public var delegate: SkillLayoutDelegate!
    
    override var collectionViewContentSize: CGSize {
        let numberOfBaseCells = baseSection != nil ? collectionView!.numberOfItems(inSection: baseSection!) : 0
        return CGSize(
            width: CGFloat(numberOfBaseCells) * cellWidth,
            height: collectionView!.frame.height
        )
    }
    
    override func prepare() {
        if layoutCache.isEmpty {
            for section in 0..<collectionView!.numberOfSections {
                for item in 0..<collectionView!.numberOfItems(inSection: section) {
                    let indexPath = IndexPath(item: item, section: section)
                    let gridRect = delegate.collectionView(collectionView!, gridRectForItemAt: indexPath)
                    let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                    let frame = CGRect(
                        x: CGFloat(gridRect.x),
                        y: CGFloat(gridRect.y),
                        width: CGFloat(gridRect.width),
                        height: CGFloat(gridRect.height)
                    )
                    attr.frame = frame.applying(CGAffineTransform(scaleX: cellWidth, y: cellHeight))
                    layoutCache.append(attr)
                }
            }
        }
        else {
            for item in layoutCache {
                item.scale(x: scale, y: 1)
            }
            // set new cellWidth
            cellWidth = layoutCache.last?.frame.width ?? 0
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if collectionView!.bounds.height != newBounds.height {
            print("zmena vysky")
            layoutCache = [UICollectionViewLayoutAttributes]()
            return true
        }
        
        return false
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let minIndex = Int(floor(rect.minX / cellWidth))
        let maxIndex = Int(ceil(rect.maxX / cellWidth))
        
        let indexPaths = delegate.collectionView(collectionView!, indexPathsForItemsBetween: minIndex, and: maxIndex)
        
        return layoutCache.filter {
            return indexPaths.contains($0.indexPath)
        }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutCache.first {
            return $0.indexPath == indexPath
        }
    }
    
    // MARK: - Implementation of SkillCollectionVCDelegate
    
    func SkillCellSize() -> CellSize {
        if cellWidth >= bigCellWidthBreakpoint {
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

extension UICollectionViewLayoutAttributes {
    func scale(x: CGFloat, y: CGFloat) {
        self.frame = frame.applying(CGAffineTransform(scaleX: x, y: y))
    }
    
}

struct GridRect {
    var x: UInt
    var y: UInt
    var width: UInt
    var height: UInt
    
    var horizontalSpaces: UInt {
        // TODO: jde to nejak elegantneji? (stejnetak pro vericalSpaces)
        return UInt(max(Int(width) - 1, 0))
    }
    
    var verticalSpaces: UInt {
        return UInt(max(Int(height) - 1, 0))
    }
}
