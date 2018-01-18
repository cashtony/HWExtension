#
# Be sure to run `pod lib lint HWExtension.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'HWExtension'
    s.version          = '1.0.0'
    s.summary          = 'some convenient extension and tools.'
    s.homepage         = 'https://github.com/wanghouwen/HWExtension'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'wanghouwen' => 'wanghouwen123@126.com' }
    s.source           = { :git => 'https://github.com/wanghouwen/HWExtension.git', :tag => s.version }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
    s.requires_arc = true
    
    s.ios.deployment_target = '7.0'
        
    s.subspec 'Category' do |ss|
        ss.public_header_files = 'HWExtension/Classes/Category/HWCategorys.h'
        ss.source_files = 'HWExtension/Classes/Category/*.{h,m,js}'
        ss.resource_bundles = {
            'HWExtension' => ['HWExtension/Classes/Category/JSBundle.bundle']
        }
    end
    
    s.subspec 'UI' do |ss|
        ss.public_header_files = 'HWExtension/Classes/UI/*.h', 'HWExtension/Classes/UI/UITableView+ViewModel/*.h'
        ss.source_files = 'HWExtension/Classes/UI/*.{h,m}', 'HWExtension/Classes/UI/UITableView+ViewModel/*.{h,m}'
        ss.dependency 'HWExtension/Category'
        ss.dependency 'HWExtension/Tool'
    end
    
    s.subspec 'Tool' do |ss|
        ss.public_header_files = 'HWExtension/Classes/Tool/*.h'
        ss.source_files = 'HWExtension/Classes/Tool/*.{h,m}'
    end
end