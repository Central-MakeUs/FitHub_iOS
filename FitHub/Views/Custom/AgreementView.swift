//
//  AgreementView.swift
//  FitHub
//
//  Created by 신상우 on 2023/06/28.
//

import UIKit
import RxSwift

final class AgreementView: UIView {
    //MARK: - Properties
    private let disposeBag = DisposeBag()
    private let agreementTypeString: String
    
    let checkButton = UIButton(type: .system).then {
        $0.setImage(UIImage(named: "CheckOff")?.withRenderingMode(.alwaysOriginal), for: .normal)
    }

    private let contentLabel = UILabel().then {
        $0.font = .pretendard(.bodyMedium01)
        $0.textColor = .textSub02
    }
    
    let disclosureButton = UIButton()
    
    //MARK: - Init
    init(_ content: String, isRequired: Bool) {
        self.agreementTypeString = isRequired ? "(필수) " : "(선택) "
        super.init(frame: .zero)
        self.contentLabel.text = agreementTypeString + content
        
        self.addSubView()
        self.layout()
        self.setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBinding() {
        
    }
    
    //MARK: - AddSubView
    private func addSubView() {
        self.addSubview(self.checkButton)
        self.addSubview(self.contentLabel)
        self.addSubview(self.disclosureButton)
    }
    
    //MARK: - Layout
    private func layout() {
        self.checkButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.top.bottom.equalToSuperview()
        }
        
        self.contentLabel.snp.makeConstraints {
            $0.leading.equalTo(self.checkButton.snp.trailing).offset(10)
            $0.bottom.top.equalToSuperview()
        }
        
        self.disclosureButton.snp.makeConstraints {
            $0.trailing.top.bottom.equalToSuperview()
        }
    }
}
