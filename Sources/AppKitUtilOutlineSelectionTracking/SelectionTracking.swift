
import Foundation
import AppKit
import Tree2

/// This works only with reference-type (with pointers) nodes.
/// No value-type nodes will be supported.
///
/// - You have to call insert/move/remove to sync underlying tree structure.
///
final class NSOutlineViewSelectionTracking {
    private(set) var outlineStateTree = OutlineStateTree()
    weak var target: NSOutlineView? {
        didSet(x) {
            guard target !== x else { return }
            rescanOutlineStructure()
        }
    }
    init(target x: NSOutlineView) {
        NotificationCenter.default.addObserver(
            forName: nil,
            object: x,
            queue: .main,
            using: { [weak self] in self?.process($0) })
    }
    func didInsertItems(at indices: IndexSet, inParent parent: AnyObject?) {
        guard let target = target else { fatalError("Target outline-view is missing.") }
        let parentIndexPath = parent.flatMap({ indexPath(for: $0) }) ?? []
        for range in indices.rangeView {
            func makeOutlineStateTreeNode(_ i:Int) -> OutlineStateTree {
                let n = target.child(i, ofItem: parent)! as AnyObject
                let x = OutlineStateTree(targetNode: n)
                return x
            }
            let nodes = range.map(makeOutlineStateTreeNode)
            outlineStateTree[in: parentIndexPath].subtrees.insert(contentsOf: nodes, at: range.lowerBound)
        }
    }
    func didMoveItem(at sourceIndex: Int, inParent sourceParent: AnyObject?, to targetIndex: Int, inParent targetParent: AnyObject?) {
        didRemoveItems(at: [sourceIndex], inParent: sourceParent)
        didInsertItems(at: [targetIndex], inParent: targetParent)
    }
    func didRemoveItems(at indices: IndexSet, inParent parent: AnyObject?) {
        guard target != nil else { fatalError("Target outline-view is missing.") }
        let parentIndexPath = parent.flatMap({ indexPath(for: $0) }) ?? []
        for range in indices.rangeView.reversed() {
            outlineStateTree[in: parentIndexPath].subtrees.removeSubrange(range)
        }
    }
    
    private func process(_ n:Notification) {
        assert((n.object as! NSOutlineView) === target)
        let targetNode = n.userInfo!["NSObject"]! as AnyObject
        switch n.name {
        case NSOutlineView.itemWillExpandNotification:
            break
        case NSOutlineView.itemDidExpandNotification:
            let targetIndexPath = indexPath(for: targetNode)
            outlineStateTree[in: targetIndexPath].isExpanded = true
        case NSOutlineView.itemWillCollapseNotification:
            let targetIndexPath = indexPath(for: targetNode)
            outlineStateTree[in: targetIndexPath].isExpanded = false
        case NSOutlineView.itemDidCollapseNotification:
            break
        default:
            break
        }
    }
    
    // MARK: -
    private func indexPath(for node:AnyObject) -> IndexPath {
        guard let target = target else { fatalError("Target outline-view is missing.") }
        let indexInParent = target.childIndex(forItem: node)
        if let parentNode = target.parent(forItem: node) as AnyObject? {
            return indexPath(for: parentNode).appending(indexInParent)
        }
        else {
            return [indexInParent]
        }
    }
    private func rescanOutlineStructure() {
        guard target != nil else { fatalError("Target outline-view is missing.") }
        outlineStateTree = OutlineStateTree()
        appendOutlineStructure(in: nil)
    }
    private func appendOutlineStructure(in parent:AnyObject?) {
        guard let target = target else { fatalError("Target outline-view is missing.") }
        let c = target.numberOfChildren(ofItem: parent)
        let r = 0..<c
        let nodes = r.map({ target.child($0, ofItem: parent)! as AnyObject })
        didInsertItems(at: IndexSet(integersIn: r), inParent: parent)
        for n in nodes {
            appendOutlineStructure(in: n)
        }
    }
}

struct OutlineStateTree: TreeProtocol, MutableTreeProtocol, ReplaceableTreeProtocol {
    weak var targetNode: AnyObject?
    var isExpanded = false
    var value: Void = Void()
    var subtrees = Subtrees()
    
    init() {}
    init(value v: (), subtrees ts: OutlineStateTree.Subtrees) {
        value = v
        subtrees = ts
    }
    init(targetNode x: AnyObject) {
        targetNode = x
    }
    var totalCount: Int {
        return 1 + subtrees.totalCount
    }
    var totalVisibleCount: Int {
        return isExpanded ? 1 + subtrees.totalVisibleCount : 1
    }
    struct Subtrees: RandomAccessCollection, MutableCollection, RangeReplaceableCollection {
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
            var i = 0
            while i < totalVisibleCount {
                let nodeTotalVisibleCount = impl[i].totalVisibleCount
                let nodeRowOffsetRange = i..<i+nodeTotalVisibleCount
                if nodeRowOffsetRange.contains(visibleRowOffset) {
                    /// If offset matches, return the node itself.
                    if i == visibleRowOffset { return [i] }
                    let subindexPath = impl[i]
                        .subtrees
                        .indexPathAtVisibleRowIndex(visibleRowOffset - i - 1)
                    return IndexPath(index: i).appending(subindexPath)
                }
                i += nodeTotalVisibleCount
            }
            assert(i == totalVisibleCount)
            fatalError("Supplied row index offset is out of range.")
        }
    }
}
