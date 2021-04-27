//
//  HomeViewModel.swift
//  newsletterSubscribe
//
//  Created by Lau on 26/04/2021.
//

import Foundation

class HomeViewModel {
    
    // MARK: - Properties

    static let shared = HomeViewModel()
    
    // MARK: - Output
    
    var isHidden: ((Bool) -> Void)?
    var canSendEmail: ((Bool) -> Void)?
    
    // MARK: - Input
    
    func viewDidLoad() {
        isHidden?(true)
    }
    
    func viewWillAppear() {
    }
    
    func didPressSubscribeButton(email: String) {
        if validateEmail(enterEmail: email) {
            canSendEmail?(true)
        } else {
            isHidden?(false)
        }
    }
    
    func setBodyMessage() -> String {
        let number = Int.random(in: 100000..<10000000)
        return  "Vous êtes inscrits à notre newsletter. Veuillez valider puis donner votre code de réduction  en caisse. Code : \(number)"
    }
    
    func setURL() -> URL {
        return URL(string: "https://larouteduthe.com/fr/")!
    }
    
    private func validateEmail(enterEmail:String) -> Bool{
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@",emailFormat)
        return emailPredicate.evaluate(with:enterEmail)
    }
    

    
}
