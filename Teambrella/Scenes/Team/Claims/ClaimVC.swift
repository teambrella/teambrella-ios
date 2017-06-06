//
//  ClaimVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 06.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class ClaimVC: UIViewController, Routable {
    struct Constant {
        static let avatarSize = 64
        static let proxyAvatarSize = 32
    }
    
    static var storyboardName = "Claims"
    
    var claim: ClaimLike?
    var enhancedClaim: EnhancedClaimEntity?
    
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let claim = claim else { return }
        
        loadData(claimID: claim.id)
    }
    
    func loadData(claimID: String) {
        service.server.updateTimestamp { timestamp, error in
            let key = Key(base58String: ServerService.Constant.fakePrivateKey,
                          timestamp: timestamp)
            
            let body = RequestBody(key: key, payload:["id": Int(claimID) ?? 0,
                                                      "AvatarSize": Constant.avatarSize,
                                                      "ProxyAvatarSize": Constant.proxyAvatarSize])
            let request = TeambrellaRequest(type: .claim, body: body, success: { [weak self] response in
                if case .claim(let claim) = response {
                    guard let me = self else { return }
                    
                    me.enhancedClaim = claim
                    print("Loaded enhanced claim \(claim)")
                }
                }, failure: { [weak self] error in
                 
            })
            request.start()
        }

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
