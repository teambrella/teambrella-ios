//
//  TextAdapter.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 02.06.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftSoup

struct TextAdapter {
    func parsedHTML(string: String) -> String {
        do {
            let doc: Document = try SwiftSoup.parse(string)
            return try doc.text()
        } catch Exception.Error(let type, let message) {
            print("\(type) --> " + message)
        } catch {
            print("error")
        }
        print("Falling back to original message")
        return string
    }
}
