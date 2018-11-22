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

struct ChatCellBuilder {
    static func populateUserData(cell: UICollectionViewCell,
                                 controller: UniversalChatVC,
                                 indexPath: IndexPath,
                                 model: ChatCellUserDataLike) {
        if let cell = cell as? ChatVariousContentCell {
            cell.prepare(with: model,
                         myVote: controller.dataSource.myVote,
                         type: controller.dataSource.chatType,
                         size: controller.cloudSize(for: indexPath))
            cell.avatarView.tag = indexPath.row
            cell.avatarTap.removeTarget(controller, action: #selector(UniversalChatVC.tapAvatar))
            cell.avatarTap.addTarget(controller, action: #selector(UniversalChatVC.tapAvatar))
            cell.onTapImage = { [weak controller] cell, galleryView in
                guard let controller = controller else { return }
                
                galleryView.fullscreen(in: controller, imageStrings: controller.dataSource.allImages)
            }
        } else if let cell = cell as? ChatTextCell {
            cell.prepare(with: model,
                         myVote: controller.dataSource.myVote,
                         type: controller.dataSource.chatType,
                         size: controller.cloudSize(for: indexPath))
            cell.avatarView.tag = indexPath.row
            cell.avatarTap.removeTarget(controller, action: #selector(UniversalChatVC.tapAvatar))
            cell.avatarTap.addTarget(controller, action: #selector(UniversalChatVC.tapAvatar))
            cell.onTapImage = { [weak controller] cell, galleryView in
                guard let controller = controller else { return }
                
                galleryView.fullscreen(in: controller, imageStrings: controller.dataSource.allImages)
            }
        } else if let cell = cell as? ChatImageCell {
            cell.prepare(with: model, size: controller.cloudSize(for: indexPath))
            cell.avatarView.tag = indexPath.row
            cell.avatarTap.removeTarget(controller, action: #selector(UniversalChatVC.tapAvatar))
            cell.avatarTap.addTarget(controller, action: #selector(UniversalChatVC.tapAvatar))
            cell.onTapImage = { [weak controller] cell, galleryView in
                guard let controller = controller else { return }
                
                galleryView.fullscreen(in: controller, imageStrings: controller.dataSource.allImages)
            }
            cell.onTapDelete = { [weak controller] cell in
                controller?.delete(cell)
            }
        }
    }

    static func populateUnsent(cell: UICollectionViewCell,
                                 controller: UniversalChatVC,
                                 indexPath: IndexPath,
                                 model: ChatCellModel) {
        if let model = model as? ChatUnsentImageCellModel, let cell = cell as? ChatImageCell {
            cell.prepare(with: model, size: controller.cloudSize(for: indexPath))
            cell.onTapDelete = { [weak controller] cell in
                controller?.delete(cell)
            }
        }
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    static func populateService(cell: UICollectionViewCell, controller: UniversalChatVC, model: ChatCellModel) {
        if let cell = cell as? ChatSeparatorCell, let model = model as? ChatSeparatorCellModel {
            cell.text = DateProcessor().yearFilter(from: model.date)
        } else if let cell = cell as? ChatSeparatorCell, let model = model as? ChatSeparatorCellModel {
            cell.text = DateProcessor().yearFilter(from: model.date)
        } else if let cell = cell as? ChatNewMessagesSeparatorCell,
            let model = model as? ChatNewMessagesSeparatorModel {
            cell.setNeedsDisplay()
            cell.label.text = model.text
        } else if let cell = cell as? ChatClaimPaidCell {
            if let model = model as? ServiceMessageWithButtonCellModel {
                cell.messageLabel.textAlignment = .left
                cell.messageLabel.text = model.text
                cell.button.setTitle(model.buttonText, for: .normal)
                cell.confettiView.isHidden = true
                cell.onButtonTap = { [weak controller] in
                    log("tap fund wallet (from chat)", type: .userInteraction)
                    
                    controller?.router.switchToWallet()
                    if let nc = controller?.navigationController {
                        for vc in nc.viewControllers where vc is MasterTabBarController {
                            nc.popToViewController(vc, animated: false)
                            break
                        }
                    }
                    //                    self?.navigationController?.popViewController(animated: false)
                }
            } else if model is ChatClaimPaidCellModel {
                cell.messageLabel.textAlignment = .center
                cell.messageLabel.text = "Team.Chat.ClaimPaidCell.text".localized
                cell.button.setTitle("Team.Chat.ClaimPaidCell.buttonTitle".localized, for: .normal)
                cell.onButtonTap = { [weak controller] in
                    guard let model = controller?.dataSource.chatModel,
                        let claimID = model.basic?.claimID,
                        let team = model.team else { return }
                    
                    let urlText = URLBuilder().urlString(claimID: claimID, teamID: team.teamID)
                    let messageText = CoverageLocalizer(type: team.coverageType).paidClaimText()
                    let combinedText = "\(messageText)\n\(urlText)"
                    let vc = UIActivityViewController(activityItems: [combinedText], applicationActivities: [])
                    controller?.present(vc, animated: true)
                }
            }
        } else if let cell = cell as? ServiceChatCell {
            if let model = model as? ServiceMessageCellModel {
                cell.label.text = model.text
                if model.isClickable {
                    cell.onTap = { [weak controller] in
                        guard let controller = controller else { return }
                        
                            controller.internalPhotoPicker.chatMetadata = controller.dataSource.newPhotoPost()
                            controller.internalPhotoPicker.showOptions()
                    }
                } else {
                    cell.onTap = nil
                }
            }
        }
    }
    
}
