//
//  TrendingCoinCell.swift
//  BitRise
//
//  Created by 권우석 on 3/10/25.
//

import UIKit
import Kingfisher
import SnapKit

final class TrendingCoinCell: BaseCollectionViewCell {
    
    static let identifier = "TrendingCoinCell"
    
    private let rankLabel = UILabel()
    private let coinImageView = UIImageView()
    private let symbolNameStackView = UIStackView()
    private let symbolLabel = UILabel()
    private let nameLabel = UILabel()
    private let percentageLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func configureHierarchy() {
        [rankLabel, coinImageView, symbolNameStackView, percentageLabel].forEach {
            contentView.addSubview($0)
        }
        
        [symbolLabel, nameLabel].forEach {
            symbolNameStackView.addArrangedSubview($0)
        }
    }
    
    override func configureLayout() {
        rankLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
            make.width.equalTo(20)
        }
        
        coinImageView.snp.makeConstraints { make in
            make.leading.equalTo(rankLabel.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(26)
        }
        
        symbolNameStackView.snp.makeConstraints { make in
            make.leading.equalTo(coinImageView.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
            make.width.lessThanOrEqualTo(contentView.snp.width).multipliedBy(0.5)
        }
        
        percentageLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
        }
    }
    
    override func configureView() {
        rankLabel.font = Constants.Font.regular_12 // check
        rankLabel.textColor = .brBlack
        rankLabel.textAlignment = .center
        
        coinImageView.contentMode = .scaleAspectFit
        coinImageView.clipsToBounds = true
        coinImageView.layer.cornerRadius = 13  // check -> 26 * 26
        
        symbolNameStackView.axis = .vertical
        symbolNameStackView.spacing = 2
        symbolNameStackView.alignment = .leading
        
        symbolLabel.font = Constants.Font.bold_12  // check
        symbolLabel.textColor = .brBlack
        symbolLabel.lineBreakMode = .byTruncatingTail
        
        nameLabel.font = Constants.Font.regular_9  // check
        nameLabel.textColor = .darkGray
        nameLabel.lineBreakMode = .byTruncatingTail
        
        percentageLabel.font = Constants.Font.bold_9  // check
    }
    
    func configure(coin: TrendingCoin, rank: Int, priceChangePercentage: Double) {
        rankLabel.text = "\(rank)"
        symbolLabel.text = coin.symbol.uppercased()
        nameLabel.text = coin.name
        
        // 이미지 로드
        if let url = URL(string: coin.thumb) {
            coinImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "questionmark.circle"))
        } else {
            coinImageView.image = UIImage(systemName: "questionmark.circle")
        }
        
        configurePercentage(priceChangePercentage)
    }
    
    private func configurePercentage(_ percentage: Double) {
        let formattedPercentage = NumberFormatterUtil.formatPercentage(percentage)
        
        if percentage > 0 {
            // 상승
            percentageLabel.text = "▲ \(formattedPercentage)%"
            percentageLabel.textColor = .brRed
        } else if percentage < 0 {
            // 하락
            percentageLabel.text = "▼ \(formattedPercentage)%"
            percentageLabel.textColor = .brBlue
        } else {
            // 변동 없음
            percentageLabel.text = "\(formattedPercentage)%"
            percentageLabel.textColor = .brBlack
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        rankLabel.text = nil
        symbolLabel.text = nil
        nameLabel.text = nil
        percentageLabel.text = nil
        coinImageView.image = nil
    }
}
