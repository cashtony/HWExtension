#
# Be sure to run `pod lib lint HWExtension.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'HWExtension'
    s.version          = '2.0.0'
    s.summary          = 'some convenient extension and tools.'
    s.homepage         = 'https://github.com/wanghouwen/HWExtension'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'wanghouwen' => 'wanghouwen123@126.com' }
    s.source           = { :git => 'https://github.com/wanghouwen/HWExtension.git', :tag => s.version }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
    s.requires_arc = true
    
    s.ios.deployment_target = '8.0'
    
    s.subspec 'Category' do |ss|
        ss.public_header_files = 'HWExtension/Category/*.h'
        ss.source_files = 'HWExtension/Category/*.{h,m}'
    end
    
    s.subspec 'DB' do |ss|
        ss.public_header_files = 'HWExtension/DB/*.h'
        ss.source_files = 'HWExtension/DB/*.{h,m}'
        ss.dependency 'HWExtension/Category'
        ss.dependency 'FMDB'
    end
    
    s.subspec 'Router' do |ss|
        ss.public_header_files = 'HWExtension/Router/*.h'
        ss.source_files = 'HWExtension/Router/*.{h,m}'
        ss.dependency 'JLRoutes'
        ss.dependency 'HWExtension/Category'
    end
    
    s.subspec 'UI' do |ss|
        ss.public_header_files = 'HWExtension/UI/*.h'
        ss.source_files = 'HWExtension/UI/*.{h,m}'
        ss.dependency 'HWExtension/Category'
        ss.dependency 'Masonry'
        
        ss.subspec 'Web' do |sss|
            sss.public_header_files = 'HWExtension/UI/Web/*.h'
            sss.source_files = 'HWExtension/UI/Web/*.{h,m}'
            sss.resource_bundles = {
                'HWExtension' => ['HWExtension/UI/Web/JSBundle.bundle']
            }
        end
        
        ss.subspec 'ModalTransition' do |sss|
            sss.public_header_files = 'HWExtension/UI/ModalTransition/*.h'
            sss.source_files = 'HWExtension/UI/ModalTransition/*.{h,m}'
        end
        
        ss.subspec 'UITableView+ViewModel' do |sss|
            sss.public_header_files = 'HWExtension/UI/UITableView+ViewModel/*.h'
            sss.source_files = 'HWExtension/UI/UITableView+ViewModel/*.{h,m}'
        end
        
        ss.subspec 'Graphic' do |sss|
            sss.public_header_files = 'HWExtension/UI/Graphic/*.h'
            sss.source_files = 'HWExtension/UI/Graphic/*.{h,m}'
            sss.dependency 'CorePlot', '~>2.2'
        end
    end
    
end
