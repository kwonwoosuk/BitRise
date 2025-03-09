//
//  SortButton.swift
//  BitRise
//
//  Created by 권우석 on 3/9/25.
//

import UIKit
import SnapKit

class SortButton: UIButton {
    
    private let nameLabel = UILabel()
    private let upArrowImageView = UIImageView()
    private let downArrowImageView = UIImageView()
    private let arrowStackView = UIStackView()
    
    var sortOrder: SortOrder = .none {
        didSet {
            updateAppearance()
        }
    }
    
    init(title: String) {
        super.init(frame: .zero)
        
        nameLabel.text = title
        nameLabel.font = Constants.Font.bold_12
        nameLabel.textColor = .brBlack
        nameLabel.textAlignment = .right
        
        upArrowImageView.image = UIImage(systemName: Constants.Icon.arrowUp)
        upArrowImageView.tintColor = .lightGray
        upArrowImageView.contentMode = .scaleAspectFit
        upArrowImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 7, weight: .light)
        
        downArrowImageView.image = UIImage(systemName: Constants.Icon.arrowDown)
        downArrowImageView.tintColor = .lightGray
        downArrowImageView.contentMode = .scaleAspectFit
        downArrowImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 7, weight: .light)
        
        
        arrowStackView.axis = .vertical
        arrowStackView.spacing = -3
        arrowStackView.distribution = .fillEqually
        arrowStackView.alignment = .center
        
        
        addSubview(nameLabel)
        addSubview(arrowStackView)
        arrowStackView.addArrangedSubview(upArrowImageView)
        arrowStackView.addArrangedSubview(downArrowImageView)
        
        
        nameLabel.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.trailing.equalTo(arrowStackView.snp.leading)
        }
        
        arrowStackView.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.width.equalTo(14)
            make.height.equalTo(16)
        }
        updateAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateAppearance() {
        switch sortOrder {
        case .ascending:
            upArrowImageView.tintColor = .brBlack
            downArrowImageView.tintColor = .brGray
        case .descending:
            upArrowImageView.tintColor = .brGray
            downArrowImageView.tintColor = .brBlack
        case .none:
            upArrowImageView.tintColor = .brGray
            downArrowImageView.tintColor = .brGray
        }
    }
}
