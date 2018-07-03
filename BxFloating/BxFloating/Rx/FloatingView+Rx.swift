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
import RxSwift
import RxCocoa
import SpriteKit

extension Reactive where Base: FloatingView {
    
    public func items<S: Sequence, O: ObservableType>(animator: FloatingViewAnimator = FloatingViewInstantAnimator.instance)
        -> (_ source: O)
        -> (_ factory: @escaping (FloatingView, Int, S.Iterator.Element) -> SKNode) -> Disposable where O.E == S {
            return { source in
                { factory in
                    let dataSource = RxFloatingViewReactiveArrayDataSourceSequenceWrapper<S>(viewFactory: factory)
                    return self.items(dataSource: dataSource, animator: animator)(source)
                }
            }
    }
    
    public func items<DataSource: RxFloatingViewDataSourceType & FloatingViewDataSource, O: ObservableType>(dataSource: DataSource,
                                                                                                            animator: FloatingViewAnimator)
        -> (_ source: O) -> Disposable where DataSource.Element == O.E {
            return { source in
                let disposable1 = source.subscribe { event in
                    dataSource.floatingView(self.base, observedEvent: event, animator: animator)
                }
                let disposable2 = RxFloatingViewDataSourceProxy.installForwardDelegate(dataSource, retainDelegate: true,
                                                                                       onProxyForObject: self.base)
                return Disposables.create(disposable1, disposable2)
            }
    }
    
    public var delegate: DelegateProxy<FloatingView, FloatingViewDelegate> {
        return RxFloatingViewDelegateProxy.proxy(for: base)
    }
    
    public var nodeSelected: ControlEvent<Int> {
        return ControlEvent(events:
            delegate.rx.methodInvoked(#selector(FloatingViewDelegate.floatingView(_:didSelectNodeAtIndex:)))
                .map { $0[1] as! Int }
        )
    }
}
