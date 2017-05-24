//
//  LoginDetailsPresenter.swift
//  Teambrella
//
//  Created by Yaroslav Pasternak on 24.05.17.
//  Copyright © 2017 Yaroslav Pasternak. All rights reserved.
//

import Foundation

protocol LoginDetailsView: class {
    func register(enable: Bool)
    func greeting(text: String)
    func changeDate(to date: Date)
    func changeGender(to gender: Gender)
    
    var code: String? { get }
    var gender: Gender { get }
    var date: Date { get }
    
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
    }
    
    func tapRegister() {
        guard let view = view else { return }
        
        print ("Registered with code \(view.code ?? ""), birthDate: \(view.date), gender: \(view.gender)")
        router.validate()
    }
    
    func codeTextChanged(text: String) {
        view?.register(enable: text.characters.count > 2)
    }
    
    func codeTextChanged(text: String?) {
        guard let text = text else {
            view?.register(enable: false)
            return
        }
        
        view?.register(enable: text.characters.count > 2)
    }
    
}
