//
//  CoinDetailView.swift
//  BitRise
//
//  Created by 권우석 on 3/11/25.
//

import UIKit
import SnapKit
import DGCharts

final class CoinDetailView: BaseView {
    //진짜 똥ㅇ
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    let headerView = UIView()
    let priceLabel = UILabel()
    let changePercentageLabel = UILabel()
    
    let chartView = LineChartView()
    let updateTimeLabel = UILabel()
    
    let stockInfoContainerView = UIView()
    let stockInfoTitleLabel = UILabel()
    let stockInfoMoreButton = UIButton()
    
    let high24hKeyLabel = UILabel()
    let high24hValueLabel = UILabel()
    
    let low24hKeyLabel = UILabel()
    let low24hValueLabel = UILabel()
    
    let athKeyLabel = UILabel()
    let athValueLabel = UILabel()
    let athDate = UILabel()
    
    let atlKeyLabel = UILabel()
    let atlValueLabel = UILabel()
    let atlDate = UILabel()
    
    let indicatorContainerView = UIView()
    let indicatorTitleLabel = UILabel()
    let indicatorMoreButton = UIButton()
    
    let marketCapKeyLabel = UILabel()
    let marketCapValueLabel = UILabel()
    
    let fdvKeyLabel = UILabel()
    let fdvValueLabel = UILabel()
    
    let totalVolumeKeyLabel = UILabel()
    let totalVolumeValueLabel = UILabel()
    
    let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    override func configureHierarchy() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [headerView, chartView, updateTimeLabel,
         stockInfoContainerView,
         indicatorContainerView,
         loadingIndicator].forEach {
            contentView.addSubview($0)
        }
        
        [priceLabel, changePercentageLabel].forEach {
            headerView.addSubview($0)
        }
        
        stockInfoContainerView.addSubview(stockInfoTitleLabel)
        stockInfoContainerView.addSubview(stockInfoMoreButton)
        
        [high24hKeyLabel, high24hValueLabel,
         low24hKeyLabel, low24hValueLabel,
         athKeyLabel, athValueLabel, athDate,
         atlKeyLabel, atlValueLabel, atlDate].forEach {
            stockInfoContainerView.addSubview($0)
        }
        
        indicatorContainerView.addSubview(indicatorTitleLabel)
        indicatorContainerView.addSubview(indicatorMoreButton)
        
