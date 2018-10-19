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

class ApplicationVC: UICollectionViewController, Routable {
    static let storyboardName = "Login"
    
    var type: ApplicationScreenType = .intro
    var router: ApplicationRouter?
    
    var models: [ApplicationCellModel] = []
    
    var headerModel: ApplicationHeaderCellModel!
    var userData: UserApplicationData!
    var isInEditingMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let builder = ApplicationCellModelBuilder()
        models = builder.carGroupModels()
        
        let view = ApplicationBackgroundView(frame: self.view.bounds)
        collectionView?.backgroundView = view
        
        assert(userData != nil)
    }
    
    func setupUserData(welcome: WelcomeEntity, inviteCode: String?) {
        userData = UserApplicationData(welcome: welcome)
        userData.inviteCode = inviteCode ?? ""
        headerModel = ApplicationHeaderCellModel(image: welcome.teamLogo,
                                                 name: welcome.teamName,
                                                 city: welcome.location ?? "")
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model = models[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: model.identifier.rawValue,
                                                      for: indexPath)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                   withReuseIdentifier: headerModel.identifier.rawValue,
                                                                   for: indexPath)
        cell.tag = indexPath.row
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 willDisplay cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        guard let applicationCell = cell as? ApplicationCell else {
            fatalError("Wrong cell type: \(cell)")
        }
        
        let model = models[indexPath.row]
        applicationCell.setup(with: model, userData: userData)
        (applicationCell as? ApplicationCellDecorable)?.decorate()
        if let cell = applicationCell as? ApplicationInputCell {
            applicationInput(cell: cell, addActionsFor: model)
            if isInEditingMode, let model = model as? ApplicationInputCellModel {
                cell.inputTextField.isInAlertMode = !userData.validate(model: model)
            } else {
                cell.inputTextField.isInAlertMode = false
            }
        }
        if let cell = applicationCell as? ApplicationActionCell {
            cell.onButtonTap = { [weak self] button in
                guard let `self` = self else { return }

                if self.validateInput() {
                    self.register()
                } else {
                    self.collectionView?.reloadData()
                }
            }
        }
    }

    func validateInput() -> Bool {
        for model in models {
            guard let model = model as? ApplicationInputCellModel else {
                continue
            }

            if userData.validate(model: model) == false {
                isInEditingMode = true
                return false
            }
        }
        return true
    }
    
    func register() {
        let loginWorker = LoginWorker()
        loginWorker.register(userData: userData) { error in
            guard error == nil else { return }

            SimpleStorage().store(bool: false, forKey: .isRegistering)
            self.performSegue(type: .unwindToInitial, sender: self)
        }
    }
    
    func applicationInput(cell: ApplicationInputCell, addActionsFor model: ApplicationCellModel) {
        guard let model = model as? ApplicationInputCellModel else { return }
        guard let cellTextField = cell.inputTextField else { return }
        
        cell.onUserInput = { [weak self] text in
            self?.userData.update(with: text, model: model)
        }
        cell.onBeginEditing = { [weak self] cell in
            guard let self = self else { return }
            
            let fetcher: SuggestionsFetcher?
            switch model.type {
            case .city:
                fetcher = CitiesFetcher()
            case .item:
                fetcher = CarsFetcher()
            default:
                fetcher = nil
            }
            if let fetcher = fetcher {
            let vc = service.router.showSuggestions(in: self,
                                                      delegate: cell,
                                                      dataSource: fetcher,
                                                      text: cell.inputTextField.text)
            vc.textField.placeholder = cellTextField.placeholder
            }
        }
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 willDisplaySupplementaryView view: UICollectionReusableView,
                                 forElementKind elementKind: String,
                                 at indexPath: IndexPath) {
        guard let applicationView = view as? ApplicationCell else {
            fatalError("Wrong header")
        }

        applicationView.setup(with: headerModel, userData: userData)
    }

}

extension ApplicationVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let model = models[indexPath.row]
        return ApplicationCellSizer(size: collectionView.bounds.size, offset: 16).cellSize(model: model)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return ApplicationCellSizer(size: collectionView.bounds.size, offset: 16).headerSize
    }
}
