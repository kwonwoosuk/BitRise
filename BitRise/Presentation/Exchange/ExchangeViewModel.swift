//
//  ExchangeViewModel.swift
//  BitRise
//
//  Created by 권우석 on 3/8/25.
//

import Foundation
import RxSwift
import RxCocoa

enum SortType {
    case currentPrice
    case changeRate
    case tradePrice
}

enum SortOrder {
    case ascending
    case descending
    case none
}

final class ExchangeViewModel: BaseViewModel {
    
    var disposeBag = DisposeBag()
    
    private let networkManager = NetworkManager.shared
    private let webSocketManager = WebSocketManager.shared
    
    private let tickersRelay = BehaviorRelay<[UpbitTicker]>(value: [])
    private let realtimeUpdateRelay = PublishRelay<UpbitTicker>()
    private let sortTypeRelay = BehaviorRelay<SortType?>(value: nil)
    private let sortOrderRelay = BehaviorRelay<SortOrder>(value: .none)
    private let errorRelay = BehaviorRelay<APIError?>(value: nil)
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let currentPriceSortTap: ControlEvent<Void>
        let changeRateSortTap: ControlEvent<Void>
        let tradePriceSortTap: ControlEvent<Void>
    }
    
    struct Output {
        let tickers: Driver<[UpbitTicker]>
        let realtimeUpdate: Driver<UpbitTicker>
        let error: Driver<APIError?>
        let sortType: Driver<SortType?>
        let sortOrder: Driver<SortOrder>
        let isConnected: Driver<Bool>
    }
    
    init() {
        setupWebSocket()
    }
    
    deinit {
        print("⭐️ExchangeViewModel DEINIT⭐️")
        webSocketManager.disconnect()
    }
    
    private func setupWebSocket() {
        // WebSocket 실시간 데이터 수신
        webSocketManager.tickerObservable
            .subscribe(onNext: { [weak self] ticker in
                self?.updateTicker(ticker)
                self?.realtimeUpdateRelay.accept(ticker)
            })
            .disposed(by: disposeBag)
    }
    
    func transform(input: Input) -> Output {
        
        input.viewDidLoad
            .subscribe(onNext: { [weak self] in
                self?.loadInitialData()
            })
            .disposed(by: disposeBag)
        
        input.currentPriceSortTap
            .subscribe(onNext: { [weak self] in
                self?.toggleSort(type: .currentPrice)
            })
            .disposed(by: disposeBag)
        
        input.changeRateSortTap
            .subscribe(onNext: { [weak self] in
                self?.toggleSort(type: .changeRate)
            })
            .disposed(by: disposeBag)
        
        input.tradePriceSortTap
            .subscribe(onNext: { [weak self] in
                self?.toggleSort(type: .tradePrice)
            })
            .disposed(by: disposeBag)
        
        return Output(
            tickers: tickersRelay.asDriver(),
            realtimeUpdate: realtimeUpdateRelay.asDriver(onErrorJustReturn: UpbitTicker(market: "", change: "", tradePrice: 0, signedChangeRate: 0, signedChangePrice: 0, accTradePrice: 0)),
            error: errorRelay.asDriver(),
            sortType: sortTypeRelay.asDriver(),
            sortOrder: sortOrderRelay.asDriver(),
            isConnected: webSocketManager.isConnected.asDriver(onErrorJustReturn: false)
        )
    }
    
    func startWebSocket() {
        webSocketManager.connect()
    }
    
    func stopWebSocket() {
        webSocketManager.disconnect()
    }
    
    private func loadInitialData() {
        networkManager.fetchAllKRWTickers()
            .subscribe(
                onSuccess: { [weak self] tickers in
                    guard let self = self else { return }
                    
                    self.errorRelay.accept(nil)
                    
                    // 기본 정렬 (거래대금 내림차순)
                    let sortedTickers = self.sortByTradePrice(tickers: tickers, ascending: false)
                    self.tickersRelay.accept(sortedTickers)
                    
                    // REST API 데이터 로딩 완료 후 WebSocket 연결
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.startWebSocket()
                    }
                },
                onFailure: { [weak self] error in
                    if let apiError = error as? APIError {
                        self?.errorRelay.accept(apiError)
                    }
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func updateTicker(_ newTicker: UpbitTicker) {
        var currentTickers = tickersRelay.value
        
        // 해당 마켓 찾아서 업데이트
        if let index = currentTickers.firstIndex(where: { $0.market == newTicker.market }) {
            currentTickers[index] = newTicker
            
            // 현재 정렬 유지
            let currentSortType = sortTypeRelay.value
            let currentSortOrder = sortOrderRelay.value
            
            if let sortType = currentSortType, currentSortOrder != .none {
                applySorting(tickers: currentTickers, type: sortType, ascending: currentSortOrder == .ascending)
            } else {
                tickersRelay.accept(currentTickers)
            }
        }
    }
    
    private func toggleSort(type: SortType) {
        let currentType = sortTypeRelay.value
        let currentOrder = sortOrderRelay.value
        
        if currentType == type {
            switch currentOrder {
            case .none:
                sortOrderRelay.accept(.descending)
                sortTypeRelay.accept(type)
                applySorting(tickers: tickersRelay.value, type: type, ascending: false)
            case .descending:
                sortOrderRelay.accept(.ascending)
                sortTypeRelay.accept(type)
                applySorting(tickers: tickersRelay.value, type: type, ascending: true)
            case .ascending:
                sortOrderRelay.accept(.none)
                sortTypeRelay.accept(nil)
                let sortedTickers = sortByTradePrice(tickers: tickersRelay.value, ascending: false)
                tickersRelay.accept(sortedTickers)
            }
        } else {
            sortTypeRelay.accept(type)
            sortOrderRelay.accept(.descending)
            applySorting(tickers: tickersRelay.value, type: type, ascending: false)
        }
    }
    
    private func applySorting(tickers: [UpbitTicker], type: SortType, ascending: Bool) {
        var sortedTickers: [UpbitTicker] = []
        
        switch type {
        case .currentPrice:
            sortedTickers = tickers.sorted { ticker1, ticker2 in
                return ascending ? ticker1.tradePrice < ticker2.tradePrice : ticker1.tradePrice > ticker2.tradePrice
            }
        case .changeRate:
            sortedTickers = tickers.sorted { ticker1, ticker2 in
                return ascending ? ticker1.signedChangeRate < ticker2.signedChangeRate : ticker1.signedChangeRate > ticker2.signedChangeRate
            }
        case .tradePrice:
            sortedTickers = sortByTradePrice(tickers: tickers, ascending: ascending)
        }
        
        tickersRelay.accept(sortedTickers)
    }
    
    private func sortByTradePrice(tickers: [UpbitTicker], ascending: Bool) -> [UpbitTicker] {
        return tickers.sorted { ticker1, ticker2 in
            return ascending ? ticker1.accTradePrice < ticker2.accTradePrice : ticker1.accTradePrice > ticker2.accTradePrice
        }
    }
}
