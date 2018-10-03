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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ViewDecorator.homeCardShadow(for: shadowView)
        self.view.needsUpdateConstraints()
       
        setup()
        service.dao.ge
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
            break
        }
    }
    
}
