//
//  ChatNewMessagesSeparatorCell.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 22.09.2017.
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

import UIKit

class ChatNewMessagesSeparatorCell: UICollectionViewCell {
    lazy var label: Label = {
        let label = Label()
        label.font = UIFont.teambrellaBold(size: 10)
        label.textColor = self.color
        self.contentView.addSubview(label)
        return label
    }()
    
    lazy var separatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = self.color
        self.contentView.addSubview(view)
        return view
    }()
    
    var color: UIColor = .red
    
    private var areConstraintsUpdated: Bool = false
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) not implemented for \(#file)")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setNeedsUpdateConstraints()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        guard areConstraintsUpdated == false else { return }

        /*
        label.snp.makeConstraints { make in
            make.right.equalToSuperview().offset(-8)
            make.top.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        separatorLine.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.right.equalTo(label.snp.left).offset(-8)
            make.height.equalTo(0.5)
        }
 */
        areConstraintsUpdated = true
    }
    
}
