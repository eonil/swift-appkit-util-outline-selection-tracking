//
//  File.swift
//  
//
//  Created by Henry Hathaway on 9/17/19.
//

import Foundation
import AppKit
import Tree2
import TestUtil

final class TestModelController: NSObject, NSOutlineViewDataSource, NSOutlineViewDelegate {
    var hiddenRoot = TestModelNode()
    func objectForNSOutlineView(at path:IndexPath) -> TestModelNode? {
        if path == [] { return nil }
        return hiddenRoot[in: path]
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        let n = item as! TestModelNode? ?? hiddenRoot
        return n.subtrees.count
    }
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        let n = item as! TestModelNode? ?? hiddenRoot
        return n.subtrees[index]
    }
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return true
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        return NSView()
    }
    func outlineViewSelectionDidChange(_ notification: Notification) {
        note?(.selectionDidChange)
    }
    var note: ((Note) -> Void)?
    enum Note {
        case selectionDidChange
    }
}
