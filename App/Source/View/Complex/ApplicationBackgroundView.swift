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
        view.backgroundColor = UIColor.frenchBlue
        view.image = #imageLiteral(resourceName: "confetti")
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        self.addSubview(view)
        return view
    }()
    
    var isUpdatedConstraints: Bool = false
    
    override func updateConstraints() {
        super.updateConstraints()
        if !isUpdatedConstraints {
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            imageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            imageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true

            isUpdatedConstraints = true
        }
    }
    
}
