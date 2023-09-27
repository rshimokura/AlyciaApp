platform :ios, '14.0'

target 'AlyciaApp' do
  use_frameworks!
  pod 'AlyciaITR'
  pod 'NVActivityIndicatorView'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
    end
  end
end
