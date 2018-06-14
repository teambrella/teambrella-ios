//
//  PagingDraggable.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 08.07.17.

/* Copyright(C) 2017  Teambrella, Inc.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License(version 3) as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program.  If not, see<http://www.gnu.org/licenses/>.
 */

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
        var newPage: Float = Float(self.pageControl.currentPage)
        
        if velocity.x == 0 {
            let floatWidth = Float(pageWidth)
            let page: Float = targetXContentOffset - floatWidth / 2
            newPage = floor( page / floatWidth) + 1.0
        } else {
            newPage = Float(velocity.x > 0
                ? self.pageControl.currentPage + 1
                : self.pageControl.currentPage - 1)
            if newPage  > contentWidth / pageWidth {
                newPage = ceil(contentWidth / pageWidth) - 1.0
            }
        }
        self.pageControl.currentPage = Int(newPage)
        if let collection = scrollView as? UICollectionView, collection.numberOfSections == 1 {
            let maxPage: Float = Float(collection.numberOfItems(inSection: 0))
            if newPage < 0 { newPage = 0 }
            if newPage >= maxPage { newPage = Float(maxPage - 1) }
            
            targetContentOffset.pointee = scrollView.contentOffset
            collection.scrollToItem(at: IndexPath(row: Int(newPage), section: 0),
                                    at: .centeredHorizontally,
                                    animated: true)
        } else {
            let point: CGPoint = CGPoint(x: CGFloat(newPage * pageWidth), y: targetContentOffset.pointee.y)
            targetContentOffset.pointee = point
        }
    }
}
