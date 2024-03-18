//
//  newHomePage.swift
//  garage
//
//  Created by Apple on 23.01.24.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class NewHomePage: UIViewController {
    
    enum Sections: Int, CaseIterable {
        case one
        case second
        
        var title: String {
            switch self {
            case .one:
                return "Мой автопарк"
            case .second:
                return "Техническое обслуживание"
            }
        }
    }
    // MARK: - Properties
    
    let notifications = Notifications()

    private var autos: [AutoModel] = []
   
    private let service: AutoService = AutoServiceImpl.shader
    
    private lazy var collectionView = makeCollectionView()
    private var selectedIndex: IndexPath = IndexPath(item: 0, section: 0)
    
    private var isShowUpdateVC: Bool = false
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(collectionView)
        sutupConstraintForCollection()
        
        title = "GARAGE"
        
        loadData() { [weak self] in
            guard let self = self else { return }
            if !self.isShowUpdateVC, !self.autos.isEmpty {
                self.isShowUpdateVC = true
                showUpdateView()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData() {}
    }
    
    private func loadData(_ callback: @escaping () -> Void) {
        service.fetchAutos() { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let autos):
                self.autos = []
                autos.forEach({ auto in
                    var newAuto = auto
                    let service = auto.services.filter({ !$0.isCompleted })
                    newAuto.services = service
                    self.autos.append(newAuto)
                })
                self.collectionView.reloadData()
                self.collectionView.selectItem(at: self.selectedIndex, animated: false, scrollPosition: .centeredHorizontally)
                
                callback()
                
            case .failure(let failure):
                print(failure)
            }
        }
    }
}

//MARK: - UICollectionViewDataSource, UICollectionViewDelegate
extension NewHomePage: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    ///устанавливаем количество элементов в секции
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0: return autos.count+1
            
        default:
            guard selectedIndex.row < autos.count else { return 0 }
            return autos[selectedIndex.row].services.count + 1
        }
    }
    /// наполняем коллекцию данными
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case 0:
            if  indexPath.row == autos.count {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellForAdd.reusableIdentifire, for: indexPath) as! CellForAdd
                cell.backgroundColor = Theme.currentTheme.backgroundColor
                cell.roundedWithShadow()
                return cell
                
            } else  {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellForAuto.reusableIdentifire, for: indexPath) as! CellForAuto
                let auto = autos[indexPath.row]
                cell.backgroundColor = cell.isSelected ? Theme.currentTheme.buttonColor : Theme.currentTheme.backgroundColor
                cell.roundedWithShadow()
                cell.delegate = self
                
                cell.autosName.text = auto.name
                cell.autosModel.text = auto.model
 // ????подписаться на делегат?????
                cell.mileage.text = "Пробег: \(auto.mileage.description) км(мили)"

                return cell
            }
        
        default:
            
            if indexPath.row == 0 {
                
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellForAdd.reusableIdentifire, for: indexPath) as! CellForAdd
                cell.backgroundColor = Theme.currentTheme.backgroundColor
                cell.roundedWithShadow()
                
                return cell
                
            } else {
                let to = autos[selectedIndex.row].services[indexPath.row-1]
            
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellForCollectionView.reusableIdentifire, for: indexPath) as! CellForCollectionView
                cell.backgroundColor = Theme.currentTheme.backgroundColor
                cell.roundedWithShadow()
                cell.tasksName.text = to.taskDescription
                
         //расчитываем progressViewValue
                
                
                if let km = to.mileage  {
                    let progressViewValue = Float(autos[selectedIndex.row].mileage - to.mileageCreatedService) / Float(km - to.mileageCreatedService)
                    cell.progressView.progress = Float(progressViewValue)
                    cell.deadline.text = "Через \(km - autos[selectedIndex.row].mileage) км(миль)"
                }
                
                if let dedline = to.dedline {
                    
                    let dedlimeValue = dedline.millisecondsSince1970
                    let todayValue = Date().millisecondsSince1970
                    let toValueCreated = to.dateCreatedService.millisecondsSince1970
                    
                    let progressViewValue = Float(todayValue - toValueCreated) / Float(dedlimeValue - toValueCreated)
                    cell.progressView.progress = Float(progressViewValue)
                    
                    
                    let delta = dedline.timeIntervalSince(Date())
                    
                    if let day = Calendar.current.dateComponents([.day], from: Date(), to: dedline).day {
                        cell.deadline.text = "Осталось \(day) дней"
                    }
                }
                return cell
            }
        }
    }
    ///деалем переходы от ячеек
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == autos.count {
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                guard let vc = storyboard.instantiateViewController(withIdentifier: "AddAutoVC") as? AddAutoVC else { return }
                vc.delegate = self
                navigationController?.pushViewController(vc, animated: true)
            } else {
                selectedIndex = indexPath
                collectionView.selectItem(at: selectedIndex, animated: true, scrollPosition: .centeredHorizontally)
                collectionView.reloadSections(IndexSet(integer: 1))
            }
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let addServiceVC = storyboard.instantiateViewController(withIdentifier: "AddService") as? AddService else { return }
            
            addServiceVC.currentAuto = autos[selectedIndex.row]
            addServiceVC.delegate = self
            if indexPath.row != 0 {
                addServiceVC.selectedIndex = indexPath.row - 1
            }
            navigationController?.pushViewController(addServiceVC, animated: true)
        }
    }
}

