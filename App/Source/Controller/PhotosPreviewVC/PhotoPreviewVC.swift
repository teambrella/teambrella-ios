//
//  PhotoPreviewVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 21.08.17.
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
//

import UIKit

class PhotoPreviewVC: UICollectionViewController {
    private(set)var photos: [String] = []
    weak var delegate: PhotoPreviewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modalPresentationStyle = .overCurrentContext
        view.backgroundColor = .white
        collectionView?.backgroundColor = .white
        // collectionView?.clipsToBounds = false
        if let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        registerCells()
    }
    
    func addPhotos(_ photos: [String]) {
        for (idx, photo) in photos.enumerated() {
        self.photos.insert(photo, at: idx)
        }
        collectionView?.reloadData()
    }
    
    private func registerCells() {
        collectionView?.register(PhotoPreviewCell.nib, forCellWithReuseIdentifier: PhotoPreviewCell.cellID)
    }
    
    @objc
    func cellTapCancel(sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        collectionView?.performBatchUpdates({
            self.photos.remove(at: indexPath.row)
            self.collectionView?.deleteItems(at: [indexPath])
        }, completion: { _ in
            self.delegate?.photoPreview(controller: self, didDeleteItemAt: indexPath)
            guard let collectionView = self.collectionView else { return }
            
            collectionView.reloadItems(at: collectionView.indexPathsForVisibleItems)
        })
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: PhotoPreviewCell.cellID, for: indexPath)
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 willDisplay cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        guard let cell = cell as? PhotoPreviewCell else { return }
        
        let imageString = photos[indexPath.row]
        if let string = cell.imageString, string == imageString {
            
        } else {
            cell.imageView.image = nil
            cell.imageView.showImage(string: imageString, needHeaders: true)
        }
        cell.cancelButton.removeTarget(self, action: nil, for: .allEvents)
        cell.cancelButton.addTarget(self, action: #selector(cellTapCancel), for: .touchUpInside)
        cell.cancelButton.tag = indexPath.row
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 moveItemAt sourceIndexPath: IndexPath,
                                 to destinationIndexPath: IndexPath) {
        let photo = photos.remove(at: sourceIndexPath.row)
        photos.insert(photo, at: destinationIndexPath.row)
    }
}

extension PhotoPreviewVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.height, height: collectionView.bounds.height)
    }
}
