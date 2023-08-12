//
//  TitleCell.swift
//  FitHub
//
//  Created by iOS신상우 on 2023/08/11.
//

import UIKit
import RxSwift
import RxCocoa

protocol TitleCellDelegate: AnyObject {
    func changeTitleFrame()
    func changeTitle(string: String)
}

final class TitleCell: UICollectionViewCell {
    static let identifier = "TitleCell"
    
    private let disposeBag = DisposeBag()
    weak var delegate: TitleCellDelegate?
    
    let titleTextView = ExpandTextView().then {
        $0.textColor = .textInfo
        $0.backgroundColor = .clear
        $0.isScrollEnabled = false
        $0.text = "제목을 입력해주세요."
        $0.font = .pretendard(.titleMedium)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentView.addSubview(titleTextView)
        
        self.titleTextView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        self.textViewBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(text: String) {
        self.titleTextView.text = text
    }
    
    private func textViewBinding() {
        titleTextView.rx.text
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.titleTextView.sizeToFit()
                self.titleTextView.canResign = false
                if self.contentView.frame.height != self.titleTextView.contentSize.height {
                    self.delegate?.changeTitleFrame()
                }
                self.titleTextView.canResign = true
            })
            .disposed(by: disposeBag)
        
        titleTextView.rx.didBeginEditing
            .bind{
                if self.titleTextView.text == "제목을 입력해주세요." {
                    self.titleTextView.text = ""
                }
                self.titleTextView.textColor = .textDefault
            }.disposed(by: disposeBag)
        
        titleTextView.rx.didEndEditing
            .bind { [weak self] in
                guard let self = self else { return }
                
                if self.titleTextView.text.count == 0 {
                    self.titleTextView.text = "제목을 입력해주세요."
                    self.titleTextView.textColor = .textSub02
                }
                self.delegate?.changeTitle(string: self.titleTextView.text)
            }.disposed(by: disposeBag)
    }
}
