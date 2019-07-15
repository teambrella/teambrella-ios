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
            cell.onTapImage = { [weak controller] cell, galleryView in
                guard let controller = controller else { return }

                galleryView.fullscreen(in: controller, imageStrings: controller.dataSource.allImages)
            }
        } else if let cell = cell as? ChatTextCell, let model = model as? ChatTextCellModel {
            cell.prepare(with: model,
                         myVote: controller.dataSource.myVote,
                         type: controller.dataSource.chatType,
                         size: controller.cloudSize(for: indexPath))
        } else if let cell = cell as? ChatImageCell {
            if let model = model as? ChatUnsentImageCellModel {
                cell.prepareUnsentCell(model: model,
                                       marksOnlyMode: controller.dataSource.isMarksOnlyMode,
                                       size: controller.cloudSize(for: indexPath),
                                       image: controller.unsentImages[model.id])
            } else {
                cell.prepareRealCell(model: model,
                                     size: controller.cloudSize(for: indexPath))
            }
            cell.onTapImage = { [weak controller] cell, galleryView in
                guard let controller = controller else { return }

                galleryView.fullscreen(in: controller, imageStrings: controller.dataSource.allImages)
            }
            cell.onTapDelete = { [weak controller] cell in
                controller?.delete(cell)
            }
        }
        
        if let cell = cell as? ChatUserDataCell {
            cell.avatarView.tag = indexPath.row
            cell.avatarTap.removeTarget(controller, action: #selector(UniversalChatVC.tapAvatar))
            cell.avatarTap.addTarget(controller, action: #selector(UniversalChatVC.tapAvatar))
            cell.onInitiateCommandList = { [weak controller] cell in
                if controller?.dataSource.isInputAllowed ?? false {
                    guard let controller = controller else { return }
                    
                    controller.showCommandList(model: model)
                }
            }
        }
        
    }

    static func populateUnsent(cell: UICollectionViewCell,
                               controller: UniversalChatVC,
                               indexPath: IndexPath,
                               model: ChatCellModel) {
        if let model = model as? ChatUnsentImageCellModel, let cell = cell as? ChatImageCell {
            cell.prepareUnsentCell(model: model,
                                   marksOnlyMode: controller.dataSource.isMarksOnlyMode,
                                   size: controller.cloudSize(for: indexPath),
                                   image: controller.unsentImages[model.id])
            cell.onTapDelete = { [weak controller] cell in
                controller?.delete(cell)
            }
        }
    }
    
    // swiftlint:disable:next cyclomatic_complexity
    static func populateService(cell: UICollectionViewCell,
                                controller: UniversalChatVC,
                                model: ChatCellModel) {
        if let cell = cell as? ChatSeparatorCell, let model = model as? ChatSeparatorCellModel {
            cell.text = DateProcessor().yearFilter(from: model.date)
        } else if let cell = cell as? ChatSeparatorCell, let model = model as? ChatSeparatorCellModel {
            cell.text = DateProcessor().yearFilter(from: model.date)
        } else if let cell = cell as? ChatNewMessagesSeparatorCell,
            let model = model as? ChatNewMessagesSeparatorModel {
            cell.setNeedsDisplay()
            cell.label.text = model.text
        } else if let cell = cell as? ChatClaimPaidCell, let model = model as? ServiceMessageWithButtonCellModel {
            cell.messageLabel.textAlignment = .left
            cell.messageLabel.text = model.text
            cell.button.setTitle(model.buttonText, for: .normal)
            cell.confettiView.isHidden = true
            cell.onButtonTap = { [weak controller] in
                log("tap fund wallet (from chat)", type: .userInteraction)
                switch model.command {
                case .addPhoto, .addMorePhoto:
                    controller?.showAddPhoto()
                default:
                    controller?.router.switchToWallet()
                    if let nc = controller?.navigationController {
                        for vc in nc.viewControllers where vc is MasterTabBarController {
                            nc.popToViewController(vc, animated: false)
                            break
                        }
                    }
                }
            }
        } else if let cell = cell as? ChatClaimPaidCell, model is ChatClaimPaidCellModel {
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
        } else if let cell = cell as? ChatServiceTextCell, let model = model as? ServiceMessageCellModel {
            cell.prepare(with: model, size: controller.sizeForServiceMessage(model: model) )
            if let command = model.command {
                cell.onTap = { [weak controller] in
                    switch command {
                    case .addMorePhoto:
                        controller?.showAddPhoto()
                    default:
                        break
                    }
                }
            } else {
                cell.onTap = nil
            }
        }
    }
    
    static func populateVotingStats(cell: UICollectionViewCell,
                                controller: UniversalChatVC,
                                model: ChatCellModel) {
        guard let chatModel = controller.dataSource.chatModel else {return}
        let basic = chatModel.basic
        let team = chatModel.team
        var isMe = false
        guard basic != nil, team != nil else { return }
        
        if let cell = cell as? VotingStatsCell, let model = model as? VotingStatsCellModel {
            
            if let me = service.session?.currentUserID, me == basic!.userID {
                cell.headerLabel.text = "Team.TeammateCell.howIVote".localized.uppercased()
                isMe = true
            } else {
                cell.headerLabel.text = "Team.TeammateCell.howXVotes".localized(basic!.name?.first ?? "").uppercased()
            }
            
            cell.forRisksTitleLabel.text = "Team.TeammateCell.forRisks".localized.uppercased()
            if (basic!.risksVoteAsTeamOrBetter ?? -1) < 0 {
                cell.forRisksValueLabel.text = "-"
            } else {
                cell.forRisksValueLabel.text = String(format: "%.0f%%", (basic!.risksVoteAsTeamOrBetter!*100).rounded())
            }
            
            cell.forPayoutsTitleLabel.text = "Team.TeammateCell.forPayouts".localized.uppercased()
            if (basic!.claimsVoteAsTeamOrBetter ?? -1) < 0 {
                cell.forPayoutsValueLabel.text = "-"
            } else {
                cell.forPayoutsValueLabel.text = String(format: "%.0f%%", (basic!.claimsVoteAsTeamOrBetter!*100).rounded())
            }
            
            cell.forRisksInfoLabel.text = "Team.TeammateCell.asTeamOrLower".localized.uppercased()
            cell.forPayoutsInfoLabel.text = "Team.TeammateCell.asTeamOrMore".localized.uppercased()
            
            cell.onTapClaims = { [weak controller] in
                controller?.router.presentVotingStats(teamID: team!.teamID,
                                                      teammateID: basic!.teammateID ?? -1,
                                                      teammateName: basic!.name?.entire ?? "",
                                                      voteAsTeamOrBetter: basic!.claimsVoteAsTeamOrBetter ?? -1,
                                                      voteAsTeam: basic!.claimsVoteAsTeam ?? -1,
                                                      isClaimsStats: true,
                                                      isMe: isMe)
            }
            cell.onTapRisks = { [weak controller] in
                controller?.router.presentVotingStats(teamID: team!.teamID,
                                                      teammateID: basic!.teammateID ?? -1,
                                                      teammateName: basic!.name?.entire ?? "",
                                                      voteAsTeamOrBetter: basic!.risksVoteAsTeamOrBetter ?? -1,
                                                      voteAsTeam: basic!.risksVoteAsTeam ?? -1,
                                                      isClaimsStats: false,
                                                      isMe: isMe)
            }
        }
    }

}
