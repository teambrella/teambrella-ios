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

private let reuseIdentifier = "title cell"

class ApplicationVC: UICollectionViewController, Routable {
    static let storyboardName = "Login"
    
    var type: ApplicationScreenType = .intro
    var router: ApplicationRouter?
    
    var models: [ApplicationCellModel] = []
    var headers: [ApplicationCellModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let builder = ApplicationCellModelBuilder()
        models = builder.carGroupModels()
        headers = builder.carGroupHeaderModels()
        
        let view = HomeBackgroundView(frame: self.view.bounds)
        view.backgroundColor = .white
        collectionView?.backgroundView = view
        
        service.dao.getCars(string: "q").observe { result in
            switch result {
            case let .value(cars):
                print("Cars: \(cars)")
            case let .error(error):
                print("Error: \(error)")
            }
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using [segue destinationViewController].
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return headers.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
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
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 willDisplay cell: UICollectionViewCell,
                                 forItemAt indexPath: IndexPath) {
        guard let applicationCell = cell as? ApplicationCell else {
            fatalError("Wrong cell type: \(cell)")
        }
        
        let model = models[indexPath.row]
        applicationCell.setup(with: model)
        (applicationCell as? ApplicationCellDecorable)?.decorate()
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 willDisplaySupplementaryView view: UICollectionReusableView,
                                 forElementKind elementKind: String,
                                 at indexPath: IndexPath) {
        guard let applicationView = view as? ApplicationCell else {
            fatalError("Wrong header")
        }
        
        let model = headers[indexPath.section]
        applicationView.setup(with: model)
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
