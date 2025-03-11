//
//  CoinDetailViewController.swift
//  BitRise
//
//  Created by 권우석 on 3/10/25.
//


import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class CoinDetailViewController: BaseViewController {
    
    private let mainView = CoinDetailView()
    private let viewModel = CoinDetailViewModel()
    private let disposeBag = DisposeBag()
    
    private var coinId: String = ""
    private var coinName: String = ""
    private var coinSymbol: String = ""
    
    private let favoriteButtonTappedRelay = PublishRelay<Void>()
    private let moreButtonTappedRelay = PublishRelay<Void>()
    private let viewWillAppearRelay = PublishRelay<Void>()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    func configure(with coin: SearchCoin) {
        self.coinId = coin.id
        self.coinName = coin.name
        self.coinSymbol = coin.symbol.uppercased()
        
        setupNavigationTitle(symbol: coin.symbol.uppercased(), imageUrl: coin.thumb)
        
        viewModel.configure(coinId: coinId, coinName: coinName)
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: Constants.Icon.arrowLeft),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        navigationItem.leftBarButtonItem?.tintColor = .brBlack
        
        let favoriteButton = UIBarButtonItem(
            image: UIImage(systemName: Constants.Icon.star),
            style: .plain,
            target: self,
            action: #selector(favoriteButtonTapped)
        )
        favoriteButton.tintColor = .brBlack
        navigationItem.rightBarButtonItem = favoriteButton
    }
    
    private func setupNavigationTitle(symbol: String, imageUrl: String) {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        
        let coinImageView = UIImageView()
        coinImageView.contentMode = .scaleAspectFit
        coinImageView.clipsToBounds = true
        coinImageView.layer.cornerRadius = 12
        coinImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            coinImageView.widthAnchor.constraint(equalToConstant: 24),
            coinImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        let symbolLabel = UILabel()
        symbolLabel.text = symbol
        symbolLabel.font = .systemFont(ofSize: 18, weight: .bold)
        symbolLabel.textColor = .brBlack
        
        if let url = URL(string: imageUrl) {
            coinImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "questionmark.circle"))
        } else {
            coinImageView.image = UIImage(systemName: "questionmark.circle")
        }
        
        stackView.addArrangedSubview(coinImageView)
        stackView.addArrangedSubview(symbolLabel)
        
        navigationItem.titleView = stackView
    }
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func favoriteButtonTapped() {
        favoriteButtonTappedRelay.accept(())
    }
    
    @objc private func moreButtonTapped() {
        moreButtonTappedRelay.accept(())
    }
    
    override func bind() {
        let input = CoinDetailViewModel.Input(
            viewDidLoad: Observable.just(()),
            viewWillAppear: viewWillAppearRelay,
            favoriteButtonTapped: favoriteButtonTappedRelay,
            moreButtonTapped: moreButtonTappedRelay
        )
        
        let output = viewModel.transform(input: input)
        
        output.coinDetail
            .drive(onNext: { [weak self] coinDetail in
                guard let self = self, let coinDetail = coinDetail else { return }
                self.updateUI(with: coinDetail)
            })
            .disposed(by: disposeBag)
        
        output.isLoading
            .drive(onNext: { [weak self] isLoading in
                self?.mainView.showLoading(isLoading)
            })
            .disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { [weak self] error in
                self?.showErrorAlert(message: error.message)
            })
            .disposed(by: disposeBag)

        output.message
            .drive(onNext: { [weak self] message in
                self?.showToast(message: message)
            })
            .disposed(by: disposeBag)
        
        output.isFavorite
            .drive(onNext: { [weak self] isFavorite in
                let imageName = isFavorite ? Constants.Icon.starFill : Constants.Icon.star
                self?.navigationItem.rightBarButtonItem?.image = UIImage(systemName: imageName)
            })
            .disposed(by: disposeBag)
        
        mainView.stockInfoMoreButton.rx.tap
            .bind(to: moreButtonTappedRelay)
            .disposed(by: disposeBag)
        
        mainView.indicatorMoreButton.rx.tap
            .bind(to: moreButtonTappedRelay)
            .disposed(by: disposeBag)
    }
    
    
    
    private func updateUI(with coinDetail: CoinDetail) {
        mainView.priceLabel.text = "₩\(Int(coinDetail.currentPrice).formatted())"
            
            if let changePercentage = coinDetail.priceChangePercentage24h {
                let formattedPercentage = NumberFormatterUtil.formatPercentage(changePercentage)
                
                if changePercentage > 0 {
                    mainView.changePercentageLabel.text = "▲ \(formattedPercentage)%"
                    mainView.changePercentageLabel.textColor = .systemRed
                } else if changePercentage < 0 {
                    mainView.changePercentageLabel.text = "▼ \(formattedPercentage)%"
                    mainView.changePercentageLabel.textColor = .systemBlue
                } else {
                    mainView.changePercentageLabel.text = "\(formattedPercentage)%"
                    mainView.changePercentageLabel.textColor = .black
                }
            }
        
            if let sparklineData = coinDetail.sparklineIn7d?.price, !sparklineData.isEmpty {
                mainView.configureChart(with: sparklineData)
            }
            
            mainView.updateTimeLabel.text = Date().toFormattedUpdateString()
            
            mainView.high24hValueLabel.text = "₩\(Int(coinDetail.high24h ?? 0).formatted())"
            mainView.low24hValueLabel.text = "₩\(Int(coinDetail.low24h ?? 0).formatted())"
            
            if let ath = coinDetail.ath, let athDate = coinDetail.athDate {
                mainView.athValueLabel.text = "₩\(Int(ath).formatted())"
                mainView.athDate.text = "\(athDate.toFormattedDate())"
            }
            
            if let atl = coinDetail.atl, let atlDate = coinDetail.atlDate {
                mainView.atlValueLabel.text = "₩\(Int(atl).formatted())"
                mainView.atlDate.text = "\(atlDate.toFormattedDate())"
            }
            
            mainView.marketCapValueLabel.text = "₩\(Int(coinDetail.marketCap ?? 0).formatted())"
            mainView.fdvValueLabel.text = "₩\(Int(coinDetail.fullyDilutedValuation ?? 0).formatted())"
            mainView.totalVolumeValueLabel.text = "₩\(Int(coinDetail.totalVolume ?? 0).formatted())"
        }
}
