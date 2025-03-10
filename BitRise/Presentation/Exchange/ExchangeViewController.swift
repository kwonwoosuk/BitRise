//
//  ExchangeViewController.swift
//  BitRise
//
//  Created by 권우석 on 3/8/25.
//

import UIKit
import RxSwift
import RxCocoa

final class ExchangeViewController: BaseViewController {
    
    private let mainView = ExchangeView()
    private let viewModel = ExchangeViewModel()
    private let disposeBag = DisposeBag()
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.startTimer()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopTimer()
    }
    
    private func setupNavigationBar() {
        
        let naviLabel = UILabel()
        naviLabel.text = "거래소"
        naviLabel.font = .systemFont(ofSize: 18, weight: .heavy)
        naviLabel.textColor = .brBlack
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: naviLabel)
        navigationItem.title = ""
    }
    
    private func setupTableView() {
        mainView.tableView.register(ExchangeTableViewCell.self, forCellReuseIdentifier: ExchangeTableViewCell.identifier)
    }
    
    override func bind() {
        let viewDidLoadTrigger = Observable.just(())
        
        let emptyTimer = Observable<Void>.create { observer in
            return Disposables.create {
                print("타이머 Observable Disposed ")
            }
        }
        
        let currentPriceSortTap = mainView.currentPriceSortButton.rx.tap
        let changeRateSortTap = mainView.changeRateSortButton.rx.tap
        let tradePriceSortTap = mainView.tradePriceSortButton.rx.tap
        
        let input = ExchangeViewModel.Input(
            viewDidLoad: viewDidLoadTrigger,
            timerTrigger: emptyTimer,
            currentPriceSortTap: currentPriceSortTap,
            changeRateSortTap: changeRateSortTap,
            tradePriceSortTap: tradePriceSortTap
        )
        let output = viewModel.transform(input: input)
        
        output.tickers
            .drive(mainView.tableView.rx.items(cellIdentifier: ExchangeTableViewCell.identifier, cellType: ExchangeTableViewCell.self)) { _, element, cell in
                cell.configure(with: element)
            }
            .disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { [weak self] error in
                if let error = error {
                    self?.showErrorAlert(message: error.message)
                }
            })
            .disposed(by: disposeBag)
        
        
        Driver.combineLatest(output.sortType, output.sortOrder)
            .drive(onNext: { [weak self] sortType, sortOrder in
                self?.updateSortButtonsUI(sortType: sortType, sortOrder: sortOrder)
            })
            .disposed(by: disposeBag)
        
    }
    
    private func updateSortButtonsUI(sortType: SortType?, sortOrder: SortOrder) {
        mainView.currentPriceSortButton.sortOrder = .none
        mainView.changeRateSortButton.sortOrder = .none
        mainView.tradePriceSortButton.sortOrder = .none
        
        guard let sortType = sortType else { return }
        
        switch sortType {
        case .currentPrice:
            mainView.currentPriceSortButton.sortOrder = sortOrder
        case .changeRate:
            mainView.changeRateSortButton.sortOrder = sortOrder
        case .tradePrice:
            mainView.tradePriceSortButton.sortOrder = sortOrder
        }
    }
  
    
    
}
