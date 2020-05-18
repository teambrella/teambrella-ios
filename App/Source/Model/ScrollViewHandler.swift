//
/* Copyright(C) 2018 Teambrella, Inc.
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

class ScrollViewHandler {
    var previousScrollOffset: CGFloat = 0
    var highBackwardSpeed: CGFloat = 10
    var highForwardSpeed: CGFloat = -10
    
    var onFastBackwardScroll: ((CGFloat) -> Void)?
    var onFastForwardScroll: ((CGFloat) -> Void)?
    
    var onScrollingUp: (() -> Void)?
    var onScrollingDown: (() -> Void)?
    
    var isScrolling: Bool = false
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        let velocity = currentOffset - previousScrollOffset
        previousScrollOffset = currentOffset
//        if velocity > highBackwardSpeed {
//            onFastBackwardScroll?(velocity)
//        }
//        if velocity < highForwardSpeed {
//            onFastForwardScroll?(velocity)
//        }
        if isScrolling {
            if velocity > 0 {
                onScrollingUp?()
            }
            if velocity < 0 {
                onScrollingDown?()
            }
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling = true
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        isScrolling = false
    }
}
