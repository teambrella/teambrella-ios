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
        
        print("received notification: \(request)")
        guard let content = request.content.mutableCopy() as? UNMutableNotificationContent else { return }
        
        if let urlString = request.content.userInfo["image"] as? String {
            print(urlString)
            
            content.body += "url: \(urlString)"
            //contentHandler(content)
            
            guard let url = URL(string: urlString) else { return }
            
            store(url: url, fileExtension: "png", completion: { path, error in
                if let path = path,
                    let attachment = try? UNNotificationAttachment(identifier: "image", url: path, options: nil) {
                        content.attachments = [attachment]
                    content.subtitle = "Получен атачмент"
                        contentHandler(content)
                    } else {
                    content.subtitle = "Атачмент не удалось получить"
                    content.body = "\(error)"
                        contentHandler(content)
                    }
                })
 
            /*
            UIImage.fetchImage(string: urlString, completion: { image, error in
                if let filePath = self.saveImage(image: image),
                    let attachment = try? UNNotificationAttachment(identifier: "image", url: filePath, options: nil) {
                    content.attachments = [attachment]
                    content.title = "Ok"
                    contentHandler(content)
                } else {
                    content.title = "Failed to fetch image"
                    contentHandler(content)
                }
            })
            */
 
        } else {
            // fall back to the original content
            content.title = "No info about image in this push"
            contentHandler(request.content)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt"
        // at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            bestAttemptContent.title = "Time expired"
            contentHandler(bestAttemptContent)
        }
    }
    
    /*
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
 */
    
    func store(url: URL, fileExtension: String, completion: ((URL?, Error?) -> Void)?) {
        // obtain path to temporary file
        let fileName = ProcessInfo.processInfo.globallyUniqueString
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
        let path = fileURL.appendingPathComponent("\(fileName).\(fileExtension)")
        
        // fetch attachment
        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, response, error in
            _ = try? data?.write(to: path)
            completion?(path, error)
        }
        task.resume()
    }
    
}
