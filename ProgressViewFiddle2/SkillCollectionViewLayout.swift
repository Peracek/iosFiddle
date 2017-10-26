//
//  SkillCollectionViewLayout.swift
//  ProgressViewFiddle2
//
//  Created by Pavel Peroutka on 27/08/2017.
//  Copyright © 2017 Pavel Peroutka. All rights reserved.
//

import UIKit

class SkillCollectionViewLayout: UICollectionViewLayout {
    
    let bigCellWidthBreakpoint: CGFloat = 200

    public var scale: CGFloat = 1.0
    public var delegate: SkillLayoutDelegate!
    
    private var collectionViewIsNotEmpty: Bool {
        // TODO: opravit, prilis draha operace
        if let baseSection = baseSection {
            return self.collectionView!.numberOfItems(inSection: baseSection) > 0
        }
        return false
    }
    
    private var baseSection: Int? {
        if collectionView!.numberOfSections > 0 {
            return collectionView!.numberOfSections - 1
        }
        return nil
    }
    
    private lazy var cellWidth: CGFloat? = {
        if self.collectionViewIsNotEmpty {
            return self.collectionView!.frame.width / CGFloat(self.collectionView!.numberOfItems(inSection: self.baseSection!))
        }
        return nil
    }()
    private lazy var cellHeight: CGFloat? = {
        if self.collectionViewIsNotEmpty {
            return self.collectionView!.frame.height / CGFloat(self.collectionView!.numberOfSections)
        }
        return nil
    }()
    
    private var layoutCache = [UICollectionViewLayoutAttributes]()
    
    private var boundsChanged = false
    
    override var collectionViewContentSize: CGSize {
        if collectionViewIsNotEmpty {
            let numberOfBaseCells = collectionView!.numberOfItems(inSection: baseSection!)
            return CGSize(
                width: CGFloat(numberOfBaseCells) * (cellWidth!),
                height: CGFloat(collectionView!.numberOfSections) * (cellHeight!)
            )
        }
        return CGSize(width: 0, height: 0)
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
                    attr.frame = frame.applying(CGAffineTransform(scaleX: cellWidth!, y: cellHeight!))
                    layoutCache.append(attr)
                }
            }
        }
        else if boundsChanged {
            // if new bounds width is biggr then width of content, then enlarge it
            if collectionView!.bounds.width > collectionViewContentSize.width {
                let scaleX = collectionView!.bounds.width / collectionViewContentSize.width
                layoutCache.forEach { attr in
                    attr.scale(x: scaleX, y: 1)
                }
            }
            if collectionView!.bounds.height != collectionViewContentSize.height {
                let scaleY = collectionView!.bounds.height / collectionViewContentSize.height
                layoutCache.forEach { attr in
                    attr.scale(x: 1, y: scaleY)
                }
            }
            boundsChanged = false
            // TODO: make sure it's the baseSection cell width

            cellWidth = layoutCache.last?.frame.width ?? 0
            cellHeight = layoutCache.last?.frame.height ?? 0
        }
        else {
            if collectionView!.bounds.width <= collectionViewContentSize.width || scale > 1 {
                let screenWidthToContentRatio = collectionView!.bounds.width / collectionViewContentSize.width
                if collectionViewContentSize.width * scale < collectionView!.bounds.width {
                    scale = screenWidthToContentRatio
                }
                for item in layoutCache {
                    item.scale(x: scale, y: 1)
                }
                // TODO: make sure it's the baseSection cell width
                cellWidth = layoutCache.last?.frame.width ?? 0
            }
        }
        
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if collectionView!.bounds.height != newBounds.height
            || collectionView!.bounds.width != newBounds.width {
            boundsChanged = true
            return true
        }
        
        return false
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if collectionViewIsNotEmpty {
            let minIndex = Int(floor(rect.minX / cellWidth!))
            let maxIndex = Int(ceil(rect.maxX / cellWidth!))
            
            let indexPaths = delegate.collectionView(collectionView!, indexPathsForItemsBetween: minIndex, and: maxIndex)
            
            return layoutCache.filter {
                return indexPaths.contains($0.indexPath)
            }
        }
        return nil
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutCache.first {
            return $0.indexPath == indexPath
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
