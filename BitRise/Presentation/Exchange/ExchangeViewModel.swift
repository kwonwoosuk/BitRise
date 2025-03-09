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
    private var timerDisposable: Disposable?
    
    private let networkManager = NetworkManager.shared
    private let tickersRelay = BehaviorRelay<[UpbitTicker]>(value: [])
    private let sortTypeRelay = BehaviorRelay<SortType?>(value: nil)
    private let sortOrderRelay = BehaviorRelay<SortOrder>(value: .none)
    private let errorRelay = BehaviorRelay<APIError?>(value: nil)
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let timerTrigger: Observable<Void>
        let currentPriceSortTap: ControlEvent<Void>
        let changeRateSortTap: ControlEvent<Void>
        let tradePriceSortTap: ControlEvent<Void>
    }
    
    struct Output {
        let tickers: Driver<[UpbitTicker]>
        let error: Driver<APIError?>
        let sortType: Driver<SortType?>
        let sortOrder: Driver<SortOrder>
    }
    
    init() {
        // ViewModel 초기화
    }
    
    deinit {
        print("⭐️exchange 뷰모델 DEINIT됨⭐️")
    }
    
    func transform(input: Input) -> Output {
        input.viewDidLoad
            .subscribe(onNext: { [weak self] in
                self?.fetchTickers()
            })
            .disposed(by: disposeBag)
        
        // 타이머
        input.timerTrigger
            .subscribe(onNext: { [weak self] in
                self?.fetchTickers()
            })
            .disposed(by: disposeBag)
        
        input.currentPriceSortTap
            .debug("현재가 탭")
            .subscribe(onNext: { [weak self] in
                self?.toggleSort(type: .currentPrice)
            })
            .disposed(by: disposeBag)
        
        input.changeRateSortTap
            .debug("전일대비 탭")
            .subscribe(onNext: { [weak self] in
                self?.toggleSort(type: .changeRate)
            })
            .disposed(by: disposeBag)
        
        input.tradePriceSortTap
            .debug("거래대금 탭")
            .subscribe(onNext: { [weak self] in
                self?.toggleSort(type: .tradePrice)
            })
            .disposed(by: disposeBag)
        
        return Output(
            tickers: tickersRelay.asDriver(),
            error: errorRelay.asDriver(),
            sortType: sortTypeRelay.asDriver(),
            sortOrder: sortOrderRelay.asDriver()
        )
    }
    
    func startTimer() {
        stopTimer() // 기존타이머 dispose
        
        timerDisposable = Observable<Int>.interval(.seconds(5), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                print("타이머 실행됨")
                self?.fetchTickers()
            })
    }
    
    func stopTimer() {
        timerDisposable?.dispose()
        timerDisposable = nil
        print("timer dispoe됨")
    }
    
    private func fetchTickers() {
        networkManager.fetchAllKRWTickers()
            .subscribe(
                onSuccess: { [weak self] tickers in
                    guard let self = self else { return }
                    
                    self.errorRelay.accept(nil)
                    // 현재 정렬 상태를 유지하면서 새 데이터 적용
                    let currentSortType = self.sortTypeRelay.value
                    let currentSortOrder = self.sortOrderRelay.value
                    
                    if let sortType = currentSortType, currentSortOrder != .none {
                        // 현재 정렬 기준이 있으면 그대로 적용
                        self.applySorting(tickers: tickers, type: sortType, ascending: currentSortOrder == .ascending)
                    } else {
                        // 정렬 기준이 없거나 .none이면 기본 정렬 (거래대금 내림차순) 적용
                        // API에서 이미 거래대금 내림차순으로 주지만, 명시적으로 정렬 적용
                        let sortedTickers = self.sortByTradePrice(tickers: tickers, ascending: false)
                        self.tickersRelay.accept(sortedTickers)
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
    
    private func toggleSort(type: SortType) {
        let currentType = sortTypeRelay.value
        let currentOrder = sortOrderRelay.value
        
        if currentType == type {
            switch currentOrder {
            case .none:
                // 선택 안 됨 -> 내림차순
                sortOrderRelay.accept(.descending)
                sortTypeRelay.accept(type)
                applySorting(tickers: tickersRelay.value, type: type, ascending: false)
                
            case .descending:
                // 내림차순 -> 오름차순
                sortOrderRelay.accept(.ascending)
                sortTypeRelay.accept(type)
                applySorting(tickers: tickersRelay.value, type: type, ascending: true)
                
            case .ascending:
                // 오름차순 -> 선택 안 됨 (정렬 해제)
                sortOrderRelay.accept(.none)
                sortTypeRelay.accept(nil)
                // 정렬 해제 시 기본 정렬 (거래대금 내림차순)
                let sortedTickers = sortByTradePrice(tickers: tickersRelay.value, ascending: false)
                tickersRelay.accept(sortedTickers)
            }
        } else {
            // 새로운 정렬 기준 선택
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
