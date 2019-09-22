//
//  File.swift
//  
//
//  Created by Henry Hathaway on 9/17/19.
//

import AppKit
import TestUtil
@testable import AppKitUtilOutlineSelectionTracking
@testable import AppKitUtilOutlineSelectionTrackingTestUtil



let MILLION = 1_000_000
let model = TestModelController()
let window = NSWindow()
let view = NSOutlineView()
let column = NSTableColumn()
var tracking = OutlineStateTree()
var opcodePRNG = ReproduciblePRNG(MILLION)
var rowSelPRNG = ReproduciblePRNG(MILLION)
window.orderFront(nil)
window.setFrame(NSRect(x: 0, y: 0, width: 50, height: 50), display: true)
window.contentView = view
window.display()
view.addTableColumn(column)
view.outlineTableColumn = column
view.dataSource = model
view.delegate = model
view.reloadData()

func validate() {
//    for p in model.hiddenRoot.paths.dfs {
//        guard p != [] else { continue }
//        let objectForNSOV = model.objectForNSOutlineView(at: p)
//        let a = tracking.isExpandedUsingNSOutlineViewReportingRules(at: p)
//        let b = view.isItemExpanded(objectForNSOV)
//        precondition(a == b)
//    }
    let a = view.scanOutlineState(for: nil)
    var b = tracking
    b.collapseAllHiddenItemsUsingNSOutlineViewReportingRules()
    
    precondition(a == b)
//    let viewVisibleRowCount = view.numberOfRows
//    let trackingVisibleNodeCountExceptRoot = tracking.subtrees.totalVisibleCount
//    precondition(viewVisibleRowCount == trackingVisibleNodeCountExceptRoot)
}

var insertCount = 0
var removeCount = 0
for i in 0..<MILLION {
    let opcode = opcodePRNG.nextWithRotation(in: 0..<7)
    switch opcode {
    case 0,1,2:
        // Insert.
        let targetPath = model.hiddenRoot.makeRandomInsertionIndexPath()
        guard targetPath != [] else { break }
        let targetIndex = targetPath.last!
        let parentPath = targetPath.dropLast()
        let newNode = TestModelNode()
        let parentNode = model.hiddenRoot[in: parentPath]
        parentNode.subtrees.insert(newNode, at: targetIndex)
        let parentObjectInNSOV = model.objectForNSOutlineView(at: parentPath)
        view.insertItems(at: [targetIndex], inParent: parentObjectInNSOV, withAnimation: [])
        view.reloadData()
        tracking[in: parentPath].subtrees.insert(OutlineStateTree(), at: targetIndex)
        let insertedNodeCount = parentNode.subtrees[targetIndex].countAll()
        insertCount += insertedNodeCount
        validate()
    case 3,4:
        // Remove.
        guard let targetPath = model.hiddenRoot.makeRandomDeletionIndexPath() else { break }
        guard targetPath != [] else { break }
        let targetIndex = targetPath.last!
        let parentPath = targetPath.dropLast()
        let parentNode = model.hiddenRoot[in: parentPath]
        let removingNodeCount = parentNode.subtrees[targetIndex].countAll()
        parentNode.subtrees.remove(at: targetIndex)
        let parentObjectInNSOV = model.objectForNSOutlineView(at: parentPath)
        view.removeItems(at: [targetIndex], inParent: parentObjectInNSOV, withAnimation: [])
        view.reloadData()
        tracking[in: parentPath].subtrees.remove(at: targetIndex)
        removeCount += removingNodeCount
        validate()
    case 5:
        // Expand.
        guard let targetPath = model.hiddenRoot.makeRandomExistingIndexPath() else { break }
        guard targetPath != [] else { break }
        for i in 0..<targetPath.count {
            let path = targetPath[..<i]
            let objectInNSOV = model.objectForNSOutlineView(at: path)
            view.expandItem(objectInNSOV, expandChildren: false)
            precondition(view.isItemExpanded(objectInNSOV))
            tracking[in: path].isExpanded = true
            validate()
        }
    case 6:
        // Collapse.
        guard let targetPath = model.hiddenRoot.makeRandomExistingIndexPath() else { break }
        guard targetPath != [] else { break }
        let targetObjectInNSOV = model.objectForNSOutlineView(at: targetPath)
        view.collapseItem(targetObjectInNSOV, collapseChildren: false)
        precondition(view.isItemExpanded(targetObjectInNSOV) == false)
        tracking[in: targetPath].isExpanded = false
        validate()
    default:
        break
    }
    
//    precondition(query != nil)

    
//    for i in 0..<view.numberOfRows {
//        let p = query!.indexPathAtVisibleRowIndex(i)
//        let sourceNode = view.item(atRow: i)! as AnyObject
//        let targetNode = model.hiddenRoot[in: p]
//        precondition(sourceNode === targetNode)
//    }
    
    // Stat.
    if i % 1_000 == 0 {
        let aliveNodeCount = 1 + insertCount - removeCount
        precondition(aliveNodeCount == model.hiddenRoot.countAll())
        print("\(i)/\(MILLION): nodes=\(aliveNodeCount) insert=\(insertCount), remove=\(removeCount)...")
    }
}
