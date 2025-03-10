//
//  SearchCoinViewController.swift
//  BitRise
//
//  Created by 권우석 on 3/11/25.
//

import UIKit
import RxSwift
import RxCocoa

final class SearchCoinViewController: BaseViewController {
    
    private let mainView = SearchCoinView()
    private let viewModel = SearchCoinViewModel()
    private let disposeBag = DisposeBag()
    
    private let coinSelectedRelay = PublishRelay<SearchCoin>()
    private let favoriteToggledRelay = PublishRelay<SearchCoin>()
    let searchQuerySubject = PublishSubject<String?>()
    
    override func loadView() {
        view = mainView
    }
    override func viewDidLoad() {
            super.viewDidLoad()
            setupToastView()
        }
    
    override func bind() {
        let searchQuery = searchQuerySubject
            .compactMap { $0 }
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
            .distinctUntilChanged()
            .share()
    
        let input = SearchCoinViewModel.Input(
            viewDidLoad: Observable.just(()),
            searchQuery: searchQuerySubject.asObservable(),
            coinCellSelected: coinSelectedRelay.asObservable(),
            favoriteToggled: favoriteToggledRelay.asObservable()
        )
        
        let output = viewModel.transform(input: input)

        output.coins
            .drive(mainView.tableView.rx.items(cellIdentifier: SearchCoinCell.identifier, cellType: SearchCoinCell.self)) { [weak self] _, coin, cell in
                guard let self = self else { return }
                
                let isFavorite = self.viewModel.isFavorite(coinId: coin.id)
                cell.configure(with: coin, isFavorite: isFavorite)
                
                cell.onFavoriteToggle = { [weak self] in
                    self?.favoriteToggledRelay.accept(coin)
                }
            }
            .disposed(by: disposeBag)
        
        output.isLoading
            .drive(onNext: { [weak self] isLoading in
                self?.mainView.showLoading(isLoading)
            })
            .disposed(by: disposeBag)
        
        output.coins
            .drive(onNext: { [weak self] coins in
                self?.mainView.showEmptyState("검색 결과가 없습니다.", show: coins.isEmpty)
            })
            .disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { [weak self] error in
                self?.showErrorAlert(message: error.message)
                self?.mainView.showEmptyState("검색 중 오류가 발생했습니다.", show: true)
            })
            .disposed(by: disposeBag)
        
        output.message
                    .drive(onNext: { [weak self] message in
                        self?.showToast(message: message)
                    })
                    .disposed(by: disposeBag)
        
        mainView.tableView.rx.modelSelected(SearchCoin.self)
            .subscribe(onNext: { [weak self] coin in
                self?.coinSelectedRelay.accept(coin)
                self?.navigateToCoinDetail(coin: coin)
            })
            .disposed(by: disposeBag)
        
    }
    
    private let toastView = UIView()
        private let toastLabel = UILabel()
        
        private func setupToastView() {
            toastView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
            toastView.layer.cornerRadius = 10
            toastView.clipsToBounds = true
            toastView.alpha = 0
            
            toastLabel.textColor = .white
            toastLabel.font = .systemFont(ofSize: 14)
            toastLabel.textAlignment = .center
            toastLabel.numberOfLines = 0
            
            view.addSubview(toastView)
            toastView.addSubview(toastLabel)
            
            toastView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(-100)
                make.width.lessThanOrEqualToSuperview().offset(-40)
            }
            
            toastLabel.snp.makeConstraints { make in
                make.edges.equalToSuperview().inset(12)
            }
        }
        
        
        private func showToast(message: String) {
            toastLabel.text = message
            
            UIView.animate(withDuration: 0.3, animations: {
                self.toastView.alpha = 1
            }, completion: { _ in
                UIView.animate(withDuration: 0.3, delay: 2, options: .curveEaseOut, animations: {
                    self.toastView.alpha = 0
                })
            })
        }
    
    
    func updateSearchQuery(_ query: String?) {
        if let query = query, !query.isEmpty {
            searchQuerySubject.onNext(query)
        }
    }
    
    private func navigateToCoinDetail(coin: SearchCoin) {
        let detailVC = CoinDetailViewController()
        detailVC.configure(with: coin)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
