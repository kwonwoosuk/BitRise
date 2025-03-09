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
        
        // 5초마다 자동 새로고침 // 탭바 델리게이트로 다른뷰 가면 멈춰 주도록하능 기능 추가해야함
        let timer = Observable<Int>.interval(.seconds(5), scheduler: MainScheduler.instance)
            .map { _ in () }
        
        // 버튼 탭 이벤트
        let currentPriceSortTap = mainView.currentPriceSortButton.rx.tap
        let changeRateSortTap = mainView.changeRateSortButton.rx.tap
        let tradePriceSortTap = mainView.tradePriceSortButton.rx.tap
        
        // Input 구성
        let input = ExchangeViewModel.Input(
            viewDidLoad: viewDidLoadTrigger,
            timerTrigger: timer,
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
                    self?.showErrorAlert(with: error.message)
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
        [mainView.currentPriceSortButton, mainView.changeRateSortButton, mainView.tradePriceSortButton].forEach {
            $0.setImage(nil, for: .normal)
        }
        
        guard let sortType = sortType, sortOrder != .none else {
            return
        }
        
        // 선택된 정렬 버튼에 화살표 이미지임시 추가
        // 커스텀으로 해야겠다 뒤엔 추가가 안된다...
        let arrowImage = sortOrder == .ascending ?
            UIImage(systemName: Constants.Icon.arrowUp) :
            UIImage(systemName: Constants.Icon.arrowDown)
        
        switch sortType {
        case .currentPrice:
            mainView.currentPriceSortButton.setImage(arrowImage, for: .normal)
        case .changeRate:
            mainView.changeRateSortButton.setImage(arrowImage, for: .normal)
        case .tradePrice:
            mainView.tradePriceSortButton.setImage(arrowImage, for: .normal)
        }
    }
    
    private func showErrorAlert(with message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
  
}
