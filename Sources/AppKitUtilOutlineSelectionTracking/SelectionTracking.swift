//
//import Foundation
//import AppKit
//import Tree2
//
///// This works only with reference-type (with pointers) nodes.
///// No value-type nodes will be supported.
/////
///// - You have to call insert/move/remove to sync underlying tree structure.
/////
//public final class NSOutlineViewSelectionTracking {
//    private(set) var outlineStateTree = OutlineStateTree()
//    private var observation: AnyObject?
//    public var resolveIndexPath: ((AnyObject) -> IndexPath) = { _ in fatalError("No function.") }
//    func indexPath(for n:AnyObject) -> IndexPath {
//        return resolveIndexPath(n)
//    }
//    public weak var target: NSOutlineView? {
//        didSet(x) {
//            guard target !== x else { return }
//            observation = NotificationCenter.default.addObserver(
//                forName: nil,
//                object: target,
//                queue: .main,
//                using: { [weak self] in self?.process($0) })
//            rescanOutlineStructure()
//        }
//    }
//    public var note: ((Note) -> Void)?
//    public enum Note {
//        /// You cannot query `NSOutlineView` selections at any time.
//        /// As the view can show inconsistent state at some point,
//        /// This is the only safe time to query.
//        case readyToQuery(Query)
//    }
//    public struct Query {
//        var state: OutlineStateTree
//        public func indexPathAtVisibleRowIndex(_ offset: Int) -> IndexPath {
//            return state.subtrees.indexPathAtVisibleRowIndex(offset)
//        }
//    }
//    
//    public init() {}
//    public func didInsertItems(at indices: IndexSet, inParent parent: AnyObject?) {
//        guard let target = target else { fatalError("Target outline-view is missing.") }
//        let parentIndexPath = parent.flatMap({ indexPath(for: $0) }) ?? []
//        for range in indices.rangeView {
//            func makeOutlineStateTreeNode(_ i:Int) -> OutlineStateTree {
//                let n = target.child(i, ofItem: parent)! as AnyObject
//                let x = OutlineStateTree(targetNode: n)
//                return x
//            }
//            let nodes = range.map(makeOutlineStateTreeNode)
//            outlineStateTree[in: parentIndexPath].subtrees.insert(contentsOf: nodes, at: range.lowerBound)
//        }
//    }
//    public func didMoveItem(at sourceIndex: Int, inParent sourceParent: AnyObject?, to targetIndex: Int, inParent targetParent: AnyObject?) {
//        didRemoveItems(at: [sourceIndex], inParent: sourceParent)
//        didInsertItems(at: [targetIndex], inParent: targetParent)
//    }
//    public func didRemoveItems(at indices: IndexSet, inParent parent: AnyObject?) {
//        guard target != nil else { fatalError("Target outline-view is missing.") }
//        let parentIndexPath = parent.flatMap({ indexPath(for: $0) }) ?? []
//        for range in indices.rangeView.reversed() {
//            outlineStateTree[in: parentIndexPath].subtrees.removeSubrange(range)
//        }
//    }
//    
//    
//    // MARK: - Implementations
//    private func process(_ n:Notification) {
//        assert((n.object as! NSOutlineView) === target)
//        switch n.name {
//        case NSOutlineView.itemWillExpandNotification:
//            break
//        case NSOutlineView.itemDidExpandNotification:
//            let targetNode = n.userInfo!["NSObject"]! as AnyObject
//            let targetIndexPath = indexPath(for: targetNode)
//            outlineStateTree[in: targetIndexPath].isExpanded = true
//            // DO NOT FIRE NOTE HERE.
//            // See `outlineViewItemDidCollapse` for details.
//        case NSOutlineView.itemWillCollapseNotification:
//            break
//        case NSOutlineView.itemDidCollapseNotification:
//            let targetNode = n.userInfo!["NSObject"]! as AnyObject
//            /// Here visibility tracker cannot track index-path properly
//            /// because expansion state has been changed and has not been
//            /// integrated into visibility tracker itself.
//            /// We cannot use visibility tracker to find index-path
//            /// from selection.
//            ///
//            /// INCONSISTENT STATE ISSUE
//            /// ------------------------
//            /// When you collapse a node in a `NSOutlineView`,
//            /// it collapses all descendant expanded nodes and fires collapse
//            /// event for each one of them in leaf-to-root order.
//            /// The problem is, all of these events are getting fired AFTER
//            /// the collapse operation fully finished.
//            ///
//            /// For example, if end-user collapses A in this given tree,
//            ///
//            ///      - A
//            ///        - B
//            ///          - C
//            ///            - D
//            ///
//            /// It becomes like this.
//            ///
//            ///      + A
//            ///
//            /// And `NSOutlineView` sends collapse event 3 times for
//            /// each of C, B and A. C at first, A at last.
//            /// If you catch the event for C and query expansion state
//            /// in `NSOutlineView`, you would expect something like this.
//            ///
//            ///      - A
//            ///        - B
//            ///          + C
//            ///
//            /// But actually, it shows this tree.
//            ///
//            ///      + A
//            ///
//            /// First event (for C) gets fired AFTER all collapsing has
//            /// been finished. At this point, actual state of
//            /// `NSOutlineView` is different with your expectation,
//            /// and I consider this as *inconsistent state*.
//            ///
//            /// This is obviously a bug as `NSOutlineView` is supposed to
//            /// work in synchronous manner.
//            ///
//            /// WORKAROUND
//            /// ----------
//            /// The best way to deal with this is not firing note on
//            /// collapse/expand events. On these events, I just update
//            /// the visibility informations and do not fire a note.
//            /// Instead, I fire note only for selection-change event
//            /// because at the point of the event, state is fully
//            /// consistent.
//            ///
//            let targetIndexPath = indexPath(for: targetNode)
//            outlineStateTree[in: targetIndexPath].isExpanded = false
//            // DO NOT FIRE NOTE HERE.
//        case NSOutlineView.selectionDidChangeNotification:
//            let q = Query(state: outlineStateTree)
//            note?(.readyToQuery(q))
//        default:
//            break
//        }
//    }
//    
////    private func indexPath(for node:AnyObject) -> IndexPath {
////        guard let target = target else { fatalError("Target outline-view is missing.") }
////        let indexInParent = target.childIndex(forItem: node)
////        assert(indexInParent >= 0)
////        if let parentNode = target.parent(forItem: node) as AnyObject? {
////            return indexPath(for: parentNode).appending(indexInParent)
////        }
////        else {
////            return [indexInParent]
////        }
////    }
//    private func rescanOutlineStructure() {
//        guard target != nil else { fatalError("Target outline-view is missing.") }
//        outlineStateTree = OutlineStateTree()
//        appendOutlineStructure(in: nil)
//    }
//    private func appendOutlineStructure(in parent:AnyObject?) {
//        guard let target = target else { fatalError("Target outline-view is missing.") }
//        let c = target.numberOfChildren(ofItem: parent)
//        let r = 0..<c
//        let nodes = r.map({ target.child($0, ofItem: parent)! as AnyObject })
//        didInsertItems(at: IndexSet(integersIn: r), inParent: parent)
//        for n in nodes {
//            appendOutlineStructure(in: n)
//        }
//    }
//}
//
//struct OutlineStateTree: TreeProtocol, MutableTreeProtocol, ReplaceableTreeProtocol {
//    weak var targetNode: AnyObject?
//    var isExpanded = false
//    var value: Void = Void()
//    var subtrees = Subtrees()
//    
//    init() {}
//    init(value v: (), subtrees ts: OutlineStateTree.Subtrees) {
//        value = v
//        subtrees = ts
//    }
//    init(targetNode x: AnyObject) {
//        targetNode = x
//    }
//    var totalCount: Int {
//        return 1 + subtrees.totalCount
//    }
//    var totalVisibleCount: Int {
//        return isExpanded ? 1 + subtrees.totalVisibleCount : 1
//    }
//    struct Subtrees: RandomAccessCollection, MutableCollection, RangeReplaceableCollection {
//        private var impl = [OutlineStateTree]()
//        private(set) var totalCount = 0
//        private(set) var totalVisibleCount = 0
//        var startIndex: Int { impl.startIndex }
//        var endIndex: Int { impl.endIndex }
//        subscript(_ i:Int) -> OutlineStateTree {
//            get { impl[i] }
//            set(x) { replaceSubrange(i..<i+1, with: CollectionOfOne(x)) }
//        }
//        subscript(_ r:Range<Int>) -> ArraySlice<OutlineStateTree> {
//            get { impl[r] }
//            set(x) { replaceSubrange(r, with: x) }
//        }
//        mutating func replaceSubrange<C, R>(_ subrange:R, with newElements:C) where C : Collection, R : RangeExpression, Element == C.Element, Index == R.Bound {
//            let q = subrange.relative(to: self)
//            let removings = impl[q]
//            totalCount -= removings.lazy.map({ $0.totalCount }).reduce(0, +)
//            totalVisibleCount -= removings.lazy.map({ $0.totalVisibleCount }).reduce(0, +)
//            impl.replaceSubrange(subrange, with: newElements)
//            totalCount += newElements.lazy.map(({ $0.totalCount })).reduce(0, +)
//            totalVisibleCount += newElements.lazy.map({ $0.totalVisibleCount }).reduce(0, +)
//        }
//        func indexPathAtVisibleRowIndex(_ visibleRowOffset:Int) -> IndexPath {
//            var i = 0
//            while i < totalVisibleCount {
//                let nodeTotalVisibleCount = impl[i].totalVisibleCount
//                let nodeRowOffsetRange = i..<i+nodeTotalVisibleCount
//                if nodeRowOffsetRange.contains(visibleRowOffset) {
//                    /// If offset matches, return the node itself.
//                    if i == visibleRowOffset { return [i] }
//                    let subindexPath = impl[i]
//                        .subtrees
//                        .indexPathAtVisibleRowIndex(visibleRowOffset - i - 1)
//                    return IndexPath(index: i).appending(subindexPath)
//                }
//                i += nodeTotalVisibleCount
//            }
//            assert(i == totalVisibleCount)
//            fatalError("Supplied row index offset is out of range.")
//        }
//    }
//}
