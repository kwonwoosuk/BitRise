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
    
    private var currentTickers: [UpbitTicker] = []
    
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
        viewModel.startWebSocket()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.stopWebSocket()
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
        mainView.tableView.dataSource = self
        mainView.tableView.delegate = self
    }
    
    override func bind() {
        let input = ExchangeViewModel.Input(
            viewDidLoad: Observable.just(()),
            currentPriceSortTap: mainView.currentPriceSortButton.rx.tap,
            changeRateSortTap: mainView.changeRateSortButton.rx.tap,
            tradePriceSortTap: mainView.tradePriceSortButton.rx.tap
        )
        
        let output = viewModel.transform(input: input)
        
        // 전체 데이터 업데이트
        output.tickers
            .drive(onNext: { [weak self] tickers in
                self?.currentTickers = tickers
                self?.mainView.tableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        // 실시간 개별 업데이트
        output.realtimeUpdate
            .drive(onNext: { [weak self] ticker in
                self?.updateCell(with: ticker)
            })
            .disposed(by: disposeBag)
        
        // 에러 처리
        output.error
            .drive(onNext: { [weak self] error in
                if let error = error {
                    self?.showErrorAlert(message: error.message)
                }
            })
            .disposed(by: disposeBag)
        
        // 연결 상태 표시
        output.isConnected
            .drive(onNext: { [weak self] isConnected in
                self?.updateConnectionStatus(isConnected: isConnected)
            })
            .disposed(by: disposeBag)
        
        // 정렬 버튼 UI 업데이트
        Driver.combineLatest(output.sortType, output.sortOrder)
            .drive(onNext: { [weak self] sortType, sortOrder in
                self?.updateSortButtons(sortType: sortType, sortOrder: sortOrder)
            })
            .disposed(by: disposeBag)
    }
    
    private func updateCell(with ticker: UpbitTicker) {
        guard let index = currentTickers.firstIndex(where: { $0.market == ticker.market }) else {
            return
        }
        
        // 데이터 업데이트
        currentTickers[index] = ticker
        
        // 해당 셀만 애니메이션과 함께 업데이트
        let indexPath = IndexPath(row: index, section: 0)
        
        if let cell = mainView.tableView.cellForRow(at: indexPath) as? ExchangeTableViewCell {
            cell.configure(with: ticker, animated: true)
        }
    }
    
    private func updateConnectionStatus(isConnected: Bool) {
        DispatchQueue.main.async {
            let imageName = isConnected ? "wifi" : "wifi.slash"
            let color: UIColor = isConnected ? .systemGreen : .systemRed
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: imageName),
                style: .plain,
                target: nil,
                action: nil
            )
            self.navigationItem.rightBarButtonItem?.tintColor = color
        }
    }
    
    private func updateSortButtons(sortType: SortType?, sortOrder: SortOrder) {
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

// MARK: - TableView DataSource & Delegate
extension ExchangeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentTickers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ExchangeTableViewCell.identifier, for: indexPath) as? ExchangeTableViewCell else {
            return UITableViewCell()
        }
        
        let ticker = currentTickers[indexPath.row]
        cell.configure(with: ticker, animated: false)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
