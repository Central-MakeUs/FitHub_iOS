//
//  RegistCompletionViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/26.
//

import UIKit
import RxSwift

final class RegistCompletionViewController: BaseViewController {
    //MARK: - Properties
    private let checkImageView = UIImageView().then {
        $0.image = UIImage(named: "RegistIcon")?.withRenderingMode(.alwaysOriginal)
    }
    
    private let titleLabel = UILabel().then {
        $0.textColor = .textDefault
        $0.font = .pretendard(.headLineSmall)
    }
    
    private let subTitleLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.text = "그럼 특별한 운동과 사람들이 있는\n핏허브로 떠나 보실까요?"
        $0.font = .pretendard(.bodyLarge01)
        $0.textColor = .iconEnabled
    }
    
    private let goHomeButton = StandardButton(type: .system).then {
        $0.setTitle("홈으로", for: .normal)
    }
    
    init(name: String) {
        self.titleLabel.text = "\(name)님 만나서 반가워요!"
        super.init(nibName: nil, bundle: nil)
        //TODO: 닉네임 정보 받아서 출력해주기.

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - SetupBinding
    override func setupBinding() {
        self.goHomeButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.navigationController?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - AddSubView
    override func addSubView() {
        self.view.addSubview(checkImageView)
        self.view.addSubview(titleLabel)
        self.view.addSubview(subTitleLabel)
        self.view.addSubview(goHomeButton)
    }
    
    override func layout() {
        self.checkImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(246)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(77)
        }
        
        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.checkImageView.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
        }
        
        self.subTitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(7)
        }
        
        self.goHomeButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-10)
            $0.height.equalTo(52)
        }
    }
}
