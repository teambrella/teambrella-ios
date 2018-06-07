//
/* Copyright(C) 2016-2018 Teambrella, Inc.
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
 * along with this program.  If not, see http://www.gnu.org/licenses/
 */

import ClockKit
import WatchKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    enum Constant {
        static let complicationCurrentEntry = "ComplicationCurrentEntry"
        static let complicationTextData = "ComplicationTextData"
        static let complicationShortTextData = "ComplicationShortTextData"
    }

    // MARK: - Timeline Configuration
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication,
                                          withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    // MARK: - Timeline Population

    func getCurrentTimelineEntry(for complication: CLKComplication,
                                 withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        //        guard let myDelegate = WKExtension.shared().delegate as? ExtensionDelegate else { return }
        //
        //        var data: Dictionary = myDelegate.dictionaryWithValues(forKeys: [Constant.complicationCurrentEntry,
        //                                                                          Constant.complicationTextData,
        //

        var entry: CLKComplicationTimelineEntry?
        let now = Date()
        let longText = "Teambrella" //data[Constant.complicationTextData] as! String
        let shortText = "Wallet" //data[Constant.complicationShortTextData] as! String

        if complication.family == .modularSmall {
            let textTemplate = CLKComplicationTemplateModularSmallSimpleText()
            textTemplate.textProvider = CLKSimpleTextProvider(text: shortText, shortText: shortText)
            entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: textTemplate)
        } else if complication.family == .modularLarge {
            let large = CLKComplicationTemplateModularLargeStandardBody()
            large.headerTextProvider = CLKSimpleTextProvider(text: longText)
            large.body1TextProvider = CLKSimpleTextProvider(text: shortText)
            entry = CLKComplicationTimelineEntry(date: now, complicationTemplate: large)
        }

        handler(entry)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication,
                                      withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        print("complication family: \(complication.family)")
        if complication.family == .modularSmall {
            let smallFlat = CLKComplicationTemplateModularSmallSimpleText()
            smallFlat.textProvider = CLKSimpleTextProvider(text: "Wallet", shortText: "W")
            handler(smallFlat)
        } else if complication.family == .modularLarge {
            let large = CLKComplicationTemplateModularLargeStandardBody()
            large.headerTextProvider = CLKSimpleTextProvider(text: "Wallet")
            large.body1TextProvider = CLKSimpleTextProvider(text: "Coverage: 100%")
            handler(large)

        } else {
            handler(nil)
        }
    }
    
}
