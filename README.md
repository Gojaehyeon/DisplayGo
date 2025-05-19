# DisplayGo

> Quickly swap your main display on macOS without dragging windows.
단축키 하나로 메인 디스플레이를 전환하세요.
[MAc App Store Download!](https://apps.apple.com/kr/app/displaygo/id6746069948?l=en-GB&mt=12)

---

**🧐 Motivation / 제작 동기**

> When using a dual-monitor setup on my Mac — one for main work and the other for AI chatbots or messengers — I often found it inconvenient to keep turning my head to switch focus.
> 
> 
> I wanted a tool that would let me **swap the actual content of the screens** with a single shortcut, **so I could stay focused in the same direction without physically moving.**
> 
> That’s why I built DisplayGo.
> 

> 메인 작업용 모니터와 AI 챗봇이나 메신저를 띄워놓는 모니터 두 대 구성으로 맥을 사용할 때, 목을 자꾸 움직여 시선을 바꾸는 게 불편했습니다.
보조 모니터의 컨텐츠로 집중을 옮겨야 하는 경우 **메인 모니터를 향한 시선을 그대로 둔 채 단축키 하나로 화면 자체를 스왑하는 툴**이 있으면 좋겠다고 생각했고, 직접 만들었습니다.
> 

---

## 🙋‍♂️ Author / 제작자

<div align="left" style="display: flex; align-items: center; gap: 32px;">

  <img src="https://avatars.githubusercontent.com/u/149154032?v=4" width="230" style="border-radius: 12px;" />

  <div style="flex: 1;">
    <strong style="font-size: 20px;">고재현 (Go Jaehyun)</strong><br>
    <span style="font-size: 16px;">Indie iOS/macOS Developer · Product Designer                       </span><br><br>
    <ul>
      <li><strong>GitHub:</strong> <a href="https://github.com/Gojaehyeon">@Gojaehyeon</a></li>
      <li>✨ I make tools that simplify daily workflows.</li>
      <li>🛠️ Always building for real-life use cases.</li>
      <li>🚀 Dreaming of working in Silicon Valley</li>
    </ul>
  </div>

</div>

---

**🔧 Features / 기능**

- ✅ Instantly swap primary display between two monitors
    
    → 외부 모니터 두 대 사이에서 메인 디스플레이를 즉시 전환
    
- ✅ No root permissions required
    
    → 루트 권한 없이 사용 가능
    
- ✅ Menu bar app
    
    → 메뉴바 앱
    
- ✅ Written in Swift with CoreGraphics → Swift + CoreGraphics 기반 구현

---

**💻 How to Use / 사용 방법**

1. **Launch the app and set your preferred shortcut.**
    
    앱을 실행한 뒤, 원하는 단축키를 설정하세요.
    
    *(기본 단축키는 ⌘ + ⌥ + 1 입니다)*
    
2. 🔁 **The app swaps your main display instantly**
    
    실행 중인 상태에서 단축키를 누르면 메인 디스플레이가 전환됩니다.
    
3. 🖥️ **Currently supports only two displays**
    
    현재는 최대 2개의 디스플레이까지만 지원됩니다.
    
4. 🚫 **The app runs in the menu bar, not in the Dock**
    
    앱은 메뉴바에서 실행되며 Dock에는 표시되지 않습니다. 이 점은 정상적인 동작입니다.
    

---

**🛠️ Tech Stack / 기술 스택**

- Swift
- CoreGraphics (CGDisplay API)
- macOS AppKit

---

**✨ Plans / 앞으로의 계획**

- [ ]  세 개 이상의 모니터 환경에서 Display Swap 로직 개발 및 구현
- [ ]  앱스토어 공식 배포(심사중)
- [ ]  사용자 피드백 반영 후 지속적 업데이트

## 🗓️ DisplayGo 개발 타임라인 요약

---

### ✅ 2025.03.24 – `displayplacer` 설치, CLI 방식으로 디스플레이 스왑 시도 시작  
- Homebrew로 displayplacer 설치  
- 디스플레이 UUID 추출 및 명령어 테스트
- 절반의 성공, 단축어와 터미널을 연동하여 작동은 확인했으나 다른 디스플레이에서 작동 X

---

### ⚠️ 2025.03.25 – CLI 방식 실패  
- 디스플레이 ID가 재부팅마다 달라지는 등 신뢰성 문제  
- 자동화 스크립트 방식 포기
- 샌드박스 정책으로 인해 앱에서 터미널 접근 불가함을 배웠음

---

### 🧱 2025.03.29 – Swift 기반 macOS 메뉴바 앱 개발 시작  
- 메뉴바 앱 구조 설계  
- SwiftUI 기반으로 본격 개발 시작
- 여전히 디스플레이 스왑 로직은 구현하지 못함

---

### 🧱 2025.04.02 – CoreGraphics (CGDisplay API)를 이용한 로직 제작
- 메뉴바 앱 구조 설계  
- SwiftUI 기반으로 본격 개발 시작
- CGDisplay API 발견, 스왑 관련 핵심 함수 개발 완료

---

### 🧪 2025.04.03~04.25 – 단축키 디버깅 지옥  
- 핫키가 작동하지 않아 이벤트 수신 구조 점검  
- NSMenu 충돌, 권한 문제 등 원인 분석  
- 여러 라이브러리 시도 (HotKey, MASShortcut 등)  
- 하지만 실제로는 **핫키 패키지 누락** 상태였음

---

### 📛 2025.05.06 – 작동 착각, 실패한 핫키 구현  
- 단축키가 되는 듯 착각했지만 이벤트 수신 안 됨  
- 이 구현은 폐기

---

### ✅ 2025.05.17 – 단축키 기능 최종 성공  
- HotKey 패키지 올바르게 설치  
- `swap.swift`와 기능 통합  
- 진짜 작동하는 디스플레이 스왑 완성

---

### 🚀 2025.05.17 밤 – App Store Connect 제출  
- 이름: DisplayGo  
- 기능 설명, 다국어 설명, 스크린샷 포함 제출

---

### ❌ 2025.05.18 – 리젝 피드백 수신  
- 앱 아이콘 이슈(저작권)로 인해 3번의 리젝
- 시뮬레이터 영상 불가, 실제 기기 영상 요구

---

### 📸 2025.05.18 밤 – 실제 맥북에서 영상 촬영  
- 작동 영상 촬영 및 제출 완료

### 📸 2025.05.19 – 앱스토어 출시 완료
