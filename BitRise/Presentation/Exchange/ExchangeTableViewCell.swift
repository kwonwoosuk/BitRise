//
//  ExchangeTableViewCell.swift
//  BitRise
//
//  Created by 권우석 on 3/8/25.
//

import UIKit
import SnapKit

final class ExchangeTableViewCell: BaseTableViewCell {
    
    static let identifier = "ExchangeTableViewCell"
    
    private let coinNameLabel = UILabel()
    private let currentPriceLabel = UILabel()
    private let changeRateStackView = UIStackView()
    private let changeRateLabel = UILabel()
    private let changePriceLabel = UILabel()
    private let tradePriceLabel = UILabel()
    
    private let priceBackgroundView = UIView()
    private let changeBackgroundView = UIView()
    
    override func configureHierarchy() {
        [priceBackgroundView, changeBackgroundView, coinNameLabel, currentPriceLabel,
         changeRateStackView, tradePriceLabel].forEach {
            contentView.addSubview($0)
        }
        
        [changeRateLabel, changePriceLabel].forEach {
            changeRateStackView.addArrangedSubview($0)
        }
    }
    
    override func configureLayout() {
        coinNameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.width.equalToSuperview().multipliedBy(0.25)
        }
        
        currentPriceLabel.snp.makeConstraints { make in
            make.top.equalTo(coinNameLabel)
            make.leading.equalTo(coinNameLabel.snp.trailing)
            make.width.equalToSuperview().multipliedBy(0.2)
        }
        
        changeRateStackView.snp.makeConstraints { make in
            make.top.equalTo(coinNameLabel)
            make.leading.equalTo(currentPriceLabel.snp.trailing)
            make.width.equalToSuperview().multipliedBy(0.25)
        }
        
        tradePriceLabel.snp.makeConstraints { make in
            make.top.equalTo(coinNameLabel)
            make.leading.equalTo(changeRateStackView.snp.trailing)
            make.trailing.equalToSuperview().offset(-16)
        }
     
        
        changeBackgroundView.snp.makeConstraints { make in
            make.edges.equalTo(changeRateStackView).inset(-4)
        }
    }
    
    override func configureView() {
        coinNameLabel.font = Constants.Font.bold_12
        coinNameLabel.textColor = .brBlack
        
        currentPriceLabel.font = Constants.Font.regular_12
        currentPriceLabel.textColor = .brBlack
        currentPriceLabel.textAlignment = .right
        
        changeRateStackView.axis = .vertical
        changeRateStackView.distribution = .fillEqually
        changeRateStackView.spacing = 2
        changeRateStackView.alignment = .trailing
        
        changeRateLabel.font = Constants.Font.regular_12
        changeRateLabel.textAlignment = .right
        
        changePriceLabel.font = Constants.Font.regular_9
        changePriceLabel.textAlignment = .right
        
        tradePriceLabel.font = Constants.Font.regular_12
        tradePriceLabel.textColor = .brBlack
        tradePriceLabel.textAlignment = .right
        
        // 배경뷰 설정
        priceBackgroundView.layer.cornerRadius = 4
        priceBackgroundView.alpha = 0
        
        changeBackgroundView.layer.cornerRadius = 4
        changeBackgroundView.alpha = 0
    }
    
    func configure(with ticker: UpbitTicker, animated: Bool = false) {
        // 코인명 (KRW-BTC -> BTC/KRW)
        let marketComponents = ticker.market.split(separator: "-")
        if marketComponents.count == 2 {
            coinNameLabel.text = "\(marketComponents[1])/\(marketComponents[0])"
        } else {
            coinNameLabel.text = ticker.market
        }
        
        // 현재가
        currentPriceLabel.text = formatPrice(ticker.tradePrice)
        
        // 변동률, 변동가격
        changeRateLabel.text = formatPercentage(ticker.signedChangeRate)
        changePriceLabel.text = formatChangePrice(ticker.signedChangePrice)
        
        // 거래대금
        tradePriceLabel.text = formatTradePrice(ticker.accTradePrice)
        
        // 색상 설정
        setChangeColor(change: ticker.change)
        
        // 애니메이션 (실시간 업데이트시에만)
        if animated {
            showPriceAnimation(change: ticker.change)
        }
    }
    
    private func showPriceAnimation(change: String) {
        let color: UIColor
        
        switch change {
        case "RISE":
            color = .brRed
        case "FALL":
            color = .brBlue
        default:
            return
        }
        
        // 현재가 애니메이션
        priceBackgroundView.backgroundColor = color.withAlphaComponent(0.3)
        UIView.animate(withDuration: 0.1, animations: {
            self.priceBackgroundView.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 0.8, delay: 0.1, options: .curveEaseOut, animations: {
                self.priceBackgroundView.alpha = 0
            })
        }
        
        // 변동률 애니메이션
        changeBackgroundView.backgroundColor = color.withAlphaComponent(0.2)
        UIView.animate(withDuration: 0.15, animations: {
            self.changeBackgroundView.alpha = 1.0
        }) { _ in
            UIView.animate(withDuration: 1.0, delay: 0.2, options: .curveEaseOut, animations: {
                self.changeBackgroundView.alpha = 0
            })
        }
    }
    
    private func formatPrice(_ price: Double) -> String {
        if abs(price) >= 1000 && price.truncatingRemainder(dividingBy: 1) == 0 {
            return Int(price).formatted()
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 1
        
        return formatter.string(from: NSNumber(value: price)) ?? "0"
    }
    
    private func formatPercentage(_ rate: Double) -> String {
        let percentage = rate * 100
        return String(format: "%.2f%%", percentage)
    }
    
    private func formatChangePrice(_ price: Double) -> String {
        if price == 0 {
            return "0"
        }
        
        let roundedPrice = round(price * 100) / 100
        
        if roundedPrice.truncatingRemainder(dividingBy: 1) == 0 {
            return Int(roundedPrice).formatted()
        } else {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 2
            
            return formatter.string(from: NSNumber(value: roundedPrice)) ?? "0"
        }
    }
    
    private func formatTradePrice(_ price: Double) -> String {
        if price >= 1_000_000 {
            let millions = Int(price / 1_000_000).formatted()
            return "\(millions)백만"
        } else {
            return Int(price).formatted()
        }
    }
    
    private func setChangeColor(change: String) {
        let textColor: UIColor
        
        switch change {
        case "RISE":
            textColor = .brRed
        case "FALL":
            textColor = .brBlue
        default:
            textColor = .brBlack
        }
        
        changeRateLabel.textColor = textColor
        changePriceLabel.textColor = textColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        coinNameLabel.text = nil
        currentPriceLabel.text = nil
        changeRateLabel.text = nil
        changePriceLabel.text = nil
        tradePriceLabel.text = nil
        
        priceBackgroundView.alpha = 0
        changeBackgroundView.alpha = 0
    }
}
