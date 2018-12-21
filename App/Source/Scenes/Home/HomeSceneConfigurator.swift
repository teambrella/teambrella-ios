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

import Foundation

protocol HomeConfigurator {
    var model: HomeModel? { get set }

    func configure(controller: HomeVC)
    func clearScreen(controller: HomeVC)
}

class HomeDefaultConfigurator: HomeConfigurator {
    var model: HomeModel?

    func clearScreen(controller: HomeVC) {
        controller.greetingsTitleLabel.text = nil
        controller.greetingsSubtitileLabel.text = nil

        controller.leftBrickAmountLabel.text = "..."
        controller.rightBrickAmountLabel.text = "..."

        //itemCard.avatarView.image = #imageLiteral(resourceName: "imagePlaceholder")
        controller.itemCard.subtitleLabel.text = nil
        controller.itemCard.titleLabel.text = nil
    }

    func configure(controller: HomeVC) {
        guard let model = model else { return }

        controller.leftBrickAmountLabel.text = String(format: "%.0f", model.coverage.percentage)
        controller.rightBrickAmountLabel.text = String(Int(MEth(model.balance).value))
        controller.rightBrickCurrencyLabel.text = service.session?.cryptoCoin.code

        controller.greetingsTitleLabel.text = "Home.salutation".localized(controller.dataSource.name.first)
        controller.greetingsSubtitileLabel.text = "Home.subtitle".localized

        controller.leftBrickTitleLabel.text = "Home.leftBrick.title".localized
        controller.rightBrickTitleLabel.text = "Home.rightBrick.title".localized

        if !model.smallPhoto.string.isEmpty {
            controller.itemCard.avatarView.present(imageString: model.smallPhoto.string)
        }

        controller.itemCard.avatarView.onTap = { [weak controller] sender in
            let context = UniversalChatContext()
            service.router.presentChat(context: context)
        }
        controller.itemCard.titleLabel.text = model.objectName.entire
        controller.itemCard.statusLabel.text = "Home.itemCard.status".localized
        controller.itemCard.subtitleLabel.text = CoverageLocalizer(type: model.teamPart.coverageType).coverageType

        let buttonTitle = model.haveVotingClaims
            ? "Home.submitButton.anotherClaim".localized
            : "Home.submitButton.claim".localized
        controller.submitClaimButton.setTitle(buttonTitle, for: .normal)

        controller.pageControl.numberOfPages = controller.dataSource.cardsCount
        controller.topBarVC.setPrivateMessages(unreadCount: model.unreadCount)

        if let accessLevel = service.session?.currentTeam?.teamAccessLevel {
            controller.submitClaimButton.isEnabled = accessLevel == .full
        }
        controller.submitClaimButton.setTitleColor(#colorLiteral(red: 0.5843137255, green: 0.6470588235, blue: 0.6941176471, alpha: 1), for: .disabled)
        controller.submitClaimButton.borderColor = controller.submitClaimButton.isEnabled ? #colorLiteral(red: 0.568627451, green: 0.8784313725, blue: 1, alpha: 1) : #colorLiteral(red: 0.5843137255, green: 0.6470588235, blue: 0.6941176471, alpha: 1)
        controller.submitClaimButton.shadowColor = controller.submitClaimButton.isEnabled ? #colorLiteral(red: 0.568627451, green: 0.8784313725, blue: 1, alpha: 0.2) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        controller.submitClaimButton.alpha = controller.submitClaimButton.isEnabled ? 1 : 0.5
    }

}
