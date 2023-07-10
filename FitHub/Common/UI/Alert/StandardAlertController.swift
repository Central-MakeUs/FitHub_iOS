//
//  StandardAlertController.swift
//  OnandOff
//
//  Created by 신상우 on 2023/02/18.
//

import UIKit

final class StandardAlertController: UIViewController{
    private lazy var alertView = UIStackView(arrangedSubviews: [contentStackView,actionStackView]).then {
        $0.spacing = 30
        $0.layoutMargins = .init(top: 30, left: 0, bottom: 0, right: 0)
        $0.isLayoutMarginsRelativeArrangement = true
        $0.axis = .vertical
        $0.layer.masksToBounds = true
        $0.backgroundColor = .bgLight
        $0.layer.cornerRadius = 5
        
    }
    
    private let titleLabel = PaddingLabel(padding: .init(top: 0, left: 30, bottom: 0, right: 30)).then {
        $0.textAlignment = .center
        $0.font = .pretendard(.titleMedium)
        $0.numberOfLines = 0
        $0.textColor = .textDefault
    }
    
    private let messageLabel = PaddingLabel(padding: .init(top: 0, left: 30, bottom: 0, right: 30)).then {
        $0.textAlignment = .center
        $0.font = .pretendard(.bodyMedium01)
        $0.numberOfLines = 0
        $0.textColor = .textSub02
    }
    
    private lazy var contentStackView = UIStackView(arrangedSubviews: [titleLabel, messageLabel]).then {
        $0.spacing = 15
        $0.layoutMargins = .init(top: 0, left: 30, bottom: 0, right: 30)
        $0.isLayoutMarginsRelativeArrangement = true
        $0.axis = .vertical
    }
    
    private let actionStackView = UIStackView().then {
        $0.distribution = .fillEqually
    }
    
    init(title: String?, message: String?) {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .overCurrentContext
        
        self.titleLabel.text = title
        self.messageLabel.text = message
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
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Configure
    private func configure() {
        self.view.backgroundColor = .black.withAlphaComponent(0.8)
        NotificationCenter.default.addObserver(self, selector: #selector(willDismissVC), name: .dismissStandardAlert, object: nil)
    }
    
    private func prepareAction() {
        guard let first = self.actionStackView.arrangedSubviews.first else { return }
        guard let last = self.actionStackView.arrangedSubviews.last else { return }
        first.layer.cornerRadius = 5
        first.layer.maskedCorners = .layerMinXMaxYCorner
        last.layer.cornerRadius = 5
        last.layer.maskedCorners = .layerMaxXMaxYCorner
    }
    
    func addAction(_ action: UIButton) {
        self.actionStackView.addArrangedSubview(action)
    }
    
    func addAction(_ actions: [UIButton]) {
        actions.forEach {
            self.actionStackView.addArrangedSubview($0)
        }
    }
    
    /// 알림 제목 부분 색 변환 ( 하이라이트) 함수
    func titleHighlight(highlightString: String, color: UIColor) {
        guard let oldAttributeStr = self.titleLabel.attributedText else { return }
        let newAttributeStr = NSMutableAttributedString(attributedString: oldAttributeStr)
        newAttributeStr.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: ((self.titleLabel.text ?? "") as NSString).range(of: highlightString))
        
        self.titleLabel.attributedText = newAttributeStr
    }
    
    /// 알림 메시지 부분 색 변환 ( 하이라이트) 함수
    func messageHighlight(highlightString: String, color: UIColor) {
        guard let oldAttributeStr = self.messageLabel.attributedText else { return }
        let newAttributeStr = NSMutableAttributedString(attributedString: oldAttributeStr)
        newAttributeStr.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: ((self.messageLabel.text ?? "") as NSString).range(of: highlightString))
        
        self.messageLabel.attributedText = newAttributeStr
    }
    
    // MARK: - AddSubView
    private func addSubView() {
        self.view.addSubview(self.alertView)
    }
    
    // MARK: - Layout
    private func layout() {
        self.alertView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(28)
        }
        
        self.actionStackView.snp.makeConstraints {
            $0.height.equalTo(54)
        }
    }
    
    //MARK: - Selector
    @objc private func willDismissVC() {
        self.dismiss(animated: false)
    }
}
