import Foundation

struct NotionItem: Identifiable {
    let id: String
    let title: RichText
    let description: RichText
    let lastEdited: Date
    let tags: [String]
}

struct RichText {
    let content: String
    let annotations: TextAnnotations?
    let href: String?
}

struct TextAnnotations {
    let bold: Bool
    let italic: Bool
    let strikethrough: Bool
    let underline: Bool
    let code: Bool
    let color: String
}