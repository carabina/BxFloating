Pod::Spec.new do |s|

    s.name             = 'BxFloating'
    s.version = '0.1.3'
    s.swift_version    = '4.1'
    s.summary          = 'Incredibly easy floating views on iOS.'

    s.description      = 'BxFloating provides a wrapper for SpriteKit floating views with an interface similar to UITableView.'

    s.homepage          = 'https://bx.borchero.com/floating'
    s.documentation_url = 'https://bx.borchero.com/floating/docs'
    s.license           = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
    s.author            = { 'Oliver Borchert' => 'borchero@icloud.com' }
    s.source            = { :git => 'https://github.com/borchero/BxFloating.git',
        :tag => s.version.to_s }

    s.platform = :ios
    s.ios.deployment_target = '11.0'

    s.source_files = 'BxFloating/**/*'

    s.dependency 'RxSwift'
    s.dependency 'RxCocoa'
    s.dependency 'BxUtility'
    s.dependency 'BxUI'

    s.frameworks = 'UIKit', 'SpriteKit', 'CoreMotion'

end

