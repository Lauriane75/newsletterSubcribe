//
//  AuthManager.swift
//  newsletterSubscribe
//
//  Created by Lau on 27/04/2021.
//

import FirebaseFirestore
import Firebase

final class DataBaseManager {
    
    private let dataBase = Firestore.firestore()
    
    func saveUser(email: String, completion: @escaping((_ error: Error?) -> Void)) {
        dataBase.collection("users").addDocument(data: [
            "email": email,
        ]) { (Error) in
            completion(Error)
        }
    }
}
