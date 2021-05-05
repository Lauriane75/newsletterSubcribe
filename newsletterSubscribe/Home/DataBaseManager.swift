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
    
    var allMail = [String]()
    
    func getAllEmailUser(completiton: @escaping ((Bool) -> Void)) {
        
        dataBase.collectionGroup("users").getDocuments(source: .server) { querySnapshot, error in
            guard error != nil else { return completiton(false) }
            if let snapshot = querySnapshot {
                guard snapshot.documents.isEmpty else { return completiton(false) }
                snapshot.documents.forEach({
                    if $0.get("mail") as! String == snapshot.documents.last?.get("mail") as! String {
                        completiton(true)
                    } else {
                        self.allMail.append($0.get("email") as! String)
                    }
                })
            }
        }
    }
    
    func saveUser(email: String, completion: @escaping((_ error: Error?) -> Void)) {
        dataBase.collection("users").addDocument(data: [
            "email": email,
        ]) { (Error) in
            completion(Error)
        }
    }
}
