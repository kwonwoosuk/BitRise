//
//  CoinDetailViewController.swift
//  BitRise
//
//  Created by 권우석 on 3/10/25.
//


import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Kingfisher

final class CoinDetailViewController: BaseViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleNaviView = UIView()
    private let titleNaviImageView = UIImageView()
    private let titleNaviLabel = UILabel()
    
    private let infoView = UIView()
    private let placeholderLabel = UILabel()
    
    private let viewModel = SearchViewModel()
    private let disposeBag = DisposeBag()
    
    private var coinId: String = ""
    private var coinName: String = ""
    private var coinSymbol: String = ""
    private var coinThumb: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
    }
    
    func configure(with coin: SearchCoin) {
        self.coinId = coin.id
        self.coinName = coin.name
        self.coinSymbol = coin.symbol
        self.coinThumb = coin.thumb
        
        if isViewLoaded {
            updateUI()
        }
    }
    
    private func updateUI() {
        titleNaviLabel.text = coinSymbol.uppercased()
        
        if let url = URL(string: coinThumb) {
            titleNaviImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "questionmark.circle"))
        } else {
            titleNaviImageView.image = UIImage(systemName: "questionmark.circle")
        }
        updateFavoriteButton()
    }
    
    private func setupNavigationBar() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: Constants.Icon.arrowLeft),
                                         style: .plain,
                                         target: self,
                                         action: #selector(backButtonTapped))
        backButton.tintColor = .brBlack
        navigationItem.leftBarButtonItem = backButton
        
        let favoriteButton = UIBarButtonItem(image: UIImage(systemName: Constants.Icon.star),
                                             style: .plain,
                                             target: self,
                                             action: #selector(favoriteButtonTapped))
        favoriteButton.tintColor = .brBlack
        navigationItem.rightBarButtonItem = favoriteButton
        
        setupTitleView()
    }
    
    private func setupTitleView() {
        titleNaviView.frame = CGRect(x: 0, y: 0, width: 120, height: 40)
        
        titleNaviImageView.frame = CGRect(x: 10, y: 7, width: 26, height: 26)
        titleNaviImageView.contentMode = .scaleAspectFit
        titleNaviImageView.clipsToBounds = true
        titleNaviImageView.layer.cornerRadius = 13
        
        titleNaviLabel.frame = CGRect(x: 40, y: 10, width: 80, height: 20)
        titleNaviLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleNaviLabel.textColor = .brBlack
        
        titleNaviView.addSubview(titleNaviImageView)
        titleNaviView.addSubview(titleNaviLabel)
        
        navigationItem.titleView = titleNaviView
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    override func configureHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
    
    }
    
    override func configureLayout() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(view)
        }
    }
    
    override func configureView() {
        view.backgroundColor = .white
        scrollView.showsVerticalScrollIndicator = false
    
        updateUI()
    }

    private func updateFavoriteButton() {
        let isFavorite = FavoriteManager.shared.isFavorite(coinId: coinId)
        let imageName = isFavorite ? Constants.Icon.starFill : Constants.Icon.star
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: imageName)
        navigationItem.rightBarButtonItem?.tintColor = .brBlack
    }
    
    @objc private func favoriteButtonTapped() {
        let isAdded = FavoriteManager.shared.toggleFavorite(
            coinId: coinId,
            name: coinName
        )
        
        updateFavoriteButton()
        let message = isAdded ?
            "\(coinName)이 즐겨찾기 되었습니다" :
            "\(coinName)이 즐겨찾기에서 제거 되었습니다"
    
        showToast(message: message)
    }
    
    override func bind() {
        FavoriteManager.shared.favoritesChanged
            .subscribe(onNext: { [weak self] in
                self?.updateFavoriteButton()
            })
            .disposed(by: disposeBag)
    }
}
