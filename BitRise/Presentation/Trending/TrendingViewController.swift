//
//  TrendingViewController.swift
//  BitRise
//
//  Created by 권우석 on 3/9/25.
//

import UIKit
import RxSwift
import RxCocoa

final class TrendingViewController: BaseViewController {
    
    private let mainView = TrendingView()
    private let viewModel = TrendingViewModel()
    private let disposeBag = DisposeBag()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupCollectionViews()
        mainView.headerView.setupTapGesture(in: self)
    }

    private func setupNavigationBar() {
        let naviLabel = UILabel()
        naviLabel.text = "가상자산 / 심볼 검색"
        naviLabel.font = .systemFont(ofSize: 18, weight: .heavy)
        naviLabel.textColor = .brBlack
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: naviLabel)
        navigationItem.title = ""
    }
    
    private func setupCollectionViews() {

        mainView.coinsCollectionView.dataSource = self
        mainView.coinsCollectionView.delegate = self
        
        mainView.nftsCollectionView.dataSource = self
        mainView.nftsCollectionView.delegate = self
    }
    
    override func bind() {
        let viewDidLoadTrigger = Observable.just(())
        let viewWillAppearTrigger = Observable.just(())
        
        let searchBarReturnKey = mainView.headerView.searchBar.rx.searchButtonClicked
            .withLatestFrom(mainView.headerView.searchBar.rx.text.orEmpty) // nil제거해서 보내기
        
        let input = TrendingViewModel.Input(
            viewDidLoad: viewDidLoadTrigger,
            viewWillAppear: viewWillAppearTrigger,
            searchBarReturnKey: searchBarReturnKey
        )
        
        let output = viewModel.transform(input: input)
        
        output.trendingCoins
            .drive(onNext: { [weak self] _ in
                self?.mainView.coinsCollectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        output.trendingNFTs
            .drive(onNext: { [weak self] _ in
                self?.mainView.nftsCollectionView.reloadData()
            })
            .disposed(by: disposeBag)
        
        output.timestamp
            .drive(onNext: { [weak self] timestamp in
                if let timestamp = timestamp {
                    self?.mainView.updateTimestamp(timestamp)
                }
            })
            .disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { [weak self] error in
                self?.showErrorAlert(with: error)
            })
            .disposed(by: disposeBag)
        
//        output.pushToSearchResult
//            .drive(onNext: { [weak self] query in
//                self?.navigateToSearchResult(with: query)
//                self?.mainView.headerView.searchBar.text = ""
//                self?.mainView.headerView.searchBar.resignFirstResponder()
//            })
//            .disposed(by: disposeBag)
    }
    
//    private func navigateToSearchResult(with query: String) {
//        // 검색 결과 화면으로 이동하는 로직 (추후 구현)
//        print("검색어: \(query)")
//        // let searchResultVC = SearchResultViewController(query: query)
//        // navigationController?.pushViewController(searchResultVC, animated: true)
//    }
    
    private func showErrorAlert(with error: APIError) {
        let alert = UIAlertController(title: "오류", message: error.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}

extension TrendingViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == mainView.coinsCollectionView { // prefix로 잘라와서 그냥 넣긴하는데...이게 맞는가...
            return 14
        } else if collectionView == mainView.nftsCollectionView {
            return 7
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == mainView.coinsCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrendingCoinCell.identifier,
                for: indexPath) as? TrendingCoinCell else {
                return UICollectionViewCell()
            }
            
            let coins = viewModel.getCurrentTrendingCoins()
            if indexPath.item < coins.count {
                let coin = coins[indexPath.item]
                
                let priceChangePercentage = coin.data?.priceChangePercentage24h?.krw ?? 0
                cell.configure(coin: coin, rank: indexPath.item + 1, priceChangePercentage: priceChangePercentage)
            }
            
            return cell
        } else if collectionView == mainView.nftsCollectionView {
            
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: TrendingNFTCell.identifier,
                for: indexPath) as? TrendingNFTCell else {
                return UICollectionViewCell()
            }
            
            let nfts = viewModel.getCurrentTrendingNFTs()
            if indexPath.item < nfts.count {
                let nft = nfts[indexPath.item]

                let priceChangePercentage = Double(nft.data?.floorPriceInUsd24hPercentageChange ?? "0") ?? 0.0
                cell.configure(nft: nft, priceChangePercentage: priceChangePercentage)
            }
            
            return cell
        }
        
        return UICollectionViewCell()
    }
}

extension TrendingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == mainView.coinsCollectionView {
            
            let coins = viewModel.getCurrentTrendingCoins()
            if indexPath.item < coins.count {
                let selectedCoin = coins[indexPath.item]
                print("선택된 코인: \(selectedCoin.name)")
                // 코인 상세 화면으로 이동 (추후 구현)
                // let detailVC = CoinDetailViewController(coinId: selectedCoin.id)
                // navigationController?.pushViewController(detailVC, animated: true)
            }
        } else if collectionView == mainView.nftsCollectionView {
            return
        }
    }
}
