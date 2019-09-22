import XCTest
@testable import AppKitUtilOutlineSelectionTracking
@testable import AppKitUtilOutlineSelectionTrackingTestUtil

final class AppKitUtilOutlineSelectionTrackingTests: XCTestCase {
    func testBasics() {
        var tx = OutlineStateTree()
        tx.isExpanded = true
        tx[in: []].subtrees.append(OutlineStateTree())
        tx[in: []].subtrees.append(OutlineStateTree())
        tx[in: [0]].isExpanded = true
        tx[in: [1]].isExpanded = true
        XCTAssertEqual(tx.totalCount, 3)
        XCTAssertEqual(tx.totalVisibleCount, 3)
        XCTAssertEqual(tx.subtrees.totalCount, 2)
        XCTAssertEqual(tx.subtrees.totalVisibleCount, 2)
        XCTAssertEqual(tx.subtrees.indexPathAtVisibleRowIndex(0), [0])
        XCTAssertEqual(tx.subtrees.indexPathAtVisibleRowIndex(1), [1])
        tx[in: [0]].subtrees.append(OutlineStateTree())
        tx[in: [0]].subtrees.append(OutlineStateTree())
        tx[in: [0]].subtrees.append(OutlineStateTree())
        XCTAssertEqual(tx.totalCount, 6)
        XCTAssertEqual(tx.totalVisibleCount, 6)
        XCTAssertEqual(tx.subtrees.totalCount, 5)
        XCTAssertEqual(tx.subtrees.totalVisibleCount, 5)
        XCTAssertEqual(tx.subtrees.indexPathAtVisibleRowIndex(0), [0])
        XCTAssertEqual(tx.subtrees.indexPathAtVisibleRowIndex(1), [0,0])
        XCTAssertEqual(tx.subtrees.indexPathAtVisibleRowIndex(2), [0,1])
        XCTAssertEqual(tx.subtrees.indexPathAtVisibleRowIndex(3), [0,2])
        XCTAssertEqual(tx.subtrees.indexPathAtVisibleRowIndex(4), [1])
        tx[in: [0]].isExpanded = false
        XCTAssertEqual(tx.totalCount, 6)
        XCTAssertEqual(tx.totalVisibleCount, 3)
        XCTAssertEqual(tx.subtrees.totalCount, 5)
        XCTAssertEqual(tx.subtrees.totalVisibleCount, 2)
        XCTAssertEqual(tx.subtrees.indexPathAtVisibleRowIndex(0), [0])
        XCTAssertEqual(tx.subtrees.indexPathAtVisibleRowIndex(1), [1])
        tx[in: [0,0]].subtrees.append(OutlineStateTree())
        tx[in: [0,0]].subtrees.append(OutlineStateTree())
        tx[in: [0,0]].subtrees.append(OutlineStateTree())
        XCTAssertEqual(tx.totalCount, 9)
        XCTAssertEqual(tx.totalVisibleCount, 3)
        XCTAssertEqual(tx.subtrees.totalCount, 8)
        XCTAssertEqual(tx.subtrees.totalVisibleCount, 2)
        XCTAssertEqual(tx.subtrees.indexPathAtVisibleRowIndex(0), [0])
        XCTAssertEqual(tx.subtrees.indexPathAtVisibleRowIndex(1), [1])
        tx[in: [0]].isExpanded = true
        XCTAssertEqual(tx.totalCount, 9)
        XCTAssertEqual(tx.totalVisibleCount, 6)
        XCTAssertEqual(tx.subtrees.totalCount, 8)
        XCTAssertEqual(tx.subtrees.totalVisibleCount, 5)
        XCTAssertEqual(tx.subtrees.indexPathAtVisibleRowIndex(0), [0])
        XCTAssertEqual(tx.subtrees.indexPathAtVisibleRowIndex(1), [0,0])
        XCTAssertEqual(tx.subtrees.indexPathAtVisibleRowIndex(2), [0,1])
        XCTAssertEqual(tx.subtrees.indexPathAtVisibleRowIndex(3), [0,2])
        XCTAssertEqual(tx.subtrees.indexPathAtVisibleRowIndex(4), [1])
        tx[in: [0,0]].isExpanded = true
        XCTAssertEqual(tx.totalCount, 9)
        XCTAssertEqual(tx.totalVisibleCount, 9)
        XCTAssertEqual(tx.subtrees.totalCount, 8)
        XCTAssertEqual(tx.subtrees.totalVisibleCount, 8)
        XCTAssertEqual(tx.subtrees.indexPathAtVisibleRowIndex(0), [0])
        XCTAssertEqual(tx.subtrees.indexPathAtVisibleRowIndex(1), [0,0])
        XCTAssertEqual(tx.subtrees.indexPathAtVisibleRowIndex(2), [0,0,0])
        XCTAssertEqual(tx.subtrees.indexPathAtVisibleRowIndex(3), [0,0,1])
        XCTAssertEqual(tx.subtrees.indexPathAtVisibleRowIndex(4), [0,0,2])
        XCTAssertEqual(tx.subtrees.indexPathAtVisibleRowIndex(5), [0,1])
        XCTAssertEqual(tx.subtrees.indexPathAtVisibleRowIndex(6), [0,2])
        XCTAssertEqual(tx.subtrees.indexPathAtVisibleRowIndex(7), [1])
        tx[in: [0]].isExpanded = false
        XCTAssertEqual(tx.totalCount, 9)
        XCTAssertEqual(tx.totalVisibleCount, 3)
        XCTAssertEqual(tx.subtrees.totalCount, 8)
        XCTAssertEqual(tx.subtrees.totalVisibleCount, 2)
        XCTAssertEqual(tx.subtrees.indexPathAtVisibleRowIndex(0), [0])
        XCTAssertEqual(tx.subtrees.indexPathAtVisibleRowIndex(1), [1])
    }
}
