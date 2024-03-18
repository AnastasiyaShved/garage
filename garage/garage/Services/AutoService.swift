//
//  AutoService.swift
//  garage
//
//  Created by Apple on 2.02.24.
//

import Foundation
import Firebase
import FirebaseAuth

protocol AutoService: AnyObject {
    func fetchAutos(callback: @escaping (Result<[AutoModel], AutoServiceError>) -> Void)
    func registerAuto(_ model: AutoModel, callback: @escaping (Result<AutoModel, AutoServiceError>) -> Void)
    func deleteAuto(_ autoId: String, callback: @escaping (Result<Void, AutoServiceError>) -> Void)
    func chengeAuto(_ autoId: String, _ model: AutoModel, callback: @escaping (Result<Void, AutoServiceError>) -> Void)
    
    
    func registerTO(_ autoId: String, _ model: ServiceModel, callback: @escaping (Result<ServiceModel, AutoServiceError>) -> Void)
    func chengeService(_ autoId: String, _ model: ServiceModel, callback: @escaping (Result<Void, AutoServiceError>) -> Void)
    func deleteService(_ autoId: String, _ model: ServiceModel, callback: @escaping (Result<Void, AutoServiceError>) -> Void)
    
}

class AutoServiceImpl: AutoService {
  
    static let shader: AutoServiceImpl = AutoServiceImpl()
    
    private init() {}
    
    func fetchAutos(callback: @escaping (Result<[AutoModel], AutoServiceError>) -> Void) {
        
        guard let user = Auth.auth().currentUser else { return }
        
        Database.database().reference(withPath: "users").child(user.uid).child("autos").getData { error, snapshot in
            if let error = error {
                callback(.failure(.serverError))
            } else {
                var autos: [AutoModel] = []
                
                guard let snapshot = snapshot else {
                    callback(.failure(.serverError))
                    return
                }
                
                for item in snapshot.children {
                    guard let snapshot = item as? DataSnapshot,
                          let newAuto = AutoModel(snapshot: snapshot) else {
                        callback(.failure(.serverError))
                        callback(.failure(.serverError))
                        return  }
                    autos.append(newAuto)
                }
                callback(.success(autos))
            }
        }
    }
    
    func registerAuto(_ model: AutoModel, callback: @escaping (Result<AutoModel, AutoServiceError>) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        let autosReference = Database.database().reference(withPath: "users").child(user.uid).child("autos")
        //создаем ссылку на авто
        let autoRef = autosReference.child(model.id)
        //отправляем на сервер
        autoRef.setValue(model.convertToDictionary()) { (error, ref) in
            if let _ = error {
                callback(.failure(.errorAddAuto))
            } else {
                callback(.success(model))
            }
        }
    }
    
    func chengeAuto(_ autoId: String, _ model: AutoModel, callback: @escaping (Result<Void, AutoServiceError>) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        let autoReference = Database.database().reference(withPath: "users").child(user.uid).child("autos")
        
        var servicesDic: [String : Any] = [:]
        
        model.services.forEach({ item in
            servicesDic[item.id] = item.convertToDictionary()
        })
        
        
        let dic: [AnyHashable: Any] = ["name" : model.name,
                                       "model" : model.model,
                                       "number" : model.number,
                                       "vin" : model.vin,
                                       "motorVolume" : model.motorVolume,
                                       "motorType" : model.motorType,
                                       "mileage" : model.mileage,
                                       "yearOfProduction" : model.yearOfProduction,
                                       "services": servicesDic
        ]
    
        autoReference.updateChildValues([autoId: dic], withCompletionBlock: {(error, ref) in
            if let _ = error {
                callback(.failure(.errorAddAuto))
            } else {
                callback(.success(()))
            }
        })
    }
    
    func deleteAuto(_ autoId: String, callback: @escaping (Result<Void, AutoServiceError>) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        let autosReference = Database.database().reference(withPath: "users").child(user.uid).child("autos")
    
        autosReference.updateChildValues([autoId: nil], withCompletionBlock: {(error, ref) in
            if let _ = error {
                callback(.failure(.errorAddAuto))
            } else {
                callback(.success(()))
            }
        })
    }
    
    func registerTO(_ autoId: String, _ model: ServiceModel,  callback: @escaping (Result<ServiceModel, AutoServiceError>) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        let autosReference = Database.database().reference(withPath: "users").child(user.uid).child("autos").child(autoId).child("services")
        
        let serviceRef = autosReference.child(model.id)
        //отправляем на сервер
        serviceRef.setValue(model.convertToDictionary()) { (error, ref) in
            if let _ = error {
                callback(.failure(.errorAddAuto))
            } else {
                callback(.success(model))
            }
        }
    }
    
    func chengeService(_ autoId: String, _ model: ServiceModel, callback: @escaping (Result<Void, AutoServiceError>) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        let autosReference = Database.database().reference(withPath: "users").child(user.uid).child("autos").child(autoId).child("services")
        
        let serviceRef = autosReference.child(model.id)
        
        var dic: [AnyHashable: Any] = ["taskDescription" : model.taskDescription, "isCompleted" : model.isCompleted]
        
        if let mileage = model.mileage {
            dic["mileage"] = mileage
        }
        
        if let date = model.dedline?.toString() {
            dic["dedline"] = date
        }
        serviceRef.updateChildValues(dic) { (error, ref) in
            if let _ = error {
                callback(.failure(.errorAddAuto))
            } else {
                callback(.success(()))
            }
        }
    }
    
    func deleteService(_ autoId: String, _ model: ServiceModel, callback: @escaping (Result<Void, AutoServiceError>) -> Void) {
        guard let user = Auth.auth().currentUser else { return }
        let autosReference = Database.database().reference(withPath: "users").child(user.uid).child("autos").child(autoId).child("services")
        
        let serviceRef = autosReference.child(model.id)
        //отправляем на сервер
        serviceRef.removeValue { ( error, ref ) in
            if let _ = error {
                callback(.failure(.serverError))
            } else {
                callback(.success(()))
            }
        }
    }
    
    
}

enum AutoServiceError: Error {
    case serverError
    case errorAddAuto
    
    var title: String {
        switch self {
        case .serverError:
            return "Ошибка сервера"
        case .errorAddAuto:
            return "Ошибка регистрации авто"
        }
    }
}
