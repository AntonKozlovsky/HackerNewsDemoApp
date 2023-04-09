import Foundation

class HackerNewsManager {
    
    private let api = HackerNewsAPI()
}

extension HackerNewsManager {
        
    func loadBestStories()  async throws -> [StoryDto] {
        
        let itemsIdList = try await api.loadBestStoriesIdList()
        
        var loadedItemList: [StoryDto] = []
        
        for itemId in itemsIdList {
            
            let loadedItem = try await api.loadItem(by: itemId)
            loadedItemList.append(loadedItem)
        }
        
        return loadedItemList.sorted { s1, s2 in
            s1.time < s2.time
        }
    }
}

