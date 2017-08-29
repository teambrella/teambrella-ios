//
//  SortCellDataSource.swift
//  Teambrella
//
//  Created by Екатерина Рыжова on 05.07.17.

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

import Foundation

struct SortDataSource {
    var count: Int { return models.count }
    var models: [SortCellModel] = []

    mutating func createFakeModels() {
        models = [SortCellModel(topText: "Proxy.SortVC.Cell.Rating".localized,
                                bottomText: "Proxy.SortVC.Cell.Rating.HighLow".localized),
                  SortCellModel(topText: "Proxy.SortVC.Cell.Rating".localized,
                                bottomText: "Proxy.SortVC.Cell.Rating.LowHigh".localized),
                  SortCellModel(topText: "Proxy.SortVC.Cell.Alphabetical".localized,
                                bottomText: "Proxy.SortVC.Cell.Alphabetical.AZ".localized),
                  SortCellModel(topText: "Proxy.SortVC.Cell.Alphabetical".localized,
                                bottomText: "Proxy.SortVC.Cell.Alphabetical.ZA".localized)]
    }
    
    subscript(indexPath: IndexPath) -> SortCellModel {
        return models[indexPath.row]
    }
    
}
