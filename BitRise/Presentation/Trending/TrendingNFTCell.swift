//
//  TrendingNFTCell.swift
//  BitRise
//
//  Created by 권우석 on 3/10/25.
//

import UIKit
import Kingfisher
import SnapKit

final class TrendingNFTCell: BaseCollectionViewCell {
    
    static let identifier = "TrendingNFTCell"
    
    private let nftImageView = UIImageView()
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let percentageLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configuration
    override func configureHierarchy() {
        [nftImageView, nameLabel, priceLabel, percentageLabel].forEach {
            contentView.addSubview($0)
        }
    }
    
    override func configureLayout() {
        nftImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
            make.size.equalTo(80)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(nftImageView.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(4)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        
        percentageLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
            make.bottom.lessThanOrEqualToSuperview().offset(-8)
        }
    }
    
    override func configureView() {
        
        nftImageView.contentMode = .scaleAspectFit
        nftImageView.clipsToBounds = true
        nftImageView.layer.cornerRadius = 28
        
        nameLabel.font = Constants.Font.bold_9
        nameLabel.textColor = .brBlack
        nameLabel.textAlignment = .center
        nameLabel.lineBreakMode = .byTruncatingTail
        
        priceLabel.font = Constants.Font.regular_9
        priceLabel.textColor = .brGray
        priceLabel.textAlignment = .center
        
        percentageLabel.font = Constants.Font.bold_9
        percentageLabel.textAlignment = .center
    }
    
    // confugure Cell
    func configure(nft: TrendingNFT, priceChangePercentage: Double) {
        nameLabel.text = nft.name
        
        if let url = URL(string: nft.thumb) {
            nftImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "questionmark.circle"))
        } else {
            nftImageView.image = UIImage(systemName: "questionmark.circle")
        }
        
        if let floorPrice = nft.data?.floorPrice {
            priceLabel.text = floorPrice
        } else {
            priceLabel.text = "가격 정보 없음"
        }
        
        configurePercentage(priceChangePercentage)
    }
    
    private func configurePercentage(_ percentage: Double) {
        let formattedPercentage = NumberFormatterUtil.formatPercentage(percentage)
        
        if percentage > 0 { // 값이 오른경
            percentageLabel.text = "▲ \(formattedPercentage)%"
            percentageLabel.textColor = .brRed
        } else if percentage < 0 { // 값이 내린경우
            percentageLabel.text = "▼ \(formattedPercentage)%"
            percentageLabel.textColor = .brBlue
        } else { // 변동 없음
            percentageLabel.text = "\(formattedPercentage)%"
            percentageLabel.textColor = .brBlack
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        nameLabel.text = nil
        priceLabel.text = nil
        percentageLabel.text = nil
        nftImageView.image = nil
    }
}
