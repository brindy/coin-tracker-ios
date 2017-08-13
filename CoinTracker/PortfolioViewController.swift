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
    var busy = false

    override func viewDidLoad() {

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshCoins), for: .valueChanged)

        tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl!.frame.size.height), animated: true)
        refreshCoins()
    }

    override func viewWillAppear(_ animated: Bool) {
        refreshPortfolio()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if positions.count == 0 {
            return 1
        }

        return positions.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if positions.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "Info")!
        }

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Total") as! TotalCell
            cell.update(with: positions)
            return cell
        }

        let index = indexPath.row - 1
        let cell = tableView.dequeueReusableCell(withIdentifier: "Position") as! PositionCell
        let position = positions[index]
        if let coin = CoinRepository.shared.coin(for: position.coinId) {
            cell.update(with: position, and: coin)
        } else {
            cell.unknwownCoin()
        }
        return cell
    }

    func refreshPortfolio() {
        navigationItem.title = "Your Coins - \(AppSettings().currency)"
        positions = Array(Portfolio.shared.positions.values).sorted(by: { (left, right) -> Bool in
            guard let leftCoin = repository.coin(for: left.coinId) else { return false }
            guard let rightCoin = repository.coin(for: right.coinId) else { return false }
            return leftCoin.symbol.compare(rightCoin.symbol) == .orderedAscending

        })
        self.busy = false
        self.refreshControl?.endRefreshing()
        tableView.reloadData()
    }

    func refreshCoins() {
        busy = true
        refreshControl?.beginRefreshing()
        CoinRepository.shared.refresh {
            self.refreshPortfolio()
        }
    }

}

class TotalCell: UITableViewCell {

    @IBOutlet weak var totalText: UILabel!
    @IBOutlet weak var lastUpdatedText: UILabel!

    func update(with positions: [Position]) {

        let repository = CoinRepository.shared
        var value = 0.0
        for position in positions {
            if let coin = repository.coin(for: position.coinId) {
                let price = Double(coin.price) ?? 0.0
                value += (position.amount * price)
            }
        }

        totalText.text = String(format: "%.2f \(AppSettings().currency)", value)

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        lastUpdatedText.text = "Last updated \(dateFormatter.string(from: repository.lastUpdated))"
    }

}

class PositionCell: UITableViewCell {

    @IBOutlet weak var symbolText: UILabel!
    @IBOutlet weak var amountText: UILabel!
    @IBOutlet weak var valueText: UILabel!
    @IBOutlet weak var changeText: UILabel!
    @IBOutlet weak var changeTypeText: UILabel!
    @IBOutlet weak var changeDirectionImage: UIImageView!

    func update(with position: Position, and coin: Coin) {
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
