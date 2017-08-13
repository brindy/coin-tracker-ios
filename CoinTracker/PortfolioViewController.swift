//
//  YourCoinsViewController.swift
//  CoinTracker
//
//  Created by Christopher Brind on 12/08/2017.
//  Copyright © 2017 Christopher Brind. All rights reserved.
//

import Foundation
import UIKit

class PortfolioViewController: UITableViewController {

    let repository = CoinRepository.shared

    var positions = [Position]()

    override func viewDidLoad() {
        title = "Your Coins - \(AppSettings().currency)"
    }

    override func viewDidAppear(_ animated: Bool) {
        positions = Array(Portfolio.shared.positions.values).sorted(by: { (left, right) -> Bool in
            guard let leftCoin = repository.coin(for: left.coinId) else { return true }
            guard let rightCoin = repository.coin(for: right.coinId) else { return true }
            return leftCoin.symbol.compare(rightCoin.symbol) == .orderedAscending
        })
        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return positions.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! PositionCell
        let position = positions[indexPath.row]
        if let coin = CoinRepository.shared.coin(for: position.coinId) {
            cell.update(position, with: coin)
        } else {
            cell.unknwownCoin()
        }
        return cell
    }

}

class PositionCell: UITableViewCell {

    @IBOutlet weak var symbolText: UILabel!
    @IBOutlet weak var amountText: UILabel!
    @IBOutlet weak var valueText: UILabel!
    @IBOutlet weak var changeText: UILabel!
    @IBOutlet weak var changeTypeText: UILabel!
    @IBOutlet weak var changeDirectionImage: UIImageView!

    func update(_ position: Position, with coin: Coin) {
        symbolText.text = coin.symbol
        amountText.text = "\(position.amount) \(coin.name)"

        let price = Double(coin.price) ?? 0.0
        let value = position.amount * price
        valueText.text = String(format: "%.2f // %.2f", value, price)

        let change = coin.change.day
        let directionUp = change.characters.first != "-"
        let direction = directionUp ? "+" : ""
        changeText.text = "\(direction)\(change)"
        changeTypeText.text = "24h"

        // TODO direction of change
    }

    func unknwownCoin() {
        symbolText.text = "???"
        amountText.text = ""
        valueText.text = ""
        changeText.text = ""
        changeTypeText.text = ""
        changeDirectionImage.image = nil
    }

}
