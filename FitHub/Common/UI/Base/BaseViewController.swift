//
//  BaseViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/26.
//
import UIKit
import RxSwift
import RxKeyboard

class BaseViewController: UIViewController {
    // MARK:- Rx
    var disposeBag = DisposeBag()
    
    private var rxKeyboard: Disposable?
    
    // MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAttributes()
        addSubView()
        configureNavigation()
        layout()
        configureUI()
        setupBinding()
        
        hideKeyboardWhenTapped()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.rxKeyboard?.dispose()
    }
    
    func configureUI() {
        self.view.backgroundColor = .bgDefault
    }
    
    func addSubView() {
        
    }
    
    func layout() {
        
    }
    
    func configureNavigation() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "BackButton")?.withRenderingMode(.alwaysOriginal),
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(dldClickBackButton))
    }
    
    func setupAttributes() {
        
    }
    
    @objc func dldClickBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupBinding() {
    }
    
    func responseToKeyboardHegiht(_ view: UIView) {
        self.rxKeyboard = RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] keyboardHeight in
                guard let self else { return }
                let height = keyboardHeight > 0 ? -keyboardHeight + self.view.safeAreaInsets.bottom : 0
            
                view.snp.updateConstraints {
                    $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(height)
                }
                self.view.layoutIfNeeded()
            })
    }
    
    func comfirmAlert(title: String, subtitle: String, completion: @escaping(UIAlertAction) -> Void) -> UIAlertController{
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: completion))
        
        return alert
    }
}


