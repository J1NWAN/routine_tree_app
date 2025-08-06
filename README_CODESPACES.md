# 🚀 GitHub Codespaces에서 Flutter 개발하기

이 프로젝트는 GitHub Codespaces에서 즉시 Flutter 개발을 시작할 수 있도록 설정되어 있습니다.

## 📋 사전 요구사항

- GitHub 계정
- 웹 브라우저 (Chrome, Firefox, Safari, Edge 등)

## 🛠️ Codespaces 시작하기

### 방법 1: GitHub 웹사이트에서
1. GitHub 저장소 페이지로 이동
2. 초록색 **"Code"** 버튼 클릭
3. **"Codespaces"** 탭 선택
4. **"Create codespace on main"** 클릭

### 방법 2: 직접 URL 접근
```
https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=YOUR_REPO_ID
```

## 🎯 자동 설정 과정

Codespace가 생성되면 다음 작업들이 자동으로 실행됩니다:

1. ✅ Flutter SDK 설정 및 확인
2. ✅ 웹 지원 활성화
3. ✅ 의존성 패키지 설치 (`flutter pub get`)
4. ✅ 코드 생성 실행 (Hive, Riverpod 등)
5. ✅ VS Code 확장프로그램 설치
6. ✅ Flutter Doctor 실행으로 환경 검증

## 🚀 앱 실행하기

### VS Code 확장프로그램 사용 (권장)
1. `Ctrl+Shift+P` (또는 `Cmd+Shift+P`)로 명령 팔레트 열기
2. "Flutter: Select Device" 입력하여 웹 브라우저 선택
3. `F5` 키를 누르거나 "Run and Debug" 패널에서 실행

### 터미널에서 실행
```bash
# 웹에서 실행 (포트 8080)
flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0

# 또는 단순히
flutter run -d chrome
```

### VS Code 태스크 사용
1. `Ctrl+Shift+P`로 명령 팔레트 열기
2. "Tasks: Run Task" 선택
3. "Flutter: Run Web" 선택

## 🌐 앱 접근하기

앱이 실행되면:
- Codespace에서 자동으로 포트가 포워딩됩니다
- 브라우저 탭이나 알림을 통해 앱에 접근할 수 있습니다
- 일반적으로 `https://[codespace-name]-8080.app.github.dev` 형태의 URL로 접근

## 🛠️ 유용한 VS Code 명령어

- **Flutter: Hot Reload** - 코드 변경사항 즉시 반영
- **Flutter: Hot Restart** - 앱 전체 재시작
- **Flutter: Clean** - 빌드 캐시 정리
- **Dart: Restart Analysis Server** - Dart 분석 서버 재시작

## 🔧 코드 생성

모델이나 Riverpod 코드를 수정한 후:

```bash
# 코드 생성 실행
flutter packages pub run build_runner build --delete-conflicting-outputs

# 또는 watch 모드 (파일 변경 감지 자동 생성)
flutter packages pub run build_runner watch --delete-conflicting-outputs
```

## 📱 지원되는 플랫폼

Codespaces에서는 **웹** 플랫폼만 지원됩니다:
- ✅ Web (Chrome, Firefox 등)
- ❌ Android (에뮬레이터 불가)
- ❌ iOS (시뮬레이터 불가)
- ❌ macOS/Windows/Linux 데스크톱

## 🔍 문제해결

### Flutter Doctor 실행
```bash
flutter doctor
```

### 의존성 재설치
```bash
flutter clean
flutter pub get
```

### 포트 문제
만약 8080 포트가 사용 중이면:
```bash
flutter run -d web-server --web-port 3000 --web-hostname 0.0.0.0
```

### VS Code 확장프로그램 수동 설치
1. 확장프로그램 패널 열기
2. "Dart" 및 "Flutter" 확장프로그램 설치

## 💡 팁

1. **Hot Reload**: `r` 키로 빠른 새로고침
2. **Hot Restart**: `R` 키로 완전 재시작
3. **터미널**: `` Ctrl+` `` (백틱)으로 터미널 열기
4. **파일 탐색**: `Ctrl+P`로 빠른 파일 검색
5. **Git**: 내장 Git 지원으로 커밋/푸시 가능

## 📊 리소스 사용량

- **CPU**: 2-4 core 권장
- **RAM**: 4-8GB 권장
- **Storage**: 프로젝트 크기에 따라 자동 할당

## ⚠️ 제한사항

- Codespace는 일정 시간 후 자동 정지됩니다
- 무료 계정은 월 사용량 제한이 있습니다
- 네이티브 앱(Android/iOS) 개발은 불가능합니다
- 물리적 디바이스 연결은 불가능합니다

## 🆘 도움말

문제가 발생하면:
1. Codespace 재시작: 브라우저 새로고침
2. 완전 재구축: Codespace 삭제 후 재생성
3. [GitHub Codespaces 문서](https://docs.github.com/en/codespaces) 참조
