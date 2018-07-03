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

import Foundation
import SpriteKit
import CoreMotion
import BxUtility

internal class FloatingScene: SKScene {
    
    private enum State {
        case none
        case moving
    }
    
    private(set) var nodes: [SKNode] = []
    
    weak var selectionDelegate: FloatingSceneDelegate?
    
    private var state: State = .none
    private lazy var motionManager: CMMotionManager = CMMotionManager()
    private var lastAccelerometerData: CGVector?
    
    override init() {
        super.init(size: .zero)
        
        self.scaleMode = .aspectFill
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        self.physicsWorld.gravity = .zero
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        let gravityField = SKFieldNode.radialGravityField()
        gravityField.region = SKRegion(radius: 10000)
        gravityField.minimumRadius = 10000
        gravityField.strength = 10000
        self.addChild(gravityField)
        
        if !motionManager.isAccelerometerActive {
            motionManager.startAccelerometerUpdates()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addNode(_ node: SKNode, at index: Int, using animator: FloatingViewAnimator) {
        self.nodes.insert(node, at: index)
        self.addChild(node)
        animator.animate(inserted: node)
    }
    
    func removeNode(at index: Int, using animator: FloatingViewAnimator) {
        let node = self.nodes.remove(at: index)
        animator.animate(removed: node) {
            node.removeFromParent()
        }
    }
    
    func reloadNode(at index: Int, with node: SKNode) {
        let removed = self.nodes[index]
        removed.removeFromParent()
        self.nodes[index] = node
        node.position = removed.position
        self.addChild(node)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if motionManager.isAccelerometerAvailable {
            if let data = motionManager.accelerometerData?.acceleration {
                if let lastData = lastAccelerometerData {
                    physicsWorld.gravity.dx = (CGFloat(data.x) - lastData.dx) * 100
                    physicsWorld.gravity.dy = (CGFloat(data.y) - lastData.dy) * 100
                }
                
                lastAccelerometerData = CGVector(dx: data.x, dy: data.y)
            }
        }
        
        // linear damping
        nodes.forEach { node in
            let distance = hypot(node.position.x, node.position.y)
            node.physicsBody?.linearDamping = 2
            
            if distance <= 100 {
                node.physicsBody?.linearDamping += ((100 - distance) / 10)
            }
        }
    }
    
    func removeAll(using animator: FloatingViewAnimator = FloatingViewInstantAnimator.instance) {
        nodes.forEach { _ in
            self.removeNode(at: 0, using: animator)
        }
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
    }
    
    deinit {
        motionManager.stopDeviceMotionUpdates()
    }
}

extension FloatingScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.state = .none
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        guard let touch = touches.first else {
            return
        }
        let previousLocation = touch.previousLocation(in: self)
        let location = touch.location(in: self)
        
        let dx = location.x - previousLocation.x
        let dy = location.y - previousLocation.y
        
        if abs(dx) < 10e-5 && abs(dy) < 10e-5 {
            return
        }
        
        self.state = .moving
        
        let distanceToCenter = sqrt(hypot(location.x, location.y))
        
        let multiplier = 1000 / max(distanceToCenter, 10)
        
        nodes.forEach { node in
            let direction = CGVector(dx: multiplier * dx, dy: multiplier * dy)
            node.physicsBody?.applyForce(direction)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        if self.state != .moving {
            guard let touch = touches.first else {
                return
            }
            let touchLocation = touch.location(in: self)
            if let touchedNode = self.nodes(at: touchLocation).first {
                var current: SKNode? = touchedNode
                var nodeIndex = current.flatMap(self.nodes.index(of:))
                while let node = current, nodeIndex == nil {
                    current = node.parent
                    nodeIndex = current.flatMap(self.nodes.index(of:))
                }
                if let index = nodeIndex {
                    selectionDelegate?.floatingScene(didSelectNodeAtIndex: index)
                }
            }
        }
    }
    
}
