//
/* Copyright(C) 2017 Teambrella, Inc.
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
 * along with this program.  If not, see<http://www.gnu.org/licenses/>.
 */

import UserNotifications
//import UIKit

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest,
                             withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        guard let content = request.content.mutableCopy() as? UNMutableNotificationContent else { return }
        guard let payloadDict = content.userInfo["Payload"] as? [AnyHashable: Any] else { return }
        
        let payload = RemotePayload(dict: payloadDict)
        
        let message = RemoteMessage(payload: payload)
        message.title.flatMap { content.title = $0 }
        message.subtitle.flatMap { content.subtitle = $0 }
        message.body.flatMap { content.body = $0 }
        
        if let avatarURL = message.avatar {
            UIImage.fetchAvatar(string: avatarURL, completion: { image, error in
                if let filePath = self.saveImage(image: image),
                    let attachment = try? UNNotificationAttachment(identifier: "image", url: filePath, options: nil) {
                    content.attachments = [attachment]
                    contentHandler(content)
                } else {
                    content.title = "Failed to fetch image"
                    contentHandler(content)
                }
            })
        } else if let imageURL = message.image {
            UIImage.fetchImage(string: imageURL, completion: { image, error in
                if let filePath = self.saveImage(image: image),
                    let attachment = try? UNNotificationAttachment(identifier: "image", url: filePath, options: nil) {
                    content.attachments = [attachment]
                    contentHandler(content)
                } else {
                    content.title = "Failed to fetch image"
                    contentHandler(content)
                }
            })
        } else {
            // fall back to the original content
            content.title = "No info about image in this push"
            contentHandler(request.content)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            bestAttemptContent.title = "Time expired"
            contentHandler(bestAttemptContent)
        }
    }
    
    func saveImage(image: UIImage?) -> URL? {
        guard let image = image else { return nil }
        
        if let data = UIImagePNGRepresentation(image) {
            let filename = ProcessInfo.processInfo.globallyUniqueString
            let path = URL(fileURLWithPath: NSTemporaryDirectory())
            let filePath = path.appendingPathComponent("\(filename).png")
            do {
                try data.write(to: filePath)
                return filePath
            } catch {
                
            }
        }
        return nil
    }
    
}
