//
//  UserListViewController.swift
//  AlyciaApp
//
//  Created by Shimokura on 2023/09/27.
//

import UIKit
import AlyciaITR
import Cartography

class UserListViewController: UIViewController {

    let userListCellIdentifier = "cellIdentifier"
    let cellHeight: CGFloat = 64
    
    let curl = Curl()
//    var result: UITextView?
    
    var data: [[String]] = [[String]]()
    
    lazy var closeBtn: UIButton = {
        let btn = UIButton(type: .close)
        btn.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        view.addSubview(btn)
        return btn
    }()
    
    lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.register(UserTableViewCell.self, forCellReuseIdentifier: userListCellIdentifier)
        table.delegate = self
        table.dataSource = self
        view.addSubview(table)
        return table
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
//        result = UITextView()
//        result?.backgroundColor = .white
//        result?.textColor = .darkGray
//        view.addSubview(result!)
//        constrain(view, result!) {
//            base, text in
//            text.edges == inset(base.edges, 50)
//        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        curl.setGradientBackground(view: view)
        setView()
        NotificationCenter.default.addObserver(self, selector: #selector(showResult(notification:)), name: Notifications.SearchUserNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        curl.searchGithubUser(user: "lion")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setView() {
        constrain(view, closeBtn, tableView) {
            base, close, table in
            close.width == 30
            close.height == close.width
            close.top == base.safeAreaLayoutGuide.top + 20
            close.trailing == base.trailing - 20
            table.top == close.bottom + 20
            table.leading == base.leading + 20
            table.trailing == base.trailing - 20
            table.bottom == base.safeAreaLayoutGuide.bottom - 50
        }
    }

    @objc func showResult(notification: Notification) {
        if let userInfo = notification.userInfo {
            DispatchQueue.main.async {
                if let users = userInfo["user"] {
                    print(users)
                    if let users = users as? Curl.User {
                        users.items.forEach { item in
                            self.data.append([item.login, item.html_url.absoluteString])
                        }
                    }
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @objc func closeView() {
        dismiss(animated: true)
    }
}

extension UserListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: userListCellIdentifier, for: indexPath) as? UserTableViewCell {
            cell.backgroundColor = .clear
            let listData = data[indexPath.row]
            cell.configure(name: listData[0] , url: listData[1] , cellHeight: cellHeight)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let url = URL(string: data[indexPath.row][1]) {
            UIApplication.shared.open(url)
        }
    }
}
