# Uncomment the next line to define a global platform for your project
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '10.0'
inhibit_all_warnings!

workspace 'AgoraEducation.xcworkspace'

target 'AgoraEducation' do
  use_frameworks!
  
  pod 'AgoraLog', :path => 'Modules/AgoraLog/AgoraLog.podspec'
  pod 'EduSDK', :path => 'Modules/EduSDK/EduSDK.podspec'
  pod 'AgoraWhiteBoard', :path => 'Modules/AgoraWhiteBoard/AgoraWhiteBoard.podspec'
  
  pod 'AgoraReplay', :path => 'Modules/AgoraReplay/AgoraReplay.podspec'
  pod 'AgoraReplayUI', :path => 'Modules/AgoraReplayUI/AgoraReplayUI.podspec'
  
  # if you use swift project, you just only change 'OC' to 'Swift'
  pod 'AgoraHandsUp', :path => 'Modules/AgoraHandsUp/AgoraHandsUp.podspec', :subspecs => ['OC']
  
  # if you use swift project, you just only change 'OC' to 'Swift'
  pod 'AgoraActionProcess', :path => 'Modules/AgoraActionProcess/AgoraActionProcess.podspec', :subspecs => ['OC']
end
