import Foundation
import Network

class HackerNewsAPI {
    
    func loadBestStoriesIdList() async throws -> [Int] {
        try await getItems(from: Constants.storiesEndPoint)
    }
    
    func loadItem(by itemId: Int) async throws -> StoryDto {
        
        let urlPath = String(format: Constants.itemEndPoint, itemId)
        return try await getItems(from: urlPath)
    }
}
 
extension HackerNewsAPI {
    
    private func getItems<T: Decodable>(from urlPath: String) async throws -> T {
        guard let endpointURL = URL(string: urlPath) else {
            throw APIError.unknownError
        }
        
        let request = URLRequest(url: endpointURL)
        let response = try await URLSession
            .shared
            .data(for: request)
        
        guard (response.1 as! HTTPURLResponse).statusCode == 200 else {
            throw APIError.unknownError
        }
        
        return try JSONDecoder().decode(T.self, from: response.0)
    }
}

extension HackerNewsAPI {
    
    enum APIError: Error {
        case unknownError
    }
}

private extension HackerNewsAPI {
    
    struct Constants {
        static let storiesEndPoint = "https://hacker-news.firebaseio.com/v0/topstories.json"
        static let itemEndPoint = "https://hacker-news.firebaseio.com/v0/item/%d.json"
    }
}
