//
//  SearchCoinViewController.swift
//  BitRise
//
//  Created by 권우석 on 3/11/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

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
