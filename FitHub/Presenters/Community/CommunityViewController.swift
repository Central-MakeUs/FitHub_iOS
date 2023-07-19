//
//  CommunityViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/19.
//

import UIKit

final class CommunityViewController: BaseViewController {
    let searchBar = UISearchBar().then {
        
        $0.searchTextField.layer.masksToBounds = true
        $0.searchTextField.backgroundColor = .bgSub01
        $0.searchTextField.layer.cornerRadius = 20
    }
    
    override func configureUI() {
        self.navigationItem.leftBarButtonItem = nil
    }
    
    override func configureNavigation() {
        let noti = UIBarButtonItem(image: UIImage(named: "BackButton"), style: .plain, target: nil, action: nil)
        let bookmark = UIBarButtonItem(image: UIImage(named: "BackButton"), style: .plain, target: nil, action: nil)
        
        self.navigationItem.rightBarButtonItems = [bookmark,noti]
        
        self.navigationItem.titleView = searchBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

