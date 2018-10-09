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

class ApplicationBackgroundView: UIView {
    lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear //UIColor.frenchBlue
        view.image = #imageLiteral(resourceName: "confetti")
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        self.addSubview(view)
        return view
    }()
    
    lazy var gradientView: GradientView = {
        let view = GradientView()
        self.addSubview(view)
        view.topColor = #colorLiteral(red: 0.2549019608, green: 0.3058823529, blue: 0.8, alpha: 1)
        view.bottomColor = #colorLiteral(red: 0.4078431373, green: 0.4549019608, blue: 0.9058823529, alpha: 1)
        return view
    }()
    
    var isUpdatedConstraints: Bool = false
    
    override func updateConstraints() {
        super.updateConstraints()
        if !isUpdatedConstraints {
            gradientView.translatesAutoresizingMaskIntoConstraints = false
            gradientView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            gradientView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            gradientView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            gradientView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            imageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            imageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
            
            isUpdatedConstraints = true
        }
    }
    
}
