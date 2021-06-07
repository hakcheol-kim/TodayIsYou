# AdBrixRemaster-iOS
CocoaPods으로 설치를 위한, AdBrixRM.framework repo.

## x86_64, i386 include 관련 빌드 오류시
- 콘솔(터미널)에서 AdBrixRM.framework 파일 위치로 이동 후 아래 두 명령어를 입력
- lipo -remove x86_64 ./AdBrixRM.framework/AdBrixRM -o ./AdBrixRM.framework/AdBrixRM
- lipo -remove i386 ./AdBrixRM.framework/AdBrixRM -o ./AdBrixRM.framework/AdBrixRM

# More detail integration Guide
Read these AdBrix Remaster official sites
- for Objective-C : https://help.adbrix.io/hc/ko/articles/360002668613-%EC%95%A0%EB%93%9C%EB%B8%8C%EB%A6%AD%EC%8A%A4-iOS-%EC%97%B0%EB%8F%99%ED%95%98%EA%B8%B0-Objective-c-
- for Swift : https://help.adbrix.io/hc/ko/articles/360003068234-%EC%95%A0%EB%93%9C%EB%B8%8C%EB%A6%AD%EC%8A%A4-iOS-%EC%97%B0%EB%8F%99%ED%95%98%EA%B8%B0-Swift-
- for Unity C# Plugin : https://help.adbrix.io/hc/ko/articles/360007761334-%EC%95%A0%EB%93%9C%EB%B8%8C%EB%A6%AD%EC%8A%A4-iOS-%EC%97%B0%EB%8F%99%ED%95%98%EA%B8%B0-Unity-

# Version Notice
- Now support for Swift 5.1 from SDK ver1.6.0
