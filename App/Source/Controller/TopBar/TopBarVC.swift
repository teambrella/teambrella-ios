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

protocol TopBarDelegate: class {
    func topBar(vc: TopBarVC, didSwitchTeamToID: Int)
}

final class TopBarVC: UIViewController {
    struct Constant {
        static let teamIconWidth: CGFloat = 24
        static let teamIconCornerRadius: CGFloat = 4
    }
    
    @IBOutlet var teamButton: DropDownButton!
    @IBOutlet var privateMessagesButton: LabeledButton!
    @IBOutlet var titleLabel: UILabel!
    
    var router: MainRouter?
    var session: Session?
    
    weak var delegate: TopBarDelegate?
    
    class func show(in viewController: UIViewController, in view: UIView) -> TopBarVC {
        let vc = TopBarVC(nibName: "TopBarVC", bundle: nil)
        vc.view.frame = view.bounds
        vc.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(vc.view)
        viewController.addChildViewController(vc)
        vc.didMove(toParentViewController: viewController)
        
        vc.router = service.router
        vc.session = service.session
        
        return vc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    func setup() {
        setupTeamButton()
        titleLabel.text = session?.currentTeam?.teamName
    }
    
    func setPrivateMessages(unreadCount: Int) {
        if unreadCount > 0 {
            privateMessagesButton.cornerText = String(unreadCount)
        } else {
            privateMessagesButton.cornerText = nil
        }
    }
    
    private func setupTeamButton() {
        guard let source = session?.currentTeam?.teamLogo else { return }
        
        UIImage.fetchAvatar(string: source,
                            width: Constant.teamIconWidth,
                            cornerRadius: Constant.teamIconCornerRadius) { image, error  in
                                guard error == nil else { return }
                                guard let image = image, let cgImage = image.cgImage else { return }
                                
                                let scaled = UIImage(cgImage: cgImage,
                                                     scale: UIScreen.main.nativeScale,
                                                     orientation: image.imageOrientation)
                                self.teamButton.setImage(scaled, for: .normal)
        }
    }
    
    @IBAction func tapTeams(_ sender: DropDownButton) {
        guard let containingController = delegate as? UIViewController else { return }
        
        router?.showChooseTeam(in: containingController, delegate: self)
    }
    
    @IBAction func tapPrivateMessages(_ sender: LabeledButton) {
        router?.presentPrivateMessages()
    }
    
}

extension TopBarVC: ChooseYourTeamControllerDelegate {
    func chooseTeam(controller: ChooseYourTeamVC, didSelectTeamID: Int) {
        session?.switchToTeam(id: didSelectTeamID)
        router?.switchTeam()
        delegate?.topBar(vc: self, didSwitchTeamToID: didSelectTeamID)
    }
}
