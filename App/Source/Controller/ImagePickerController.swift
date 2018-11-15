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
    func imagePicker(controller: ImagePickerController, didSendPhotoPost post: ChatEntity)
    func imagePicker(controller: ImagePickerController, failedWith error: Error)
}

struct ChatMetadata {
    let topicID: String
    let postID: String
}

class ImagePickerController: NSObject {
    weak var parent: UIViewController?
    weak var delegate: ImagePickerControllerDelegate?
    
    var compressionRate: CGFloat = 0.3
    var maxSide: CGFloat = 1800

    var chatMetadata: ChatMetadata?

    var imageToSend: UIImage?
    weak var imagePicker: UIImagePickerController?
    
    init(parent: UIViewController, delegate: ImagePickerControllerDelegate?) {
        self.parent = parent
        self.delegate = delegate
        super.init()
    }
    
    func showOptions() {
        if chatMetadata != nil {
            showCamera()
            return
        }

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
    
    private func showSource(source: UIImagePickerController.SourceType) {
        guard let controller = parent else { return }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = source
        self.imagePicker = picker
        controller.present(picker, animated: true, completion: nil)
    }

    private func sendAvatar(image: UIImage, imageData: Data) {
        service.dao.sendAvatar(data: imageData).observe { [weak self] result in
            guard let `self` = self else { return }

            switch result {
            case let .value(avatar):
                self.delegate?.imagePicker(controller: self, didSendImage: image, urlString: avatar)
            case let .error(error):
                log(error)
            }
        }
    }

    private func sendPhoto(image: UIImage, imageData: Data) {
        service.dao.sendPhoto(data: imageData).observe { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .value(imageStrings):
                guard  let first = imageStrings.first else { return }

                self.delegate?.imagePicker(controller: self, didSendImage: image, urlString: first)
            case let .error(error):
                self.delegate?.imagePicker(controller: self, failedWith: error)
            }
        }
    }

    private func sendPhotoPost(image: UIImage, imageData: Data, chatMetadata: ChatMetadata) {
        let future = service.dao.sendPhotoPost(topicID: chatMetadata.topicID,
                                               postID: chatMetadata.postID,
                                               data: imageData)
        future.observe { [weak self] result in
            guard let self = self else { return }

            switch result {
            case let .value(post):
                self.delegate?.imagePicker(controller: self, didSendPhotoPost: post)
            case let .error(error):
                self.delegate?.imagePicker(controller: self, failedWith: error)
            }
        }
    }

    func send(image: UIImage, isAvatar: Bool) -> UIImage {
        guard let resizedImage = ImageTransformer(image: image).imageToFit(maxSide: maxSide) else {
            fatalError("Can't resize image")
        }
        guard let imageData = resizedImage.jpegData(compressionQuality: self.compressionRate) else {
            fatalError("Can't process image")
        }

        imageToSend = resizedImage
        
        if isAvatar {
            sendAvatar(image: image, imageData: imageData)
        } else if let chatMetadata = chatMetadata {
            sendPhotoPost(image: image, imageData: imageData, chatMetadata: chatMetadata)
        } else {
            sendPhoto(image: image, imageData: imageData)
        }

        return resizedImage
    }

    func close(isCancelled: Bool = true) {
        delegate?.imagePicker(controller: self, willClosePickerByCancel: isCancelled)
        imagePicker?.dismiss(animated: true, completion: nil)
    }
    
}

extension ImagePickerController: UINavigationControllerDelegate {
    
}

// MARK: UIImagePickerControllerDelegate
extension ImagePickerController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        close()
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            delegate?.imagePicker(controller: self, didSelectImage: pickedImage)
        }

        close(isCancelled: false)
    }
    
}
