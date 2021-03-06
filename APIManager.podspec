Pod::Spec.new do |s|
s.platform = :ios
s.ios.deployment_target = '9.0'
s.name = "APIManager"
s.summary = "APIManager lets base get API."
s.requires_arc = true

s.version = "0.0.2"
s.author = { "Hoan Phan" => "phanvanhoan54cntt@gmail.com" }
s.homepage = "https://github.com/hoanphan/APIManager"
s.source = { :git => "https://github.com/hoanphan/APIManager.git",
             :tag => "#{s.version}" }

s.framework = "Foundation"
s.dependency 'RxSwift', '=5.1.1'
s.dependency 'ObjectMapper', '=4.2.0'
s.dependency 'Alamofire', '=4.9.1'
s.dependency 'Moya', '=13.0.1'

s.source_files = "APIManager/**/*.{swift}"
s.swift_version = "4.2"

end
