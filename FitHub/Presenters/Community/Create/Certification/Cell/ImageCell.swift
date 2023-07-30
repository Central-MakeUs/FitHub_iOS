//
//  ImageCell.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/28.
//

import UIKit
import RxSwift
import RxCocoa
import PhotosUI

final class ImageCell: UICollectionViewCell {
    static let identifier = "ImageCell"
    let disposeBag = DisposeBag()
    
    var tapButton: (()->Void)?
    
    private let imageView = UIImageView().then {
        $0.backgroundColor = .bgSub01
        $0.contentMode = .scaleAspectFit
    }
    
    private let changeImageButton = UIButton(type: .system).then {
        var configure = UIButton.Configuration.plain()
        configure.contentInsets = .init(top: 8, leading: 12, bottom: 8, trailing: 12)
        configure.background.backgroundColor = .black.withAlphaComponent(0.8)
        configure.background.cornerRadius = 20
        
        var titleAttr = AttributedString.init("사진 바꾸기")
        titleAttr.font = .pretendard(.labelLarge)
        titleAttr.foregroundColor = .textSub01
        configure.attributedTitle = titleAttr
        
        $0.configuration = configure
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(self.imageView)
        self.contentView.addSubview(self.changeImageButton)
        
        self.imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.changeImageButton.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview().offset(-20)
        }
        
        self.setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(image: UIImage?) {
        self.imageView.image = image
    }
    
    private func setupBinding() {
        self.changeImageButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.tapButton?()
            })
            .disposed(by: disposeBag)
    }
}
