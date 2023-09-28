//
//  AlyciaViewController.swift
//  AlyciaApp
//
//  Created by Shimokura on 2023/09/28.
//

import UIKit
import AlyciaITR
import Cartography

class AlyciaViewController: UIViewController {
    
    lazy var byeButton: UIButton = {
        let btn = UIButton(type: .detailDisclosure)
        btn.setTitle("Bye!", for: .normal)
        btn.addTarget(self, action: #selector(bye), for: .touchUpInside)
        btn.titleLabel?.textAlignment = .center
        view.addSubview(btn)
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        constrain(view, byeButton) {
            base, btn in
            btn.width == 160
            btn.centerX == base.centerX
            btn.bottom == base.safeAreaLayoutGuide.bottom - 30
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Alycia().setAlycia(view: view)
        Alycia().showProgress(view: view)
    }

    @objc func bye() {
        UIView.animate(withDuration: 1, delay: 0) {
            self.dismiss(animated: true)
        }
    }
}
