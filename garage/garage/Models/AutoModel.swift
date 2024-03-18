//
//  File.swift
//  garage
//
//  Created by Apple on 3.01.24.
//

import UIKit
import Firebase
import FirebaseDatabase

struct AutoModel {
    var id: String
    var name: String = "" //сделать из перечисления
    var model: String
    var number: String
    var vin: String
    var motorVolume: Double //ограничить знаками после запятой
    var motorType: String //сделать из перечисления
    var mileage: Int
    var yearOfProduction: Int //сделать из перечисления
    var services: [ServiceModel] = []
    
    init(
        id: String = UUID().uuidString,
        name: String,
        model: String,
        number: String,
        vin: String,
        motorVolume: Double,
        motorType: String,
        mileage: Int,
        yearOfProduction: Int,
        services: [ServiceModel]
    ) {
        self.id = id
        self.name = name
        self.model = model
        self.number = number
        self.vin = vin
        self.motorVolume = motorVolume
        self.motorType = motorType
        self.mileage = mileage
        self.yearOfProduction = yearOfProduction
        self.services = services
    }
    
    /// для получения данных из FB и дальнейшего создания из  низ объекта
    init?(snapshot: DataSnapshot) {
        
        guard let snapshotValue = snapshot.value as? [String: Any],
              let name = snapshotValue[Constants.nameKey] as? String,
              let model = snapshotValue[Constants.modelKey] as? String,
              let number = snapshotValue[Constants.numberKey] as? String,
              let vin = snapshotValue[Constants.vinKey] as? String,
              let motorVolume = snapshotValue[Constants.motorVolumeKey] as? Double,
              let motorType = snapshotValue[Constants.motorTypeKey] as? String,
              let mileage = snapshotValue[Constants.mileageKey] as? Int,
              let yearOfProduction = snapshotValue[Constants.yearOfProductionKey] as? Int
            else {
            return nil }
        
        self.id = snapshot.key
        self.name = name
        self.model = model
        self.number = number
        self.vin = vin
        self.motorVolume = motorVolume
        self.motorType = motorType
        self.mileage = mileage
        self.yearOfProduction = yearOfProduction
        
        if let services = snapshotValue[Constants.servicesKey] as? [String: Any?] {
            var serv: [ServiceModel] = []
            
            services.forEach { (key, value) in
                guard let value = value as? [String: Any] else { return }
                guard let taskDescription = value[ServiceModel.Constants.taskDescriptionKey] as? String else { return }
                guard let isCompleted = value[ServiceModel.Constants.isCompletedKey] as? Bool else { return }
                guard let dateCreatedServiceString = value[ServiceModel.Constants.dateCreatedServiceKey] as? String,
                        let dateCreated = dateCreatedServiceString.toDate() else { return }
                guard let mileageCreatedService = value[ServiceModel.Constants.mileageCreatedServiceKey] as? Int else { return }
                
                var date: Date?
                
                if let value = value[ServiceModel.Constants.dedlineKey] as? String {
                    date = value.toDate()
                }
                
                serv.append(ServiceModel(
                    id: key,
                    taskDescription: taskDescription,
                    mileage: value[ServiceModel.Constants.mileageKey] as? Int,
                    dedline: date,
                    isCompleted: isCompleted,
                    dateCreatedService: dateCreated,
                    mileageCreatedService: mileageCreatedService
                ))
            }
            self.services = serv
        }
    }
    
    func convertToDictionary() -> [String: Any] {
        
        var servicesDic: [String: Any?] = [:]
        
        services.forEach({ value in
            servicesDic[value.id] = value.convertToDictionary()
        })
        
        return [Constants.nameKey: name,
         Constants.modelKey: model,
         Constants.numberKey: number,
         Constants.vinKey: vin,
         Constants.motorVolumeKey: motorVolume,
         Constants.motorTypeKey: motorType,
         Constants.mileageKey: mileage,
         Constants.yearOfProductionKey: yearOfProduction,
         Constants.servicesKey: servicesDic] as [String : Any]
    }
    
    private enum Constants {
        static let nameKey = "name"
        static let modelKey = "model"
        static let numberKey = "number"
        static let vinKey = "vin"
        static let motorVolumeKey = "motorVolume"
        static let motorTypeKey = "motorType"
        static let mileageKey = "mileage"
        static let yearOfProductionKey = "yearOfProduction"
        static let servicesKey = "services"
    }
    
    enum Variation {
       static let km = "км"
       static let miles = "мили"
   }
}


//настроиваем растояние по краям collectionView
struct Constans {
    static let leftDistanceToView: CGFloat = 16
    static let rightDistanceToView: CGFloat = 16
    static let galleryMinimumLineSpace: CGFloat = 3
    static let heightGalleryCollectionView: CGFloat = 120
    static let shadowRadius: CGFloat = 5
    static let topAnchorForView: CGFloat = 8
    // дополнить размером BarButtonItem
    //заменить на данные величины размеры отступов на главном экране
    static let heightServiceCollectionView = {UIScreen.main.bounds.height - Constans.shadowRadius * 2 - Constans.topAnchorForView * 2 - 360}
}

