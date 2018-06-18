//
//  LoginDetailsPresenter.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 24.05.17.

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

protocol LoginDetailsView: class {
    var code: String? { get }
    var gender: Gender { get }
    var date: Date { get }
    
    func register(enable: Bool)
    func greeting(text: String)
    func changeDate(to date: Date)
    func changeGender(to gender: Gender)
    func showAvatar(url: URL)
}

protocol LoginDetailsPresenter {
    var router: LoginDetailsRouter { get set }
    
    func viewDidLoad()
    func tapRegister()
    func codeTextChanged(text: String?)
}

class LoginDetailsPresenterImpl: LoginDetailsPresenter {
    let user: FacebookUser
    weak var view: LoginDetailsView?
    var router: LoginDetailsRouter
    
    init (user: FacebookUser, router: LoginDetailsRouter) {
        self.user = user
        self.router = router
    }
    
    func viewDidLoad() {
        guard let view = view else { return }
        
        view.register(enable: false)
        view.greeting(text: "Hello, \(user.name)")
        
        var dateComponents = DateComponents()
        dateComponents.year = -user.minAge
        let defaultDate = Calendar.current.date(byAdding: dateComponents, to: Date()) ?? Date()
        view.changeDate(to: defaultDate)
        view.changeGender(to: user.gender)
        
        if let avatar = user.picture, let url = URL(string: avatar) {
            view.showAvatar(url: url)
        }
    }
    
    func tapRegister() {
        guard let view = view else { return }
        
        print ("Registered with code \(view.code ?? ""), birthDate: \(view.date), gender: \(view.gender)")
        router.validate()
    }
    
    func codeTextChanged(text: String) {
        view?.register(enable: text.count > 2)
    }
    
    func codeTextChanged(text: String?) {
        guard let text = text else {
            view?.register(enable: false)
            return
        }
        
        view?.register(enable: text.count > 2)
    }
    
}
