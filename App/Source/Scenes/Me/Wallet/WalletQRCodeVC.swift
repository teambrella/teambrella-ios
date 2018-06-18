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

import PKHUD
import QRCode
import UIKit

class WalletQRCodeVC: UIViewController, Routable {
    static let storyboardName = "Me"

    var privateKey: String = ""

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var saveButton: BorderedButton!
    @IBOutlet var cancelButton: BorderedButton!
    @IBOutlet var printButton: BorderedButton!

    @IBAction func tapSaveButton(_ sender: UIButton) {
        if let image = imageView.image {
            HUD.show(.progress)
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(didFinishSaving), nil)
        }
    }

    @IBAction func tapCancelButton(_ sender: UIButton) {
        close()
    }

    @IBAction func tapPrint(_ sender: UIButton) {
        if let image = imageView.image {
            print(image: image)
        }
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.setTitle("Me.Wallet.QRCodeVC.saveButton.title".localized, for: .normal)
        cancelButton.setTitle("Me.Wallet.QRCodeVC.closeButton.title".localized, for: .normal)
        
        printButton.setTitle("Me.Wallet.QRCodeVC.printButton.title".localized, for: .normal)
        imageView.image = generateQRCode()
    }

    // MARK: Public

    func close() {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: Private

    @objc
    private func didFinishSaving(_ image: UIImage, error: Error?, contextInfo: UnsafeRawPointer) {
        HUD.hide()
        if let error = error {
            presentError(error: error)
        } else {
            saveButton.setTitle("Me.Wallet.QRCodeVC.saveButton.saved.title".localized, for: .normal)
            saveButton.isEnabled = false
        }
    }

    private func presentError(error: Error) {
        let error = error as NSError
        let vc = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        vc.addAction(cancel)
        present(vc, animated: true, completion: nil)
    }

    private func print(image: UIImage) {
        let printer = Printer(presentingView: view)
        printer.print(image: image) { error in
            if let error = error {
                self.presentError(error: error)
            }
        }
    }
    
    private func generateQRCode() -> UIImage? {
        guard var qrCode = QRCode(privateKey) else { return nil }
        
        qrCode.size = CGSize(width: 250, height: 250)
        qrCode.color = CIColor(rgba: "2C3948")
        qrCode.backgroundColor = CIColor(rgba: "F8FAFD")
        return qrCode.image
    }

}
