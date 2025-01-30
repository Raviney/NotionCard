import SwiftUI

struct FontConstants {
    static let titleSize: CGFloat = 24
    static let bodySize: CGFloat = 16
    static let chineseFontName = "Source Han Serif"
    static let englishFontName = ".SFUI-Serif"
}

enum ViewMode {
    case cards
    case grid
}

struct ContentView: View {
    @StateObject private var viewModel = CardViewModel()
    @State private var viewMode: ViewMode = .cards
    @State private var selectedIndex: Int = 0
    @State private var isScrolling = false
    @State private var lastTapTime = Date()
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                } else if let error = viewModel.error {
                    Text(error.localizedDescription)
                        .foregroundColor(.red)
                } else {
                    Group {
                        if viewMode == .cards {
                            TabView(selection: $selectedIndex) {
                                ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { index, item in
                                    SimpleCardView(item: item)
                                        .tag(index)
                                        .frame(maxHeight: .infinity)
                                        .simultaneousGesture(
                                            DragGesture(minimumDistance: 20)
                                                .onChanged { value in
                                                    let verticalTranslation = value.translation.height
                                                    let horizontalTranslation = value.translation.width
                                                    
                                                    if abs(horizontalTranslation) < abs(verticalTranslation) * 0.5 && verticalTranslation > 50 {
                                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0.2)) {
                                                            viewMode = .grid
                                                        }
                                                    }
                                                }
                                        )
                                }
                            }
                            .tabViewStyle(PageTabViewStyle())
                            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                        } else {
                            ScrollView {
                                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16)], spacing: 16) {
                                    ForEach(Array(viewModel.items.enumerated()), id: \.element.id) { index, item in
                                        SimpleCardView(item: item)
                                            .onTapGesture {
                                                let now = Date()
                                                if !isScrolling && now.timeIntervalSince(lastTapTime) > 0.3 {
                                                    lastTapTime = now
                                                    selectedIndex = index
                                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.55, blendDuration: 0.25)) {
                                                        viewMode = .cards
                                                    }
                                                }
                                            }
                                    }
                                }
                                .padding(16)
                            }
                            .gesture(
                                DragGesture(minimumDistance: 20)
                                    .onChanged { _ in
                                        isScrolling = true
                                    }
                                    .onEnded { value in
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            isScrolling = false
                                        }
                                        
                                        let verticalTranslation = value.translation.height
                                        let horizontalTranslation = value.translation.width
                                        
                                        if abs(horizontalTranslation) < abs(verticalTranslation) * 0.5 && verticalTranslation > 80 {
                                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0.3)) {
                                                viewMode = .cards
                                            }
                                        }
                                    }
                            )
                        }
                    }
                }
            }
            .navigationTitle("Notion Cards")
            .task {
                await viewModel.loadItems()
            }
        }
    }
}

struct SimpleCardView: View {
    let item: NotionItem
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                StyledText(richText: item.title)
                    .font(getFont(for: item.title.content, size: FontConstants.titleSize))
                    .fontWeight(.semibold)
                    .tracking(isChinese(text: item.title.content) ? 2.5 : 0.5)
                    .padding(.bottom, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                StyledText(richText: item.description)
                    .font(getFont(for: item.description.content, size: FontConstants.bodySize))
                    .fontWeight(.regular)
                    .lineSpacing(isChinese(text: item.description.content) ? 8 : 6)
                    .tracking(isChinese(text: item.description.content) ? 1.5 : 0.3)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(32)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
    }
}

struct StyledText: View {
    let richText: RichText
    
    var body: some View {
        Group {
            if richText.href != nil {
                Link(richText.content, destination: URL(string: richText.href!)!)
                    .applyTextStyle(annotations: richText.annotations)
            } else {
                Text(richText.content)
                    .applyTextStyle(annotations: richText.annotations)
            }
        }
    }
}

extension View {
    func applyTextStyle(annotations: TextAnnotations?) -> some View {
        self
            .italic(annotations?.italic ?? false)
            .bold(annotations?.bold ?? false)
            .strikethrough(annotations?.strikethrough ?? false)
            .underline(annotations?.underline ?? false)
            .foregroundColor(color(from: annotations?.color))
            .monospaced(annotations?.code ?? false)
    }
    
    private func color(from colorName: String?) -> Color {
        switch colorName {
        case "blue": return .blue
        case "red": return .red
        case "green": return .green
        case "yellow": return .yellow
        case "orange": return .orange
        case "purple": return .purple
        case "brown": return .brown
        case "pink": return .pink
        case "gray": return .gray
        case "default": return .primary
        case "gray_background": return .gray.opacity(0.2)
        case "brown_background": return .brown.opacity(0.2)
        case "orange_background": return .orange.opacity(0.2)
        case "yellow_background": return .yellow.opacity(0.2)
        case "green_background": return .green.opacity(0.2)
        case "blue_background": return .blue.opacity(0.2)
        case "purple_background": return .purple.opacity(0.2)
        case "pink_background": return .pink.opacity(0.2)
        case "red_background": return .red.opacity(0.2)
        default: return .primary
        }
    }
}

private func isChinese(text: String) -> Bool {
    text.contains { char in
        char.unicodeScalars.contains { scalar in
            scalar.value >= 0x4E00 && scalar.value <= 0x9FFF
        }
    }
}

private func getFont(for text: String, size: CGFloat) -> Font {
    if isChinese(text: text) {
        return .custom(FontConstants.chineseFontName, size: size)
    } else {
        return .custom(FontConstants.englishFontName, size: size)
    }
}

#Preview {
    ContentView()
}
