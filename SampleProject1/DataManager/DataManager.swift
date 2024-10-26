//
//  DataManager.swift
//  TStore
//
//  Created by thiruvazhagan on 24/09/24.
//
import CoreData
import Foundation

class DataManager {
    
    var isDataLoaded = false
    let context: NSManagedObjectContext 
    
    //Initialization
    init(context: NSManagedObjectContext) {
        self.context = context
    }

    //Fetch or Create Entity
    private func fetchOrCreate<T: NSManagedObject>(entityName: String, predicate: NSPredicate, in context: NSManagedObjectContext) throws -> T {
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        fetchRequest.predicate = predicate
        
        if let existingEntity = try context.fetch(fetchRequest).first {
            return existingEntity
        } else {
            return T(context: context)
        }
    }
    
    //Fetch Data from URL
    func fetchData(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Failed to load data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Data is nil.")
                return
            }
            
            DispatchQueue.global(qos: .background).async {
                self.parseAndSaveData(data: data)
                DispatchQueue.main.async {
                    self.isDataLoaded = true
                    self.updateUIAfterDataLoad()
                }
            }
        }.resume()
    }
    
    func updateUIAfterDataLoad() {
        guard isDataLoaded else { return }
        
        // Fetch the stored data to update the view
           MainViewModel.shared.fetchStoredData()
        // Automatically select the first category if available
        if let firstCategory = MainViewModel.shared.categoriesFetchedResultsController.fetchedObjects?.first {
         
            MainViewModel.shared.selectedCategoryId = firstCategory.id
            MainViewModel.shared.filterProducts(byCategory: firstCategory.id)
            
            // Notify UI about the category change
            MainViewModel.shared.onCategoriesUpdate?()
        }
    }
    
    private func parseAndSaveData(data: Data) {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else { return }
            
            context.performAndWait {
                if let categories = json["category"] as? [[String: Any]] {
                    self.parseAndSaveCategories(categories)
                }
                
                if let products = json["products"] as? [[String: Any]] {
                    self.parseAndSaveProducts(products)
                }
                
                if let cardOffers = json["card_offers"] as? [[String: Any]] {
                    self.parseAndSaveCardOffers(cardOffers)
                }
                
                do {
                    try context.save()
                    DispatchQueue.main.async {
                        self.fetchStoredData()
                    }
                } catch {
                    print("Error saving context: \(error.localizedDescription)")
                }
            }
        } catch {
            print("Error parsing data: \(error.localizedDescription)")
        }
    }
    
    private func parseAndSaveProducts(_ products: [[String: Any]]) {
        for product in products {
            do {
                let productEntity: ProductsEntity = try fetchOrCreate(entityName: "ProductsEntity", predicate: NSPredicate(format: "id == %@", product["id"] as? String ?? UUID().uuidString), in: context)
                
                productEntity.name = product["name"] as? String ?? ""
                productEntity.price = product["price"] as? Int32 ?? 0
                productEntity.rating = (product["rating"] as? Float) ?? (product["rating"] as? Double).map { Float($0) } ?? 0.0
                productEntity.reviewCount = product["review_count"] as? Int32 ?? 0
                productEntity.categoryID = product["category_id"] as? String ?? ""
                productEntity.id = product["id"] as? String ?? UUID().uuidString
                productEntity.imageUrl = product["image_url"] as? String ?? ""
                productEntity.productDesc = product["description"] as? String ?? ""
                productEntity.colors = (product["colors"] as? [String]) as NSObject?
                
                if let cardOfferIds = product["card_offer_ids"] as? [String] {
                    for offerId in cardOfferIds {
                        let fetchRequest: NSFetchRequest<OffersId> = OffersId.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "id == %@", offerId)
                        
                        let cardOffer: OffersId
                        if let existingOffer = (try? context.fetch(fetchRequest))?.first {
                            cardOffer = existingOffer
                        } else {
                            cardOffer = OffersId(context: context)
                            cardOffer.id = offerId
                        }
                        
                        productEntity.addToOffersids(cardOffer)
                        cardOffer.addToProducts(productEntity)
                    }
                }
                
            } catch {
                print("Failed to save product: \(error.localizedDescription)")
            }
        }
    }
    

    private func parseAndSaveCardOffers(_ offers: [[String: Any]]) {
        for offer in offers {
            do {
                let cardOffer: CardOffers = try fetchOrCreate(entityName: "CardOffers", predicate: NSPredicate(format: "id == %@", offer["id"] as? String ?? UUID().uuidString), in: context)
                
                cardOffer.cardName = offer["card_name"] as? String ?? ""
                cardOffer.percentage = offer["percentage"] as? Double ?? 0.0
                cardOffer.id = offer["id"] as? String ?? UUID().uuidString
                cardOffer.imageUrl = offer["image_url"] as? String ?? ""
                cardOffer.maxDiscount = offer["max_discount"] as? String ?? ""
                cardOffer.offerDesc = offer["offer_desc"] as? String ?? ""
                
            } catch {
                print("Failed to save card offer: \(error.localizedDescription)")
            }
        }
    }
    
    private func parseAndSaveCategories(_ categories: [[String: Any]]) {
        for category in categories {
            do {
                let categoryEntity: CategoryEntity = try fetchOrCreate(entityName: "CategoryEntity", predicate: NSPredicate(format: "id == %@", category["id"] as? String ?? UUID().uuidString), in: context)
                
                categoryEntity.name = category["name"] as? String ?? ""
                categoryEntity.layout = category["layout"] as? String ?? ""
                categoryEntity.id = category["id"] as? String ?? UUID().uuidString
                
            } catch {
                print("Failed to save category: \(error.localizedDescription)")
            }
        }
    }

    func fetchStoredData() {
        // Fetch data for products, categories, and card offers from Core Data
        do {

            try MainViewModel.shared.productsFetchedResultsController.performFetch()
            try MainViewModel.shared.categoriesFetchedResultsController.performFetch()
            try MainViewModel.shared.cardOffersFetchedResultsController.performFetch()
            
            // Notify the UI that data has been loaded and is ready for display
            DispatchQueue.main.async {
                // Notify the view controllers or views that products have been updated
                MainViewModel.shared.onProductsUpdate?()
                MainViewModel.shared.onCategoriesUpdate?()
                MainViewModel.shared.onCardOffersUpdate?()
            }
        } catch {
            print("Failed to fetch data from Core Data: \(error.localizedDescription)")
        }
    }
}

