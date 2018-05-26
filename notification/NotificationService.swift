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

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest,
                             withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler

        guard let content = request.content.mutableCopy() as? UNMutableNotificationContent else { return }

        bestAttemptContent = content
        guard let payloadDict = content.userInfo["Payload"] as? [AnyHashable: Any] else { return }
        guard let apsDict = content.userInfo["aps"] as? [AnyHashable: Any] else { return }

        let aps = APS(dict: apsDict)
        let payload = RemotePayload(dict: payloadDict)
        let message = RemoteMessage(aps: aps, payload: payload)

        // set content from payload instead of aps
        message.title.flatMap { content.title = $0 }
        message.subtitle.flatMap { content.subtitle = $0 }
        message.body.flatMap { content.body = $0 }

        fetchAttachments(message: message) { [weak self] in
            self?.handleContent()
        }
    }

    override func serviceExtensionTimeWillExpire() {
        handleContent()
    }

    private func handleContent() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    private func fetchAttachments(message: RemoteMessage, completion: @escaping () -> Void) {
        if let avatarURL = message.avatar {
            UIImage.fetchAvatar(string: avatarURL, completion: { [weak self] image, error in
                self?.saveAndAttach(image: image, completion: completion)
            })
        } else if let imageURL = message.image {
            UIImage.fetchImage(string: imageURL, completion: { [weak self] image, error in
               self?.saveAndAttach(image: image, completion: completion)
            })
        } else {
            completion()
        }
    }

    private func saveAndAttach(image: UIImage?, completion: @escaping () -> Void) {
        if let filePath = saveImageToDisk(image: image),
            let attachment = try? UNNotificationAttachment(identifier: "image", url: filePath, options: nil) {
            bestAttemptContent?.attachments = [attachment]
        }
        completion()
    }
    
    private func saveImageToDisk(image: UIImage?) -> URL? {
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
