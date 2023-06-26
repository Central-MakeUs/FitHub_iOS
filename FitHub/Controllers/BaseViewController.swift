//
//  BaseViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/26.
//
import UIKit
import RxSwift

class BaseViewController: UIViewController {
    // MARK:- Rx
    var disposeBag = DisposeBag()
    
    // MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAttributes()
        addSubView()
        configureNavigation()
        layout()
        configureUI()
        setupBinding()
    }
    
    func configureUI() {
        self.view.backgroundColor = .white
    }
    
    func addSubView() {
        
    }
    
    func layout() {
        
    }

    func configureNavigation() {
        self.navigationController?.navigationBar.tintColor = .iconDefault
        self.navigationItem.backButtonTitle = ""
    }
    
    func setupAttributes() {
        
    }
    
    func setupBinding() {
    }
    
    func comfirmAlert(title: String, subtitle: String, completion: @escaping(UIAlertAction) -> Void) -> UIAlertController{
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: completion))
        
        return alert
    }
}


