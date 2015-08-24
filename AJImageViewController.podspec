Pod::Spec.new do |s|
  s.name             = "AJImageViewController"
  s.version          = "0.1.0"
  s.summary          = "AJImageViewController is a custom UIViewController for displaying images."
  s.description      = "AJImageViewController is a custom UIViewController that displays images in two modes: the first show a single image, which is perfect for profile pictures, for example. The second one shows a set of images with features like zooming, what is great for photo albuns."
  s.homepage         = "https://github.com/ajeferson/AJImageViewController"
  s.license          = 'MIT'
  s.author           = { "Alan Jeferson" => "alan.jeferson11@gmail.com" }
  s.source           = { :git => "https://github.com/ajeferson/AJImageViewController.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'AJImageViewController' => ['Pod/Assets/*.png']
  }
end
