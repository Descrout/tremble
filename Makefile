iosfix:
	rm -rf pubspec.lock ios/Pods ios/Podfile.lock
	flutter pub get
	pod install --repo-update --project-directory=ios
