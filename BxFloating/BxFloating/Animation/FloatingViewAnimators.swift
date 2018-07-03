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

import SpriteKit
import BxUtility

public struct FloatingViewInstantAnimator: FloatingViewAnimator {
    
    public static var instance: FloatingViewInstantAnimator {
        return .init()
    }
}

public struct FloatingViewFlowInShrinkAnimator: FloatingViewAnimator {
    
    public static var instance: FloatingViewFlowInShrinkAnimator {
        return .init()
    }
    
    public func animate(inserted node: SKNode) {
        guard let scene = node.scene else {
            return
        }
        node.position = CGPoint(x: CGFloat.random(between: 0, and: 1) < 0.5 ?
                                        -scene.frame.width / 2 + node.frame.width / 2 :
                                        scene.frame.width / 2 - node.frame.width / 2,
                                y: .random(between: -scene.frame.height / 2 + node.frame.height / 2,
                                           and: scene.frame.height / 2 - node.frame.height / 2))
    }
    
    public func animate(removed node: SKNode, completion: @escaping () -> Void) {
        let action = SKAction.scale(to: 1, duration: 0.3)
        node.run(action, completion: completion)
    }
}
