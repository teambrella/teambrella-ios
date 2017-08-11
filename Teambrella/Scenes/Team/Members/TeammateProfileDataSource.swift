//
//  TeammateProfileDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 30.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import SwiftyJSON
import UIKit

enum TeammateProfileCellType: String {
    case me, summary, object, stats, contact, dialog, dialogCompact, voting
}

enum SocialItemType: String {
    case facebook, twitter, email
}

struct SocialItem {
    var name: String {
        return type.rawValue
    }
    let type: SocialItemType
    let icon: UIImage?
    let address: String
}

class TeammateProfileDataSource {
    let id: String
    let isMe: Bool
    let isVoting: Bool
    var isMyProxy: Bool = false
    
    var source: [TeammateProfileCellType] = []
    var extendedTeammate: ExtendedTeammate?
    var riskScale: RiskScaleEntity? { return extendedTeammate?.riskScale }
    var isNewTeammate = false
    
    init(id: String, isVoting: Bool, isMe: Bool) {
        self.id = id
        self.isVoting = isVoting
        self.isMe = isMe
    }
    
    var sections: Int = 1
    
    func rows(in section: Int) -> Int {
        return source.count
    }
    
    func type(for indexPath: IndexPath) -> TeammateProfileCellType {
        return source[indexPath.row]
    }
    
    func loadEntireTeammate(completion: @escaping () -> Void) {
        let key = Key(base58String: ServerService.privateKey, timestamp: service.server.timestamp)
        
        let body = RequestBodyFactory.teammateBody(key: key, id: id)
        let request = TeambrellaRequest(type: .teammate, body: body, success: { [weak self] response in
            guard let me = self else { return }
            
            if case .teammate(let extendedTeammate) = response {
                me.extendedTeammate = extendedTeammate
                me.modifySource()
                completion()
            }
        })
        request.start()
    }
    
    func addToProxy(completion: @escaping (Bool) -> Void) {
        service.storage.myProxy(userID: id, add: !isMyProxy, success: { [weak self] in
            guard let me = self else { return }
            
            me.isMyProxy = !me.isMyProxy
            completion(me.isMyProxy)
        }) { [weak self] error in
            guard let me = self else { return }
            
            completion(me.isMyProxy)
        }
    }
    
    func sendRisk(userID: String, risk: Double?, completion: @escaping (JSON) -> Void) {
        service.server.updateTimestamp { timestamp, error in
            let key = service.server.key
            let body = RequestBody(payload: ["TeammateId": userID,
                                             "MyVote": risk ?? NSNull(),
                                             "Since": key.timestamp,
                                             "ProxyAvatarSize": 32])
            let request = TeambrellaRequest(type: .teammateVote, body: body, success: { response in
                if case .teammateVote(let json) = response {
                    completion(json)
                }
            })
            request.start()
        }
        
    }
    
    private func modifySource() {
        guard let teammate = extendedTeammate else { return }
        
        isMyProxy = teammate.basic.isMyProxy
        if isVoting {
            isNewTeammate = true
            source.append(.dialogCompact)
            source.append(.voting)
        } else {
            source.append(isMe ? .me : .summary)
                source.append(.object)
                source.append(.stats)
            if !socialItems.isEmpty {
                source.append(.contact)
            }
            if !isNewTeammate {
                source.append(.dialog)
            }
        }
    }
    
    var socialItems: [SocialItem] {
        var items: [SocialItem] = []
        if let facebook = extendedTeammate?.basic.facebook {
            items.append(SocialItem(type: .facebook, icon: #imageLiteral(resourceName: "facebook"), address: facebook))
        }
        return items
    }
}
