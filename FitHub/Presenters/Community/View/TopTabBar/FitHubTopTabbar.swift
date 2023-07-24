//
//  FitHubTopTabbar.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/20.
//

import UIKit
import RxSwift

final class FitHubTopTabbar: UIView {
    //MARK: - Properties
    private let disposeBag = DisposeBag()
    
    private let itemStackView: UIStackView
    
    private var lineLayer: CALayer?
    private var indicatorLayer: CALayer?
    
    //MARK: - Init
    init(_ items: [TopTabbarItem]) {
        items.enumerated().forEach { (i,v) in
            v.tag = i
        }
        itemStackView = UIStackView(arrangedSubviews: items).then {
            $0.distribution = .fillProportionally
        }
        super.init(frame: .zero)
        
        self.addSubView()
        self.layout()
        self.setupBinding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        if self.lineLayer == nil {
            _ = CALayer().then {
                $0.backgroundColor = UIColor.bgSub01.cgColor
                self.layer.addSublayer($0)
                self.lineLayer = $0
                $0.frame = CGRect(x: 0,
                                  y: self.frame.height,
                                  width: self.frame.width,
                                  height: 1)
            }
        }
        
        itemStackView.layoutIfNeeded()
        
        if self.indicatorLayer == nil {
            _ = CALayer().then {
                $0.backgroundColor = UIColor.iconDefault.cgColor
                self.layer.addSublayer($0)
                self.indicatorLayer = $0
                
                guard let item = self.itemStackView.subviews.first as? TopTabbarItem else { return }
                item.isSelected = true
                
                guard let x = item.titleLabel?.frame.origin.x,
                      let width = item.titleLabel?.frame.width else { return }
                
                $0.frame = CGRect(x: x,
                                  y: self.frame.height-0.5,
                                  width: width,
                                  height: 2)
            }
        }
    }
    
    //MARK: - Method
    private func selectedItem(_ index: Int) {
        let cnt = self.itemStackView.arrangedSubviews.count
        if index >= cnt && index < 0 { return }
        
        guard let indicatorLayer,
              let item = self.itemStackView.subviews[index] as? UIButton,
              let labelX = item.titleLabel?.frame.origin.x,
              let width = item.titleLabel?.frame.width else { return }
        
        let buttonX = item.frame.origin.x
        
        UIView.animate(withDuration: 1.0) {
            indicatorLayer.frame = CGRect(x: buttonX + labelX,
                                          y: self.frame.height-0.5,
                                          width: width,
                                          height: 2)
        }
        
        self.itemStackView.subviews.forEach {
            guard let item = $0 as? TopTabbarItem else { return }
            item.isSelected = false
        }

        item.isSelected = true
    }
    
    //MARK: - bind
    private func setupBinding() {
        self.itemStackView.subviews
            .compactMap { $0 as? UIButton }
            .forEach { item in
                item.rx.tap
                    .bind(onNext: { [weak self] in
                        self?.selectedItem(item.tag)
                    })
                    .disposed(by: disposeBag)
            }
    }
    
    //MARK: - addSubView
    private func addSubView() {
        self.addSubview(self.itemStackView)
    }
    
    //MARK: - Layout
    private func layout() {
        self.itemStackView.snp.makeConstraints {
            $0.leading.trailing.top.bottom.equalToSuperview()
        }
    }
}
