////
////  File.swift
////  
////
////  Created by Henry Hathaway on 9/17/19.
////
//
//import Foundation
//import AppKit
//import TestUtil
//@testable import AppKitUtilOutlineSelectionTracking
//@testable import AppKitUtilOutlineSelectionTrackingTestUtil
//
//func run() {
//    let n = 1_000_000
//    let model = TestModelController()
//    let window = NSWindow()
//    let scroll = NSScrollView()
//    let view = NSOutlineView()
//    let column = NSTableColumn()
//    var tracking = OutlineStateTree()
//    //var tracker = NSOutlineViewSelectionTracking()
//    var opcodePRNG = ReproduciblePRNG(n)
//    var rowSelPRNG = ReproduciblePRNG(n)
//
//    window.orderFront(nil)
//    window.setFrame(NSRect(x: 0, y: 0, width: 200, height: 200), display: true)
//    window.contentView?.addSubview(scroll)
//    scroll.frame = CGRect(x: 0, y: 0, width: 180, height: 180)
//    scroll.documentView = view
//    view.addTableColumn(column)
//    view.outlineTableColumn = column
//    view.dataSource = model
//    view.delegate = model
//    view.reloadData()
//    // Mark root as expanded.
//    tracking.isExpanded = true 
//    
//    //tracker.target = view
//    //tracker.resolveIndexPath = { n in (n as! TestModelNode).indexPath() }
//    model.note = { n in
//        switch n {
//        case .selectionDidChange:
//            // This is the only moment that tha `NSOutlineView` is properly sychronized
//            // and you can interact with it with no issue.
//            // Validate.
//            precondition(model.hiddenRoot.countAll() == tracking.totalCount)
//            for p in model.hiddenRoot.paths.dfs {
//                // In `NSOutlineView`, root is always represented as `nil`.
//                let node = p == [] ? nil : model.hiddenRoot[in: p]
//                precondition(view.isItemExpanded(node) == tracking[in: p].isExpanded)
//            }
//        }
//    }
//
//    var insertCount = 0
//    var removeCount = 0
//
//    var i = 0
//
//    func step() {
//        let opcode = opcodePRNG.nextWithRotation(in: 0..<8)
//        switch opcode {
//        case 0,1,2:
//            // Insert.
//            let p = model.hiddenRoot.makeRandomInsertionIndexPath()
//            let n = TestModelNode()
//            let parentNode = model.hiddenRoot[in: p.dropLast()]
//            parentNode.subtrees.insert(n, at: p.last!)
//            tracking[in: p.dropLast()].subtrees.insert(OutlineStateTree(), at: p.last!)
//            view.reloadData()
//            let nc = parentNode.subtrees[p.last!].countAll()
//            insertCount += nc
//        case 3,4:
//            // Remove.
//            guard let p = model.hiddenRoot.makeRandomDeletionIndexPath() else { break }
//            let parentNode = model.hiddenRoot[in: p.dropLast()]
//            let nc = parentNode.subtrees[p.last!].countAll()
//            parentNode.subtrees.remove(at: p.last!)
//            tracking[in: p.dropLast()].subtrees.remove(at: p.last!)
//            view.reloadData()
//            removeCount += nc
//        case 5,6:
//            // Expand.
//            guard let p = model.hiddenRoot.makeRandomExistingIndexPath() else { break }
//            for i in 0..<p.count {
//                let p1 = p[..<i]
//                let node = model.hiddenRoot[in: p1]
//                view.expandItem(node)
//                tracking[in: p1].isExpanded = true
//                // DO NOT expect expansion to finish immediately.
//            }
//            
//        case 7:
//            // Collapse.
//            guard let p = model.hiddenRoot.makeRandomExistingIndexPath() else { break }
//            let node = model.hiddenRoot[in: p]
//            view.collapseItem(node)
//            precondition(view.isItemExpanded(node) == false)
//            tracking[in: p].isExpanded = false
//        default:
//            break
//        }
//        
//        // Validate.
//    //    var query = NSOutlineViewSelectionTracking.Query?.none
//    //    tracker.note = { n in
//    //        switch n {
//    //        case let .readyToQuery(q):  query = q
//    //        }
//    //    }
//        view.selectRowIndexes([], byExtendingSelection: false)
//        precondition(view.selectedRowIndexes.count == 0)
//        view.selectRowIndexes(IndexSet(integersIn: 0..<view.numberOfRows), byExtendingSelection: false)
//        
//    //    precondition(view.numberOfRows == tracking.subtrees.totalVisibleCount)
//    //    precondition(query != nil)
//    //    for i in 0..<view.numberOfRows {
//    //        let p = query!.indexPathAtVisibleRowIndex(i)
//    //        let sourceNode = view.item(atRow: i)! as AnyObject
//    //        let targetNode = model.hiddenRoot[in: p]
//    //        precondition(sourceNode === targetNode)
//    //    }
//        
//        // Stat.
//        if i % 1_000 == 0 {
//            let aliveNodeCount = 1 + insertCount - removeCount
//            precondition(aliveNodeCount == model.hiddenRoot.countAll())
//            print("\(i)/\(n): nodes=\(aliveNodeCount) insert=\(insertCount), remove=\(removeCount)...")
//        }
//        i += 1
//        if i < n {
//            RunLoop.main.perform(inModes: [.common], block: {
//                step()
//            })
//        }
//    }
//    step()
//}
//
//final class AppDelegate: NSObject, NSApplicationDelegate {
//    func applicationDidFinishLaunching(_ notification: Notification) {
//        run()
//    }
//}
//let app = NSApplication.shared
//let appd = AppDelegate()
//app.delegate = appd
//app.run()
//
//
//
