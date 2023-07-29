//
//  ContentCell.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/28.
//

import UIKit
import RxSwift
import RxCocoa

final class ContentCell: UICollectionViewCell {
    static let identifier = "ContentCell"
    
    var disposeBag = DisposeBag()
    
    let contentTextView = UITextView().then {
        $0.textColor = .textSub02
        $0.backgroundColor = .clear
        $0.isScrollEnabled = false
        $0.text = "오늘 운동은 어땠나요?느낀점을 작성해봐요"
        $0.font = .pretendard(.bodyMedium01)
    }
    
    let label = UILabel().then {
        $0.text = "아오이어아오어오엉아ㅓ어옹ㅎ"
        $0.numberOfLines = 0
        $0.textColor = .textDefault
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(contentTextView)
        
        self.contentTextView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        self.textViewBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func textViewBinding() {
        contentTextView.rx
              .didChange
              .subscribe(onNext: { [weak self] in
                  guard let self = self else { return }
                  self.contentTextView.sizeToFit()
              })
              .disposed(by: disposeBag)
        
        contentTextView.rx.didBeginEditing
            .bind{
                if self.contentTextView.text == "오늘 운동은 어땠나요?느낀점을 작성해봐요" {
                    self.contentTextView.text = ""
                }
                self.contentTextView.textColor = .textDefault
            }.disposed(by: disposeBag)
        
        contentTextView.rx.didEndEditing
            .bind{
                if self.contentTextView.text.count == 0 {
                    self.contentTextView.text = "오늘 운동은 어땠나요?느낀점을 작성해봐요"
                    self.contentTextView.textColor = .textSub02
                }
            }.disposed(by: disposeBag)
    }
}
