import XCTest
import SwiftUI
@testable import NotionCard

final class ContentViewTests: XCTestCase {
    
    func testViewModeToggle() {
        let contentView = ContentView()
        
        // 测试初始状态
        XCTAssertEqual(contentView.viewMode, .cards, "初始视图模式应该是卡片模式")
        
        // 模拟视图模式切换
        contentView.viewMode = .grid
        XCTAssertEqual(contentView.viewMode, .grid, "视图模式应该成功切换到瀑布流模式")
        
        contentView.viewMode = .cards
        XCTAssertEqual(contentView.viewMode, .cards, "视图模式应该成功切换回卡片模式")
    }
    
    func testCardSelection() {
        let contentView = ContentView()
        
        // 测试卡片选择
        contentView.selectedIndex = 2
        XCTAssertEqual(contentView.selectedIndex, 2, "选中的卡片索引应该更新为2")
        
        // 测试滚动状态
        contentView.isScrolling = true
        XCTAssertTrue(contentView.isScrolling, "滚动状态应该正确更新")
        
        contentView.isScrolling = false
        XCTAssertFalse(contentView.isScrolling, "滚动状态应该正确重置")
    }
}