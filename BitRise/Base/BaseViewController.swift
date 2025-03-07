//
//  BaseViewController.swift
//  BitRise
//
//  Created by 권우석 on 3/8/25.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureHierarchy()
        configureLayout()
        configureView()
        bind()
    }
    
    func configureHierarchy() { }
    
    func configureLayout() { }
    
    func configureView() { }
    
    func bind() { }
     
}
