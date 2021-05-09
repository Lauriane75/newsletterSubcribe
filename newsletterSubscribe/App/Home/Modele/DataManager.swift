//
//  DataManager.swift
//  newsletterSubscribe
//
//  Created by Lau on 07/05/2021.
//

import Foundation

class DataManager {
    
    private var homeData: [HomeData] = []
    static let shared = DataManager()
    
    private init() {
        updateData()
    }

    func getData() -> [HomeData] {
        
        return homeData
    }
    
    private func updateData() {
        homeData = [HomeData(emailTextField: "Adresse email", nameTextField: "Prénom", subscribeButton: "Je m'inscris", errorLabelEmptyField: "Remplissez votre Prénom et email pour vous inscrire", errorLabelWrongEmail: "Oups une erreur en tappant votre email ?\nEssayez encore !", errorConnection: "Pas de connexion internet.\nVeuillez recommencer"
                             , bottomLabel: "Pour plus de promo : \n Inscrivez-vous sur notre site en bas de page", logoText: "logo-rdt", backButton: "Retour", subscriptionValidatedLabel: "Inscription validée !\nRendez-vous dans votre boite mail. Veuillez présenter votre coupon de remise en caisse", urlWebsite: URL(string: "https://larouteduthe.com/fr/")!, objectEmail: "Inscription Newsletter", bodyEmail: "Vous êtes inscrits à notre newsletter. Veuillez valider puis donner votre code de réduction  en caisse. Code : ", webViewLabel: "Descendez en bas de page\n vous inscrire et obtenir votre remise en ligne")]
    }
}




