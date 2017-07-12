//
//  DateProcessor.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 11.07.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation
import SwiftDate

struct DateProcessor {
    
    // swiftlint:disable force_try
    func stringInterval(from date: Date, isColloquial: Bool = true) -> String {
        let (colloquial, relevant) = try! date.colloquial(to: Date())
        return isColloquial ? colloquial : relevant ?? ""
    }
    
    // swiftlint:disable force_try
    func stringFromNow(seconds: Int = 0,
                       minutes: Int = 0,
                       hours: Int = 0,
                       days: Int = 0,
                       isColloquial: Bool = true) -> String {
        let dateInRegion: DateInRegion = DateInRegion()
        let date = dateInRegion - days.days - hours.hours - minutes.minutes - seconds.seconds
        let (colloquial, relevant) = try! date.colloquialSinceNow()
        return isColloquial ? colloquial : relevant ?? ""
    }
}
