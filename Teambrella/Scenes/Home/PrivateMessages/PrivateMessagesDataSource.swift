//
//  PrivateMessagesDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 30.08.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import UIKit

class PrivateMessagesDataSource: NSObject {
    let limit = 100
    var offset = 0
    var hasNext: Bool = true
    var previousFilter: String?
    
    var items: [PrivateChatUser] = []
    
    var isEmpty: Bool { return items.isEmpty }
  
    var onLoad: (() -> Void)?
    
    func loadNext(filter: String? = nil) {
        if filter != previousFilter { items.removeAll() }
        previousFilter = filter
        service.storage.requestPrivateList(offset: offset, limit: limit, filter: filter).observe { [weak self] result in
            guard let `self` = self else { return }
            
            switch result {
            case let .value(users):
                self.items.append(contentsOf: users)
                self.offset += users.count
                self.hasNext = users.count == self.limit
                self.onLoad?()
            case .error:
                break
            }
        }
    }
    
}
