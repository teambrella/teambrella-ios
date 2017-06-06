//
//  Date.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 13.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

extension Date {
    func interval(of component: Calendar.Component, since date: Date) -> Int {
        let currentCalendar = Calendar.current
        guard let start = currentCalendar.ordinality(of: component, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: component, in: .era, for: self) else { return 0 }
        
        return end - start
    }
    
    var cSharpString: String { return iso8601 }
    
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}
