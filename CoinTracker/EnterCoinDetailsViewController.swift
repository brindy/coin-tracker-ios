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

    let portfolio = Portfolio.shared

    var coin: Coin!

    let formatter = DateFormatter()

    override func viewDidLoad() {
        title = coin.symbol

        formatter.dateStyle = .medium

        titleCell.textLabel?.text = coin.symbol
        titleCell.detailTextLabel?.text = coin.name
        dateText.inputView = datePicker

        datePicker.addTarget(self, action: #selector(updateDate), for: .valueChanged)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        amountText.resignFirstResponder()
        dateText.resignFirstResponder()
    }

    @IBAction func done() {
        portfolio.add(coinId: coin.id, amount: Double(amountText.text ?? "0")!, date: datePicker.date)
        navigationController?.popToRootViewController(animated: true)
    }

    @IBAction func tapAmountCell() {
        amountText.becomeFirstResponder()
    }

    @IBAction func tapDateCell() {
        dateText.becomeFirstResponder()
    }

    func updateDate() {
        dateText.text = formatter.string(from: datePicker.date)
    }

}
