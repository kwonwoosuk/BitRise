//
//  ThirdEmptyViewController.swift
//  BitRise
//
//  Created by 권우석 on 3/9/25.
//

import UIKit
import SnapKit

final class ThirdEmptyViewController: BaseViewController {
    
    
    private let messageLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureHierarchy() {
        view.addSubview(messageLabel)
    }
    
    override func configureLayout() {
        messageLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
    
    override func configureView() {
        view.backgroundColor = .brWhite
        
        messageLabel.text = "이 탭은 개발 중입니다."
              
        
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.textColor = .gray
        messageLabel.textAlignment = .center
    }
    
    
}
