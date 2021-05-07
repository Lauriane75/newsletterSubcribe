//
//  HomeViewModel.swift
//  newsletterSubscribe
//
//  Created by Lau on 26/04/2021.
//

import Foundation
import FirebaseFirestore

class HomeViewModel {
    
    // MARK: - Properties
    
    static let shared = HomeViewModel()
    
    // MARK: - Output
    
    var errorViewIsHidden: ((Bool) -> Void)?
    var validatedViewIsHidden: ((Bool) -> Void)?
    var canSendEmail: ((Bool) -> Void)?
    var errorText: ((String) -> Void)?
    
    // MARK: - Input
    
    func viewDidLoad() {
        errorViewIsHidden?(true)
        validatedViewIsHidden?(true)
    }
    
    func viewWillAppear() {
    }
    
    func didPressSubscribeButton(name: String?, email: String?) {
        let dataBase = Firestore.firestore()
        guard name != "" && email != "" else {
            errorText?("Remplissez votre Prénom et email pour vous inscrire")
            errorViewIsHidden?(false)
            return
        }
        if validateEmail(enterEmail: email!) {
            canSendEmail?(true)
            dataBase.collection("users").addDocument(data: ["email": email!, "name": name!]) { (error) in
                guard error != nil else {
                    self.errorText?("Pas de connexion internet.\nVeuillez recommencer")
                    return
                }
            }
        } else {
            self.errorText?("Oups une erreur en tappant votre email ?\nEssayez encore !")
            self.errorViewIsHidden?(false)
        }
    }
    
    func setBodyMessage() -> String {
        let number = Int.random(in: 100000..<10000000)
        return  "Vous êtes inscrits à notre newsletter. Veuillez valider puis donner votre code de réduction  en caisse. Code : \(number)"
    }
    
    func setURL() -> URL {
        return URL(string: "https://larouteduthe.com/fr/")!
    }
    
    private func validateEmail(enterEmail:String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@",emailFormat)
        return emailPredicate.evaluate(with:enterEmail)
    }
    
    
    
}
