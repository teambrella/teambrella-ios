//
//  ChatHeader.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 13.09.17.
/* Copyright(C) 2017  Teambrella, Inc.
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
//

import SnapKit
import UIKit

/*
class ChatHeader: UICollectionReusableView {
    lazy var titleLabel: Label = {
        let label = Label()
        label.font = UIFont.teambrellaBold(size: 17)
        label.numberOfLines = 2
        label.textAlignment = .center
        self.addSubview(label)
        return label
    }()
    
    lazy var button: UIButton = {
       let button = UIButton()
        button.setTitle(nil, for: .normal)
        self.addSubview(button)
        return button
    }()
    
    lazy var separator: UIView = {
       let view = UIView()
        view.backgroundColor = .paleGray
        self.addSubview(view)
        return view
    }()
    
    private var isConstraintsUpdated: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) not implemented for \(#file)")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        guard isConstraintsUpdated == false else { return }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview()
        }
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        separator.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(0.5)
        }
        isConstraintsUpdated = true
    }
    
}
*/
