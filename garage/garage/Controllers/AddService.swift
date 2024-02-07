//
//  AddService.swift
//  garage
//
//  Created by Apple on 30.01.24.
//

import Foundation
import Firebase
import FirebaseDatabase

protocol AddServiceDelagate: AnyObject {
    //ссыдки на методы обновления инфы а массиве и коллекции
    func addTO(_ model: ServiceModel)
    func update(_ model: ServiceModel, for index: Int)
    func deleteTO(index: Int)
    
}

class AddService: UIViewController {
    
    // MARK: - Properties
    weak var delegate: AddServiceDelagate?
    var currentAuto: AutoModel!
    var selectedIndex: Int?
    
    let notifications = Notifications()
    
    let datePicker = UIDatePicker()
    
    @IBOutlet weak var segmentStack: UIStackView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    
    private var currentService: ServiceModel? {
        didSet {
            descriptionTF.text = currentService?.taskDescription
            
            segmentStack.isHidden = true
            
            if let dedline = currentService?.dedline?.toString() {
                serviceDedlineTF.text = dedline
                self.mileStack.isHidden = true
                self.dateStack.isHidden = false
            }
            
            if let milage = currentService?.mileage {
                self.dateStack.isHidden = true
                self.mileStack.isHidden = false
                serviceMileageTF.text = String(milage)
            }
            
            switcher.isOn = currentService?.isCompleted ?? false
        }
    }
    
    private let service: AutoService = AutoServiceImpl.shader
    
    @IBOutlet weak var workDescriptionLbl: UILabel!
    @IBOutlet weak var serviceDedlineLbl: UILabel!
    @IBOutlet weak var serviseMileageLbl: UILabel!
    
    @IBOutlet weak var descriptionTF: UITextField!
    @IBOutlet weak var serviceDedlineTF: UITextField!
    @IBOutlet weak var serviceMileageTF: UITextField!
    @IBOutlet weak var save: UIButton!
    
    @IBOutlet weak var switcherStack: UIStackView!
    @IBOutlet weak var switcher: UISwitch!
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var dateStack: UIStackView!
    @IBOutlet weak var mileStack: UIStackView!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        checkService()
        setUpDatePicker()
    
        applyTheme()
        title = "Добавить напоминание"
                
    }
    
    // MARK: - Actions
    @IBAction func button(_ sender: UIButton) {
        guard let description = descriptionTF.text
        else { return }
        
        if var currentService = currentService {
            currentService.taskDescription = descriptionTF?.text ?? ""
            
            currentService.dedline = serviceDedlineTF.text?.toDate()
            currentService.mileage = Int(serviceMileageTF.text ?? "")
            
            if currentService.isCompleted {
                currentService.dedline = Date()
            }
            
            updateService(model: currentService)
            
        } else {
            
            let dedline = segmentControl.selectedSegmentIndex == 0 ?  serviceDedlineTF.text?.toDate() : nil
            
            let mileage = segmentControl.selectedSegmentIndex == 1 ? Int(serviceMileageTF.text ?? "") :  nil
            
            let model = ServiceModel(taskDescription: description, mileage: mileage, dedline: dedline , isCompleted: false, dateCreatedService: Date(), mileageCreatedService: currentAuto.mileage)
            addService(model: model)
        }
    }
    
    
    @IBAction func deleteBtn(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: "Удалить напоминание?", preferredStyle: .alert)
        ///action 1
        let delete = UIAlertAction(title: "Удалить", style: .default) { [weak self] _ in
            
            if let currentService = self?.currentService {
                self?.deleteService(model: currentService)
            } else { return }
            
            self?.navigationController?.popViewController(animated: true)
        }
        ///action 2
        let cancel = UIAlertAction(title: "Отмена", style: .default) { _ in }
        alertController.addAction(delete)
        alertController.addAction(cancel)
        present(alertController, animated: true)
    }
    
    @IBAction func switcherAction(_ sender: Any) {
        currentService?.isCompleted.toggle()
    }
    
    @IBAction func segmentAction(_ sender: Any) {
        dateStack.isHidden.toggle()
        mileStack.isHidden.toggle()
    }
    
    
    // MARK: - Private functions
    
    //add new service
    func addService(model: ServiceModel) {
        service.registerTO(currentAuto.id, model, callback: { [weak self] result in
            switch result {
            case .success(let to):
                self?.delegate?.addTO(to)
                ///добаляем уведомление
                self?.notifications.scheduleNotification(serviceId: model.id, title: "Attention", message: model.taskDescription, triggerType: .time(15))
//                model.dedline ?? Date())
                self?.navigationController?.popViewController(animated: true)
            case .failure:
                print("auto not added")
            }
        })
    }
    
    //update service
    func updateService(model: ServiceModel) {
        service.chengeService(currentAuto.id, model, callback: { [weak self] result in
            switch result {
            case .success():
                self?.delegate?.update(model, for: self?.selectedIndex ?? 0)
                self?.notifications.scheduleNotification(serviceId: model.id, title: "Attention", message: model.taskDescription, triggerType: .time(15))
//                model.dedline ?? Date())
                
                self?.navigationController?.popViewController(animated: true)
            case .failure:
                print("service not update")
            }
        })
    }
    

    func deleteService(model: ServiceModel) {
        service.deleteService(currentAuto.id, model, callback: { [ weak self] result in
            switch result {
            case .success():
                self?.delegate?.deleteTO(index: self?.selectedIndex ?? 0)
                self?.navigationController?.popViewController(animated: true)
            case .failure:
                print("service not deleted")
            }
        })
    }
    
    private func applyTheme() {
        self.view.backgroundColor = Theme.currentTheme.backgroundColor
        workDescriptionLbl.textColor = Theme.currentTheme.textColor
        serviseMileageLbl.textColor = Theme.currentTheme.textColor
        serviceDedlineLbl.textColor = Theme.currentTheme.textColor
        save.tintColor = Theme.currentTheme.buttonColor
        deleteBtn.tintColor = Theme.currentTheme.buttonColor
    }
    ///изменение вида экрана в замисимости от наличия данных
    func checkService() {
        if let selectedIndex = selectedIndex {
            currentService = currentAuto.services[selectedIndex]
            save.setTitle("Изменить", for: .normal)
            deleteBtn.isHidden = false
            switcherStack.isHidden = false
        }
    }
}
// MARK: - создание и настройка DatePicker
extension AddService {
    
    func setUpDatePicker() {
//        serviceDedlineTF.text = Date().toString()
        serviceDedlineTF.inputView = datePicker
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
       
        let localeID = Locale.preferredLanguages.first
        datePicker.locale = Locale(identifier: localeID!)
        
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        //создаем жест
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureDone))
        self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dateChanged() {
        getDateFromPicker()
    }
    
    @objc func tapGestureDone() {
        view.endEditing(true)
    }
    // формируем дату из DataPocker в нужный нам формат и кладем TF
    func getDateFromPicker() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        serviceDedlineTF.text = formatter.string(from: datePicker.date)
    }
    
}