extension NewHomePage {
    func showUpdateView() {
        let vc = UpdateMileageVC()
        vc.modalPresentationStyle = .fullScreen
        
        self.navigationController?.present(vc, animated: true)
    }
    
    //MARK: - setup collection layout
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            
            return sectionIndex == 0 ? self.makeFirstLayoutSection() : self.makeSecondLayoutSection()
        }
        return layout
    }
    ///настраиваем лаяуты
    private func makeFirstLayoutSection() -> NSCollectionLayoutSection {
        let spacing: CGFloat = 8
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(220),
            heightDimension: .absolute(100))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(220),
            heightDimension: .absolute(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(spacing)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
        section.interGroupSpacing = spacing
        section.orthogonalScrollingBehavior = .groupPagingCentered
        
        return section
    }
    
    private func makeSecondLayoutSection() -> NSCollectionLayoutSection {
        let spacing: CGFloat = 8
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(100))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(spacing)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: spacing, leading: spacing, bottom: spacing, trailing: spacing)
        section.interGroupSpacing = spacing
        
        return section
    }
    
    // MARK: - setup collection
    private func makeCollectionView() -> UICollectionView {
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: createLayout())
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = LichtTheme().backgroundColor
        
        let nib = UINib(nibName: CellForAuto.reusableIdentifire, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: CellForAuto.reusableIdentifire)
        
        ///!!!!!!!!
        let secondNib = UINib(nibName: CellForCollectionView.reusableIdentifire, bundle: nil)
        collectionView.register(secondNib, forCellWithReuseIdentifier: CellForCollectionView.reusableIdentifire)
        
        let addNib = UINib(nibName: CellForAdd.reusableIdentifire, bundle: nil)
        collectionView.register(addNib, forCellWithReuseIdentifier: CellForAdd.reusableIdentifire)
        
       ///Зарегистрироваи заголовок для секции
        collectionView.register(SectionsHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionsHeader.reuserID)

        return collectionView
    }
    
    private func sutupConstraintForCollection() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
//MARK: - обновление массива и данных в collectionView после изменения авто
extension NewHomePage: AddAutoVCDelegate {
    func updateAuto(_ model: AutoModel) {
        self.autos[selectedIndex.row] = model
        self.collectionView.reloadData()
    }
    
    func deleteAuto(_ autoId: String) {
        guard let index = self.autos.firstIndex(where: { $0.id == autoId }) else { return }
        self.autos.remove(at: index)
        self.selectedIndex = IndexPath(item: 0, section: 0)
        self.collectionView.reloadData()
        self.collectionView.selectItem(at: self.selectedIndex, animated: false, scrollPosition: .centeredHorizontally)
    }
    
    func addAuto(_ model: AutoModel) {
        self.autos.append(model)
        self.selectedIndex = IndexPath(item: self.autos.firstIndex(where: { $0.id == model.id }) ?? 0, section: 0) 
        self.collectionView.reloadData()
    }
}

//MARK: - обновление массива и данных в collectionView после изменения сервисов
extension NewHomePage: AddServiceDelagate {
    func addTO(_ model: ServiceModel) {
        if !model.isCompleted {
            self.autos[selectedIndex.row].services.append(model)
            self.collectionView.reloadData()
        }
    }
    
    func update(_ model: ServiceModel, for index: Int) {
        if !model.isCompleted {
            self.autos[selectedIndex.row].services[index] = model
        } else {
            self.autos[selectedIndex.row].services.remove(at: index)
        }
        
        self.collectionView.reloadData()
    }
    
    func deleteTO(index: Int) {
        self.autos[selectedIndex.row].services.remove(at: index)
        self.collectionView.reloadData()
        self.collectionView.selectItem(at: self.selectedIndex, animated: false, scrollPosition: .centeredHorizontally)
    }
}

extension UICollectionViewCell {
    func roundedWithShadow() {
        self.layer.cornerRadius = 5
        self.layer.shadowRadius = 5
        self.layer.shadowOpacity = 0.3
        self.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.clipsToBounds = false
    }
}

extension NewHomePage: CellAutoDelegate {
    
    func openAutoDetail() {
        print("page open")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "AddAutoVC") as? AddAutoVC else { return }

        vc.delegate = self
        vc.currentAuto = autos[selectedIndex.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension Date {
    var millisecondsSince1970: Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
}

