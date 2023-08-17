//
//  PagingControlItem.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/18.
//

import UIKit

final class CardPagingControlView: UIView {
    private let scrollView = UIScrollView().then {
        $0.isScrollEnabled = false
        $0.isPagingEnabled = false
        $0.showsHorizontalScrollIndicator = false
    }
    
    private let pageControl = UIPageControl().then {
        $0.tintColor = .purple
        $0.currentPage = 0
        $0.pageIndicatorTintColor = .iconDisabled
        $0.currentPageIndicatorTintColor = .primary
        $0.hidesForSinglePage = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.scrollView)
        self.addSubview(self.pageControl)
        
        self.scrollView.delegate = self
        
        self.scrollView.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
        }
        
        self.pageControl.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setItems(items: [MyExerciseItemDTO]) {
        self.pageControl.numberOfPages = items.count
        let width = UIScreen.main.bounds.width-40
        for index in 0..<items.count {
            _ = MyPageExerciseCardView().then {
                if index == 0 { $0.titleLabel.text = "메인 운동" }
                $0.configureInfo(items[index])
                let xPosition = width * CGFloat(index)
                $0.frame = CGRect(x: xPosition, y: 0, width: width, height: 122)
                
                self.scrollView.contentSize.width = width * CGFloat(index+1)
                self.scrollView.addSubview($0)
            }
        }
    }
    
    func resetItem() {
        self.scrollView.subviews.forEach {
            $0.removeFromSuperview()
        }
    }
}
extension CardPagingControlView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) { // scrollView가 스와이프 될 때 발생 될 이벤트
        self.pageControl.currentPage = Int(round(scrollView.contentOffset.x / (UIScreen.main.bounds.width-88)))
    }
}
