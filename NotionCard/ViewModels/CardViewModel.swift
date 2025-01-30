import Foundation

@MainActor
class CardViewModel: ObservableObject {
    @Published var items: [NotionItem] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let notionService = NotionService()
    
    func loadItems() async {
        isLoading = true
        error = nil
        
        do {
            items = try await notionService.fetchItems()
        } catch {
            self.error = error
            print("Error loading items: \(error)")
        }
        
        isLoading = false
    }
}
