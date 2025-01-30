import Foundation
import SystemConfiguration

struct NotionResponse: Codable {
    let results: [NotionPage]
}

struct NotionPage: Codable {
    let id: String
    let lastEditedTime: String
    let properties: Properties
    
    enum CodingKeys: String, CodingKey {
        case id
        case lastEditedTime = "last_edited_time"
        case properties
    }
}

struct Properties: Codable {
    let name: TitleProperty
    let description: RichTextProperty
    let tags: MultiSelectProperty
}

struct TitleProperty: Codable {
    let title: [TextContent]
}

struct RichTextProperty: Codable {
    let richText: [TextContent]
    
    enum CodingKeys: String, CodingKey {
        case richText = "rich_text"
    }
}

struct MultiSelectProperty: Codable {
    let multiSelect: [Tag]
    
    enum CodingKeys: String, CodingKey {
        case multiSelect = "multi_select"
    }
}

struct TextContent: Codable {
    let plainText: String
    let annotations: Annotations?
    let type: String
    let href: String?
    
    enum CodingKeys: String, CodingKey {
        case plainText = "plain_text"
        case annotations
        case type
        case href
    }
}

struct Annotations: Codable {
    let bold: Bool
    let italic: Bool
    let strikethrough: Bool
    let underline: Bool
    let code: Bool
    let color: String
}

struct Tag: Codable {
    let name: String
}

class NotionService {
    private let apiKey: String
    private let databaseId: String
    
    init() {
        // 从环境变量获取配置
        self.apiKey = ProcessInfo.processInfo.environment["NOTION_API_KEY"] ?? ""
        self.databaseId = ProcessInfo.processInfo.environment["NOTION_DATABASE_ID"] ?? ""
        
        // 验证配置
        guard !apiKey.isEmpty else {
            fatalError("NOTION_API_KEY not found in environment variables")
        }
        guard !databaseId.isEmpty else {
            fatalError("NOTION_DATABASE_ID not found in environment variables")
        }
    }
    
    func fetchItems() async throws -> [NotionItem] {
        guard let url = URL(string: "https://api.notion.com/v1/databases/\(databaseId)/query") else {
            throw NotionError.invalidConfiguration("Invalid database ID")
        }
        
        // 检查网络连接状态
        if !isNetworkReachable() {
            throw NotionError.networkError("No network connection available")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("2022-06-28", forHTTPHeaderField: "Notion-Version")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30 // 设置30秒超时
        
        // 添加重试机制
        let maxRetries = 3
        var retryCount = 0
        
        while retryCount < maxRetries {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NotionError.networkError("Invalid response type")
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    let decoder = JSONDecoder()
                    let notionResponse = try decoder.decode(NotionResponse.self, from: data)
                    return try parseNotionResponse(notionResponse)
                case 401:
                    throw NotionError.authenticationError("Invalid API key")
                case 404:
                    throw NotionError.notFound("Database not found")
                case 429: // Rate limit
                    if retryCount < maxRetries - 1 {
                        try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(retryCount)) * 1_000_000_000))
                        retryCount += 1
                        continue
                    }
                    throw NotionError.serverError("Rate limit exceeded")
                default:
                    throw NotionError.serverError("Server returned status code: \(httpResponse.statusCode)")
                }
            } catch let error as NotionError {
                throw error
            } catch {
                if retryCount < maxRetries - 1 && (error as NSError).code == NSURLErrorNotConnectedToInternet {
                    try await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(retryCount)) * 1_000_000_000))
                    retryCount += 1
                    continue
                }
                throw NotionError.networkError(error.localizedDescription)
            }
        }
        
        throw NotionError.networkError("Failed after \(maxRetries) retries")
    }
    
    private func isNetworkReachable() -> Bool {
        var flags = SCNetworkReachabilityFlags()
        let reachability = SCNetworkReachabilityCreateWithName(nil, "api.notion.com")
        
        guard let reachabilityRef = reachability,
              SCNetworkReachabilityGetFlags(reachabilityRef, &flags) else {
            print("无法获取网络状态标志")
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let canConnectWithoutUserInteraction = canConnectAutomatically && !flags.contains(.interventionRequired)
        
        let isNetworkReachable = isReachable && (!needsConnection || canConnectWithoutUserInteraction)
        
        if !isNetworkReachable {
            print("网络不可达：isReachable=\(isReachable), needsConnection=\(needsConnection), canConnectWithoutUserInteraction=\(canConnectWithoutUserInteraction)")
        }
        
        return isNetworkReachable
    }
    
    private func parseNotionResponse(_ response: NotionResponse) throws -> [NotionItem] {
        return response.results.map { page in
            let titleText = page.properties.name.title.map { content in
                RichText(
                    content: content.plainText,
                    annotations: content.annotations.map { annotations in
                        TextAnnotations(
                            bold: annotations.bold,
                            italic: annotations.italic,
                            strikethrough: annotations.strikethrough,
                            underline: annotations.underline,
                            code: annotations.code,
                            color: annotations.color
                        )
                    },
                    href: content.href
                )
            }.first ?? RichText(content: "Untitled", annotations: nil, href: nil)
            
            let descriptionTexts = page.properties.description.richText.map { content in
                RichText(
                    content: content.plainText,
                    annotations: content.annotations.map { annotations in
                        TextAnnotations(
                            bold: annotations.bold,
                            italic: annotations.italic,
                            strikethrough: annotations.strikethrough,
                            underline: annotations.underline,
                            code: annotations.code,
                            color: annotations.color
                        )
                    },
                    href: content.href
                )
            }
            
            let combinedDescription = RichText(
                content: descriptionTexts.map { $0.content }.joined(separator: "\n"),
                annotations: descriptionTexts.first?.annotations,
                href: descriptionTexts.first?.href
            )
            
            return NotionItem(
                id: page.id,
                title: titleText,
                description: combinedDescription,
                lastEdited: ISO8601DateFormatter().date(from: page.lastEditedTime) ?? Date(),
                tags: page.properties.tags.multiSelect.map { $0.name }
            )
        }
    }
}

enum NotionError: LocalizedError {
    case invalidConfiguration(String)
    case authenticationError(String)
    case networkError(String)
    case serverError(String)
    case notFound(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidConfiguration(let message):
            return "Configuration error: \(message)"
        case .authenticationError(let message):
            return "Authentication error: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .notFound(let message):
            return "Not found: \(message)"
        }
    }
}
