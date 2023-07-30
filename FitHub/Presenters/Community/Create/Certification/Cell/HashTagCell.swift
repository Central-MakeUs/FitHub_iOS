//
//  HashTagCell.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/28.
//

import UIKit
import RxSwift

protocol HashTagDelegate: AnyObject {
    func addHashTag(_ text: String)
    func deleteHashTag(_ text: String)
}

final class HashTagCell: UICollectionViewCell {
    static let identifier = "HashTagCell"
    
    weak var delegate: HashTagDelegate?
    
    //MARK: - Properties
    var disposeBag = DisposeBag()
    
    private lazy var stackView = UIStackView(arrangedSubviews: [tagTextField, deleteButton]).then {
        $0.spacing = 6
        $0.distribution = .equalSpacing
    }
    
    let tagTextField = UITextField().then {
        $0.textAlignment = .center
        $0.placeholder = "+태그추가"
        $0.isEnabled = false
        $0.font = .pretendard(.labelLarge)
        $0.textColor = .textSub01
        
    }
    
    let deleteButton = UIButton().then {
        var configure = UIButton.Configuration.plain()
        configure.contentInsets = .zero
        configure.image = UIImage(named: "CancelIcon")?.withRenderingMode(.alwaysOriginal)
        
        $0.configuration = configure
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 16
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.iconSub.cgColor
        
        self.contentView.addSubview(stackView)
        
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.top.bottom.equalToSuperview().inset(6)
        }
        
        self.setUpBinding()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        tagTextField.placeholder = ""
        tagTextField.isEnabled = false
        deleteButton.configuration?.image = UIImage(named: "CancelIcon")?.withRenderingMode(.alwaysOriginal)
    }
    
    private func setUpBinding() {
        self.tagTextField.rx.text.orEmpty
            .map { String($0.filter { !$0.isWhitespace }) }
            .map { String($0.prefix(8)) }
            .bind(to: self.tagTextField.rx.text)
            .disposed(by: disposeBag)
        
        self.tagTextField.rx.controlEvent(.editingDidEnd)
            .withLatestFrom(self.tagTextField.rx.text.orEmpty.asObservable())
            .filter { !$0.isEmpty }
            .bind { [weak self] text in
                self?.delegate?.addHashTag(text)
                self?.tagTextField.text = ""
            }
            .disposed(by: disposeBag)
        
        self.deleteButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let text = self?.tagTextField.text else { return }
                self?.delegate?.deleteHashTag(text)
            })
            .disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureLabel(_ name: String) {
        self.tagTextField.text = name
    }
    
    func configureAddCell(_ isEnable: Bool) {
        if isEnable {
            self.layer.borderColor = UIColor.iconSub.cgColor
            self.tagTextField.attributedPlaceholder = NSAttributedString(string: "+태그추가",
                                                                         attributes: [.font : UIFont.pretendard(.labelLarge),
                                                                                      .foregroundColor : UIColor.textDefault])
        } else {
            self.layer.borderColor = UIColor.iconDisabled.cgColor
            self.tagTextField.attributedPlaceholder = NSAttributedString(string: "+태그추가",
                                                                         attributes: [.font : UIFont.pretendard(.labelLarge),
                                                                                      .foregroundColor : UIColor.iconDisabled])
        }
        self.deleteButton.configuration?.image = nil
        self.tagTextField.isEnabled = isEnable
    }
    
}
