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
    
    init(parent: UIViewController, delegate: ImagePickerControllerDelegate?) {
        self.parent = parent
        self.delegate = delegate
        super.init()
    }
    
    func show() {
        guard let controller = parent else { return }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        controller.present(picker, animated: true, completion: nil)
    }
    
    func send(image: UIImage) {
        guard let imageData = UIImageJPEGRepresentation(image, self.compressionRate) else {
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
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            delegate?.imagePicker(controller: self, didSelectPhoto: pickedImage)
            send(image: pickedImage)
        }
        
        delegate?.imagePicker(controller: self, willClosePickerByCancel: false)
        picker.dismiss(animated: true, completion: nil)
    }
    
}
