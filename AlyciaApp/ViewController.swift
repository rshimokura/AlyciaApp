//
//  ViewController.swift
//  AlyciaApp
//
//  Created by Shimokura on 2023/09/27.
//

import UIKit
import AlyciaITR
import Cartography

class ViewController: UIViewController {

    let cellIdentifier = "cellIdentifier"
    
    let curl = Curl()
    let rick = Rick()
    
    let data = [
        ["7/1", "Coffee Shop", 380, "Latte Large"],
        ["7/3", "Pet House", 1980, "Hand Towel"],
        ["7/10", "Mexican Restaurant", 5800, "Tacos"],
        ["7/22", "Pub Lion", 3200, "Beer"],
        ["7/30", "Bubba Gump Shrimp", 3200, "shrimp"],
        ["7/31", "Tokyo Station", 3200, "Tickets"],
    ]
    
    lazy var sampleList: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.register(CardDetailTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        table.delegate = self
        table.dataSource = self
        view.addSubview(table)
        return table
    }()
    
    lazy var stack: UIStackView = {
        let v = UIStackView()
        v.alignment = .center
        v.axis = .horizontal
        v.distribution = .equalSpacing
        v.addArrangedSubview(buttonA)
        v.addArrangedSubview(UIView())
        v.addArrangedSubview(buttonB)
        v.addArrangedSubview(UIView())
        v.addArrangedSubview(buttonC)
        view.addSubview(v)
        return v
    }()
    
    lazy var buttonA: RequestButton = {
        let btn = RequestButton(str: "Kingdom", p: self, setTarget: true)
        view.addSubview(btn)
        return btn
    }()
    
    lazy var buttonB: RequestButton = {
        let btn = RequestButton(str: "Search User", p: self, setTarget: false)
        btn.tag = 0
        btn.addTarget(self, action: #selector(showNext(sender:)), for: .touchUpInside)
        return btn
    }()

    lazy var buttonC: RequestButton = {
        let btn = RequestButton(str: "Get User", p: self, setTarget: false)
        btn.tag = 1
        btn.addTarget(self, action: #selector(showNext(sender:)), for: .touchUpInside)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        NotificationCenter.default.addObserver(self, selector: #selector(fromKingdom), name: Notifications.RequestButtonNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setView() {
        curl.addLabel(text: "Simba!", view: view)
        curl.setGradientBackground(view: view)
        
        switch rick.auth(user: "nara") {
        case .authorized:
            print("authorized")
        case .rejected:
            print("rejected")
        case .unknown:
            print("unknown")
        }
        
        if let img = curl.getImage() {
            let imgView = UIImageView(image: img)
            imgView.layer.borderWidth =  3
            imgView.layer.borderColor = UIColor.brown.cgColor
            imgView.layer.cornerRadius = 10
            imgView.clipsToBounds = true
            imgView.contentMode = .scaleAspectFit
            view.addSubview(imgView)
            constrain(view, imgView) {
                base, img in
                img.top == base.top + 150
                img.leading == base.leading + 100
                img.trailing == base.trailing - 100
                img.height == img.width
            }
        }
        
        constrain(view, sampleList, stack) {
            base, table, stack in
            table.leading == base.leading + 20
            table.trailing == base.trailing - 20
            table.top == base.top + 400
            table.bottom == stack.top - 30
            stack.bottom == base.safeAreaLayoutGuide.bottom - 20
            stack.leading == base.leading + 10
            stack.trailing == base.trailing - 10
            stack.height == 50
        }
    }
    
    @objc func fromKingdom(notification: NSNotification) {
        var resultMessage = "auth failed."
        if let userinfo = notification.userInfo {
            if let result = userinfo["auth"] as? Bool {
                if result, let message = userinfo["message"] as? String {
                    resultMessage = "auth: [\(result)]\nmessage: [\(message)]"
                }
            }
        }
        let alert = UIAlertController(title: "ライブラリ返却値", message: resultMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CardDetailTableViewCell {
            cell.backgroundColor = .clear
            let listData = data[indexPath.row]
            cell.configure(date: listData[0] as! String,
                           summary: listData[1] as! String,
                           amount: listData[2] as! Int,
                           memo: listData[3] as! String)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        // draw? > yes > API > show result
        let alert = UIAlertController(title: "おみくじ引く？", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "はい", style: .default, handler: { _ in
            self.showResult(title: self.rick.draw())
        }))
        alert.addAction(UIAlertAction(title: "いいえ", style: .cancel))
        present(alert, animated: true)
    }
    
    func showResult(title: String, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    @objc func showNext(sender: UIButton) {
        switch sender.tag {
        case 0:
            let vc = UserListViewController()
            present(vc, animated: true)
        case 1:
            let vc = UserDetailViewController()
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        default:
            break
        }
    }
}


