Pod::Spec.new do |s|

  s.name         = "CachedAsyncImage"
  s.version      = "2.1.1"
  s.summary      = "CachedAsyncImage is the simplest way to add cache to your AsyncImage."

  s.description  = <<-DESC
  CachedAsyncImage is the simplest way to add cache to your AsyncImage.
                   DESC

  s.homepage     = "https://github.com/lorenzofiamingo/swiftui-cached-async-image"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Lorenzo Fiamingo" => "https://github.com/lorenzofiamingo" }

  s.ios.deployment_target = "13.0"
  s.tvos.deployment_target = "13.0"
  s.osx.deployment_target = "10.15"
  s.watchos.deployment_target = "6.0"

  s.source       = { :git => "https://github.com/lorenzofiamingo/swiftui-cached-async-image.git", :tag => "#{s.version}" }

  s.source_files  = "Sources/**/*"

end
