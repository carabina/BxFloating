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

public class FloatingContentView: SKView {
    
    open override var backgroundColor: UIColor? {
        get {
            return super.backgroundColor
        } set {
            super.backgroundColor = newValue
            floatingScene.backgroundColor = newValue ?? .clear
        }
    }
    
    internal var floatingScene: FloatingScene {
        return self.scene as! FloatingScene
    }
    
    public init() {
        super.init(frame: .zero)
        
        let scene = FloatingScene()
        presentScene(scene)
        
        applyStyle(.floatCollection)
        backgroundColor = .white
        
        delegate = self
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        floatingScene.size = self.bounds.size
    }
}

extension FloatingContentView: SKViewDelegate {
    
    public func view(_ view: SKView, shouldRenderAtTime time: TimeInterval) -> Bool {
        return true
    }
}
