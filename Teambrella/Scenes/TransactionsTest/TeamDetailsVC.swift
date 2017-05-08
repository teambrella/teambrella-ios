//
//  TeamDetailsVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 25.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class TeamDetailsVC: UIViewController {
    var team: Team!
    
    @IBOutlet var teamLabel: UILabel!
    @IBOutlet var idLabel: UILabel!
    @IBOutlet var testnetLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        teamLabel.text = team.name
        idLabel.text = "Id: \(team.id)"
        testnetLabel.text = team.isTestnet ? "Is Testnet" : "Is a Real Group"
        // Do any additional setup after loading the view.
    }
    
    @IBAction func tapClose(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
