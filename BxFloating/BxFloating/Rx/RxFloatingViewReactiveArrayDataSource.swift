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
import SpriteKit
import BxUtility

class RxFloatingViewReactiveArrayDataSourceSequenceWrapper<S: Sequence>: RxFloatingViewReactiveArrayDataSource<S.Iterator.Element>, RxFloatingViewDataSourceType {
    
    typealias Element = S
    
    func floatingView(_ floatingView: FloatingView, observedEvent: RxSwift.Event<S>, animator: FloatingViewAnimator) {
        Binder(self) { floatingViewDataSource, items in
            let items = Array(items)
            floatingViewDataSource.floatingView(floatingView, observedElements: items, animator: animator)
        }.on(observedEvent)
    }
}

class RxFloatingViewReactiveArrayDataSource<Element>: FloatingViewDataSource {
    
    private var itemModels: [Element]? = nil
    
    let viewFactory: (FloatingView, Int, Element) -> SKNode
    
    init(viewFactory: @escaping (FloatingView, Int, Element) -> SKNode) {
        self.viewFactory = viewFactory
    }
    
    func numberOfNodes(in floatingView: FloatingView) -> Int {
        return itemModels?.count ?? 0
    }
    
    func floatingView(_ floatingView: FloatingView, nodeAtIndex index: Int) -> SKNode {
        return viewFactory(floatingView, index, itemModels![index])
    }
}

extension RxFloatingViewReactiveArrayDataSource where Element: Hashable {
    
    func floatingView(_ floatingView: FloatingView, observedElements: [Element], animator: FloatingViewAnimator) {
        let old = itemModels ?? []
        let diff = Set.diff(old, new: observedElements)
        itemModels = observedElements
        floatingView.removeNodes(at: diff.removed.compactMap(old.index(of:)), with: animator)
        floatingView.insertNodes(at: diff.inserted.compactMap(observedElements.index(of:)), with: animator)
    }
}

extension RxFloatingViewReactiveArrayDataSource {
    
    func floatingView(_ floatingView: FloatingView, observedElements: [Element], animator: FloatingViewAnimator) {
        itemModels = observedElements
        floatingView.reloadNodes(with: animator)
    }
}
