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
    
    override func configureHierarchy() {
        [coinNameLabel, currentPriceLabel, changeRateStackView, tradePriceLabel].forEach {
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
            make.width.equalToSuperview().multipliedBy(0.3)
        }
    }
    
    override func configureView() {
        // 코인
        coinNameLabel.font = Constants.Font.bold_12 // check
        coinNameLabel.textColor = .brBlack
        
        // 현재가
        currentPriceLabel.font = Constants.Font.regular_12 // check
        currentPriceLabel.textColor = .brBlack
        currentPriceLabel.textAlignment = .right
        
        // 스택
        changeRateStackView.axis = .vertical
        changeRateStackView.distribution = .fillEqually
        changeRateStackView.spacing = 2
        changeRateStackView.alignment = .trailing
        
        // 전일대비 상(가격변동률)
        changeRateLabel.font = Constants.Font.regular_12 // check
        changeRateLabel.textAlignment = .right
        
        // 전일대비 하(가격)
        changePriceLabel.font = Constants.Font.regular_9 // check
        changePriceLabel.textAlignment = .right
        
        // 거래대금
        tradePriceLabel.font = Constants.Font.regular_12 // check
        tradePriceLabel.textColor = .brBlack
        tradePriceLabel.textAlignment = .right
    }
    // cell.configure
    func configure(with ticker: UpbitTicker) {
        // 코인 이름 표시 (KRW-BTC -> BTC/KRW)
        let marketComponents = ticker.market.split(separator: "-")
        if marketComponents.count == 2 {
            coinNameLabel.text = "\(marketComponents[1])/\(marketComponents[0])"
        } else {
            coinNameLabel.text = ticker.market
        }
        
        // 현재가 표시
        currentPriceLabel.text = formatCurrentPrice(ticker.tradePrice)
        
        // 전일대비 변화율과 변화량 표시
        let changeRatePercent = formatPercentage(ticker.signedChangeRate)
        let changePrice = formatChangePrice(ticker.signedChangePrice)
        
        changeRateLabel.text = changeRatePercent
        changePriceLabel.text = changePrice
        
        // 거래대금 표시
        tradePriceLabel.text = formatTradePrice(ticker.accTradePrice)
        
        // 상승/하락/보합 색상 설정
        setChangeColor(change: ticker.change)
    }
    
    
    // 현재가 포맷팅 (tradePrice) // 거래소 화면에서만 쓰이는 포멧팅
    private func formatCurrentPrice(_ price: Double) -> String {
        // 정수부가 4자리 이상인 경우 정수 포맷팅 사용
        if abs(price) >= 1000 && price.truncatingRemainder(dividingBy: 1) == 0 {
            return Int(price).formatted()
        }
        
        // 정수부가 3자리 이하이면 소수점한자리까지 표시
        if price.truncatingRemainder(dividingBy: 1) == 0 {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 1
            formatter.maximumFractionDigits = 1
            return formatter.string(from: NSNumber(value: price)) ?? "0"
        } else {
            // 소수점이 있는 경우
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 1
            
            if (price * 10).truncatingRemainder(dividingBy: 1) == 0 {
                formatter.maximumFractionDigits = 1
            }
            
            return formatter.string(from: NSNumber(value: price)) ?? "0"
        }
    }
    
    // 변화율 포맷팅 (%) changeRatePercent
    private func formatPercentage(_ rate: Double) -> String { // 가격 변화율은 기본소수점 표기방식 2자리까지
        let percentage = rate * 100
        return String(format: "%.2f%%", percentage)
    }
    
    /// 변화량 포멧팅 소수둘떄
    private func formatChangePrice(_ price: Double) -> String {
        if price == 0 {
            return "0"
        }
        
        
        let roundedPrice = round(price * 100) / 100 // 3자리에서 반올림
        
        if roundedPrice.truncatingRemainder(dividingBy: 1) == 0 {
            
            return Int(roundedPrice).formatted()
        } else {
            // 소수점이 있는 경우
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 2
            
            return formatter.string(from: NSNumber(value: roundedPrice)) ?? "0"
        }
    }
    
    private func formatTradePrice(_ price: Double) -> String {
        // 백만 단위로 변환 (1,000,000 이상일 경우)
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
            textColor = .brRed // 상승
        case "FALL":
            textColor = .brBlue // 하락
            
        default: // "EVEN"
            textColor = .brBlack // 변동 없음
        }
        
        // 변화율과 변화량 텍스트 색상 설정
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
    }
}
