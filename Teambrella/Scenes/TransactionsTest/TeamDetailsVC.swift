//
//  TeamDetailsVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.04.17.

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

class TeamDetailsVC: UIViewController {
    var team: Team!
    
    @IBOutlet var teamLabel: UILabel!
    @IBOutlet var idLabel: UILabel!
    @IBOutlet var testnetLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let team = team else {
            teamLabel.text = "No team"
            return
        }
        
        teamLabel.text = team.name
        idLabel.text = "Id: \(team.id)"
        testnetLabel.text = team.isTestnet ? "Is Testnet" : "Is a Real Group"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func tapClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
