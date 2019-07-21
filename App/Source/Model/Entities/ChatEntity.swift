//
//  ChatEntity.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 17.07.17.

/* Copyright(C) 2017  Teambrella, Inc.
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

import ExtensionsPack
import Foundation

enum SystemType: Int, Codable {
    case firstPhotoMissing = 800
    case firstPostMissing  = 810
    case needsFunding      = 900
    
}

struct SystemMessageID {
    static let addPhoto = "00000800-0800-0800-0800-000000000001"
}

struct ChatEntity: Decodable {
    let userID: String
    let lastUpdated: Int64
    let id: String
    let likes: Int
    let myLike: Int
    let isMarked: Bool
    let grayed: Double
    let suggestAddingToProxy: Bool?
    let suggestRemovingFromProxy: Bool?
    let text: String
    let teammate: TeammatePart?
    let systemType: SystemType?

    private let imagesReceived: [String]?
    private let smallImagesReceived: [String]?
    private let imageRatiosReceived: [CGFloat]?

    var images: [String] { return imagesReceived ?? [] }
    var smallImages: [String] { return smallImagesReceived ?? [] }
    var imageRatios: [CGFloat] { return imageRatiosReceived ?? [] }

    private let dateCreated: UInt64

    var created: Date { return Date(ticks: dateCreated) }

    enum CodingKeys: String, CodingKey {
        case userID = "UserId"
        case lastUpdated = "LastUpdated"
        case id = "Id"
        case likes = "Likes"
        case myLike = "MyLike"
        case isMarked = "IsMarked"
        case grayed = "Grayed"
        case suggestAddingToProxy = "SuggestAddingToProxy"
        case suggestRemovingFromProxy = "SuggestRemovingFromProxy"
        case text = "Text"
        case imagesReceived = "Images"
        case smallImagesReceived = "SmallImages"
        case imageRatiosReceived = "ImageRatios"
        case teammate = "TeammatePart"
        case dateCreated = "Created"
        case systemType = "SystemType"
    }

    struct TeammatePart: Decodable {
        let isMyProxy: Bool
        let name: Name
        let avatar: Avatar
        let vote: Double?

        enum CodingKeys: String, CodingKey {
            case isMyProxy = "IsMyProxy"
            case name = "Name"
            case avatar = "Avatar"
            case vote = "Vote"
        }
        
    }

}
