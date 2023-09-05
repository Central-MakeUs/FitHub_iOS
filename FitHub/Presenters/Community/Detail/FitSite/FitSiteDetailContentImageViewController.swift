//
//  FitSiteDetailContentImageViewController.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/22.
//

import UIKit
import RxSwift
import RxCocoa
import Kingfisher


final class FitSiteDetailContentImageViewController: BaseViewController {
    private let image: PictureList
    
    private let backButton = UIButton(type: .system).then {
        $0.setImage(UIImage(named: "ic_close")?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    init(image: PictureList) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.kf.setImage(with: URL(string: image.pictureUrl)) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let item):
                let ratio = item.image.size.height / item.image.size.width
                imageView.snp.remakeConstraints {
                    $0.horizontalEdges.equalToSuperview()
                    $0.top.equalTo(self.backButton.snp.bottom).offset(20)
                    $0.height.equalTo(self.imageView.snp.width).multipliedBy(ratio)
                }
            case .failure(let error):
                print(error)
                self.notiAlert("사진을 불러오는데 실패했습니다.")
            }
        }
    }
    
    override func addSubView() {
        [backButton,imageView].forEach {
            self.view.addSubview($0)
        }
    }
    
    override func layout() {
        backButton.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.trailing.equalToSuperview().offset(-12)
            $0.width.height.equalTo(24)
        }
        
        imageView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(backButton.snp.bottom).offset(20)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    override func setupBinding() {
        backButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
}
