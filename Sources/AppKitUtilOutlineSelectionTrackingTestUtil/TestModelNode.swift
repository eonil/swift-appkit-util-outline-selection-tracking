//
//  File.swift
//  
//
//  Created by Henry Hathaway on 9/17/19.
//

import Foundation
import Tree2
import TestUtil

private var testDataSeed = 0
private func makeTestData() -> Int {
    testDataSeed += 1
    return testDataSeed
}

private var selectionPRNG = ReproduciblePRNG(1_000_000)

final class TestModelNode: TreeProtocol {
    var data = makeTestData()
    weak var parent: TestModelNode?
    var subtrees = [TestModelNode]() {
        willSet {
            for n in subtrees {
                n.parent = nil
            }
        }
        didSet {
            for n in subtrees {
                n.parent = self
            }
        }
    }
    func indexPath() -> IndexPath {
        if parent === nil { return [] }
        else {
            return parent!.indexPath().appending(parent!.subtrees.firstIndex(where: { $0 === self })!)
        }
    }
    func countAll() -> Int {
        return 1 + subtrees.map({ $0.countAll() }).reduce(0, +)
    }
    func makeRandomInsertionIndexPath() -> IndexPath {
        let dice = selectionPRNG.nextWithRotation(in: 0..<100)
        if !subtrees.isEmpty && dice < 98 {
            let indexDice = selectionPRNG.nextWithRotation(in: 0..<subtrees.count)
            let indexPath = IndexPath(index: indexDice)
            return indexPath.appending(subtrees[indexDice].makeRandomInsertionIndexPath())
        }
        else {
            let indexDice = subtrees.count == 0 ? 0 : selectionPRNG.nextWithRotation(in: 0..<subtrees.count)
            let indexPath = IndexPath(index: indexDice)
            return indexPath
        }
    }
    func makeRandomExistingIndexPath() -> IndexPath? {
        if subtrees.isEmpty { return nil }
        let dice = selectionPRNG.nextWithRotation(in: 0..<100)
        if dice < 98 {
            let indexDice = selectionPRNG.nextWithRotation(in: 0..<subtrees.count)
            let indexPath = IndexPath(index: indexDice)
            if let subindexPath = subtrees[indexDice].makeRandomDeletionIndexPath() {
                return indexPath.appending(subindexPath)
            }
            else {
                return indexPath
            }
        }
        else {
            let indexDice = selectionPRNG.nextWithRotation(in: 0..<subtrees.count)
            let indexPath = IndexPath(index: indexDice)
            return indexPath
        }
    }
    func makeRandomDeletionIndexPath() -> IndexPath? {
        return makeRandomExistingIndexPath()
    }
}
