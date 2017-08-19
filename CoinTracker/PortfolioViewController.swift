//
//  YourCoinsViewController.swift
//  CoinTracker
//
//  Created by Christopher Brind on 12/08/2017.
//  Copyright © 2017 Christopher Brind. All rights reserved.
//

import Foundation
import UIKit

class PortfolioViewController: UITableViewController, PeriodUpdatedDelegate {

    struct Constants {
        static let headerCells = 2
    }

    var currentPeriod = Period.last24h

    let repository = CoinRepository.shared
    let portfolio = Portfolio.shared

    var positions = [Position]()
    var busy = false

    override func viewDidLoad() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshCoins), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        refreshPortfolio()
        tableView.bounces = !positions.isEmpty
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if positions.isEmpty {
            return 1
        }

        return positions.count + Constants.headerCells
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if positions.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: "Info")!
        }

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Period") as! PeriodCell
            cell.delegate = self
            cell.period = currentPeriod
            return cell
        }

        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Total") as! TotalCell
            cell.update(with: positions)
            return cell
        }

        let index = indexPath.row - Constants.headerCells
        let cell = tableView.dequeueReusableCell(withIdentifier: "Position") as! PositionCell
        let position = positions[index]
        if let coin = CoinRepository.shared.coin(for: position.coinId) {
            cell.update(with: position, and: coin, for: currentPeriod)
        } else {
            cell.unknwownCoin()
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {

        if positions.isEmpty {
            return false
        }

        return indexPath.row > 0
    }

    override func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        if positions.isEmpty {
            return nil
        }

        if indexPath.row < Constants.headerCells {
            return nil
        }

        let subtract = UITableViewRowAction(style: .default, title: "Sell") { (action, indexPath) in }
        subtract.backgroundColor = UIColor.orange

        let position = positions[indexPath.row - Constants.headerCells]

        let delete =  UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            self.confirm(message: "Delete this coin?") {
                self.portfolio.delete(coinId: position.coinId)
                self.refreshPortfolio()
            }
        }

        return [subtract, delete]
    }

    func refreshPortfolio() {
        navigationItem.title = "Your Coins - \(AppSettings().currency)"
        positions = Array(portfolio.positions.values).sorted(by: { (left, right) -> Bool in
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

    func periodUpdated(period: Period) {
        currentPeriod = period
        tableView.reloadData()
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

    func update(with position: Position, and coin: Coin, for period: Period) {
        symbolText.text = coin.symbol
        amountText.text = "\(position.amount) \(coin.name)"

        let price = Double(coin.price) ?? 0.0
        let value = position.amount * price
        valueText.text = String(format: "%.2f // %.2f", value, price)

        let change = period.change(for: coin)
        let directionUp = change.characters.first != "-"
        let direction = directionUp ? "+" : ""
        changeText.text = "\(direction)\(change)%"

        let directionIndiator = directionUp ? "🔼" : "🔽"

        changeTypeText.text = "\(directionIndiator) \(period.descriptor)"
    }

    func unknwownCoin() {
        symbolText.text = "???"
        amountText.text = ""
        valueText.text = ""
        changeText.text = ""
        changeTypeText.text = ""
    }

}

class PeriodCell: UITableViewCell {

    weak var delegate: PeriodUpdatedDelegate?

    @IBOutlet weak var periodSegments: UISegmentedControl!

    var period: Period {
        set {
            periodSegments.selectedSegmentIndex = newValue.rawValue
        }

        get {
            return Period.init(rawValue: periodSegments.selectedSegmentIndex)!
        }
    }

    @IBAction func updatePeriod(sender: UISegmentedControl) {
        delegate?.periodUpdated(period: period)
    }

}

protocol PeriodUpdatedDelegate: class {

    func periodUpdated(period: Period)

}

enum Period: Int {

    case last1h = 0
    case last24h
    case last7d

}

extension Period {

    var descriptor: String {
        get {

            switch(self) {
            case .last1h: return "1h"
            case .last24h: return "24h"
            case .last7d: return "7d"
            }

        }
    }

    func change(for coin: Coin) -> String {

        switch(self) {
        case .last1h: return coin.change.hour
        case .last24h: return coin.change.day
        case .last7d: return coin.change.sevenDays
        }

    }

}



