//
//  StandardNotificationAlertView.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/03.
//

import UIKit

final class StandardNotificationAlertView: UIStackView {
    private var delayedExecutionWorkItem: DispatchWorkItem?
    
    private let contentLabel = UILabel().then {
        $0.font = .pretendard(.labelLarge)
        $0.textColor = .white
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    
    init(_ content: String) {
        super.init(frame: .zero)
        self.addSubview(self.contentLabel)
        
        self.contentLabel.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview().inset(20)
        }
        
        self.contentLabel.text = content
        self.backgroundColor = .black.withAlphaComponent(0.75)
        self.layer.cornerRadius = 5
        
        delayedExecutionWorkItem?.cancel()
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.removeFromSuperview()
        }
        
        // 5초 후에 클로저를 실행
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: workItem)
        
        // 현재 작업 항목을 저장 ( 추후 슈퍼뷰 탭 이벤트시 취소 기능 추가 가능성 )
        self.delayedExecutionWorkItem = workItem
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
