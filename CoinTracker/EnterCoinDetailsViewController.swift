//
//  EnterCoinDetailsViewController.swift
//  CoinTracker
//
//  Created by Christopher Brind on 12/08/2017.
//  Copyright © 2017 Christopher Brind. All rights reserved.
//

import Foundation
import UIKit

class EnterCoinDetailsViewController: UITableViewController {

    @IBOutlet weak var titleCell: UITableViewCell!
    @IBOutlet weak var amountText: UITextField!
    @IBOutlet weak var dateText: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!

    var coin: Coin!

    let formatter = DateFormatter()

    override func viewDidLoad() {
        formatter.dateStyle = .medium

        titleCell.textLabel?.text = coin.symbol
        titleCell.detailTextLabel?.text = coin.name
        dateText.inputView = datePicker

        datePicker.addTarget(self, action: #selector(updateDate), for: .valueChanged)
    }

    @IBAction func done() {
        Portfolio.shared.add(coin, amount: Double(amountText.text ?? "0")!, date: datePicker.date)
        navigationController?.popToRootViewController(animated: true)
    }

    func updateDate() {
        dateText.text = formatter.string(from: datePicker.date)
    }

}
