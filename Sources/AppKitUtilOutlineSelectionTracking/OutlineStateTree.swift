//
//  File.swift
//  
//
//  Created by Henry Hathaway on 9/17/19.
//

import Foundation
import Tree2

struct OutlineStateTree: TreeProtocol, MutableTreeProtocol, ReplaceableTreeProtocol, Equatable {
    var isExpanded = false
    var subtrees = Subtrees()
    
    init() {}
    var totalCount: Int {
        return 1 + subtrees.totalCount
    }
    var totalVisibleCount: Int {
        return isExpanded ? 1 + subtrees.totalVisibleCount : 1
    }
    struct Subtrees: RandomAccessCollection, MutableCollection, RangeReplaceableCollection, Equatable {
        private var impl = [OutlineStateTree]()
        private(set) var totalCount = 0
        private(set) var totalVisibleCount = 0
        var startIndex: Int { impl.startIndex }
        var endIndex: Int { impl.endIndex }
        subscript(_ i:Int) -> OutlineStateTree {
            get { impl[i] }
            set(x) { replaceSubrange(i..<i+1, with: CollectionOfOne(x)) }
        }
        subscript(_ r:Range<Int>) -> ArraySlice<OutlineStateTree> {
            get { impl[r] }
            set(x) { replaceSubrange(r, with: x) }
        }
        mutating func replaceSubrange<C, R>(_ subrange:R, with newElements:C) where C : Collection, R : RangeExpression, Element == C.Element, Index == R.Bound {
            let q = subrange.relative(to: self)
            let removings = impl[q]
            totalCount -= removings.lazy.map({ $0.totalCount }).reduce(0, +)
            totalVisibleCount -= removings.lazy.map({ $0.totalVisibleCount }).reduce(0, +)
            impl.replaceSubrange(subrange, with: newElements)
            totalCount += newElements.lazy.map(({ $0.totalCount })).reduce(0, +)
            totalVisibleCount += newElements.lazy.map({ $0.totalVisibleCount }).reduce(0, +)
        }
        func indexPathAtVisibleRowIndex(_ visibleRowOffset:Int) -> IndexPath {
            var checkedRowCount = 0
            var checkedNodeCount = 0
            while checkedNodeCount < totalVisibleCount {
                let nodeTotalVisibleCount = impl[checkedRowCount].totalVisibleCount
                let nodeRowOffsetRange = checkedNodeCount..<checkedNodeCount+nodeTotalVisibleCount
                if nodeRowOffsetRange.contains(visibleRowOffset) {
                    /// If offset matches, return the node itself.
                    if checkedNodeCount == visibleRowOffset { return [checkedRowCount] }
                    let subindexPath = impl[checkedRowCount]
                        .subtrees
                        .indexPathAtVisibleRowIndex(visibleRowOffset - checkedNodeCount - 1)
                    return IndexPath(index: checkedRowCount).appending(subindexPath)
                }
                checkedRowCount += 1
                checkedNodeCount += nodeTotalVisibleCount
            }
            assert(checkedNodeCount == totalVisibleCount)
            fatalError("Supplied row index offset is out of range.")
        }
    }
}
extension OutlineStateTree {
    /// Applies some rules to replicate NSOutlineView's expansion state reporting rules.
    /// This is provided only for testing.
    func isExpandedUsingNSOutlineViewReportingRules(at targetPath :IndexPath) -> Bool {
        if targetPath == [] { return true }
        for i in 0..<targetPath.count {
            let subpath = targetPath[..<i]
            if self[in: subpath].isExpanded == false { return false }
        }
        return self[in: targetPath].isExpanded
    }
    mutating func collapseAllHiddenItemsUsingNSOutlineViewReportingRules() {
        var collapsedPaths = [IndexPath]()
        for p in paths.dfs {
            if p == [] {
                self[in: p].isExpanded = true
            }
            else {
                if self[in: p].isExpanded == false {
                    collapsedPaths.append(p)
                }
                else {
                    for i in 0..<p.count {
                        let p1 = p[..<i]
                        if collapsedPaths.contains(p1) {
                            self[in: p].isExpanded = false
                        }
                    }
                }
            }
        }
    }
}


import AppKit
extension NSOutlineView {
    func item(at targetPath: IndexPath) -> AnyObject? {
        if targetPath == [] { return nil }
        let superitem = item(at: targetPath.dropLast())
        return child(targetPath.last!, ofItem: superitem) as AnyObject
    }
    func scanOutlineState(at targetPath: IndexPath) -> OutlineStateTree {
        return scanOutlineState(for: item(at: targetPath))
    }
    /// BEWARE! Resulting state can be different with actual underlying state.
    /// You can perform test only by calling `isExpandedUsingNSOutlineViewReportingRules`.
    func scanOutlineState(for item: AnyObject?) -> OutlineStateTree {
        var x = OutlineStateTree()
        x.isExpanded = true
        for i in 0..<numberOfChildren(ofItem: item) {
            let subitem = child(i, ofItem: item) as AnyObject?
            var cx = scanOutlineState(for: subitem)
            cx.isExpanded = isItemExpanded(subitem)
            x.subtrees.append(cx)
        }
        return x
    }
}
