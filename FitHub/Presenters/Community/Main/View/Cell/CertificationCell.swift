//
//  CertificationCell.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/23.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher

protocol CertificationCellDelegate: AnyObject {
    func toggleSelected(recordId: Int)
}

final class CertificationCell: UICollectionViewCell {
    static let identifier = "CertificationCell"
    private let disposeBag = DisposeBag()
    
    weak var delegate: CertificationCellDelegate?
    
    private let imageView = UIImageView().then {
        $0.backgroundColor = .iconDisabled
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 5
    }
    
    private let likeButton = UIButton().then {
        $0.isEnabled = false
        $0.setImage(UIImage(named: "ic_heart_default")?.withRenderingMode(.alwaysOriginal), for: .normal)
        $0.setImage(UIImage(named: "ic_heart_default")?.withRenderingMode(.alwaysOriginal), for: .disabled)
        $0.backgroundColor = .clear
    }
    
    private let likeCntLabel = UILabel().then {
        $0.shadowOffset = .init(width: 0.5, height: 0.5)
        $0.shadowColor = .black.withAlphaComponent(0.2)
        $0.text = "-"
        $0.textColor = .textDefault
        $0.font = .pretendard(.bodySmall02)
    }
    
    private let checkButton = UIButton().then {
        $0.setImage(UIImage(named: "CheckOff"), for: .normal)
        $0.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubView()
        self.layout()
        self.setUpBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(_ item: CertificationDTO) {
        self.imageView.kf.setImage(with: URL(string: item.pictureUrl ?? ""))
        self.likeCntLabel.text = "\(item.likes)"
        
        let likeImage = item.isLiked ? UIImage(named: "ic_heart_pressed") : UIImage(named: "ic_heart_default")
        self.likeButton.setImage(likeImage?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    func configureMyFeeCell(_ item: CertificationDTO, isSelected: Bool) {
        self.imageView.kf.setImage(with: URL(string: item.pictureUrl ?? ""))
        self.likeCntLabel.text = "\(item.likes)"
        
        let likeImage = item.isLiked ? UIImage(named: "ic_heart_pressed") : UIImage(named: "ic_heart_default")
        self.likeButton.setImage(likeImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        checkButton.isHidden = false
        changeCheck(isSelected: isSelected)
        checkButton.tag = item.recordId
    }
    
    func changeCheck(isSelected: Bool) {
        let image = isSelected ? UIImage(named: "CheckOn") : UIImage(named: "CheckOff")
        checkButton.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    // MARK: - setUpBinding
    private func setUpBinding() {
        checkButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.delegate?.toggleSelected(recordId: checkButton.tag)
            }
            .disposed(by: disposeBag)
    }
    
    //MARK: - AddSubView
    private func addSubView() {
        self.contentView.addSubview(imageView)
        self.contentView.addSubview(likeButton)
        self.contentView.addSubview(likeCntLabel)
        self.contentView.addSubview(checkButton)
    }
    
    //MARK: - Layout
    private func layout() {
        self.imageView.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
        }
        
        self.likeButton.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview().inset(10)
        }
        
        self.likeCntLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.likeButton)
            $0.leading.equalTo(self.likeButton.snp.trailing).offset(2)
        }
        
        checkButton.snp.makeConstraints {
            $0.trailing.top.equalToSuperview().inset(10)
        }
    }
}
