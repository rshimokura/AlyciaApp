//
//  UserDetailViewController.swift
//  AlyciaApp
//
//  Created by Shimokura on 2023/09/27.
//

import UIKit
import AlyciaITR
import Cartography
import NVActivityIndicatorView

class UserDetailViewController: UIViewController {

    let curl = Curl()
    
    lazy var closeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "close"), for: .normal)
        btn.addTarget(self, action: #selector(closeView), for: .touchUpInside)
        view.addSubview(btn)
        return btn
    }()
    
    lazy var activityIndicator: NVActivityIndicatorView = {
        let frame = CGRect(x: view.bounds.width / 2 - 30, y: view.bounds.height / 2 - 30, width: 60, height: 60)
        let indicator = NVActivityIndicatorView(frame: frame)
        indicator.type = .ballSpinFadeLoader
        indicator.color = .yellow
        view.addSubview(indicator)
        return indicator
    }()
    
    lazy var image: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.layer.cornerRadius = 10
        v.layer.borderColor = UIColor.white.cgColor
        v.layer.borderWidth = 4
        v.clipsToBounds = true
        view.addSubview(v)
        return v
    }()
    
    lazy var name: UILabel = {
        let v = UILabel()
        v.font = .boldSystemFont(ofSize: 26)
        v.textColor = .black
        view.addSubview(v)
        return v
    }()
    
    lazy var statusMessage: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .white
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 14)
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        label.adjustsFontSizeToFitWidth = true
        label.isHidden = true
        view.addSubview(label)
        return label
    }()
    
    lazy var statusIcon: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFit
        v.isUserInteractionEnabled = true
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(showStatusMessage))
        v.addGestureRecognizer(recognizer)
        view.addSubview(v)
        return v
    }()
    
    lazy var friendList: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 2
        stack.distribution = .fill
        let title = UILabel()
        title.text = "Friends"
        title.font = .boldSystemFont(ofSize: 22)
        title.textColor = .black
        title.backgroundColor = .clear
        stack.addArrangedSubview(title)
        stack.addArrangedSubview(UIView())
        view.addSubview(stack)
        return stack
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        curl.setPaleGradientBackground(view: view)
        NotificationCenter.default.addObserver(self, selector: #selector(showResult(notification:)), name: Notifications.SampleAPINotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // start indicator
        activityIndicator.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.curl.getSampleData()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setView() {
        constrain(view, closeBtn, name, statusIcon, statusMessage, image, friendList) {
            base, close, name, icon, msg, image, list in
            close.width == 30
            close.height == close.width
            close.top == base.safeAreaLayoutGuide.top + 20
            close.trailing == base.trailing - 20
            name.top == close.bottom + 30
            name.leading == base.leading + 30
            icon.leading == name.trailing + 10
            icon.centerY == name.centerY
            icon.width == 30
            icon.height == icon.width
            msg.top == icon.top
            msg.leading == icon.trailing + 6
            msg.width == 100
            image.top == icon.bottom + 10
            image.leading == name.leading
            image.trailing == base.trailing - 30
            image.height <= image.width
            list.top == image.bottom + 25
            list.leading == name.leading
            list.trailing == image.trailing
            list.bottom == base.safeAreaLayoutGuide.bottom - 40
        }
    }

    @objc func closeView() {
        dismiss(animated: true)
    }
    
    @objc func showStatusMessage() {
        if let status = Curl.Status(rawValue: statusIcon.tag) {
            statusMessage.text = status.string()
        
            UIView.transition(with: statusMessage, duration: 0.4, options: .transitionCrossDissolve, animations: {
                self.statusMessage.isHidden = false
            }) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                     self.statusMessage.isHidden = true
                }
            }
        }
    }
    
    @objc func showResult(notification: Notification) {
        // indicator
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.setView()
        }
                
        if let userInfo = notification.userInfo {
            if let data = userInfo["data"] as? Curl.MyJsonData {
                let user = data.content()
                DispatchQueue.main.async {
                    self.name.text = user.user
                    self.setFriendList(list: user.list)
                    self.setImage(decodeString: user.image)
                    self.getStateIcon(value: Int(user.status))
                }
                print(data.data.user)
                print(data.data.list.debugDescription)
            } else if let error = userInfo["error"] as? String {
                print(error)
            } else {
                print(userInfo.debugDescription)
            }
        }
    }
    
    func setFriendList(list: [String]) {
        list.forEach { friend in
            let f = UILabel()
            f.text = " ・ \(friend)"
            f.textColor = .darkGray
            f.font = .systemFont(ofSize: 20)
            friendList.addArrangedSubview(f)
        }
        friendList.addArrangedSubview(UIView())
    }
    
    func setImage(decodeString: String) {
        guard let imageData = Data(base64Encoded: decodeString) else { return }
        image.image = UIImage(data: imageData)
        
        // calc aspect
        if let width = image.image?.size.width, let height = image.image?.size.height {
            let aspect: Double = height / width
            constrain(image) {
                img in
                img.height == img.width * aspect
            }
        }
    }
    
    func getStateIcon(value: Int) {
        if let status = Curl.Status(rawValue: value), let img = curl.getStateIcon(status: status) {
            statusIcon.image = img
            statusIcon.tag = value
        }
    }
}
