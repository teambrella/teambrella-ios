//
//  ChatDataSource.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 06.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Chatto
import Foundation

class ChatDataSource: ChatDataSourceProtocol {
    var hasMoreNext: Bool = false
    var hasMorePrevious: Bool = false
    var chatItems: [ChatItemProtocol] = []
    weak var delegate: ChatDataSourceDelegateProtocol?
    var topic: Topic
    
    init(topic: Topic) {
        self.topic = topic
    }
    
    func loadNext() {
        
    }
    
    func loadPrevious() {
        
    }
    
    func adjustNumberOfMessages(preferredMaxCount: Int?, focusPosition: Double, completion: (Bool) -> Void) {
        
    }
}
