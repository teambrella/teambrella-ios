//
//  TeamCell.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 13.07.17.

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

import UIKit

class TeamCell: UITableViewCell, XIBInitableCell {
    @IBOutlet var container: UIView!
    @IBOutlet var teamIcon: UIImageView!
    @IBOutlet var incomingCount: Label!
    @IBOutlet var teamName: UILabel!
    @IBOutlet var itemName: UILabel!
    @IBOutlet var coverage: UILabel!
    @IBOutlet var tick: UIImageView!
    @IBOutlet var iconCoverage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        teamIcon.layer.cornerRadius = 3
        incomingCount.layer.borderWidth = 1.5
        incomingCount.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1).cgColor
    }
    
}
