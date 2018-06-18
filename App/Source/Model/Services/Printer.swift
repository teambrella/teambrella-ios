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

import UIKit

final class Printer {
    let presentingView: UIView
    let presentingFrame: CGRect

    init(presentingView: UIView, presentingFrame: CGRect? = nil) {
        self.presentingView = presentingView
        self.presentingFrame = presentingFrame ?? presentingView.frame
    }

    func print(image: UIImage,
               completion: @escaping (Error?) -> Void) {
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = UIPrintInfoOutputType.general
        printInfo.jobName = "Teambrella print job"

        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        printController.printingItem = image
        printController.present(from: presentingFrame,
                                in: presentingView,
                                animated: true,
                                completionHandler: { controller, success, error in
                                   completion(error)
        })
    }

}
