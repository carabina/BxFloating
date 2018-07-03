Pod::Spec.new do |s|

    s.name             = 'BxFloating'
    s.version = '0.1.1'
    s.summary          = 'Easy floating views on iOS.'

    s.description      = 'BxFloating provides a wrapper to use a floating view as in Apple Music using SpriteKit.'

    s.homepage         = 'https://github.com/borchero/BxFloating'
    s.license          = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
    s.author           = { 'borchero' => 'borchero@icloud.com' }
    s.source           = { :git => 'https://github.com/borchero/BxFloating.git', :tag => s.version.to_s }

    s.ios.deployment_target = '11.0'

    s.source_files = 'BxFloating/**/*'

    s.dependency 'RxSwift'
    s.dependency 'RxCocoa'
    s.dependency 'BxUtility'
    s.dependency 'BxUI'

    s.framework 'UIKit'
    s.framework 'SpriteKit'
    s.framework 'CoreMotion'

end
