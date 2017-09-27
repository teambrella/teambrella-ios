//
//  ImagePickerController.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

protocol ImagePickerControllerDelegate: class {
    func imagePicker(controller: ImagePickerController, didSendPhoto photo: String)
    func imagePicker(controller: ImagePickerController, didSelectPhoto photo: UIImage)
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
        
        service.storage.sendPhoto(data: imageData).observe { [weak self] result in
            guard let me = self else { return }
            
            switch result {
            case let .value(imageString):
                me.delegate?.imagePicker(controller: me, didSendPhoto: imageString)
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            delegate?.imagePicker(controller: self, didSelectPhoto: pickedImage)
        }
        
        delegate?.imagePicker(controller: self, willClosePickerByCancel: false)
        picker.dismiss(animated: true, completion: nil)
    }
    
}
