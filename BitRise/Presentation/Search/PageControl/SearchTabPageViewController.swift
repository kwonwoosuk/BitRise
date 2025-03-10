//
//  SearchTabPageViewController.swift
//  BitRise
//
//  Created by 권우석 on 3/11/25.
//

import UIKit

final class SearchTabPageViewController: UIPageViewController {
    
    private lazy var page: [UIViewController] = {
        
        let coinVC = SearchCoinViewController()
        let nftVC = UIViewController()
        let exchangeVC = UIViewController()
        nftVC.view.backgroundColor = .white
        exchangeVC.view.backgroundColor = .white
        
        return [coinVC, nftVC, exchangeVC]
    }()
    
    
    
    var onPageChanged: ((Int) -> Void)?
    
    override init(transitionStyle style: UIPageViewController.TransitionStyle, navigationOrientation: UIPageViewController.NavigationOrientation, options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: options)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let firstVC = page.first {
            setViewControllers([firstVC], direction: .forward, animated: false)
        }
    }
    
    func setCurrentPage(_ index: Int) {
        guard index >= 0 && index < page.count else { return }
        
        let viewController = page[index]
        
        guard let currentVC = page.first,
              let currentIndex = page.firstIndex(of: currentVC) else {
            return
        }
        
        let direction: UIPageViewController.NavigationDirection =
        index > currentIndex ? .forward : .reverse
        
        setViewControllers([viewController], direction: direction, animated: true) { [weak self] completed in
            if completed {
                DispatchQueue.main.async {
                    self?.onPageChanged?(index)
                }
            }
        }
    }
}

extension SearchTabPageViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = page.firstIndex(of: viewController), index > 0 else {
            return nil
        }
        return page[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = page.firstIndex(of: viewController), index < page.count - 1 else {
            return nil
        }
        return page[index + 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed,
           let visibleViewController = pageViewController.viewControllers?.first,
           let index = page.firstIndex(of: visibleViewController) {
            onPageChanged?(index)
        }
    }
}
