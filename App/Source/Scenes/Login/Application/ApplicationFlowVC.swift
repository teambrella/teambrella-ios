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

import UIKit

class ApplicationFlowVC: UIViewController {
    @IBOutlet var logoImageView: UIImageView!
    @IBOutlet var teamNameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    
    @IBOutlet var shadowView: UIView!
    @IBOutlet var containerView: RoundedCornersView!
    @IBOutlet var forwardButton: BorderedButton!
    
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var textView: UILabel!
    
    var welcome: WelcomeEntity? {
        didSet {
            guard let welcome = welcome else { return }
            
            logoImageView.show(welcome.teamLogo)
            teamNameLabel.text = welcome.teamName
            locationLabel.text = welcome.location.localizedUppercase
            headerLabel.text = welcome.title
            textView.attributedText = welcome.text
                .attributed()
                .add(font: UIFont.teambrella(size: 17), range: nil)
                .add(fontColor: #colorLiteral(red: 0.4743444324, green: 0.5259671211, blue: 0.5632535219, alpha: 1), range: nil)
                .add(lineInterval: 0.5 * 17, range: nil)
        }
    }
    
    var inviteCode: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ViewDecorator.homeCardShadow(for: shadowView)
        self.view.needsUpdateConstraints()
       
        setup()
        getWelcomeData()
    }
    
    private func getWelcomeData() {
        let teamID = 2028
        inviteCode = "ABCZ"
        
        service.dao.getWelcome(teamID: teamID, inviteCode: inviteCode).observe { result in
            switch result {
            case let .value(welcome):
                self.welcome = welcome
            case let .error(error):
                print(error)
            }
        }
    }
    
    private func setup() {
        logoImageView.layer.cornerRadius = 4
        logoImageView.clipsToBounds = true
        
        teamNameLabel.text = nil
        locationLabel.text = nil
        headerLabel.text = nil
        textView.text = nil
        
        forwardButton.setTitle("General.forward".localized, for: .normal)
    }

    @IBAction func tapButton(_ sender: UIButton) {
             performSegue(withIdentifier: "application", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "error screen":
            if let vc = segue.destination as? LoginNoInviteVC {
                vc.error = TeambrellaError(kind: .permissionDenied, description: "sdf")
            }
        default:
            if let vc = segue.destination as? ApplicationVC, let welcome = welcome {
                vc.setupUserData(welcome: welcome, inviteCode: inviteCode)
            }
        }
    }
    
}
