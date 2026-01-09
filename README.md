# Go Now

시간을 지키는 스케줄 관리 앱

## 프로젝트 소개

Go Now는 일정 관리와 시간 계산을 도와주는 Flutter 기반 웹/모바일 앱입니다.

**주요 기능:**
- 일정별 준비시간 및 마무리시간 관리
- 이동수단별 이동시간 자동 계산
- 사용자별 설정 및 데이터 관리
- 직관적인 캘린더 UI

## Supabase 데이터베이스 설정

### 1. Supabase 프로젝트 생성

1. https://supabase.com 접속 및 계정 생성 (무료)
2. "New project" 클릭
3. 프로젝트 정보 입력:
   - Project name: go-now (원하는 이름)
   - Database Password: 안전한 비밀번호 생성
   - Region: Northeast Asia (Seoul) 선택
4. "Create new project" 클릭 (약 2분 소요)

### 2. API 키 확인 및 설정

1. 프로젝트 대시보드에서 **Settings > API** 로 이동
2. 다음 정보 복사:
   - **Project URL**: `https://xxxxx.supabase.co`
   - **anon public key**: `eyJhbGci...`

3. `lib/config/supabase_config.dart` 파일 수정:
```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://xxxxx.supabase.co'; // 복사한 URL
  static const String supabaseAnonKey = 'eyJhbGci...'; // 복사한 Key
}
```

### 3. 데이터베이스 테이블 생성

Supabase 대시보드에서 **SQL Editor** 클릭 후 다음 SQL 실행:

```sql
-- users 테이블 (사용자 추가 정보)
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  nickname TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- notices 테이블 (공지사항)
CREATE TABLE notices (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Row Level Security (RLS) 활성화
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE notices ENABLE ROW LEVEL SECURITY;

-- users 정책: 본인 데이터만 읽기/수정 가능
CREATE POLICY "Users can read own data" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own data" ON users FOR UPDATE USING (auth.uid() = id);

-- notices 정책: 모두 읽기 가능
CREATE POLICY "Anyone can read notices" ON notices FOR SELECT TO authenticated USING (true);
```

## 개발 환경 설정

### Flutter 개발 서버 실행

#### Chrome 모드 (권장)
```bash
flutter run -d chrome
```
- 자동으로 Chrome 브라우저에서 앱 실행
- Hot Reload 지원 (앱 실행 중 `r` 키 입력)
- Hot Restart 지원 (앱 실행 중 `R` 키 입력)

#### Web Server 모드
```bash
flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0
```
- `http://localhost:8080` 으로 접속
- 브라우저를 수동으로 열어야 함

## 개발 서버 관리 가이드

### 백그라운드 프로세스 문제 방지

Flutter 개발 서버를 실행할 때 다음 사항들을 주의해야 합니다:

#### 문제 상황
- 반복적으로 `flutter run`을 실행하면 백그라운드에 여러 개의 프로세스가 쌓임
- 포트 충돌 발생 (8080 포트 중복 사용)
- 메모리 및 리소스 낭비

#### 방지 방법

**1. 새 서버 시작 전 기존 프로세스 확인**

Windows:
```bash
# 8080 포트 사용 중인 프로세스 확인
netstat -ano | findstr :8080

# 프로세스 종료 (PID는 위 명령어 결과에서 확인)
taskkill /F /PID <PID>
```

macOS/Linux:
```bash
# 8080 포트 사용 중인 프로세스 확인
lsof -i :8080

# 프로세스 종료
kill -9 <PID>
```

**2. 모든 Flutter 프로세스 일괄 종료**

Windows:
```bash
taskkill /F /IM dart.exe /T
taskkill /F /IM flutter.exe /T
```

macOS/Linux:
```bash
pkill -f flutter
pkill -f dart
```

**3. 하나의 서버만 실행**
- 개발 중에는 하나의 Flutter 서버만 실행하는 것을 권장
- 새로운 서버를 시작하기 전에 기존 서버를 종료 (`q` 키 입력)

#### 베스트 프랙티스

1. **서버 시작 전 체크리스트**
   - 기존 서버가 실행 중인지 확인
   - 포트 충돌 여부 확인
   - 필요시 기존 프로세스 종료

2. **개발 중**
   - Hot Reload (`r` 키) 적극 활용
   - 구조적 변경 시에만 Hot Restart (`R` 키)
   - 서버를 종료하지 않고 코드 수정 반영

3. **서버 종료**
   - 작업 종료 시 반드시 서버 종료 (`q` 키)
   - 백그라운드 프로세스가 남지 않도록 확인

### 포트 충돌 해결

**증상:**
```
SocketException: Failed to create server socket (OS Error: 각 소켓 주소는 하나만 사용할 수 있습니다, errno = 10048)
```

**해결 방법:**
1. 8080 포트를 사용 중인 프로세스 확인 및 종료
2. 또는 다른 포트 사용:
   ```bash
   flutter run -d web-server --web-port 8081
   ```

### Chrome 모드 vs Web Server 모드

| 구분 | Chrome 모드 | Web Server 모드 |
|-----|-------------|----------------|
| 실행 방법 | `flutter run -d chrome` | `flutter run -d web-server --web-port 8080` |
| 포트 | 랜덤 포트 자동 할당 | 고정 포트 (지정 필요) |
| 브라우저 | 자동 실행 | 수동 접속 |
| Hot Reload | 지원 | 지원 |
| 추천 용도 | 개발 환경 | 테스트/데모 환경 |

## Getting Started with Flutter

Flutter 프로젝트가 처음이라면:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Flutter 공식 문서](https://docs.flutter.dev/)
