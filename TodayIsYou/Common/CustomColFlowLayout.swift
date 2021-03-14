//
//  ColFlowLayout.swift
//  StartCode
//
//  Created by 김학철 on 2020/12/20.
//

import UIKit
protocol CustomColFlowLayoutDelegate {
    func didEndDecelatedFloawLayout(_ indexPath: IndexPath, _ point:CGPoint)
}
class CustomColFlowLayout: UICollectionViewFlowLayout {
    var delegate:CustomColFlowLayoutDelegate?
    var lastPoint:CGPoint = CGPoint.zero
    override func prepare() {
        super.prepare()
    }
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard let attributes = self.layoutAttributesForElements(in: self.collectionView!.bounds), attributes.isEmpty == false else {
            return proposedContentOffset
        }
        
        var targetIdx:Int = Int(attributes.count/2)
        let vx = velocity.x
        if vx > 0 {
            targetIdx += 1
        }
        else if vx < 0 {
            targetIdx -= 1
        }
        else {
            return lastPoint
        }
        
        if targetIdx >= attributes.count {
            targetIdx = attributes.count-1
        }
        if targetIdx < 0 {
            targetIdx = 0
        }
        
        let targetAttribute = attributes[targetIdx]

        lastPoint = CGPoint(x: targetAttribute.center.x - (self.collectionView?.bounds.size.width)!/2, y: proposedContentOffset.y)
        delegate?.didEndDecelatedFloawLayout(targetAttribute.indexPath, lastPoint)
        
        return lastPoint
    }
}
