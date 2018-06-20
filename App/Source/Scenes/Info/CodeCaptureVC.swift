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

import AVFoundation
import UIKit

class CodeCaptureVC: UIViewController, Routable, AVCaptureMetadataOutputObjectsDelegate {
    static let storyboardName: String = "Info"
    
    @IBOutlet var container: UIView!
    @IBOutlet var textView: UITextView!
    @IBOutlet var confirmButton: BorderedButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var cancelButton: UIButton!

    @IBOutlet var infoContainer: UIView!
    @IBOutlet var infoLabel: UILabel!
    
    @IBOutlet var tickImageView: UIImageView!
    
    var output = AVCaptureMetadataOutput()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var captureSession = AVCaptureSession()

    var type: LayoutType = .ethereum
    
    var lastReadString: String = ""
    
    weak var delegate: CodeCaptureDelegate?

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupCamera()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    // MARK: Callbacks
    
    @IBAction func tapClose(_ sender: UIButton) {
        close(cancelled: true)
    }
    
    @IBAction func tapConfirm(_ sender: UIButton) {
        close(cancelled: false)
    }

    // MARK: Public methods

    var animator: UIViewPropertyAnimator?
    func animateSuccess(completion: @escaping () -> Void) {
        tickImageView.alpha = 0
        tickImageView.isHidden = false
        animator = UIViewPropertyAnimator(duration: 2, curve: .easeInOut) { [unowned self] in
            self.tickImageView.alpha = 1
        }
        animator?.addCompletion { position in
            completion()
        }
        animator?.startAnimation()
    }

    func close(cancelled: Bool) {
        delegate?.codeCaptureWillClose(controller: self, cancelled: cancelled)
        dismiss(animated: true, completion: nil)
    }

    // MARK: Private methods

    private func setupViews() {
        switch type {
        case .ethereum:
            setupEthereum()
        case .privateKey:
            setupPrivateKey()
        }
    }

    private func setupEthereum() {
        titleLabel.text = "Info.codeCapture.title".localized
        confirmButton.setTitle("Info.codeCapture.button.title".localized, for: .normal)
        cancelButton.setTitle("Info.codeCapture.cancelButton.title".localized, for: .normal)
        textView.layer.cornerRadius = 8
        textView.layer.masksToBounds = true
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.bluishGray.cgColor
    }

    private func setupPrivateKey() {
        cancelButton.setTitle("Info.codeCapture.cancelButton.title".localized, for: .normal)
        infoContainer.isHidden = false
        infoLabel.text = "Let camera focus on QR code of your private key. It will log in automatically"
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: device) else {
                return
        }
        
        if captureSession.canAddInput(input) {
            captureSession.addInput(input)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = container.bounds
        container.layer.addSublayer(previewLayer)
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            log("Could not add metadata output", type: [.error, .info])
        }
    }
    
    private func codeType(text: String) -> QRCodeType {
        let array: [(String, QRCodeType)] = [
            ("^[5KL][1-9A-HJ-NP-Za-km-z]{50,51}$", .bitcoinWiF),
            ("^[123mn][1-9A-HJ-NP-Za-km-z]{26,35}", .bitcoinPublicKey),
            ("^0x[a-fA-F0-9]{40}$", .ethereum)
        ]
        for item in array {
            if text.range(of: item.0, options: .regularExpression) != nil {
                return item.1
            }
        }
        return .unknown
    }
    
    private func read(string: String) {
        guard lastReadString != string && string != "" else { return }
        
        lastReadString = string
        textView.text = string
        let type = codeType(text: string)
        Vibrator().vibrate()
        delegate?.codeCapture(controller: self, didCapture: string, type: type)
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        for metadata in metadataObjects {
            if let readableObject = metadata as? AVMetadataMachineReadableCodeObject,
                let code = readableObject.stringValue {
                read(string: code)
            }
        }
    }

    enum LayoutType {
        case ethereum
        case privateKey
    }
    
}
