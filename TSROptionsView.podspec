Pod::Spec.new do |s|
  # Platform setup
  s.platform     = :ios, "8.0"
  s.requires_arc = true

  # Information
  s.name         =  "TSROptionsView"
  s.version      =  "0.0.7"
  s.summary      =  "Options view like the one seen in the Spotify app for iOS."
  s.author       =  { "Nicolai Persson" => "recognize@me.com" }
  s.license      =  "Copyright (c) 2014 Tonsser. All rights reserved."
  s.source       =  { :git => 'https://github.com/tonsser/ios-options-selector.git', :tag => '0.0.7' }
  s.homepage     =  "https://tonsser.com"

  # Frameworks
  s.frameworks   = "Foundation", "UIKit"

  # Source files
  s.source_files = "TSROptionsView/Source"
end
