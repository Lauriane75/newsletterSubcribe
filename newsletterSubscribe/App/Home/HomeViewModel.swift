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
    
    var dataManager = DataManager.shared
    
    private var homeDataItems: [HomeDataItem] = [] {
        didSet {
            DispatchQueue.main.async {
                self.visibleItems?(self.homeDataItems)
            }
        }
    }
        
    // MARK: - Output
    
    var errorViewIsHidden: ((Bool) -> Void)?
    var validatedViewIsHidden: ((Bool) -> Void)?
    var canSendEmail: ((Bool) -> Void)?
    var errorText: ((String) -> Void)?
    var visibleItems: (([HomeDataItem]) -> Void)?
    
    // MARK: - Input
    
    func viewWillAppear() {
        setUpHomeDataItems()
        errorViewIsHidden?(true)
        validatedViewIsHidden?(true)
    }
    
    func didPressSubscribeButton(name: String?, email: String?) {
        guard let data = homeDataItems.first else { return }
        let dataBase = Firestore.firestore()
        guard name != "" && email != "" else {
            errorText?(data.errorLabelEmptyField)
            errorViewIsHidden?(false)
            return
        }
        if validateEmail(enterEmail: email!) {
            canSendEmail?(true)
            dataBase.collection("users").addDocument(data: ["email": email!, "name": name!]) { (error) in
                guard error != nil else {
                    self.errorText?(data.errorConnection)
                    return
                }
            }
        } else {
            self.errorText?(data.errorLabelWrongEmail)
            self.errorViewIsHidden?(false)
        }
    }
    
    func setEmailData() -> [String: String]  {
        let number = Int.random(in: 100000..<10000000)
        let objectEmail = homeDataItems.first?.objectEmail
        let bodyEmail = homeDataItems.first?.bodyEmail
        return ["\(bodyEmail ?? "") \(number)" : "\(objectEmail ?? "")"]
    }
    
    func setURL() -> URL {
        return homeDataItems.first!.urlWebsite
    }
    
    // MARK: - Private Files
    
    private func validateEmail(enterEmail:String) -> Bool {
        let emailFormat = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@",emailFormat)
        return emailPredicate.evaluate(with:enterEmail)
    }

    fileprivate func setUpHomeDataItems() {
        let getData = dataManager.getData()
        guard let data = getData.first else { return }
        let homeDataItem = HomeDataItem(emailTextField: data.emailTextField, nameTextField: data.nameTextField, subscribeButton: data.subscribeButton, errorLabelEmptyField: data.errorLabelEmptyField, errorLabelWrongEmail: data.errorLabelWrongEmail, errorConnection: data.errorConnection, bottomLabel: data.bottomLabel, logoText: data.logoText, backButton: data.backButton, subscriptionValidatedLabel: data.subscriptionValidatedLabel, urlWebsite: data.urlWebsite, objectEmail: data.objectEmail, bodyEmail: data.bodyEmail, webViewLabel: data.webViewLabel)
        homeDataItems = [homeDataItem]
    }
    
}
