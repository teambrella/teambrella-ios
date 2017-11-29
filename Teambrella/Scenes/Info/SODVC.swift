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

class SODVC: UIViewController, Routable {
    enum SODMode {
        case outdated
    }
    
    static let storyboardName = "Info"
    
    @IBOutlet var confettiView: UIImageView!
    @IBOutlet var logoView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailsLabel: UILabel!
    
    @IBOutlet var upperButton: UIButton!
    @IBOutlet var lowerButton: UIButton!
    
    var mode: SODMode = .outdated
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switch mode {
        case .outdated:
            setupAsOutdated()
        }
    }
    
    private func setupAsOutdated() {
        logoView.image = #imageLiteral(resourceName: "logo-1").withRenderingMode(.alwaysTemplate)
        logoView.tintColor = UIColor.teambrellaBlue
        
        titleLabel.text = "Info.DemoExpired.Title".localized
        detailsLabel.text = "Info.DemoExpired.Details".localized
        
        upperButton.setTitle("Info.DemoExpired.UpperButton.Title".localized, for: .normal)
        lowerButton.setTitle("Info.DemoExpired.LowerButton.Title".localized, for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
