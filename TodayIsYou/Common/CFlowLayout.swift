//
//  CFlowLayout.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/10.
//

import UIKit
protocol CFlowLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForItemAtIndexPath indexpath: NSIndexPath) -> CGFloat
}
class CFlowLayout: UICollectionViewFlowLayout {
    
    var delegate: CFlowLayoutDelegate!
    var numberOfColumns = 1
    var secInset: UIEdgeInsets = UIEdgeInsets.zero
    var lineSpacing: CGFloat = 0
    
    private var layoutCache = [UICollectionViewLayoutAttributes]()
    private var contentHeight: CGFloat = 0
    private var width: CGFloat {
        get {
            return collectionView!.bounds.width
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: width, height: contentHeight)
    }
    
    override func prepare() {
        super.prepare()
        minimumLineSpacing = lineSpacing
        sectionInset = secInset
        
        if (layoutCache.isEmpty) {
            let columnWidth = (width-secInset.left - secInset.right - CGFloat(numberOfColumns - 1) * minimumLineSpacing)/CGFloat(numberOfColumns)
            
            var xOffsets = [CGFloat]()
            for column in 0..<numberOfColumns {
                var xPos = CGFloat(column)*columnWidth
                if column == 0 {
                    xPos += sectionInset.left
                }
                else {
                    xPos += (CGFloat(column) * minimumLineSpacing) + sectionInset.left
                }
                xOffsets.append(xPos)
            }
            
            var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
            var column = 0
            for item in 0..<collectionView!.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: item, section: 0)
                
                let height = delegate.collectionView(collectionView!, heightForItemAtIndexPath: indexPath as NSIndexPath)
                
                
                if item < numberOfColumns {
                    yOffset[column] = yOffset[column] + sectionInset.top
                }
                else {
                    yOffset[column] = yOffset[column] + minimumLineSpacing
                }
                
                let frame = CGRect(x: xOffsets[column], y: yOffset[column], width: columnWidth, height: height)
                
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                layoutCache.append(attributes)
                
                contentHeight = max(contentHeight, frame.maxY)
                yOffset[column] = yOffset[column] + height
                
                if column >= numberOfColumns-1 {
                    column = 0
                }
                else {
                    column += 1
                }
            
            }
        }
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in layoutCache {
            if attributes.frame.intersects(rect) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
}
