//
//  ImagePickerController.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.08.17.
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

protocol ImagePickerControllerDelegate: class {
    func imagePicker(controller: ImagePickerController, didSendImage image: UIImage, urlString: String)
    func imagePicker(controller: ImagePickerController, didSelectImage image: UIImage)
    func imagePicker(controller: ImagePickerController, willClosePickerByCancel cancel: Bool)
}

class ImagePickerController: NSObject {
    weak var parent: UIViewController?
    weak var delegate: ImagePickerControllerDelegate?
    
    var compressionRate: CGFloat = 0.3
    var maxSide: CGFloat = 1800
    
    init(parent: UIViewController, delegate: ImagePickerControllerDelegate?) {
        self.parent = parent
        self.delegate = delegate
        super.init()
    }
    
    func showOptions() {
        let alert = UIAlertController(title: "Me.Report.ImageSource.title".localized,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Me.Report.ImageSource.camera".localized, style: .default, handler: { _ in
            self.showCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Me.Report.ImageSource.gallery".localized, style: .default, handler: { _ in
            self.showGallery()
        }))
        
        alert.addAction(UIAlertAction.init(title: "Main.cancel".localized, style: .cancel, handler: { _ in
            self.delegate?.imagePicker(controller: self, willClosePickerByCancel: true)
        }))
        
        parent?.present(alert, animated: true, completion: nil)
    }
    
    func showGallery() {
        showSource(source: .photoLibrary)
    }
    
    func showCamera() {
       showSource(source: .camera)
    }
    
    private func showSource(source: UIImagePickerControllerSourceType) {
        guard let controller = parent else { return }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = source
        controller.present(picker, animated: true, completion: nil)
    }
    
    func send(image: UIImage) {
        guard let resizedImage = ImageTransformer(image: image).imageToFit(maxSide: maxSide) else {
            fatalError("Can't resize image")
        }
        guard let imageData = UIImageJPEGRepresentation(resizedImage, self.compressionRate) else {
            fatalError("Can't process image")
        }
        
        service.dao.sendPhoto(data: imageData).observe { [weak self] result in
            guard let me = self else { return }
            
            switch result {
            case let .value(imageString):
                me.delegate?.imagePicker(controller: me, didSendImage: image, urlString: imageString)
            case .error:
                break
            }
        }
    }
    
}

extension ImagePickerController: UINavigationControllerDelegate {
    
}

// MARK: UIImagePickerControllerDelegate
extension ImagePickerController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        delegate?.imagePicker(controller: self, willClosePickerByCancel: true)
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            delegate?.imagePicker(controller: self, didSelectImage: pickedImage)
        }
        
        delegate?.imagePicker(controller: self, willClosePickerByCancel: false)
        picker.dismiss(animated: true, completion: nil)
    }
    
}
