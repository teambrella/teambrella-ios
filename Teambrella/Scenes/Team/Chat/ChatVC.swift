//
//  ChatVC.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 06.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Chatto
import ChattoAdditions
import UIKit

class ChatVC: BaseChatViewController, Routable {
    static var storyboardName = "Chat"
    
    var dataSource: ChatDataSource!

    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createDataSource(topic: Topic) {
        dataSource = ChatDataSource(topic: topic)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: BaseChatViewController
    
    override func createChatInputView() -> UIView {
        return UIView()
    }
    
    override func createPresenterFactory() -> ChatItemPresenterFactoryProtocol {
       return super.createPresenterFactory()
    }
    
    override func createPresenterBuilders() -> [ChatItemType : [ChatItemPresenterBuilderProtocol]] {
        fatalError("Not yet implemented")
    }

}

struct ChatItemBuilder: ChatItemPresenterBuilderProtocol {
    func canHandleChatItem(_ chatItem: ChatItemProtocol) -> Bool {
        return false
    }
    
    func createPresenterWithChatItem(_ chatItem: ChatItemProtocol) -> ChatItemPresenterProtocol {
        fatalError("Not yet implemented")
    }
    
    var presenterType: ChatItemPresenterProtocol.Type
}
