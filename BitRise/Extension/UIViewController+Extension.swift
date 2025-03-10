//
//  UIViewController+Extension.swift
//  BitRise
//
//  Created by 권우석 on 3/10/25.
//

import UIKit

extension UIViewController {
    
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
