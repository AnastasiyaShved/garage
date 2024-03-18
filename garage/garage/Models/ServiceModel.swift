//
//  ServiceModel.swift
//  garage
//
//  Created by Apple on 5.01.24.
//

import Foundation
import Firebase
import FirebaseDatabase

struct ServiceModel {
//    var taskName: String
    var id: String
    var taskDescription: String
    var mileage: Int?
    var dedline: Date?
    var isCompleted: Bool
    var dateCreatedService: Date
    var mileageCreatedService: Int
    
    init(id: String = UUID().uuidString,
         taskDescription: String,
         mileage: Int? = nil,
         dedline: Date? = nil,
         isCompleted: Bool,
         dateCreatedService: Date,
         mileageCreatedService: Int
    ) {
        self.id = id
        self.taskDescription = taskDescription
        self.mileage = mileage
        self.dedline = dedline
        self.isCompleted = isCompleted
        self.dateCreatedService = dateCreatedService
        self.mileageCreatedService = mileageCreatedService
        
    }
    
    /// для получения данных из FB и дальнейшего создания из  низ объекта
//    init?(snapshot: DataSnapshot) {
//        guard let snapshotValue = snapshot.value as? [String: Any],
//              let taskDescription = snapshotValue[Constants.taskDescriptionKey] as? String,
//              let mileage = snapshotValue[Constants.mileageKey] as? Int,
//              let dedline = snapshotValue[Constants.dedlineKey] as? Date,
//              let isCompleted = snapshotValue[Constants.isCompletedKey] as? Bool,
//              let dateCreatedService = snapshotValue[Constants.dateCreatedServiceKey] as? Date,
//              let mileageCreatedService = snapshotValue[Constants.mileageCreatedServiceKey] as? Int
//            else { return nil }
//        self.id = snapshot.key
//        self.taskDescription = taskDescription
//        self.mileage = mileage
//        self.dedline = dedline
//        self.isCompleted = isCompleted
//        self.dateCreatedService = dateCreatedService
//        self.mileageCreatedService = mileageCreatedService
//    }
    
    func convertToDictionary() -> [String: Any?] {
        return [
            Constants.dedlineKey: dedline?.toString() ?? nil,
            Constants.mileageKey: mileage ?? nil,
            Constants.taskDescriptionKey: taskDescription,
            Constants.isCompletedKey: isCompleted,
            Constants.dateCreatedServiceKey: dateCreatedService.toString(),
            Constants.mileageCreatedServiceKey: mileageCreatedService
        ]
    }
    
     enum Constants {
        static let taskDescriptionKey = "taskDescription"
        static let mileageKey = "mileage"
        static let dedlineKey = "dedline"
        static let isCompletedKey = "isCompleted"
        static let dateCreatedServiceKey = "dateCreatedService"
        static let mileageCreatedServiceKey = "mileageCreatedService"
    }
}
