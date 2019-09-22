//
//  File.swift
//  
//
//  Created by Henry Hathaway on 9/17/19.
//

import Foundation
import XCTest
import AppKit
@testable import AppKitUtilOutlineSelectionTracking
@testable import AppKitUtilOutlineSelectionTrackingTestUtil

final class NSOutlineViewPitfallTests: XCTestCase {
    func testBasicExpansion() {
        let view = NSOutlineView()
        let model = TestModelController()
        view.dataSource = model
        view.delegate = model
        let hr = model.hiddenRoot
        let c1 = TestModelNode()
        let c2 = TestModelNode()
        hr.subtrees.append(c1)
        c1.subtrees.append(c2)
        view.reloadData()
        view.expandItem(c1)
        XCTAssertTrue(view.isItemExpanded(c1))
        XCTAssertFalse(view.isItemExpanded(c2))
    }
    func testLeafNodeExpansion() {
        let view = NSOutlineView()
        let model = TestModelController()
        view.dataSource = model
        view.delegate = model
        let hr = model.hiddenRoot
        let c1 = TestModelNode()
        let c2 = TestModelNode()
        let c3 = TestModelNode()
        hr.subtrees.append(c1)
        c1.subtrees.append(c2)
        c2.subtrees.append(c3)
        view.reloadData()
        view.expandItem(c2)
        XCTAssertEqual(view.isItemExpanded(c1), false)
        XCTAssertEqual(view.isItemExpanded(c2), false)
        XCTAssertEqual(view.isItemExpanded(c3), false)
        view.expandItem(c3)
        XCTAssertEqual(view.isItemExpanded(c1), false)
        XCTAssertEqual(view.isItemExpanded(c2), false)
        XCTAssertEqual(view.isItemExpanded(c3), false)
        view.expandItem(c1)
        XCTAssertEqual(view.isItemExpanded(c1), true)
        XCTAssertEqual(view.isItemExpanded(c2), false)
        XCTAssertEqual(view.isItemExpanded(c3), false)
        view.expandItem(c2)
        XCTAssertEqual(view.isItemExpanded(c1), true)
        XCTAssertEqual(view.isItemExpanded(c2), true)
        XCTAssertEqual(view.isItemExpanded(c3), false)
        view.expandItem(c3)
        XCTAssertEqual(view.isItemExpanded(c1), true)
        XCTAssertEqual(view.isItemExpanded(c2), true)
        XCTAssertEqual(view.isItemExpanded(c3), true)
    }
    func testCollapsingRoot() {
        let view = NSOutlineView()
        let model = TestModelController()
        view.dataSource = model
        view.delegate = model
        let hr = model.hiddenRoot
        let c1 = TestModelNode()
        let c2 = TestModelNode()
        let c3 = TestModelNode()
        hr.subtrees.append(c1)
        c1.subtrees.append(c2)
        c2.subtrees.append(c3)
        view.reloadData()
        view.expandItem(nil, expandChildren: true)
        XCTAssertEqual(view.isItemExpanded(nil), true)
        XCTAssertEqual(view.isItemExpanded(c1), true)
        XCTAssertEqual(view.isItemExpanded(c2), true)
        XCTAssertEqual(view.isItemExpanded(c3), true)
        view.collapseItem(nil)
        XCTAssertEqual(view.isItemExpanded(nil), true)
        XCTAssertEqual(view.isItemExpanded(c1), false)
        XCTAssertEqual(view.isItemExpanded(c2), false)
        XCTAssertEqual(view.isItemExpanded(c3), false)
    }
    func testCollapsingIntermediateNode() {
        let view = NSOutlineView()
        let model = TestModelController()
        view.dataSource = model
        view.delegate = model
        let hr = model.hiddenRoot
        let c1 = TestModelNode()
        let c2 = TestModelNode()
        let c3 = TestModelNode()
        hr.subtrees.append(c1)
        c1.subtrees.append(c2)
        c2.subtrees.append(c3)
        view.reloadData()
        // Expand all.
        view.expandItem(nil, expandChildren: true)
        XCTAssertEqual(view.isItemExpanded(nil), true)
        XCTAssertEqual(view.isItemExpanded(c1), true)
        XCTAssertEqual(view.isItemExpanded(c2), true)
        XCTAssertEqual(view.isItemExpanded(c3), true)
        // Collapse only one.
        // `NSOutlineView` reports as everyone if collapsed.
        view.collapseItem(c2, collapseChildren: false)
        XCTAssertEqual(view.isItemExpanded(nil), true)
        XCTAssertEqual(view.isItemExpanded(c1), true)
        XCTAssertEqual(view.isItemExpanded(c2), false)
        XCTAssertEqual(view.isItemExpanded(c3), false)
        // Expand the node again.
        // But actually it remembers which one not collapsed
        // and recovers them as expanded.
        view.expandItem(c2, expandChildren: false)
        XCTAssertEqual(view.isItemExpanded(nil), true)
        XCTAssertEqual(view.isItemExpanded(c1), true)
        XCTAssertEqual(view.isItemExpanded(c2), true)
        XCTAssertEqual(view.isItemExpanded(c3), true)
    }
}
