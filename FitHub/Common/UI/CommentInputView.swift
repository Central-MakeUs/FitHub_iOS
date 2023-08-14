//
//  CommentInputView.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/12.
//

import UIKit
import RxSwift
import RxCocoa

final class CommentInputView: UIStackView {
    private let disposeBag = DisposeBag()
    private let placeholder = "댓글 남기기"
    
    private let profileImageView = UIImageView(image: UIImage(named: "DefaultProfile")).then {
        $0.layer.cornerRadius = 15
        $0.layer.masksToBounds = true
    }
    
    let frameView = UIStackView().then {
        $0.layer.cornerRadius = 20
        $0.layer.masksToBounds = true
        $0.backgroundColor = .bgSub01
    }
    
    let commentInputView = UITextView().then {
        $0.text = "댓글 남기기"
        $0.textColor = .textInfo
        $0.font = .pretendard(.bodyMedium01)
        $0.backgroundColor = .bgSub01
        $0.isScrollEnabled = false
    }
    
    let registButton = UIButton(type: .system).then {
        $0.setTitle("등록", for: .normal)
        $0.setTitleColor(.primary, for: .normal)
        $0.setTitleColor(.textDisabled, for: .disabled)
        $0.titleLabel?.font = .pretendard(.bodyMedium02)
        $0.isEnabled = false
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubViews()
        layout()
        textViewBinding()
        
        self.backgroundColor = .bgDefault
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - AddSubViews
    private func addSubViews() {
        [profileImageView, frameView].forEach {
            self.addSubview($0)
        }
        
        [commentInputView, registButton].forEach {
            self.frameView.addSubview($0)
        }
    }
    
    private func layout() {
        profileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(30)
            $0.centerY.equalTo(frameView)
        }
        
        frameView.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(13)
            $0.trailing.equalToSuperview().offset(-20)
            $0.top.bottom.equalToSuperview().inset(10)
        }
        
        commentInputView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.top.bottom.equalToSuperview().inset(2)
            $0.trailing.equalTo(registButton.snp.leading).offset(-14)
        }
        
        registButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-4)
        }
    }
    
    private func textViewBinding() {
        commentInputView.rx.text.orEmpty
            .map { !($0.isEmpty || $0 == self.placeholder) }
            .bind(to: registButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        commentInputView.rx.didBeginEditing
            .bind{ [weak self] in
                guard let self else { return }
                if self.commentInputView.text == self.placeholder {
                    self.commentInputView.text = ""
                }
                self.commentInputView.textColor = .textDefault
            }.disposed(by: disposeBag)
        
        commentInputView.rx.didEndEditing
            .bind { [weak self] in
                guard let self = self else { return }
                if self.commentInputView.text.isEmpty {
                    self.commentInputView.text = self.placeholder
                    self.commentInputView.textColor = .textInfo
                }
            }.disposed(by: disposeBag)
    }
}
