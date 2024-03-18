//
//  SettingsVC.swift
//  garage
//
//  Created by Apple on 29.11.23.
//

import UIKit
import Firebase
import FirebaseAuth
import SwiftUI

class ServiceHistory: UIViewController {
   
    private lazy var table = makeTable()
    
    private var autos: [AutoModel] = []
    private let service: AutoService = AutoServiceImpl.shader
    
    override func viewDidLoad() {
        super.viewDidLoad()
        applyTheme()
        pinTable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        service.fetchAutos() { [weak self] result in
            self?.autos = []
            switch result {
            case .success(let autos):
                autos.forEach({ auto in
                    var newAuto = auto
                    let service = auto.services.filter({ $0.isCompleted })
                    newAuto.services = service
                    self?.autos.append(newAuto)
                })
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

extension ServiceHistory {
    
    func makeTable() -> UITableView {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.delegate = self
        table.dataSource = self
        table.rowHeight = 40

        return table
    }
    
    func pinTable() {
        self.view.addSubview(table)
        NSLayoutConstraint.activate([
            table.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            table.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
}

extension ServiceHistory: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return autos.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autos[section].services.count != 0 ? autos[section].services.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.selectionStyle = .none
        if autos[indexPath.section].services.isEmpty {
            cell.contentConfiguration = UIHostingConfiguration(content: {
                Text("Отсутствует история обслуживания")
                    .font(.system(size: 14.0))
                    .foregroundStyle(Color(uiColor: Theme.currentTheme.textColorSecondary))
            })
        } else {
            let service = autos[indexPath.section].services[indexPath.row]
            
            cell.contentConfiguration = UIHostingConfiguration(content: {
                HStack {
                    Text(service.taskDescription)
                        .font(.system(size: 14.0))
                        .foregroundStyle(Color(uiColor: Theme.currentTheme.textColorSecondary) )
                    Spacer()
                    Text(service.dedline?.toString() ?? "")
                        .font(.system(size: 14.0))
                        .foregroundStyle(Color(uiColor: Theme.currentTheme.textColorSecondary))
                }
            })
        }
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let auto = autos[section]
        return "\(auto.name)" + " " + "\(auto.model)" + " " + "\(auto.number)"
    }
}
