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

import RxSwift
import RxCocoa

extension FloatingView: HasDelegate {
    
    public typealias Delegate = FloatingViewDelegate
}

open class RxFloatingViewDelegateProxy: DelegateProxy<FloatingView, FloatingViewDelegate>, DelegateProxyType, FloatingViewDelegate {
    
    public weak private(set) var floatingView: FloatingView?
    
    public init(floatingView: FloatingView) {
        self.floatingView = floatingView
        super.init(parentObject: floatingView, delegateProxy: RxFloatingViewDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { RxFloatingViewDelegateProxy(floatingView: $0) }
    }
    
    public func floatingView(_ floatingView: FloatingView, didSelectNodeAtIndex index: Int) {
        self._forwardToDelegate?.floatingView?(floatingView, didSelectNodeAtIndex: index)
    }
}
