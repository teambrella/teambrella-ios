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

protocol MuteControllerDelegate: class {
    func mute(controller: MuteVC, didSelect type: TopicMuteType)
    func didCloseMuteController(controller: MuteVC)
}

enum TopicMuteType: Int {
    case unknown = -1
    case unmuted = 0
    case muted = 1
    
    static func type(from boolean: Bool?) -> TopicMuteType {
        if let boolean = boolean {
            return boolean == true ? .muted : .unmuted
        }
        return .unknown
    }
}

class MuteVC: UIViewController, Routable {
   static let storyboardName = "Chat"
    
    @IBOutlet var backView: UIView!
    @IBOutlet var muteView: UIView!
    @IBOutlet var headerLabel: BlockHeaderLabel!
    @IBOutlet var closeButton: UIButton!
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    @IBOutlet var collectionView: UICollectionView!
    
    fileprivate var dataSource = MuteDataSource()
    weak var delegate: MuteControllerDelegate?
    
    var type: TopicMuteType = .unknown
    
    @IBAction func tapClose(_ sender: Any) {
        close()
    }
    
    @objc
    private func close() {
        disappear {
            self.delegate?.didCloseMuteController(controller: self)
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(MuteCell.nib, forCellWithReuseIdentifier: MuteCell.cellID)
        headerLabel.text = "Team.Chat.NotificationSettings.title".localized
        dataSource.createModels()
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        recognizer.delegate = self
        backView.addGestureRecognizer(recognizer)
        backView.isUserInteractionEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        appear()
    }
    
    func appear() {
        self.bottomConstraint.constant = 0
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut], animations: {
            self.backView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            self.view.layoutIfNeeded()
        }) { finished in
            
        }
    }
    
    func disappear(completion: @escaping () -> Void) {
        self.bottomConstraint.constant = -self.muteView.frame.height
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn], animations: {
            self.backView.backgroundColor = .clear
            self.view.layoutIfNeeded()
        }) { finished in
            completion()
        }
    }
    
}

extension MuteVC: UICollectionViewDataSource {
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

extension MuteVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if let cell = cell as? MuteCell {
            let model = dataSource[indexPath]
            
            cell.icon.image = model.icon
            cell.upperLabel.text = model.topText
            cell.lowerLabel.text = model.bottomText
            cell.checker.isHidden = indexPath.row != type.rawValue
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.cellForItem(at: indexPath) is MuteCell {
            type = TopicMuteType(rawValue: indexPath.row) ?? .unknown
            delegate?.mute(controller: self, didSelect: type)
            collectionView.reloadData()
            close()
        }
    }
}

extension MuteVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height / 2)
    }
}

extension MuteVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == gestureRecognizer.view
    }
}
