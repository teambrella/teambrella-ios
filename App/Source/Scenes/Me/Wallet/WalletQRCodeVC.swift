//
/* Copyright(C) 2016-2018 Teambrella, Inc.
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
 * along with this program.  If not, see http://www.gnu.org/licenses/
 */

import QRCode
import UIKit

class WalletQRCodeVC: UIViewController, Routable {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var saveButton: BorderedButton!
    @IBOutlet var cancelButton: BorderedButton!
    
    static let storyboardName = "Me"
    
    @IBAction func tapSaveButton(_ sender: UIButton) {
        if let image = imageView.image {
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        }
    }
    
    @IBAction func tapCancelButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var privateKey: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.setTitle("Me.Wallet.QRCodeVC.saveButton.title".localized, for: .normal)
        cancelButton.setTitle("Me.Wallet.QRCodeVC.closeButton.title".localized, for: .normal)
        imageView.image = generateQRCode()
    }
    
    func generateQRCode() -> UIImage? {
        guard var qrCode = QRCode(privateKey) else { return nil }
        
        qrCode.size = CGSize(width: 250, height: 250)
        qrCode.color = CIColor(rgba: "2C3948")
        qrCode.backgroundColor = CIColor(rgba: "F8FAFD")
        return qrCode.image
    }
    
    @objc
    func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your altered image has been saved to your photos.",
                                       preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
}
