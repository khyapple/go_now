# Go Now 디자인 시스템 (Design System)

> 일관된 사용자 경험을 위한 Go Now 앱의 디자인 가이드

---

## 📋 목차

1. [색상 (Colors)](#색상-colors)
2. [타이포그래피 (Typography)](#타이포그래피-typography)
3. [간격 (Spacing)](#간격-spacing)
4. [모서리 둥글기 (Border Radius)](#모서리-둥글기-border-radius)
5. [그림자 (Shadows)](#그림자-shadows)
6. [아이콘 (Icons)](#아이콘-icons)
7. [버튼 (Buttons)](#버튼-buttons)
8. [입력 필드 (Input Fields)](#입력-필드-input-fields)
9. [카드/컨테이너 (Cards/Containers)](#카드컨테이너-cardscontainers)
10. [테두리 (Borders)](#테두리-borders)
11. [특수 컴포넌트](#특수-컴포넌트)
12. [애니메이션/전환](#애니메이션전환)

---

## 색상 (Colors)

### 1. Primary Color - Blue (파랑)

#### 사용 위치별 색상 번호

**Colors.blue[50]** `#E3F2FD`
- 배경색 (선택된 항목, 하이라이트 영역)
- 아이콘 컨테이너 배경
- 시간 표시 박스 배경
- 선택된 리스트 항목 배경

**Colors.blue[100]** `#BBDEFB`
- 배지 배경 (스케줄 개수 표시)
- 작은 컨테이너 배경

**Colors.blue[600]** `#1E88E5` ⭐ **가장 많이 사용**
- 앱바 타이틀 색상
- 주요 버튼 배경 (ElevatedButton)
- 아이콘 색상 (primary icons)
- 강조 텍스트 (타이머 숫자, 중요 정보)
- 링크 버튼 텍스트
- 다이얼로그 헤더 배경
- 테두리 (포커스 상태)
- 진행 표시 (CircularProgressIndicator)
- 시간 배지 배경
- 스케줄 색상 옵션

**Colors.blue[700]** `#1976D2`
- 배지 내부 텍스트 색상

### 2. Neutral Colors - Grey (회색)

#### 배경 계열

**Colors.grey[50]** `#FAFAFA`
- 앱 전체 배경색 (Scaffold background)
- 리스트 아이템 배경

**Colors.grey[100]** `#F5F5F5`
- 이모지 선택기 배경 등

#### 테두리 계열

**Colors.grey[200]** `#EEEEEE`
- 밝은 테두리
- 컨테이너 구분선
- 진행 바 배경

**Colors.grey[300]** `#E0E0E0`
- 입력 필드 기본 테두리 (enabledBorder)
- 일반 컨테이너 테두리
- 달력 셀 테두리

#### 텍스트/아이콘 계열

**Colors.grey[400]** `#BDBDBD`
- 비활성 텍스트
- 작은 아이콘 (화살표 등)
- 외부 날짜 (달력)

**Colors.grey[500]** `#9E9E9E`
- 보조 정보 텍스트

**Colors.grey[600]** `#757575`
- 일반 보조 텍스트
- 힌트 텍스트
- 부제목
- 캘린더 추가 정보
- 취소 버튼 텍스트

**Colors.grey[700]** `#616161`
- 일반 아이콘 (settings, back button)
- 라벨 텍스트

**Colors.grey[800]** `#424242`
- 강조 텍스트 (날짜 등)

### 3. Status Colors (상태 색상)

#### Success - Green (성공/확인)

**Colors.green[600]** `#43A047`
- 등록하기 버튼 배경
- 성공 상태 표시
- 스케줄 색상 옵션

**Colors.green[50]**
- 선택된 초록 스케줄 배경

#### Warning - Orange/Amber (경고)

**Colors.orange[50]** `#FFF3E0`
- 경고 배너 배경

**Colors.orange[200]** `#FFCC80`
- 경고 테두리

**Colors.orange[600]** `#FB8C00`
- 스케줄 색상 옵션

**Colors.orange[700]** `#F57C00`
- 경고 아이콘 색상

**Colors.amber** (기본)
- 스케줄 색상 옵션

#### Error/Delete - Red (에러/삭제)

**Colors.red[400]** `#EF5350`
- 삭제 아이콘 색상 (작은 X 버튼)

**Colors.red[600]** `#E53935`
- 삭제 버튼 배경
- 삭제 확인 텍스트
- 스케줄 색상 옵션

**Colors.red[50]**
- 선택된 빨강 스케줄 배경

### 4. Schedule Colors (스케줄 색상 팔레트)

각 색상은 [50], [600] 두 가지 톤으로 사용됩니다.

**Purple (보라)**
- `Colors.purple[50]` - 배경
- `Colors.purple[600]` `#8E24AA` - 강조

**Pink (분홍)**
- `Colors.pink[50]` - 배경
- `Colors.pink[600]` `#D81B60` - 강조

**Teal (청록)**
- `Colors.teal[50]` - 배경
- `Colors.teal[600]` `#00897B` - 강조

### 5. System Colors (시스템 색상)

**Colors.white** `#FFFFFF`
- 카드 배경
- 버튼 텍스트 (primary buttons)
- 다이얼로그 배경
- 입력 필드 배경
- 컨테이너 배경
- 앱바 배경

**Colors.black87** `rgba(0,0,0,0.87)`
- 주요 텍스트 색상

**Colors.black.withOpacity(0.05)** `rgba(0,0,0,0.05)`
- 그림자 색상

**Colors.transparent**
- 투명 배경 (특수 용도)

### 색상 사용 규칙

#### 배경 계층 구조
```
Level 1: Colors.grey[50]      (앱 전체 배경)
Level 2: Colors.white          (카드/컨테이너)
Level 3: Colors.blue[50]       (선택/강조 영역)
```

#### 텍스트 계층 구조
```
Primary:   Colors.black87 / Colors.grey[800]  (제목, 중요 정보)
Secondary: Colors.grey[700]                    (일반 본문)
Tertiary:  Colors.grey[600]                    (보조 정보)
Disabled:  Colors.grey[500] / Colors.grey[400] (비활성)
```

#### 상태별 색상
```
Default:   Colors.grey[300]    (기본 상태)
Focus:     Colors.blue[600]    (포커스 상태)
Selected:  Colors.blue[50]     (선택 상태)
Error:     Colors.red[600]     (에러 상태)
Success:   Colors.green[600]   (성공 상태)
```

#### 색상 코드 Quick Reference

| 색상 | Hex Code | 사용 빈도 | 주요 용도 |
|------|----------|-----------|-----------|
| Blue[600] | #1E88E5 | ⭐⭐⭐⭐⭐ | Primary 색상 |
| Blue[50] | #E3F2FD | ⭐⭐⭐⭐ | 배경/선택 |
| Grey[50] | #FAFAFA | ⭐⭐⭐⭐⭐ | 앱 배경 |
| Grey[600] | #757575 | ⭐⭐⭐⭐ | 보조 텍스트 |
| Grey[300] | #E0E0E0 | ⭐⭐⭐ | 테두리 |
| White | #FFFFFF | ⭐⭐⭐⭐⭐ | 카드 배경 |
| Red[600] | #E53935 | ⭐⭐ | 삭제/에러 |
| Green[600] | #43A047 | ⭐ | 성공/확인 |

---

## 타이포그래피 (Typography)

### 폰트 패밀리
- **기본**: Flutter 시스템 기본 폰트 (San Francisco/Roboto)

### 폰트 크기

#### 대제목 (Headings)
- **특대**: `64px` - 타이머 숫자 (FontWeight.bold)
- **초대**: `32px` - 날짜 타이틀 (FontWeight.bold)
- **대**: `28px` - 페이지 제목, 스케줄 제목 (FontWeight.bold)
- **중**: `20px` - 섹션 제목 (FontWeight.bold)

#### 본문 (Body)
- **대**: `18px` - 부제목 (일반/FontWeight.w500)
- **중**: `16px` - 본문, 버튼 텍스트 (FontWeight.bold/w500)
- **소**: `14px` - 보조 본문, 힌트 (FontWeight.w500/일반)

#### 작은 텍스트 (Small)
- **작음**: `13px` - 달력 날짜 (FontWeight.w500)
- **매우 작음**: `12px` - 배지, 시간 표시 (FontWeight.bold)
- **초소**: `11px` - 캘린더 이벤트 (FontWeight.w400)
- **최소**: `10px` - 추가 정보 표시 (FontWeight.w500)

### 폰트 무게 (Font Weight)
- **Bold**: `FontWeight.bold` - 제목, 강조 텍스트, 버튼
- **Semi-Bold**: `FontWeight.w500` - 보조 제목, 카드 제목
- **Regular**: `FontWeight.w400` - 일반 본문

---

## 간격 (Spacing)

### 패딩 (Padding)

#### 화면/섹션 패딩
- **화면 전체**: `20px` (EdgeInsets.all(20))
- **다이얼로그/모달**: `24px` (EdgeInsets.all(24))
- **카드 내부**: `16px` (EdgeInsets.all(16))
- **리스트 아이템**: `16px` (EdgeInsets.all(16))

#### 작은 요소 패딩
- **작은 컨테이너**: `12px` (vertical/horizontal)
- **배지**: `8px` horizontal, `4px` vertical
- **매우 작은 요소**: `6px`
- **최소 패딩**: `4px`
- **입력 필드 아이콘**: `const EdgeInsets.symmetric(vertical: 16)`

### 마진 (Margin)

#### 요소 간 간격
- **섹션 간격**: `32px` (SizedBox(height: 32))
- **카드 간격**: `24px` (SizedBox(height: 24))
- **중간 간격**: `20px` (SizedBox(height: 20))
- **일반 간격**: `16px` (SizedBox(height: 16))
- **작은 간격**: `12px` (SizedBox(height: 12))
- **최소 간격**: `8px` (SizedBox(height: 8))
- **매우 작은 간격**: `4px` (SizedBox(height: 4))
- **리스트 아이템 하단**: `12px` (margin bottom)
- **배지 아이템**: `2px` (margin bottom)

---

## 모서리 둥글기 (Border Radius)

### 큰 요소
- **다이얼로그/모달**: `24px` (BorderRadius.circular(24))
- **큰 컨테이너**: `16px` (BorderRadius.circular(16))

### 중간 요소
- **카드/버튼**: `12px` (BorderRadius.circular(12))
- **입력 필드**: `12px` (BorderRadius.circular(12))

### 작은 요소
- **배지/태그**: `12px` (BorderRadius.circular(12)) - 배지는 큰 값
- **작은 컨테이너**: `8px` (BorderRadius.circular(8))
- **매우 작은 요소**: `4px` (BorderRadius.circular(4))
- **캘린더 이벤트**: `3px` (BorderRadius.circular(3))

### 특수
- **원형**: `CircleBorder` / `BoxShape.circle` - 타이머, 오늘 날짜 표시

---

## 그림자 (Shadows)

### 표준 그림자
```dart
BoxShadow(
  color: Colors.black.withOpacity(0.05),
  blurRadius: 10,
  offset: const Offset(0, 2),
)
```

### 강한 그림자 (타이머)
```dart
BoxShadow(
  color: Colors.black.withOpacity(0.05),
  blurRadius: 20,
  offset: const Offset(0, 4),
)
```

---

## 아이콘 (Icons)

### 아이콘 크기
- **큰 아이콘**: `80px` - 로고
- **중간 아이콘**: `24px` - 일반 아이콘
- **작은 아이콘**: `20px` - 작은 버튼 아이콘
- **매우 작은 아이콘**: `16px` - 리스트 내 화살표
- **최소 아이콘**: `14px` - 위치 아이콘 등

---

## 버튼 (Buttons)

### 주요 버튼
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue[600],
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 0,
  ),
)
```

### 보조 버튼
```dart
OutlinedButton(
  style: OutlinedButton.styleFrom(
    foregroundColor: Colors.blue[600],
    side: BorderSide(color: Colors.blue[600]!, width: 1.5),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8/12),
    ),
  ),
)
```

### 액션 버튼 (하단 버튼)
- **패딩**: `vertical: 16px`
- **아이콘 크기**: `24px`
- **아이콘-텍스트 간격**: `4px`

---

## 입력 필드 (Input Fields)

### TextField 스타일
```dart
TextField(
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey[300]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
    ),
  ),
)
```

---

## 카드/컨테이너 (Cards/Containers)

### 표준 카드
```dart
Container(
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  padding: const EdgeInsets.all(16),
)
```

### 정보 카드 (아이콘 포함)
- **아이콘 컨테이너**: 48x48px
- **아이콘 컨테이너 배경**: `Colors.blue[50]`
- **아이콘 색상**: `Colors.blue[600]`
- **아이콘-텍스트 간격**: `16px`

---

## 테두리 (Borders)

### 테두리 두께
- **강조 테두리**: `2px` - 포커스 상태
- **일반 테두리**: `1.5px` - 버튼 아웃라인
- **얇은 테두리**: `1px` - 기본 컨테이너
- **매우 얇은 테두리**: `0.5px` - 캘린더 셀

---

## 특수 컴포넌트

### 배지 (Badges)
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  decoration: BoxDecoration(
    color: Colors.blue[100],
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    '텍스트',
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Colors.blue[700],
    ),
  ),
)
```

### 시간 표시 박스
```dart
Container(
  width: 60,
  height: 60,
  decoration: BoxDecoration(
    color: Colors.blue[50],
    borderRadius: BorderRadius.circular(8),
  ),
  // 중앙 정렬된 시간 텍스트
)
```

### 다이얼로그 헤더
```dart
Container(
  padding: const EdgeInsets.all(20/24),
  decoration: BoxDecoration(
    color: Colors.blue[600],
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(24),
      topRight: Radius.circular(24),
    ),
  ),
)
```

---

## 애니메이션/전환

### 페이지 전환 시간
- **일반**: `300ms` (Duration.milliseconds(300))
- **커브**: `Curves.easeInOut`

---

## 디자인 원칙

### 1. 일관성 (Consistency)
- 8px 그리드 시스템 사용 (4, 8, 12, 16, 20, 24, 32...)
- 색상, 간격, 크기를 일관되게 적용

### 2. 계층 구조 (Hierarchy)
- 폰트 크기와 무게로 정보 계층 구분
- 색상 농도로 중요도 표현
- 그림자로 깊이감 표현

### 3. 접근성 (Accessibility)
- 충분한 색상 대비 (최소 4.5:1)
- 터치 타겟 최소 크기 (48x48px)
- 명확한 상태 표시

### 4. 사용성 (Usability)
- 충분한 터치 영역
- 명확한 피드백
- 일관된 인터랙션

---

## 버전 히스토리

- **v1.0.0** (2026-01-07): 초기 디자인 시스템 문서화
