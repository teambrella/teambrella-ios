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

protocol SlidingViewDelegate: class {
    func sliding(view: SlidingView, changeContentHeight height: CGFloat)
}

class SlidingView: UIView, XIBInitable {
    var contentView: UIView!

    @IBOutlet var objectView: ChatObjectView!
    @IBOutlet var votingView: ClaimVotingView!

    @IBOutlet var objectViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var objectViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var votingViewTopConstraint: NSLayoutConstraint!
    @IBOutlet var votingViewHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: SlidingViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        xibSetup()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        ViewDecorator.shadow(for: votingView, opacity: 0.08, radius: 4)
        ViewDecorator.shadow(for: objectView, opacity: 0.08, radius: 4)
    }

    func setupViews(with delegate: ChatObjectViewDelegate & ClaimVotingDelegate, session: Session?) {
        objectView.delegate = delegate
        votingView.delegate = delegate
        votingView.session = session
    }

    func showObjectView() {
        delegate?.sliding(view: self, changeContentHeight: objectViewHeightConstraint.constant)
    }

    func showVotingView() {
        UIView.animate(withDuration: 0.3) {
            self.objectView.showChevron()
        }
        delegate?.sliding(view: self,
                          changeContentHeight: objectViewHeightConstraint.constant
                            + votingViewHeightConstraint.constant)
    }
    
    func hideObjectView() {
        delegate?.sliding(view: self, changeContentHeight: 0)
    }

    func hideVotingView() {
        UIView.animate(withDuration: 0.3) {
            self.objectView.showVoteContainer()
        }
        delegate?.sliding(view: self, changeContentHeight: objectViewHeightConstraint.constant)
    }

    func hideAll() {
        objectView.showVoteContainer()
        delegate?.sliding(view: self, changeContentHeight: 0)
    }

    func updateChatModel(model: ChatModel) {
        votingView.isChangingVote = false
        votingView.setup(with: model)
        objectView.setup(with: model)
    }
}
