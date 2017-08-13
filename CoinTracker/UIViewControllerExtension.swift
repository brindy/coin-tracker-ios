//
//  UIViewControllerExtension.swift
//  CoinTracker
//
//  Created by Christopher Brind on 13/08/2017.
//  Copyright © 2017 Christopher Brind. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {

    func confirm(message: String, completion: @escaping () -> Void) {
        let alert = UIAlertController(title: "Confirm", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in 
            completion()
        }))
        present(alert, animated: true, completion: nil)
    }

}
