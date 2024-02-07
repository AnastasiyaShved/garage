//
//  UpdateAutoViewController.swift
//  garage
//
//  Created by Apple on 6.02.24.
//

import Firebase
import FirebaseAuth
import SwiftUI

class UpdateAutoViewController: UIViewController {
    //MARK: - Properties
    private lazy var titleView = makeTitle()
    private lazy var table = makeTable()
    private lazy var closeButton = makeCloseButton()
    private lazy var updateButton = makeUpdateButton()
    
    private var autos: [AutoModel] = []
    private let service: AutoService = AutoServiceImpl.shader
    
    private let group = DispatchGroup()
    
    //MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        pinTitle()
        pinCloseButton()
        pinUpdateButton()
        pinTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        service.fetchAutos() { [weak self] result in
            self?.autos = []
            switch result {
            case .success(let autos):
                self?.autos = autos
                self?.table.reloadData()
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    // MARK: - Private functions
    private func applyTheme() {
        self.view.backgroundColor = Theme.currentTheme.backgroundColor
    }
}

// MARK: - Extensions
extension UpdateAutoViewController {

    func makeTable() -> UITableView {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.delegate = self
        table.dataSource = self

        return table
    }
    
    func pinTable() {
        self.view.addSubview(table)
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 8),
            table.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: updateButton.topAnchor, constant: -10)
        ])
    }
    
    func makeTitle() -> UILabel {
        let label = UILabel()
        label.text = "Обновите пробег"
        label.textColor = Theme.currentTheme.textColor
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }
    
    func pinTitle() {
        self.view.addSubview(titleView)
        NSLayoutConstraint.activate([
            titleView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor),
            titleView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10)
        ])
    }
    
    func makeCloseButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(.init(systemName: "xmark.circle"), for: .normal)
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        button.tintColor = Theme.currentTheme.textColorSecondary
       
        return button
    }
    
    @objc
    func close() {
        self.dismiss(animated: true)
    }
    
    func pinCloseButton() {
        self.view.addSubview(closeButton)
        
        NSLayoutConstraint.activate([
            closeButton.heightAnchor.constraint(equalToConstant: 20),
            closeButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 8),
            closeButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -10)
        ])
    }
    
    func makeUpdateButton() -> UIButton {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Обновить", for: .normal)
        button.addTarget(self, action: #selector(update), for: .touchUpInside)
        button.backgroundColor = Theme.currentTheme.buttonColor
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        
        return button
    }
    
    func pinUpdateButton() {
        self.view.addSubview(updateButton)
        NSLayoutConstraint.activate([
            updateButton.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            updateButton.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            updateButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            updateButton.heightAnchor.constraint(equalToConstant: 56)
        ])
    }
    //метод  для изменение данных в пробеге в авто в БД
    @objc
    func update() {
        self.autos.forEach({
            group.enter()
            self.service.chengeAuto($0.id, $0, callback: { [weak self] result in
                switch result {
                case .success:
                    self?.group.leave()
                case .failure(let error):
                    print(error)
                }
            })
        })
        
        group.notify(queue: .main) {
            self.dismiss(animated: true)
        }
    }
}
    //MARK: - UITableViewDelegate, UITableViewDataSource
extension UpdateAutoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return autos.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        
        let model = autos[indexPath.section]
        cell.configurationUpdateHandler = { [self] (cell, state) in
            cell.contentConfiguration = UIHostingConfiguration(content: {
                UpadateView(delegate: self, index: indexPath.section, mile: "\(model.mileage)")
            })
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let auto = autos[section]
        return "\(auto.name)" + " " + "\(auto.model)" + " " + "\(auto.number)"
    }
}

extension UpdateAutoViewController: UpadateViewDelegate {
    
    func updateValue(_ value: Int, at index: Int) {
        self.autos[index].mileage = value
    }
}


protocol UpadateViewDelegate: AnyObject {
    func updateValue(_ value: Int, at index: Int)
}

struct UpadateView: View {
    
    weak var delegate: UpadateViewDelegate?
    
    let index: Int
    @State var mile: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Текущий пробег")
                .font(.system(size: 14.0))
                .foregroundStyle(Color(uiColor: Theme.currentTheme.textColorSecondary))
            
            TextField("Введите значение", text: $mile)
                .onChange(of: mile) { _ in
                    delegate?.updateValue(Int(mile) ?? 0, at: index)
                }
        }
    }
}
