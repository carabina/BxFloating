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
import RxSwift
import RxCocoa
import SpriteKit

extension FloatingView: HasDataSource {

    public typealias DataSource = FloatingViewDataSource
}

fileprivate let floatingViewDataSourceNotSet = FloatingViewDataSourceNotSet()

final fileprivate class FloatingViewDataSourceNotSet: FloatingViewDataSource {

    func numberOfNodes(in floatingView: FloatingView) -> Int {
        return 0
    }
    
    func floatingView(_ floatingView: FloatingView, nodeAtIndex index: Int) -> SKNode {
        fatalError("Floating view data source configured incorrectly.")
    }
}

public class RxFloatingViewDataSourceProxy: DelegateProxy<FloatingView, FloatingViewDataSource>,
                                            DelegateProxyType, FloatingViewDataSource {

    public weak private(set) var floatingView: FloatingView?

    public init(floatingView: ParentObject) {
        self.floatingView = floatingView
        super.init(parentObject: floatingView, delegateProxy: RxFloatingViewDataSourceProxy.self)
    }

    public static func registerKnownImplementations() {
        self.register { RxFloatingViewDataSourceProxy(floatingView: $0) }
    }

    private weak var _requiredMethodsDataSource: FloatingViewDataSource? = floatingViewDataSourceNotSet

    public override func setForwardToDelegate(_ forwardToDelegate: FloatingViewDataSource?, retainDelegate: Bool) {
        _requiredMethodsDataSource = forwardToDelegate ?? floatingViewDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }
    
    public func numberOfNodes(in floatingView: FloatingView) -> Int {
        return (_requiredMethodsDataSource ?? floatingViewDataSourceNotSet).numberOfNodes(in: floatingView)
    }
    
    public func floatingView(_ floatingView: FloatingView, nodeAtIndex index: Int) -> SKNode {
        return (_requiredMethodsDataSource ?? floatingViewDataSourceNotSet).floatingView(floatingView,
                                                                                         nodeAtIndex: index)
    }
}

