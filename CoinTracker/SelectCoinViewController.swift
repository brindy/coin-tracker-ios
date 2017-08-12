//
//  SelectCoinViewController.swift
//  CoinTracker
//
//  Created by Christopher Brind on 12/08/2017.
//  Copyright © 2017 Christopher Brind. All rights reserved.
//

import Foundation
import UIKit

class SelectCoinViewController: UITableViewController {

    lazy var coinRepository = CoinRepository()

    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)

        if coinRepository.coins.isEmpty {
            refresh()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinRepository.coins.count
    }

    func refresh() {

        guard !(refreshControl?.isRefreshing ?? false) else {
            return
        }

        refreshControl?.beginRefreshing()

        coinRepository.refresh {
            self.refreshControl?.endRefreshing()
        }

    }

}
