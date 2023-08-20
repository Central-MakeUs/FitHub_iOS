//
//  ContentCell.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/28.
//

import UIKit
import RxSwift
import RxCocoa

protocol ContentCellDelegate: AnyObject {
    func changeContentFrame()
    func changeContent(string: String)
}

final class ContentCell: UICollectionViewCell {
    static let identifier = "ContentCell"
    
    private let disposeBag = DisposeBag()
    weak var delegate: ContentCellDelegate?

    var placeholder: String = ""
    
    let contentTextView = ExpandTextView().then {
        $0.textColor = .textSub02
        $0.backgroundColor = .clear
        $0.isScrollEnabled = false
        $0.text = "오늘 운동은 어땠나요? 느낀점을 작성해봐요"
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
    
    func configureCell(text: String) {
        self.contentTextView.text = text.isEmpty ? placeholder : text
        let color: UIColor = text.isEmpty ? .textSub02 : .textDefault
        contentTextView.textColor = color
    }
    
    private func textViewBinding() {
        contentTextView.rx.text
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.contentTextView.sizeToFit()
                self.contentTextView.canResign = false

                if self.contentView.frame.height != self.contentTextView.contentSize.height {
                    delegate?.changeContentFrame()
                }
                self.contentTextView.canResign = true
            })
            .disposed(by: disposeBag)
        
        contentTextView.rx.didBeginEditing
            .bind{
                if self.contentTextView.text == self.placeholder {
                    self.contentTextView.text = ""
                }
                self.contentTextView.textColor = .textDefault
            }.disposed(by: disposeBag)
        
        contentTextView.rx.didEndEditing
            .bind { [weak self] in
                guard let self = self else { return }
                
                if self.contentTextView.text.count == 0 {
                    self.contentTextView.text = self.placeholder
                    self.contentTextView.textColor = .textSub02
                }
                delegate?.changeContent(string: self.contentTextView.text)
            }.disposed(by: disposeBag)
    }
}
