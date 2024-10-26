//
//  ViewModel.swift
//  SampleProject1
//
//  Created by thiruvazhagan on 19/09/24.
//
import CoreData
import UIKit

class MainViewModel: NSObject,NSFetchedResultsControllerDelegate {
    
    static let shared = MainViewModel(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
    
    var selectedCategoryId: String? = nil
    var selectedOfferId: String? = nil
    
    var onProductsUpdate: (() -> Void)?
    var onCategoriesUpdate: (() -> Void)?
    var onCardOffersUpdate: (() -> Void)?
    
    var categories: [CategoryEntity] = [] {
        didSet {
            onCategoriesUpdate?()
        }
    }
    var allOffers: [CardOffers] = []
    var cardOffers: [CardOffers] = [] {
        didSet {
            onCardOffersUpdate?()
        }
    }
    var onFilteredProductsUpdate: (() -> Void)?
    
    public var context: NSManagedObjectContext
    
    // Make the initializer private so the singleton is enforced
    private init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    public lazy var productsFetchedResultsController: NSFetchedResultsController<ProductsEntity> = {
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        return setupFetchedResultsController(for: "ProductsEntity", sortDescriptor: sortDescriptor)
    }()
    
    public lazy var categoriesFetchedResultsController: NSFetchedResultsController<CategoryEntity> = {
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        return setupFetchedResultsController(for: "CategoryEntity", sortDescriptor: sortDescriptor)
    }()
    
    public lazy var cardOffersFetchedResultsController: NSFetchedResultsController<CardOffers> = {
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        return setupFetchedResultsController(for: "CardOffers", sortDescriptor: sortDescriptor)
    }()
    
    private func setupFetchedResultsController<T: NSManagedObject>(for entityName: String, sortDescriptor: NSSortDescriptor, predicate: NSPredicate? = nil) -> NSFetchedResultsController<T> {
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }
    
    func fetchStoredData() {
        do {
            try productsFetchedResultsController.performFetch()
            try categoriesFetchedResultsController.performFetch()
            try cardOffersFetchedResultsController.performFetch()
            
            // Data is fetched, you can trigger updates here or in delegate methods
            onProductsUpdate?()
            onCategoriesUpdate?()
            onCardOffersUpdate?()
            
        } catch {
            print("Failed to fetch data: \(error.localizedDescription)")
        }
    }
    
    // NSFetchedResultsController delegate methods
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        if controller == productsFetchedResultsController {
            onProductsUpdate?()  // Notify when products change
        } else if controller == categoriesFetchedResultsController {
            onCategoriesUpdate?()  // Notify when categories change
        } else if controller == cardOffersFetchedResultsController {
            onCardOffersUpdate?()  // Notify when offers change
            onProductsUpdate?()
        }
        
    }
    
    func filterProducts() {
        var predicates: [NSPredicate] = []
        
        // Filter by selected category
        if let categoryId = selectedCategoryId {
            predicates.append(NSPredicate(format: "categoryID == %@", categoryId))
        }
        
        // Filter by selected offer
        if let offerId = selectedOfferId {
            predicates.append(NSPredicate(format: "ANY offersids.id == %@", offerId))
        }
        
        // Apply the predicate to the fetch request
        let compoundPredicate = predicates.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        productsFetchedResultsController.fetchRequest.predicate = compoundPredicate
        
        do {
            try productsFetchedResultsController.performFetch()
            onProductsUpdate?()
            
        } catch {
            print("Failed to fetch filtered products: \(error.localizedDescription)")
        }
    }
    
    func filterProducts(bySearchTerm searchTerm: String = "") {
        var predicates: [NSPredicate] = []
        
        // Filter by category and offer
        if let categoryId = selectedCategoryId {
            predicates.append(NSPredicate(format: "categoryID == %@", categoryId))
        }
        if let offerId = selectedOfferId {
            predicates.append(NSPredicate(format: "ANY offersids.id == %@", offerId))
        }
        
        // Add search term filtering
        if !searchTerm.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@", searchTerm))
        }
        
        let compoundPredicate = predicates.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        productsFetchedResultsController.fetchRequest.predicate = compoundPredicate
        
