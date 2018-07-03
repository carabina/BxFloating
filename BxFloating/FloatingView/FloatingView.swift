// Copyright 2018 Oliver Borchert
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import BxUI
import BxLayout
import SpriteKit

open class FloatingView: View, Layoutable {
    
    public weak var dataSource: FloatingViewDataSource? {
        didSet {
            self.reloadNodes()
        }
    }
    
    public weak var delegate: FloatingViewDelegate?
    
    public private(set) lazy var contentView: FloatingContentView = {
        let view = FloatingContentView()
        view.floatingScene.selectionDelegate = self
        return view
    }()
    
    public func defineLayout() {
        addSubviews(contentView)
            .layout { $1.follow($0) }.apply()
    }
    
    public func node(forIndex index: Int) -> SKNode? {
        return contentView.floatingScene.nodes[index]
    }
    
    public func reloadNodes(with animator: FloatingViewAnimator = FloatingViewInstantAnimator.instance) {
        guard let dataSource = self.dataSource else {
            return
        }
        contentView.floatingScene.removeAll()
        for index in 0..<dataSource.numberOfNodes(in: self) {
            let node = dataSource.floatingView(self, nodeAtIndex: index)
            contentView.floatingScene.addNode(node, at: index, using: animator)
        }
    }
    
    public func insertNodes(at indices: [Int],
                            with animator: FloatingViewAnimator = FloatingViewInstantAnimator.instance) {
        guard let dataSource = self.dataSource else {
            return
        }
        for index in indices.sorted() {
            let node = dataSource.floatingView(self, nodeAtIndex: index)
            contentView.floatingScene.addNode(node, at: index, using: animator)
        }
    }
    
    public func removeNodes(at indices: [Int],
                            with animator: FloatingViewAnimator = FloatingViewInstantAnimator.instance) {
        for (index, offset) in indices.sorted().enumerated() {
            contentView.floatingScene.removeNode(at: index - offset, using: animator)
        }
    }
    
    public func updateNodes(at indices: [Int]) {
        guard let dataSource = self.dataSource else {
            return
        }
        for index in indices {
            let node = dataSource.floatingView(self, nodeAtIndex: index)
            contentView.floatingScene.reloadNode(at: index, with: node)
        }
    }
    
    public func animateDismissal(with action: (SKNode) -> SKAction, duration: TimeInterval,
                                 completion: @escaping () -> Void = { return }) {
        let count = contentView.floatingScene.nodes.count
        for (index, node) in contentView.floatingScene.nodes.enumerated() {
            node.physicsBody = nil
            
            node.run(action(node)) {
                if index == count - 1 {
                    completion()
                    self.contentView.floatingScene.removeAll()
                }
            }
        }
    }
    
    public func animateDismissal(shrinkingTo destination: CGPoint, duration: TimeInterval,
                                 completion: @escaping () -> Void = { return }) {
        let target = contentView.floatingScene.convertPoint(fromView: destination)
        
        let action = { (_: SKNode) -> SKAction in
            let shrinkAction = SKAction.scale(by: 0.1, duration: duration)
            let moveAction = SKAction.move(to: target, duration: duration)
            
            shrinkAction.timingMode = .easeIn
            moveAction.timingMode = .easeIn
            
            return SKAction.group([shrinkAction, moveAction])
        }
        
        self.animateDismissal(with: action, duration: duration, completion: completion)
    }
}

extension FloatingView: FloatingSceneDelegate {
    
    func floatingScene(didSelectNodeAtIndex index: Int) {
        delegate?.floatingView?(self, didSelectNodeAtIndex: index)
    }
}
