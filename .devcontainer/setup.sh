#!/bin/bash

set -e

echo "🚀 Setting up Flutter development environment..."

# Flutter 버전 확인
echo "📱 Flutter version:"
flutter --version

# Flutter doctor 실행
echo "🔍 Running Flutter doctor..."
flutter doctor

# Flutter 웹 지원 활성화
echo "🌐 Enabling Flutter web support..."
flutter config --enable-web

# 의존성 설치
echo "📦 Installing dependencies..."
flutter pub get

# 코드 생성 (Hive, Riverpod)
echo "🔧 Running code generation..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Flutter doctor 재실행 (설정 완료 확인)
echo "✅ Final Flutter doctor check:"
flutter doctor

echo "🎉 Setup complete! You can now run:"
echo "   flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0"
echo "   or use the VS Code Flutter extension to run the app"
