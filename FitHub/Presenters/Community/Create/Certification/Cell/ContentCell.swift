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
    
    var textChange: ((String)->Void)?
    var textSizeChange: (()->Void)?
    var responder: (()->())?
    
    let contentTextView = UITextView().then {
        $0.textColor = .textSub02
        $0.backgroundColor = .clear
        $0.isScrollEnabled = false
        $0.text = "오늘 운동은 어땠나요?느낀점을 작성해봐요"
        $0.font = .pretendard(.bodyMedium01)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        responder?()
    }
    
    func configureCell(text: String) {
        self.contentTextView.text = text
    }
    
    private func textViewBinding() {
        contentTextView.rx.text
            .subscribe(onNext: { _ in
                self.contentTextView.sizeToFit()

                if self.contentView.frame.height != self.contentTextView.contentSize.height {
                    self.textSizeChange?()
                }
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
            .bind { [weak self] in
                guard let self = self else { return }
                if self.contentTextView.text.count == 0 {
                    self.contentTextView.text = "오늘 운동은 어땠나요?느낀점을 작성해봐요"
                    self.contentTextView.textColor = .textSub02
                }
                self.textChange?(self.contentTextView.text)
            }.disposed(by: disposeBag)
    }
}
