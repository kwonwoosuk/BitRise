//
//  SearchViewController.swift
//  BitRise
//
//  Created by 권우석 on 3/9/25.
//


import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class SearchViewController: BaseViewController, UIGestureRecognizerDelegate {
    
    private let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 340, height: 56))
    private let tabsContainerView = UIView()
    private let tabButtonsStackView = UIStackView()
    private let pageContainerView = UIView()
    private let indicatorView = UIView()
    
    private var tabButtons = [UIButton]()
    private var pageViewController: SearchTabPageViewController!
    
    private let viewModel = SearchViewModel()
    private let disposeBag = DisposeBag()
    
    private let tabSelectedRelay = BehaviorRelay<SearchTab>(value: .coin)
    
    var initialSearchQuery: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupPageViewController()
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let query = initialSearchQuery, !query.isEmpty && navigationController?.viewControllers.count != 1 {
            searchBar.text = query
            callRequest(query: query)
            initialSearchQuery = nil
        }
    }
    
    private func callRequest(query: String) {
        if let coinVC = pageViewController.children.first as? SearchCoinViewController {
            coinVC.updateSearchQuery(query)
        }
        searchBar.resignFirstResponder()
    }
    
    override func configureHierarchy() {
        [searchBar, tabsContainerView, pageContainerView].forEach {
            view.addSubview($0)
        }
        
        tabsContainerView.addSubview(tabButtonsStackView)
        tabsContainerView.addSubview(indicatorView)
    }
    
    override func configureLayout() {
        tabsContainerView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(48)
        }
        
        tabButtonsStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.bottom.equalToSuperview().inset(8)
        }
        
        pageContainerView.snp.makeConstraints { make in
            make.top.equalTo(tabsContainerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        indicatorView.snp.makeConstraints { make in
            make.bottom.equalTo(tabsContainerView)
            make.height.equalTo(3)
            make.width.equalTo(view.frame.width / CGFloat(SearchTab.allCases.count))
            make.leading.equalToSuperview()
        }
    }
    
    override func configureView() {
        view.backgroundColor = .white
        searchBar.delegate = self
        tabButtonsStackView.axis = .horizontal
        tabButtonsStackView.distribution = .fillEqually
        tabButtonsStackView.alignment = .center
        
        for tab in SearchTab.allCases {
            let button = UIButton(type: .system)
            button.setTitle(tab.title, for: .normal)
            button.titleLabel?.font = Constants.Font.bold_12
            button.tag = tab.rawValue
            button.addTarget(self, action: #selector(tabButtonTapped(_:)), for: .touchUpInside)
            tabButtons.append(button)
            tabButtonsStackView.addArrangedSubview(button)
        }
        
        updateTabSelection(tab: .coin)
        
        indicatorView.backgroundColor = .brBlack
    }
    
    private func setupNavigationBar() {
        if navigationController?.viewControllers.count ?? 0 > 1 {
            let backButton = UIBarButtonItem(image: UIImage(systemName: "arrow.left"), style: .plain, target: self, action: #selector(backButtonTapped))
            backButton.tintColor = .brBlack
            navigationItem.leftBarButtonItem = backButton
        }
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBar.backgroundColor = .white
        searchBar.clipsToBounds = true
        
        let textField = searchBar.searchTextField
        textField.backgroundColor = .clear
        textField.clearButtonMode = .never
        searchBar.searchTextField.font = Constants.Font.regular_12
        searchBar.searchTextField.leftView = nil
        
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12, weight: .regular),
            .foregroundColor: UIColor.gray
        ]
        textField.attributedPlaceholder = NSAttributedString(
            string: "검색어를 입력해주세요.",
            attributes: placeholderAttributes
        )
        self.navigationItem.titleView = searchBar
    }
    
    private func setupPageViewController() {
        pageViewController = SearchTabPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        addChild(pageViewController)
        pageContainerView.addSubview(pageViewController.view)
        pageViewController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        pageViewController.didMove(toParent: self)
        
        pageViewController.onPageChanged = { [weak self] index in
            guard let tab = SearchTab(rawValue: index) else { return }
            self?.updateTabSelection(tab: tab)
        }
    }

    
    @objc private func tabButtonTapped(_ sender: UIButton) {
        guard let tab = SearchTab(rawValue: sender.tag) else { return }
        updateTabSelection(tab: tab)
        pageViewController.setCurrentPage(tab.rawValue)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    private func updateTabSelection(tab: SearchTab) {
        tabSelectedRelay.accept(tab)
        
        for (index, button) in tabButtons.enumerated() {
            let isSelected = index == tab.rawValue
            button.setTitleColor(isSelected ? .brBlack : .lightGray, for: .normal)
            button.titleLabel?.font = isSelected ?
                Constants.Font.bold_12 :
                Constants.Font.regular_12
        }
        
        let tabWidth = view.frame.width / CGFloat(SearchTab.allCases.count)
        UIView.animate(withDuration: 0.3) {
            self.indicatorView.snp.updateConstraints { make in
                make.leading.equalToSuperview().offset(CGFloat(tab.rawValue) * tabWidth)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    override func bind() {
        let input = SearchViewModel.Input(
            viewDidLoad: Observable.just(()),
            searchText: searchBar.rx.text,
            searchButtonTapped: searchBar.rx.searchButtonClicked,
            tabSelected: tabSelectedRelay.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        searchBar.rx.searchButtonClicked
            .withLatestFrom(searchBar.rx.text)
            .subscribe(onNext: { [weak self] query in
                guard let self = self else { return }
                
                if let query = query, !query.trimmingCharacters(in: .whitespaces).isEmpty {
                    self.callRequest(query: query)
                } else {
                    self.searchBar.resignFirstResponder()
                }
            })
            .disposed(by: disposeBag)
        
        output.message
            .drive(onNext: { [weak self] message in
                self?.showToast(message: message) 
            })
            .disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { [weak self] error in
                self?.showErrorAlert(message: error.message)
            })
            .disposed(by: disposeBag)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