        [marketCapKeyLabel, marketCapValueLabel,
         fdvKeyLabel, fdvValueLabel,
         totalVolumeKeyLabel, totalVolumeValueLabel].forEach {
            indicatorContainerView.addSubview($0)
        }
    }
    
    override func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
            make.bottom.equalToSuperview()
        }
        
        // 헤더 레이아웃
        headerView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(80)
        }
        
        priceLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        changePercentageLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview()
        }
        
        // 차트 레이아웃
        chartView.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
        }
        
        // 업데이트 시간 레이아웃
        updateTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(chartView.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
        }
        
        // 종목정보 컨테이너 레이아웃
        stockInfoContainerView.snp.makeConstraints { make in
            make.top.equalTo(updateTimeLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(200)
        }
        
        // 종목정보 타이틀
        stockInfoTitleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.height.equalTo(44)
        }
        
        stockInfoMoreButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(stockInfoTitleLabel)
        }
        
        // 24시간 고가
        high24hKeyLabel.snp.makeConstraints { make in
            make.top.equalTo(stockInfoTitleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(30)
        }
        
        high24hValueLabel.snp.makeConstraints { make in
            make.top.equalTo(high24hKeyLabel.snp.bottom)
            make.leading.equalToSuperview().offset(30)
        }
        
        // 24시간 저가
        low24hKeyLabel.snp.makeConstraints { make in
            make.top.equalTo(stockInfoTitleLabel.snp.bottom).offset(8)
            make.trailing.equalToSuperview().offset(-70)
        }
        
        low24hValueLabel.snp.makeConstraints { make in
            make.top.equalTo(low24hKeyLabel.snp.bottom)
            make.trailing.equalToSuperview().offset(-70)
        }
        // MARK: - -=------------------------------------------
        // 역대 최고가
        athKeyLabel.snp.makeConstraints { make in
            make.top.equalTo(low24hValueLabel.snp.bottom).offset(16)
            make.leading.equalToSuperview().offset(30)
        }
        
        athValueLabel.snp.makeConstraints { make in
            make.top.equalTo(athKeyLabel.snp.bottom)
            make.leading.equalToSuperview().offset(30)
        }
        
        athDate.snp.makeConstraints { make in
            make.top.equalTo(athValueLabel.snp.bottom).offset(2)
            make.leading.equalToSuperview().offset(30)
        }
        // MARK: - -=------------------------------------------
        // 역대 최저가
        atlKeyLabel.snp.makeConstraints { make in
            make.top.equalTo(low24hValueLabel.snp.bottom).offset(16)
            make.trailing.equalToSuperview().offset(-70)
            
        }
        
        atlValueLabel.snp.makeConstraints { make in
            make.top.equalTo(atlKeyLabel.snp.bottom)
            make.trailing.equalToSuperview().offset(-70)
        }
        
        atlDate.snp.makeConstraints { make in
            make.top.equalTo(atlValueLabel.snp.bottom).offset(2)
            make.trailing.equalToSuperview().offset(-70)
        }
        // MARK: - -=------------------------------------------
        // 투자지표 컨테이너 레이아웃
        indicatorContainerView.snp.makeConstraints { make in
            make.top.equalTo(stockInfoContainerView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        // 투자지표 타이틀
        indicatorTitleLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(16)
            make.height.equalTo(44)
        }
        
        indicatorMoreButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().offset(-16)
            make.centerY.equalTo(indicatorTitleLabel)
        }
        
        // 시가총액
        marketCapKeyLabel.snp.makeConstraints { make in
            make.top.equalTo(indicatorTitleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(30)
        }
        
        marketCapValueLabel.snp.makeConstraints { make in
            make.top.equalTo(marketCapKeyLabel.snp.bottom)
            make.leading.equalToSuperview().offset(30)
        }
        
        // 완전 희석 가치
        fdvKeyLabel.snp.makeConstraints { make in
            make.top.equalTo(marketCapValueLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(30)
        }
        
        fdvValueLabel.snp.makeConstraints { make in
            make.top.equalTo(fdvKeyLabel.snp.bottom)
            make.leading.equalToSuperview().offset(30)
        }
        
        // 총 거래량
        totalVolumeKeyLabel.snp.makeConstraints { make in
            make.top.equalTo(fdvValueLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(30)
            make.bottom.equalTo(indicatorContainerView.snp.bottom).offset(-16)
        }
        
        totalVolumeValueLabel.snp.makeConstraints { make in
            make.top.equalTo(totalVolumeKeyLabel.snp.bottom)
            make.leading.equalToSuperview().offset(30)
        }
    }
    
    override func configureView() {
        backgroundColor = .white
        scrollView.showsVerticalScrollIndicator = false
        
        priceLabel.font = .systemFont(ofSize: 28, weight: .bold)
        priceLabel.textColor = .black
        
        changePercentageLabel.font = .systemFont(ofSize: 16)
        
        chartView.legend.enabled = false
        chartView.rightAxis.enabled = false
        chartView.xAxis.enabled = false
        chartView.leftAxis.enabled = false
        
        updateTimeLabel.font = .systemFont(ofSize: 12)
        updateTimeLabel.textColor = .lightGray
        
        stockInfoTitleLabel.text = "종목정보"
        stockInfoTitleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        
        stockInfoMoreButton.setTitle("더보기 >", for: .normal)
        stockInfoMoreButton.setTitleColor(.brGray, for: .normal)
        stockInfoMoreButton.titleLabel?.font = .systemFont(ofSize: 14)
        
        [high24hKeyLabel, low24hKeyLabel, athKeyLabel, atlKeyLabel].forEach { label in
            label.font = Constants.Font.regular_12
            label.textColor = .brGray
        }
        
        [high24hValueLabel, low24hValueLabel, athValueLabel, atlValueLabel].forEach { label in
            label.font = Constants.Font.bold_12
            label.textColor = .brBlack
        }
        
        indicatorTitleLabel.text = "투자지표"
        indicatorTitleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        
        indicatorMoreButton.setTitle("더보기 >", for: .normal)
        indicatorMoreButton.setTitleColor(.brGray, for: .normal)
        indicatorMoreButton.titleLabel?.font = .systemFont(ofSize: 14)
        
        [marketCapKeyLabel, fdvKeyLabel, totalVolumeKeyLabel].forEach { label in
            label.font =  Constants.Font.regular_12
            label.textColor = .brGray
        }
        
        [marketCapValueLabel, fdvValueLabel, totalVolumeValueLabel].forEach { label in
            label.font = Constants.Font.bold_12
            label.textColor = .brBlack
        }
      
        
        
        
        high24hKeyLabel.text = "24시간 고가"
        low24hKeyLabel.text = "24시간 저가"
        athKeyLabel.text = "역대 최고가"
        atlKeyLabel.text = "역대 최저가"
        
        marketCapKeyLabel.text = "시가총액"
        fdvKeyLabel.text = "완전 희석 가치(FDV)"
        totalVolumeKeyLabel.text = "총 거래량"
        
        atlDate.font = Constants.Font.regular_9
        athDate.font = Constants.Font.regular_9
        
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = .gray
    }
    
    func configureChart(with prices: [Double]) {
        var entries = [ChartDataEntry]()
            
            for (index, price) in prices.enumerated() {
                let entry = ChartDataEntry(x: Double(index), y: price)
                entries.append(entry)
            }
            
            let dataSet = LineChartDataSet(entries: entries, label: "")
            dataSet.drawCirclesEnabled = false
            dataSet.lineWidth = 2
            dataSet.setColor(.systemBlue)
            
            
            let gradientColors = [
                UIColor.systemBlue.withAlphaComponent(0.6).cgColor,
                UIColor.systemBlue.withAlphaComponent(0.1).cgColor
            ]
            let gradient = CGGradient(colorsSpace: nil, colors: gradientColors as CFArray, locations: [1.0, 0.0])!
            
            dataSet.fillAlpha = 1
            dataSet.fill = LinearGradientFill(gradient: gradient, angle: 90)
            dataSet.drawFilledEnabled = true
            
            dataSet.drawValuesEnabled = false
            dataSet.mode = .cubicBezier
            
            let data = LineChartData(dataSet: dataSet)
            chartView.data = data
            
            chartView.highlightPerTapEnabled = false
            chartView.highlightPerDragEnabled = false
            chartView.setScaleEnabled(false)
            chartView.pinchZoomEnabled = false
            
            
            chartView.animate(xAxisDuration: 1.0)
    }
    
    func showLoading(_ isLoading: Bool) {
        if isLoading {
            loadingIndicator.startAnimating()
            scrollView.isHidden = true
        } else {
            loadingIndicator.stopAnimating()
            scrollView.isHidden = false
        }
    }
}