        do {
            try productsFetchedResultsController.performFetch()
            onProductsUpdate?()
        } catch {
            print("Failed to fetch filtered products: \(error.localizedDescription)")
        }
    }
    
    func filterProducts(byCategory category: String?) {
        let predicate: NSPredicate
        if let category = category {
            predicate = NSPredicate(format: "categoryID == %@", category)
        } else {
            predicate = NSPredicate(value: true)
        }
        
        // Update the predicate for the fetched results controller
        productsFetchedResultsController.fetchRequest.predicate = predicate
        
        do {
            // Perform the fetch
            try productsFetchedResultsController.performFetch()
            
            // Since NSFetchedResultsController handles updates, just notify the view
            onProductsUpdate?()
            
        } catch {
            print("Failed to fetch products for category \(category ?? "all"): \(error.localizedDescription)")
        }
    }
    
    func resetFilteredProducts() {
        // Remove any existing predicates to fetch all products
        productsFetchedResultsController.fetchRequest.predicate = nil
        
        do {
            // Perform the fetch without any filtering
            try productsFetchedResultsController.performFetch()
            
            // Notify the view that the products have been updated
            onProductsUpdate?()
            
        } catch {
            print("Failed to reset filtered products: \(error.localizedDescription)")
        }
    }
    
    func filterOffersForSelectedCategory() {
        
        guard let categoryId = selectedCategoryId else {
            
            cardOffersFetchedResultsController.fetchRequest.predicate = nil
            do {
                try cardOffersFetchedResultsController.performFetch()
                onCardOffersUpdate?()
            } catch {
                print("Failed to fetch all offers: \(error.localizedDescription)")
            }
            return
        }
        
        // Set up a predicate to filter offers based on the products in the selected category
        let productPredicate = NSPredicate(format: "ANY products.categoryID == %@", categoryId)
        cardOffersFetchedResultsController.fetchRequest.predicate = productPredicate
        
        do {
            
            try cardOffersFetchedResultsController.performFetch()
            onCardOffersUpdate?()
            
        } catch {
            print("Failed to fetch offers for category \(categoryId): \(error.localizedDescription)")
        }
    }
    
    func filterProducts(byOffer offerId: String?) {
        let predicate: NSPredicate
        
        if let offerId = offerId {
            // Filter by offer ID (relationship-based filtering)
            predicate = NSPredicate(format: "ANY offersids.id == %@", offerId)
        } else {
            // No offer selected, fetch all products
            predicate = NSPredicate(value: true)  // This will fetch all products without filtering
        }
        
        // Apply the predicate to the fetch request of the NSFetchedResultsController
        productsFetchedResultsController.fetchRequest.predicate = predicate
        
        do {
            // Perform the fetch with the new predicate
            try productsFetchedResultsController.performFetch()
            print("Offer fetched successfully")
            // Notify the view to update with the filtered products
            onProductsUpdate?()
            
        } catch {
            print("Failed to fetch products for offer \(offerId ?? "all"): \(error.localizedDescription)")
        }
    }
    
    func clearSelectedOffer() {
        // Remove the offer filter by setting predicate to nil or keeping only the category filter
        selectedOfferId = nil
        filterProducts() // Reapply filtering based on the current category or any other criteria
    }
    
    func filterAndSortProducts(by sortingCriteria: String) {
        var predicates: [NSPredicate] = []
        
        // Step 1: Filter by the selected category 
        if let categoryId = selectedCategoryId {
            let categoryPredicate = NSPredicate(format: "categoryID == %@", categoryId)
            predicates.append(categoryPredicate)
        }
        
        // Combine all predicates into one
        let compoundPredicate = predicates.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        // Apply the predicate to the fetched results controller's fetch request
        productsFetchedResultsController.fetchRequest.predicate = compoundPredicate
        
        // Step 2: Apply sorting based on the criteria
        let sortDescriptor: NSSortDescriptor
        switch sortingCriteria {
        case "Rating":
            sortDescriptor = NSSortDescriptor(key: "rating", ascending: false)
        case "Price":
            sortDescriptor = NSSortDescriptor(key: "price", ascending: false)
        default:
            sortDescriptor = NSSortDescriptor(key: "name", ascending: true) // Default sorting by name
        }
        
        // Apply the sort descriptor
        productsFetchedResultsController.fetchRequest.sortDescriptors = [sortDescriptor]
        
        do {

            try productsFetchedResultsController.performFetch()
            onProductsUpdate?()
            
        } catch {
            print("Failed to fetch filtered and sorted products: \(error.localizedDescription)")
        }
    }
}

