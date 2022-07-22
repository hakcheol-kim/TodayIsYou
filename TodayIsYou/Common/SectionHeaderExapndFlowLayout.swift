//
//  SectionHeaderExapndFlowLayout.swift
//  TodayIsYou
//
//  Created by 김학철 on 2021/03/30.
//

import UIKit

class SectionHeaderExapndFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)
        
        layoutAttributes?.forEach { (attributes) in
            if attributes.representedElementKind == UICollectionView.elementKindSectionHeader
                && attributes.indexPath.section == 0 {
                
                guard let collectionview = collectionView else {
                    return
                }
                let offetY = collectionview.contentOffset.y
//                print(offetY)
                if offetY > 0 {
                    return
                }
                let width = collectionview.bounds.width
                let height = attributes.frame.height - offetY
                attributes.frame  = CGRect(x: 0, y: offetY, width: width, height: height)
            }
        }
        return layoutAttributes
    }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
