//
//  BaseViewModel.swift
//  BitRise
//
//  Created by 권우석 on 3/8/25.
//

import Foundation
import RxSwift
import RxCocoa

protocol BaseViewModel {
    var disposeBag: DisposeBag { get }
    associatedtype Input
    associatedtype Output
    func transform(input: Input) -> Output
}


