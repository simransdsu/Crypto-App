//
//  HomeViewModel.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-01-14.
//

import Foundation
import Combine


class HomeViewModel: ObservableObject {
    
    @Published var allCoins: [CoinModel] = []
    @Published var portfolioCoins: [CoinModel] = []
    
    private let dataService = CoinDataService()
    private var cancellable = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    func addSubscribers() {
        dataService.$allCoins.sink { [weak self] coins in
            self?.allCoins.append(contentsOf: coins)
        }.store(in: &cancellable)
    }
}
