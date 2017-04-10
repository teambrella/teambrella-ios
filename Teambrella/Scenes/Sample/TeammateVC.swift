//
//  TeammateVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 10.04.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Kingfisher
import UIKit

class TeammateVC: UIViewController {
    var teammate: Teammate!
    
    @IBOutlet var avatarImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var riskLabel: UILabel!
    @IBOutlet var weightLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = URL(string: service.server.avatarURLstring(for: teammate.avatar))
        avatarImageView.kf.setImage(with: url)
        nameLabel.text = teammate.name
        loadEntireTeammate()
    }
    
    private func loadEntireTeammate() {
        guard let key = Key(base58String: ServerService.Constant.fakePrivateKey, timestamp: service.server.timestamp)
            else {
            return
        }
        
        let body = RequestBodyFactory.teammateBody(key: key, id: teammate.userID)
        let request = AmbrellaRequest(type: .teammate, body: body, success: { [weak self] response in
            if case .teammate(let teammate) = response {
                self?.teammate = teammate
                self?.presentEntireTeammate()
            }
        })
        request.start()
    }
    
    private func presentEntireTeammate() {
        teammate.price.map { self.priceLabel.text = String($0) }
        riskLabel.text = String(teammate.risk)
        teammate.weight.map { self.weightLabel.text = String($0) }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
