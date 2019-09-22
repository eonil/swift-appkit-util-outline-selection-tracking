//
//import Foundation
//import Tree2
//
///// This works only with reference-type (with pointers) nodes.
///// No value-type nodes will be supported.
/////
///// - You have to call insert/move/remove to sync underlying tree structure.
/////
//public final class NSOutlineViewSelectionTracking2<Node: AnyObject & TreeProtocol> {
//    private(set) var outlineStateTree = OutlineStateTree()
//    private var observation: AnyObject?
//    public var resolveIndexPath: ((AnyObject) -> IndexPath) = { _ in fatalError("No function.") }
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
//    public func didInsertItems(_ items:[Node], at indices: IndexSet, inParent parent: AnyObject?) {
//        let parentIndexPath = parent.flatMap(resolveIndexPath) ?? []
//        for range in indices.rangeView {
//            func makeOutlineStateTreeNode(_ i:Int) -> OutlineStateTree {
//                let n = items[i] as AnyObject
//                let x = OutlineStateTree(targetNode: n)
//                return x
//            }
//            let nodes = range.map(makeOutlineStateTreeNode)
//            outlineStateTree[in: parentIndexPath].subtrees.insert(contentsOf: nodes, at: range.lowerBound)
//        }
//    }
////    public func didMoveItem(at sourceIndex: Int, inParent sourceParent: AnyObject?, to targetIndex: Int, inParent targetParent: AnyObject?) {
////        didRemoveItems(at: [sourceIndex], inParent: sourceParent)
////        didInsertItems(at: [targetIndex], inParent: targetParent)
////    }
//    public func didRemoveItems(at indices: IndexSet, inParent parent: AnyObject?) {
//        let parentIndexPath = parent.flatMap(resolveIndexPath) ?? []
//        for range in indices.rangeView.reversed() {
//            outlineStateTree[in: parentIndexPath].subtrees.removeSubrange(range)
//        }
//    }
//    public func didExpand(node:AnyObject) {
//        let targetIndexPath = resolveIndexPath(node)
//        outlineStateTree[in: targetIndexPath].isExpanded = true
//    }
//    public func didCollapse(node:AnyObject) {
//        let targetIndexPath = resolveIndexPath(node)
//        outlineStateTree[in: targetIndexPath].isExpanded = false
//    }
//}
