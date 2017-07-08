//
//  PagingDraggable.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 08.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

protocol PagingDraggable: class {
    var draggablePageWidth: Float { get }
    var pageControl: UIPageControl! { get }
}

extension PagingDraggable where Self: UIViewController {
    func pagerWillEndDragging(_ scrollView: UIScrollView,
                              withVelocity velocity: CGPoint,
                              targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let pageWidth = draggablePageWidth
        let targetXContentOffset = Float(targetContentOffset.pointee.x)
        let contentWidth = Float(scrollView.contentSize.width)
        var newPage = Float(self.pageControl.currentPage)
        
        if velocity.x == 0 {
            newPage = floor( (targetXContentOffset - Float(pageWidth) / 2) / Float(pageWidth)) + 1.0
        } else {
            newPage = Float(velocity.x > 0 ? self.pageControl.currentPage + 1 : self.pageControl.currentPage - 1)
            if newPage  > contentWidth / pageWidth {
                newPage = ceil(contentWidth / pageWidth) - 1.0
            }
        }
        self.pageControl.currentPage = Int(newPage)
        if let collection = scrollView as? UICollectionView, collection.numberOfSections == 1 {
            let maxPage = Float(collection.numberOfItems(inSection: 0))
            if newPage < 0 { newPage = 0 }
            if newPage >= maxPage { newPage = Float(maxPage - 1) }
            
            targetContentOffset.pointee = scrollView.contentOffset
            collection.scrollToItem(at: IndexPath(row: Int(newPage), section: 0),
                                    at: .centeredHorizontally,
                                    animated: true)
        } else {
            let point = CGPoint (x: CGFloat(newPage * pageWidth), y: targetContentOffset.pointee.y)
            targetContentOffset.pointee = point
        }
    }
}
