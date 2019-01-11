//
/* Copyright(C) 2017 Teambrella, Inc.
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

protocol SelectorDelegate: class {
    func selector(controller: SelectorVC, didSelect index: Int)
    func aboutToOpenSelectorController(controller: SelectorVC)
    func didCloseSelectorController(controller: SelectorVC)
}

extension SelectorDelegate {
    func aboutToOpenSelectorController(controller: SelectorVC) {}
    func didCloseSelectorController(controller: SelectorVC) {}
}

class SelectorVC: UIViewController, Routable {
    static let storyboardName = "Chat"
    
    @IBOutlet var backView: UIView!
    @IBOutlet var muteView: UIView!
    @IBOutlet var headerLabel: BlockHeaderLabel!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var collectionView: UICollectionView!
    
    @IBOutlet var collectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet var topConstraint: NSLayoutConstraint!
    var bottomAnchor: NSLayoutConstraint?
    
    var dataSource: SelectorDataSource!
    weak var delegate: SelectorDelegate?
    
    var selectedIndex: Int = 0
    
    @IBAction func tapClose(_ sender: Any) {
        close()
    }
    
    @objc
    private func close() {
        disappear {
            self.dismiss(animated: false) {
                self.delegate?.didCloseSelectorController(controller: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
    }
    
    private func setup() {
        self.delegate?.aboutToOpenSelectorController(controller: self)
        collectionView.register(MuteCell.nib, forCellWithReuseIdentifier: MuteCell.cellID)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        recognizer.delegate = self
        backView.addGestureRecognizer(recognizer)
        backView.isUserInteractionEnabled = true
//        muteView.isUserInteractionEnabled = true
        
        headerLabel.text = dataSource.header
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appear()
    }
    
    func calculateHeight() -> CGFloat {
        let margins = view.layoutMargins
        let height = collectionView.contentSize.height
        return height + margins.bottom
    }
    
    func reload() {
        self.collectionView.reloadData()
    }
    
    func appear() {
        collectionHeightConstraint.constant = calculateHeight()
        topConstraint.isActive = false
        bottomAnchor = muteView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        bottomAnchor?.isActive = true
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            self.backView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
            self.view.layoutIfNeeded()
        }) { finished in
            
        }
    }
    
    func disappear(completion: @escaping () -> Void) {
        topConstraint.isActive = true
        bottomAnchor?.isActive = false
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn], animations: {
            self.backView.backgroundColor = .clear
            self.view.layoutIfNeeded()
        }) { finished in
            completion()
        }
    }
    
}

extension SelectorVC: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "MuteCell", for: indexPath)
    }
}

extension SelectorVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if let cell = cell as? MuteCell {
            let model = dataSource[indexPath]
            
            cell.icon.image = model.icon
            cell.upperLabel.text = model.topText
            cell.lowerLabel.text = model.bottomText
            cell.checker.isHidden = indexPath.row != selectedIndex
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.cellForItem(at: indexPath) is MuteCell {
            selectedIndex = indexPath.row
            delegate?.selector(controller: self, didSelect: selectedIndex)
            collectionView.reloadData()
            if dataSource.isHidingOnSelection {
                close()
            }
        }
    }
}

extension SelectorVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 70)
    }
}

extension SelectorVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == gestureRecognizer.view
    }
}
