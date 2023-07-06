//
//  ProfileSettingViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/05.
//

import UIKit
import RxSwift
import RxCocoa
import PhotosUI

final class ProfileSettingViewController: BaseViewController {
    //MARK: - Properties
    private let viewModel: ProfileSettingViewModel
    
    private let titleLabel = UILabel().then {
        $0.text = "프로필 설정"
        $0.textColor = .textDefault
        $0.font = .pretendard(.headLineSmall)
    }
    
    private let subTitleLabel = UILabel().then {
        $0.text = "나를 표현할 사진과 닉네임을 등록해주세요."
        $0.textColor = .textSub02
        $0.font = .pretendard(.bodyMedium01)
    }
    
    private let profileImageEditButton = UIButton().then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .gray
        $0.layer.cornerRadius = 60
        $0.layer.masksToBounds = true
    }
    
    private let cameraImageView = UIImageView().then {
        $0.image = UIImage(named: "ProfileCamera")?.withRenderingMode(.alwaysOriginal)
    }
    
    private let nickNameTextFieldView = StandardTextFieldView("닉네임").then {
        $0.placeholder = "닉네임 입력"
    }
    
    private let nextButton = StandardButton().then {
        $0.setTitle("다음", for: .normal)
        $0.isEnabled = false
    }
    
    //MARK: - Init
    init(_ viewModel: ProfileSettingViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - SetupBinding
    override func setupBinding() {
        let input = ProfileSettingViewModel.Input(nickNameText: self.nickNameTextFieldView.textField.rx.text.orEmpty.asObservable(),
                                                  nextTap: self.nextButton.rx.tap.asSignal())
        
        let output = self.viewModel.transform(input: input)
        
        output.nickNameText
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: self.nickNameTextFieldView.textField.rx.text)
            .disposed(by: disposeBag)
  
        output.nickNameStatus
            .asDriver(onErrorJustReturn: .nickNameOK)
            .drive(onNext: { [weak self] status in
                self?.nickNameTextFieldView.verifyFormat(status)
                if status == .nickNameSuccess {
                    self?.nextButton.isEnabled = true
                } else {
                    self?.nextButton.isEnabled = false
                }
            })
            .disposed(by: disposeBag)
        
        output.nextTap
            .emit(onNext: { [weak self] in
                guard let self else { return }
                self.navigationController?.pushViewController(SportsSelectingViewController(SportsSelectingViewModel(self.viewModel.userInfo)), animated: true)
            })
            .disposed(by: disposeBag)
        
        self.profileImageEditButton.rx.tap
            .asSignal()
            .emit(onNext: { [weak self] in
                self?.authorizationPhotoLibrary()
            })
            .disposed(by: disposeBag)
        
        self.viewModel.profileImage
            .asDriver()
            .drive(self.profileImageEditButton.rx.image())
            .disposed(by: disposeBag)
    }
    
    //MARK: - 사진첩 권한 체크
    private func authorizationPhotoLibrary() {
        if PHPhotoLibrary.authorizationStatus(for: .readWrite) != .authorized {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                switch status {
                case .authorized: self.showPhotoAlbum()
                default: self.showAuthAlert()
                }
            }
        } else {
            self.showPhotoAlbum()
        }
    }
    
    private func showAuthAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "사진첩 권한 요청", message: "사진첩 권한이 제한되어 앱을 이용하실 수 없습니다.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "권한 변경하기", style: .default) { _ in
                if let appSetting = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(appSetting)
                }
            }
            alert.addAction(okAction)
            
            self.present(alert, animated: true)
        }
    }
    
    private func showPhotoAlbum() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        let photoPickerVC = PHPickerViewController(configuration: configuration)
        photoPickerVC.delegate = self
        self.present(photoPickerVC, animated: true)
    }
    
    //MARK: - AddSubView
    override func addSubView() {
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.subTitleLabel)
        self.view.addSubview(self.profileImageEditButton)
        self.view.addSubview(self.cameraImageView)
        self.view.addSubview(self.nickNameTextFieldView)
        self.view.addSubview(self.nextButton)
    }
    
    //MARK: - layout
    override func layout() {
        self.titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(15)
        }
        
        self.subTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(8)
        }
        
        self.profileImageEditButton.snp.makeConstraints {
            $0.top.equalTo(self.subTitleLabel.snp.bottom).offset(45)
            $0.height.width.equalTo(120)
            $0.centerX.equalToSuperview()
        }
        
        self.cameraImageView.snp.makeConstraints {
            $0.bottom.trailing.equalTo(self.profileImageEditButton)
            $0.height.width.equalTo(36)
        }
        
        self.nickNameTextFieldView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(self.profileImageEditButton.snp.bottom).offset(27)
        }
        
        self.nextButton.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide)
            $0.height.equalTo(56)
        }
    }
}

//MARK: - PHPickerDelegate
extension ProfileSettingViewController: PHPickerViewControllerDelegate, UINavigationControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let item = results.first else { return }
        let itemProvider = item.itemProvider
        
        if itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] result, error in
                guard let image = result as? UIImage else { return }
                self?.viewModel.profileImage.accept(image)
            }
        }
    }
}
