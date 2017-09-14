//
//  TeammateVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 10.04.17.

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

import Kingfisher
import UIKit

class TeammateVC: UIViewController {
    var teammate: TeammateEntity!
    
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var riskLabel: UILabel!
    @IBOutlet var weightLabel: UILabel!
    
    @IBOutlet var modelLabel: UILabel!
    @IBOutlet var modelYearLabel: UILabel!
    
    @IBOutlet var discussionButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: service.server.avatarURLstring(for: teammate.avatar))
        avatarImageView.kf.setImage(with: url)
        nameLabel.text = teammate.name
        modelLabel.text = teammate.model
        modelYearLabel.text = String(teammate.year)
        //loadEntireTeammate()
        
        discussionButton.backgroundColor = .orange
        
    }
    
//    private func loadEntireTeammate() {
//        let key = Key(base58String: ServerService.privateKey, timestamp: service.server.timestamp)
//
//        let body = RequestBodyFactory.teammateBody(key: key, id: teammate.userID)
//        let request = TeambrellaRequest(type: .teammate, body: body, success: { [weak self] response in
//            guard let me = self else { return }
//
//            if case .teammate(let extendedTeammate) = response {
//                me.teammate.extended = extendedTeammate
//                print("topic: \(extendedTeammate.topic)")
//                me.presentEntireTeammate()
//            }
//        })
//        request.start()
//    }
    
    private func presentEntireTeammate() {
       // teammate.extended?.price.map { self.priceLabel.text = String($0) }
        riskLabel.text = String(teammate.risk)
       // teammate.extended?.weight.map { self.weightLabel.text = String($0) }
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.type == .discussion, let vc = segue.destination as? ThreadTVC {
            vc.teammate = teammate
        }
    }

}
