# DisplayGo

> Quickly swap your main display on macOS without dragging windows.
단축키 하나로 메인 디스플레이를 전환하세요.

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

<table>
  <tr>
    <td>
      <img src="https://avatars.githubusercontent.com/u/149154032?v=4" width="120" style="border-radius: 10px;" />
    </td>
    <td style="padding-left: 16px;">
      <strong>고재현 (Go Jaehyun)</strong><br>
      Indie iOS/macOS Developer · Product Designer<br><br>
      <ul>
        <li>GitHub: <a href="https://github.com/Gojaehyeon">@Gojaehyeon</a></li>
        <li>✨ I make tools that simplify daily workflows.</li>
        <li>🛠️ Always building for real-life use cases.</li>
        <li>🚀 Dreaming of working in Silicon Valley</li>
      </ul>
    </td>
  </tr>
</table>

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
