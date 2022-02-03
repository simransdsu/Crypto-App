//
//  PortfolioDataService.swift
//  Crypto App
//
//  Created by Simran Preet Narang on 2022-02-03.
//

import Foundation
import CoreData

class PortfolioDataService {
    
    private let containerName = "PortfolioContainer"
    private let entityName = "PortfolioEntity"
    private let container: NSPersistentContainer
    
    @Published var savedEntities: [PortfolioEntity] = []
    
    init() {
        container = NSPersistentContainer(name: containerName)
        container.loadPersistentStores { _, error in
            if let error = error {
                print("❌ Loading Core Data: \(error)")
            }
            self.getPorfolio()
        }
    }
    
    
    // MARK: - PUBLIC
    
    func updatePortfolio(coin: CoinModel, amount: Double) {
        if let entity = savedEntities.first(where: { $0.coinID == coin.id }) {
            if amount > 0 {
                update(entity: entity, amount: amount)
            } else {
                delete(entity: entity)
            }
        } else {
            add(coin: coin, amount: amount)
        }
    }
    
    
    // MARK: - PRIVATE
    
    private func getPorfolio() {
        let request = NSFetchRequest<PortfolioEntity>(entityName: entityName)
        do {
            savedEntities = try container.viewContext.fetch(request)
        } catch let error {
            print("❌ Fetching Portfolio Entities: \(error)")
        }
    }
    
    private func add(coin: CoinModel, amount: Double) {
        let entity = PortfolioEntity(context: container.viewContext)
        entity.coinID = coin.id
        entity.amount = amount
        applyChanges()
    }
    
    private func update(entity: PortfolioEntity, amount: Double) {
        entity.amount = amount
        applyChanges()
    }
    
    private func delete(entity: PortfolioEntity) {
        container.viewContext.delete(entity)
        applyChanges()
    }
    
    private func save() {
        do {
            try container.viewContext.save()
        } catch {
            print("❌ Saving to Core Data. \(error)")
        }
    }
    
    private func applyChanges() {
        save()
        getPorfolio()
    }
    
}
