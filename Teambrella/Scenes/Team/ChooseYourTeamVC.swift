//
//  ChooseYourTeamVC.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 13.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class ChooseYourTeamVC: UIViewController {
    @IBOutlet var backView: UIView!
    @IBOutlet var container: UIView!
    @IBOutlet var header: UILabel!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var containerHeight: NSLayoutConstraint!
    @IBOutlet var teamCell: TeamCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.text = "Team.ChooseYourTeamVC.header".localized
        //contH = tableView.countOfCells + 65
        // Do any additional setup after loading the view.
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
