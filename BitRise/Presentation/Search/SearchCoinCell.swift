//
//  SearchCoinCell.swift
//  BitRise
//
//  Created by 권우석 on 3/11/25.
//

import UIKit
import SnapKit
import Kingfisher

final class SearchCoinCell: BaseTableViewCell {
    
    static let identifier = "SearchCoinCell"
    
    private let coinImageView = UIImageView()
    private let symbolLabel = UILabel()
    private let nameLabel = UILabel()
    private let rankLabel = UILabel()
    private let favoriteButton = UIButton()
    
    var onFavoriteToggle: (() -> Void)?
    
    override func configureHierarchy() {
        [coinImageView, symbolLabel, nameLabel, rankLabel, favoriteButton].forEach {
            contentView.addSubview($0)
        }
    }
    
    override func configureLayout() {
        coinImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(36)
        }
        
        symbolLabel.snp.makeConstraints { make in
            make.leading.equalTo(coinImageView.snp.trailing).offset(12)
            make.top.equalTo(coinImageView).offset(2)
        }
        
        rankLabel.snp.makeConstraints { make in
            make.leading.equalTo(symbolLabel.snp.trailing).offset(8)
            make.centerY.equalTo(symbolLabel)
            make.height.equalTo(22)
            
        }
        
        nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(symbolLabel)
            make.top.equalTo(symbolLabel.snp.bottom).offset(4)
            make.trailing.lessThanOrEqualTo(favoriteButton.snp.leading).offset(-8)
        }
        
        favoriteButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(24)
        }
    }
    
    override func configureView() {
        coinImageView.contentMode = .scaleAspectFit
        coinImageView.layer.cornerRadius = 18 // check 36 * 36
        coinImageView.clipsToBounds = true
        
        symbolLabel.font = .systemFont(ofSize: 14, weight: .bold) //제한없음
        symbolLabel.textColor = .brBlack
        
        nameLabel.font = Constants.Font.regular_12 // check
        nameLabel.textColor = .gray
        nameLabel.lineBreakMode = .byTruncatingTail
        
        rankLabel.font = Constants.Font.bold_9 // check
        rankLabel.layer.cornerRadius = 5
        rankLabel.clipsToBounds = true
        
        rankLabel.backgroundColor = .brWhite
        rankLabel.layoutMargins = UIEdgeInsets(top: 2, left: 8, bottom: 2, right: 8)
        rankLabel.textAlignment = .center
        
        
        
        favoriteButton.addTarget(self, action: #selector(favoriteButtonTapped), for: .touchUpInside)
    }
    
    func configure(with coin: SearchCoin, isFavorite: Bool) {
        symbolLabel.text = coin.symbol.uppercased()
        nameLabel.text = coin.name
        
        if let rank = coin.marketCapRank {
            rankLabel.text = "#\(rank)"
            rankLabel.sizeToFit()
            rankLabel.frame.size.width += 16
            rankLabel.frame.size.height += 8
        } else {
            rankLabel.text = "#--"
        }
        
        if let url = URL(string: coin.thumb) {
            coinImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "questionmark.circle"))
        } else {
            coinImageView.image = UIImage(systemName: "questionmark.circle")
        }
        
        updateFavoriteButton(isFavorite: isFavorite)
    }
    
    private func updateFavoriteButton(isFavorite: Bool) {
        let imageName = isFavorite ? Constants.Icon.starFill : Constants.Icon.star
        favoriteButton.setImage(UIImage(systemName: imageName), for: .normal)
        favoriteButton.tintColor = .brBlack
        
    }
    
    @objc private func favoriteButtonTapped() {
        onFavoriteToggle?()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        coinImageView.image = nil
        symbolLabel.text = nil
        nameLabel.text = nil
        rankLabel.text = nil
        onFavoriteToggle = nil
    }
}
