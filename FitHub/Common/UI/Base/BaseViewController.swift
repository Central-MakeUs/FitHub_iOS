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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        configureNavigation()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupAttributes()
        addSubView()
        
        configureTabBar()
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
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.backgroundColor = .bgDefault
        navigationBarAppearance.shadowColor = .clear
        navigationBarAppearance.titleTextAttributes = [.foregroundColor : UIColor.textDefault,
                                                       .font : UIFont.pretendard(.titleMedium)]
        navigationItem.standardAppearance = navigationBarAppearance
        navigationItem.scrollEdgeAppearance = navigationBarAppearance
        
        
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "BackButton")?.withRenderingMode(.alwaysOriginal),
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(dldClickBackButton))
    }
    
    func configureTabBar() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = .bgDefault
        tabBarController?.tabBar.standardAppearance = tabBarAppearance
        tabBarController?.tabBar.scrollEdgeAppearance = tabBarAppearance
    }
    
    func setupAttributes() {
        
    }
    
    @objc func dldClickBackButton() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func didClickBackButtonWithFeed() {
        let alert = StandardAlertController(title: "작성을 종료하시겠습니까?", message: "작성하신 내용이 저장되지 않습니다.")
        let cancel = StandardAlertAction(title: "취소", style: .cancel)
        let ok = StandardAlertAction(title: "확인", style: .basic) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        alert.addAction([cancel,ok])
        
        self.present(alert, animated: false)
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
    
    func responseToKeyboardHeightWithScrollView(_ scrollView: UIScrollView) {
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
                   .subscribe(onNext: { notification in
                       if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size {
                           // 키보드 높이를 스크롤 뷰 컨텐츠 높이에 추가
                           scrollView.contentInset.bottom = keyboardSize.height
                           scrollView.verticalScrollIndicatorInsets.bottom = keyboardSize.height
                       }
                   })
                   .disposed(by: disposeBag)
               
               NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
                   .subscribe(onNext: { _ in
                       // 키보드가 사라질 때 컨텐츠 인셋과 스크롤 인셋을 초기화
                       scrollView.contentInset = .zero
                       scrollView.verticalScrollIndicatorInsets = .zero
                   })
                   .disposed(by: disposeBag)
    }
    
    func comfirmAlert(title: String, subtitle: String, completion: @escaping(UIAlertAction) -> Void) -> UIAlertController{
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: completion))
        
        return alert
    }
    
    func setFeedBackButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "BackButton")?.withRenderingMode(.alwaysOriginal),
                                                                style: .plain,
                                                                target: self,
                                                                action: #selector(didClickBackButtonWithFeed))
    }
}




