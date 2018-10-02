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
    var headers: [ApplicationCellModel] = []
    
    var userData: UserApplicationData!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let builder = ApplicationCellModelBuilder()
        models = builder.carGroupModels()
        headers = builder.carGroupHeaderModels()
        
        let view = ApplicationBackgroundView(frame: self.view.bounds)
        collectionView?.backgroundView = view
        
        setupUserData(teamID: 2028, inviteCode: "XYZ")
        assert(userData != nil)
    }
    
    func setupUserData(teamID: Int, inviteCode: String?) {
        userData = UserApplicationData(teamID: teamID,
                                       inviteCode: inviteCode,
                                       name: nil,
                                       area: nil,
                                       emailString: nil,
                                       model: nil)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return headers.count
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
        let model = headers[indexPath.section]
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                   withReuseIdentifier: model.identifier.rawValue,
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
        }
    }
    
    func applicationInput(cell: ApplicationInputCell, addActionsFor model: ApplicationCellModel) {
        guard let model = model as? ApplicationInputCellModel else { return }
        guard let cellTextField = cell.inputTextField else { return }
        
        let result: (Result<[String]>) -> Void = { result in
            switch result {
            case let .value(value):
                cellTextField.suggestions = value
            case let .error(error):
                print(error)
            }
        }
        
        cell.onUserInput = { [weak self] text in
            self?.userData.update(with: text, model: model)
        }
        
        switch model.type {
        case .item:
            cell.inputTextField.isAutocompleteEnabled = true
            cell.onTextChange = { textField in
               service.dao.getCars(string: textField.text).observe(with: result)
            }
        case .city:
            cell.inputTextField.isAutocompleteEnabled = true
            cell.onTextChange = { textField in
                service.dao.getCities(string: textField.text).observe(with: result)
            }
        default:
            break
        }
    }
        
        override func collectionView(_ collectionView: UICollectionView,
                                     willDisplaySupplementaryView view: UICollectionReusableView,
                                     forElementKind elementKind: String,
                                     at indexPath: IndexPath) {
            guard let applicationView = view as? ApplicationCell else {
                fatalError("Wrong header")
            }
            
            let model = headers[indexPath.section]
            applicationView.setup(with: model, userData: userData)
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
