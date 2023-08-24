//
//  OnBoardingViewController.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/24.
//

import UIKit

final class OnBoardingViewController: BaseViewController {
    
    private let pageScrollView = UIScrollView().then {
        $0.isPagingEnabled = true
        $0.showsHorizontalScrollIndicator = false
    }
    
    private let pageControl = UIPageControl().then {
        $0.numberOfPages = 4
        $0.tintColor = .purple
        $0.currentPage = 0
        $0.pageIndicatorTintColor = .iconDisabled
        $0.currentPageIndicatorTintColor = .primary
        $0.hidesForSinglePage = true
    }
    
    private let firstOnboardingView = OnboardingView(title: "핏허브에 어서오세요!",
                                                     subTitle: "재미있고 내게 맞는 운동이 찾고 싶어\n우주를 떠돌다 지친 당신, 핏허브 행성에 잘 오셨어요!",
                                                     image: "onbording_1")
    private let secondOnboardingView = OnboardingView(title: "오운완 인증하고 레벨 UP!",
                                                      subTitle: "인증샷 한 장으로 경험치가 쌓여요.\n우주먼지부터 은하까지 성장하면서 재밌게 운동해요!",
                                                      image: "onbording_2")
    
    private let thirdOnboardingView = OnboardingView(title: "운동정보를 공유해요",
                                                      subTitle: "운동에 대한 고민이 있을 때, 알려주고싶은 꿀팁이 있을 때\n핏허브에서 다른사람과 이야기해봐요.",
                                                      image: "onbording_3")
    
    private let fourthOnboardingView = OnboardingView(title: "‘특별한' 운동, 어디서 하지?",
                                                      subTitle: "재미있고 특별한 운동, 핏허브에 모아 놓았어요.\n운동시설 정보를 탐색해봐요.",
                                                      image: "onbording_4")
    
    private let skipButton = UIButton(type: .system).then {
        $0.setTitle("건너띄기", for: .normal)
        $0.setTitleColor(.textSub02, for: .normal)
        $0.titleLabel?.font = .pretendard(.bodyMedium01)
    }
    
    private let nextButton = UIButton(type: .system).then {
        $0.setTitle("다음", for: .normal)
        $0.setTitleColor(.primary, for: .normal)
        $0.titleLabel?.font = .pretendard(.bodyMedium01)
    }
    
    private let startButton = StandardButton().then {
        $0.setTitle("핏허브 시작하기", for: .normal)
        $0.isHidden = true
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.modalPresentationStyle = .fullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func addSubView() {
        [pageScrollView, pageControl, skipButton, nextButton, startButton].forEach {
            view.addSubview($0)
        }
        
        [firstOnboardingView, secondOnboardingView, thirdOnboardingView, fourthOnboardingView].forEach {
            pageScrollView.addSubview($0)
        }
    }
    
    override func setupBinding() {
        pageScrollView.rx.didScroll
            .compactMap { [weak self] in self?.pageScrollView.contentOffset.x }
            .bind(onNext: { [weak self] offsetX in
                guard let self else { return }
                self.pageControl.currentPage = Int(round(offsetX/self.view.frame.width))
                self.startButton.isHidden = self.pageControl.currentPage != 3
                self.pageControl.isHidden = self.pageControl.currentPage == 3
                self.nextButton.isHidden = self.pageControl.currentPage == 3
                self.skipButton.isHidden = self.pageControl.currentPage == 3
            })
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .compactMap { [weak self] in self?.pageControl.currentPage }
            .filter { $0 < 3 }
            .map { $0 + 1 }
            .bind(onNext: { [weak self] page in
                guard let self else { return }
                pageControl.rx.currentPage.onNext(page)
                self.pageScrollView.contentOffset.x = CGFloat(page) * view.frame.width
            })
            .disposed(by: disposeBag)
        
        skipButton.rx.tap
            .bind(onNext: { [weak self] in
                UserDefaults.standard.setValue(false, forKey: "showOnBoarding")
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
        
        startButton.rx.tap
            .bind(onNext: { [weak self] in
                UserDefaults.standard.setValue(false, forKey: "showOnBoarding")
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    override func layout() {
        pageScrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        firstOnboardingView.snp.makeConstraints {
            $0.leading.verticalEdges.equalToSuperview()
            $0.height.equalTo(view.frame.height)
            $0.width.equalTo(view.frame.width)
        }
        
        secondOnboardingView.snp.makeConstraints {
            $0.leading.equalTo(firstOnboardingView.snp.trailing)
            $0.verticalEdges.equalToSuperview()
            $0.width.equalTo(view.frame.width)
        }
        
        thirdOnboardingView.snp.makeConstraints {
            $0.leading.equalTo(secondOnboardingView.snp.trailing)
            $0.verticalEdges.equalToSuperview()
            $0.width.equalTo(view.frame.width)
        }
        
        fourthOnboardingView.snp.makeConstraints {
            $0.leading.equalTo(thirdOnboardingView.snp.trailing)
            $0.trailing.equalToSuperview()
            $0.verticalEdges.equalToSuperview()
            $0.width.equalTo(view.frame.width)
        }
        
        pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-26)
        }
        
        skipButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalTo(pageControl)
        }
        
        nextButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(pageControl)
        }
        
        startButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
            $0.height.equalTo(52)
        }
    }
}
