//
//  StandardActionSheetController
//  FitHub
//
//  Created by iOS신상우 on 2023/08/13.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture

final class StandardActionSheetController: UIViewController {
    private let disposeBag = DisposeBag()
    
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark)).then {
        $0.alpha = 0.2
    }
    
    private lazy var actionSheetView = UIStackView().then {
        $0.layer.masksToBounds = true
        $0.axis = .vertical
        $0.backgroundColor = .bgSub01
        $0.layer.cornerRadius = 20
        $0.layer.shadowOpacity = 1.0
        $0.layer.shadowRadius = 4
        $0.layer.shadowOffset = .init(width: 0, height: 3)
    }

    private let handlerImage = UIImageView(image: UIImage(named: "HandleBar")?.withTintColor(.iconDisabled,
                                                                                             renderingMode: .alwaysOriginal))
    
    private let actionStackView = UIStackView().then {
        $0.axis = .vertical
        $0.distribution = .fillEqually
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addSubView()
        self.layout()
        self.configure()
        self.prepareAction()
        setUpBinding()
    }
    
    //MARK: - Configure
    private func configure() {
        self.view.backgroundColor = .clear
    }
    
    private func prepareAction() {
        guard let first = self.actionStackView.arrangedSubviews.first as? StandardActionSheetAction else { return }
        first.lineLayer.isHidden = true
    }
    
    func addAction(_ action: StandardActionSheetAction) {
        self.actionStackView.addArrangedSubview(action)
        action.rx.tap
            .bind(onNext: { [weak self] in
                self?.dismiss(animated: false)
                action.handler?(action)
            })
            .disposed(by: disposeBag)
    }
    
    func addAction(_ actions: [StandardActionSheetAction]) {
        actions.forEach { action in
            self.actionStackView.addArrangedSubview(action)
            
            action.rx.tap
                .bind(onNext: { [weak self] in
                    self?.dismiss(animated: false)
                    action.handler?(action)
                })
                .disposed(by: disposeBag)
        }
    }
    
    //MARK: - Selector
    @objc private func willDismissVC() {
        self.dismiss(animated: true)
    }
    
    private func setUpBinding() {
        blurEffectView.rx.tapGesture()
            .bind(onNext: { [weak self] _ in
                self?.dismiss(animated: false)
            })
            .disposed(by: disposeBag)
        
        
    }
    
    // MARK: - AddSubView
    private func addSubView() {
        self.view.addSubview(self.blurEffectView)
        self.view.addSubview(self.actionSheetView)
        
        self.actionSheetView.addSubview(handlerImage)
        self.actionSheetView.addSubview(actionStackView)
    }
    
    // MARK: - Layout
    private func layout() {
        handlerImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.height.equalTo(5)
            $0.width.equalTo(43)
            $0.top.equalToSuperview().offset(14)
        }
        
        actionStackView.snp.makeConstraints {
            $0.top.equalTo(handlerImage.snp.bottom).offset(10)
            $0.trailing.bottom.equalToSuperview().offset(-20)
            $0.leading.equalToSuperview().offset(20)
        }
        
        self.actionSheetView.snp.makeConstraints {
            $0.leading.bottom.trailing.equalToSuperview()
        }
        
        self.blurEffectView.snp.makeConstraints {
            $0.leading.top.trailing.equalToSuperview()
            $0.bottom.equalTo(self.actionSheetView.snp.centerY)
        }
    }
}
