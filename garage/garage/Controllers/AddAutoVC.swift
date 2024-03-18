//
//  AddAutoVC.swift
//  garage
//
//  Created by Apple on 29.01.24.
//

import Foundation
import Firebase
import FirebaseDatabase

protocol AddAutoVCDelegate: AnyObject {
    func addAuto(_ model: AutoModel)
    func deleteAuto(_ autoId: String)
    func updateAuto(_ model: AutoModel)
}

class AddAutoVC: UIViewController {
   
    // MARK: -Properties
    private let service: AutoService = AutoServiceImpl.shader
    private var user: User!
    weak var delegate: AddAutoVCDelegate?

    var currentAuto: AutoModel?

    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var modelTF: UITextField!
    @IBOutlet weak var mileageTF: UITextField!
    @IBOutlet weak var numberTF: UITextField!
    @IBOutlet weak var vinTF: UITextField!
    @IBOutlet weak var motorTypeTF: UITextField!
    @IBOutlet weak var motorVolumeTF: UITextField!
    @IBOutlet weak var yearOfProductionTF: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        title = "Добавить авто"
        checkAuto()
        setModel()
    }
    
    // MARK: - Actionы
    
    @IBAction func button(_ sender: UIButton) {
        
        if var currentAuto = currentAuto {
            currentAuto.name = nameTF.text ?? ""
            currentAuto.model = modelTF.text ?? ""
            currentAuto.mileage = Int(mileageTF.text ?? "") ?? 0
            currentAuto.number = numberTF.text ?? ""
            currentAuto.vin = vinTF.text ?? ""
            currentAuto.motorType = motorTypeTF.text ?? ""
            currentAuto.motorVolume = Double(motorVolumeTF.text ?? "") ?? 0
            currentAuto.yearOfProduction = Int(yearOfProductionTF.text ?? "") ?? 0
//            
            updateAuto(currentAuto)
            
        } else {
            
            let model = AutoModel(name: nameTF.text ?? "", model: modelTF.text ?? "", number: numberTF.text ?? "", vin: vinTF.text ?? "", motorVolume: Double(motorVolumeTF.text ?? "") ?? 0, motorType: motorTypeTF.text ?? "", mileage: Int(mileageTF.text ?? "") ?? 0, yearOfProduction: Int(yearOfProductionTF.text ?? "") ?? 0, services: [])
//            
            addAuto(model: model)
        }
        
       
    }
    
    @IBAction func deleteButton(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: "Удалить авто?", preferredStyle: .alert)
        ///action 1
        let delete = UIAlertAction(title: "Удалить", style: .default) { [weak self] _ in
            
            if let currentAuto = self?.currentAuto {
                self?.deleteAuto(autoId: currentAuto.id)
            } else { return }
            
            self?.navigationController?.popViewController(animated: true)
        }
        ///action 2
        let cancel = UIAlertAction(title: "Отмена", style: .default) { [weak self] _ in
        }
        alertController.addAction(delete)
        alertController.addAction(cancel)
        present(alertController, animated: true)
    }
    
    
     // MARK: - Private functions
    private func applyTheme() {
        self.view.backgroundColor = Theme.currentTheme.backgroundColor
        saveBtn.tintColor = Theme.currentTheme.buttonColor
        deleteBtn.tintColor = Theme.currentTheme.buttonColor
    }
    
    ///изменение вида экрана в замисимости от наличия данных
    func checkAuto() {
        if let currentAuto = currentAuto {
            saveBtn.setTitle("Изменить", for: .normal)
            deleteBtn.isHidden = false
        }
    }
    ///заполнение  экрана данными выбранного авто для последующего изменения
    func setModel() {
        guard let currentAuto = currentAuto else { return }
        nameTF.text = currentAuto.name
        modelTF.text = currentAuto.model
        mileageTF.text = String(currentAuto.mileage ?? 0)
        numberTF.text = currentAuto.number
        vinTF.text = currentAuto.vin
        motorTypeTF.text = currentAuto.motorType
        motorVolumeTF.text = String(currentAuto.motorVolume ?? 0)
        yearOfProductionTF.text = String(currentAuto.yearOfProduction ?? 0)
    }
    ///добавление нового  авто
    func addAuto(model: AutoModel) {
        guard let autoName = nameTF.text,
              let autoModel = modelTF.text,
              let mileage = Int(mileageTF.text ?? "0"),
              let number = numberTF.text,
              let vin = vinTF.text,
              let motorType = motorTypeTF.text,
              let motorVolume =  Double(motorVolumeTF.text ?? "ytyt"),
              let yearOfProduction = Int(yearOfProductionTF.text ?? "ytyt")
        else { return }
        ///создаем авто
        let newAuto = AutoModel(
            name: autoName,
            model: autoModel,
            number: number,
            vin: vin,
            motorVolume: motorVolume,
            motorType: motorType,
            mileage: mileage,
            yearOfProduction: yearOfProduction,
            services: []
        )
        ///отправляем в БД
        service.registerAuto(newAuto) { [weak self] result in
            switch result {
            case .success(let auto):
                self?.delegate?.addAuto(auto)
                self?.navigationController?.popViewController(animated: true)
            case .failure:
                print("auto not added")
            }
        }
    }
    ///метод  по  удалению  авто
    func deleteAuto(autoId: String) {
        service.deleteAuto(currentAuto?.id ?? "", callback: { [weak self] result in
            switch result {
            case .success():
                self?.delegate?.deleteAuto(autoId)
                self?.navigationController?.popViewController(animated: true)
            case .failure:
                print("service not deleted")
            }
        })
    }
    ///метод  изменения  авто
    func updateAuto(_ model: AutoModel) {
        service.chengeAuto(currentAuto?.id ?? "", model, callback: { [weak self] result in
            switch result {
            case .success():
                self?.delegate?.updateAuto(model)
                self?.navigationController?.popViewController(animated: true)
            case .failure:
                print("auto not update")
            }
        })
    }
}


                        
