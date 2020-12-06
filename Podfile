source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '12.0'
use_frameworks!

target 'GymRats' do
    pod 'Alamofire', '~> 4.7'
    pod 'RxSwift', '~> 5'
    pod 'RxCocoa', '~> 5'
    pod 'RxAlamofire'
    pod 'Kingfisher', '~> 4.0'
    pod 'RxOptional'
    pod 'MMDrawerController', '~> 0.5.7'
    pod 'SwiftDate', '~> 5.0'
    pod 'GradientLoadingBar', '~> 1.0'
    pod 'Firebase/Core'
    pod 'Firebase/Storage'
    pod 'Analytics'
    pod 'Segment-Amplitude'
    pod 'Segment-Firebase'
    pod 'Cache'
    pod 'GooglePlaces'
    pod 'TTTAttributedLabel'
    pod 'EasyNotificationBadge'
    pod 'MessageKit'
    pod 'Pageboy', '~> 3.2'
    pod 'SkeletonView'
    pod 'ESTabBarController-swift'
    pod 'NVActivityIndicatorView/AppExtension'
    pod 'RxGesture'
    pod 'Eureka'
    pod 'PanModal'
    pod 'RSKPlaceholderTextView'
    pod 'RxDataSources', '~> 4.0'
    pod 'SwiftPhoenixClient'
    pod 'UIScrollView-InfiniteScroll', '~> 1.1.0'
    pod 'Branch'
    pod 'JVFloatLabeledTextField'
    pod 'LetterAvatarKit', '1.2.2'
    pod 'RxKeyboard'
    pod 'UnsplashPhotoPicker', '~> 1.1.1'
    pod 'ImageViewer.swift', '~> 3.0.12'
    pod 'SwiftConfettiView'
    pod 'YPImagePicker', :git => 'https://github.com/Yummypets/YPImagePicker.git'

    target 'GymRatsTests' do
      inherit! :search_paths
    end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'Segment-Amplitude'
     target.build_configurations.each do |config|
       config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '11.0'
     end
    end
  end
end
