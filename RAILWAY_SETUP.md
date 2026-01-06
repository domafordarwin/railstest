# Railway 배포 가이드 - Hello Railway

## 프로젝트 정보
- Rails 8.1.1 기반 간단한 Hello World 앱
- PostgreSQL 데이터베이스 연결 포함
- Message 모델을 통한 DB 연결 테스트

## 🚀 Railway 배포 단계

### Step 1: Railway 프로젝트 생성

1. [Railway 웹사이트](https://railway.app) 로그인
2. **"New Project"** 클릭
3. **"Deploy from GitHub repo"** 선택
4. 해당 GitHub 저장소 선택
5. Railway가 자동으로 Dockerfile을 감지하고 빌드 시작

---

### Step 2: PostgreSQL 데이터베이스 추가 (필수)

1. Railway 프로젝트 대시보드에서 **"New"** 버튼 클릭
2. **"Database"** 선택
3. **"Add PostgreSQL"** 클릭
4. PostgreSQL 서비스가 생성되면 자동으로 `DATABASE_URL` 환경 변수가 설정됩니다

**중요**: PostgreSQL과 Rails 앱 서비스가 같은 프로젝트 내에 있어야 자동으로 연결됩니다.

---

### Step 3: 환경 변수 설정 (필수)

#### 3-1. Railway 서비스 선택
- Railway 대시보드에서 **Rails 앱 서비스** (GitHub 저장소 이름)를 클릭

#### 3-2. Variables 탭 열기
- 상단 탭에서 **"Variables"** 클릭

#### 3-3. 환경 변수 추가
**"Raw Editor"** 버튼을 클릭하여 다음 변수들을 추가:

```bash
RAILS_MASTER_KEY=여기에_master.key_내용_입력
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true
```

#### RAILS_MASTER_KEY 찾기:
```bash
# 로컬에서 실행:
cat config/master.key
```

이 키를 복사하여 Railway의 `RAILS_MASTER_KEY` 값으로 입력하세요.

#### 각 변수 설명:

| 변수 이름 | 값 | 설명 |
|---------|-----|-----|
| `RAILS_MASTER_KEY` | config/master.key의 내용 | Rails credentials 복호화 키 |
| `RAILS_ENV` | `production` | Rails 실행 환경 |
| `RAILS_LOG_TO_STDOUT` | `true` | Railway 로그에 출력 활성화 |
| `RAILS_SERVE_STATIC_FILES` | `true` | 정적 파일 제공 활성화 |

#### 3-4. 변수 저장
- **"Update Variables"** 클릭
- 자동으로 재배포가 시작됩니다

---

### Step 4: 배포 확인

1. **"Deployments"** 탭에서 배포 진행 상황 확인
2. **"View Logs"** 클릭하여 빌드 및 실행 로그 확인
3. 로그에서 다음 메시지들을 확인:
   ```
   === Docker Entrypoint Starting ===
   PORT: 8080
   RAILS_ENV: production
   DATABASE_URL: postgresql://...
   === Running db:prepare ===
   === db:prepare completed successfully ===
   === Running db:seed ===
   === db:seed completed ===
   ```
4. 배포 성공 시 **"Settings"** → **"Networking"**에서 URL 확인

---

### Step 5: 도메인 확인 및 테스트

1. **"Settings"** 탭 → **"Networking"** 섹션
2. **"Generate Domain"** 클릭 (아직 없다면)
3. 생성된 URL (예: `hello-railway.up.railway.app`) 복사
4. 브라우저에서 접속하여 앱 동작 확인

#### 정상 작동 시 확인할 수 있는 내용:
- "Hello Railway! 🚀" 제목
- "Database connection is working perfectly! ✅" 메시지
- PostgreSQL에서 가져온 3개의 샘플 메시지
- Ruby 및 Rails 버전 정보

---

## 📝 주요 파일 설명

### 1. `Dockerfile`
- PostgreSQL 클라이언트 포함
- Railway의 PORT 환경 변수 자동 감지
- Production 모드로 Rails 서버 시작

### 2. `bin/docker-entrypoint`
- 상세한 로깅 포함
- 자동으로 `db:prepare` 실행 (마이그레이션)
- 자동으로 `db:seed` 실행 (샘플 데이터 생성)

### 3. `config/database.yml`
- Railway의 `DATABASE_URL` 환경 변수 사용
- primary, cache, queue, cable 데이터베이스 모두 설정

### 4. `app/controllers/home_controller.rb`
- Message 모델 조회하여 DB 연결 테스트
- 모든 메시지를 뷰에 전달

### 5. `db/seeds.rb`
- 3개의 샘플 메시지 자동 생성
- Idempotent 구조 (중복 실행 안전)

---

## 🔧 로컬 테스트

Railway에 배포하기 전에 로컬에서 테스트:

```bash
# PostgreSQL이 설치되어 있다면:
bundle install
rails db:create db:migrate db:seed
rails server

# 브라우저에서 http://localhost:3000 접속
```

---

## ⚠️ 문제 해결

### "Starting Container" → "Stopping Container" 반복

**원인**: 환경 변수가 설정되지 않았거나 DATABASE_URL이 없음

**해결**:
1. Variables 탭에서 모든 환경 변수 확인
2. PostgreSQL 서비스가 추가되었는지 확인
3. Deploy Logs에서 정확한 에러 메시지 확인

### DATABASE_URL 관련 에러

**원인**: PostgreSQL 서비스가 추가되지 않음

**해결**:
1. "New" → "Database" → "Add PostgreSQL" 클릭
2. 같은 프로젝트 내에 있는지 확인
3. DATABASE_URL이 Variables 탭에 자동으로 추가되었는지 확인

### RAILS_MASTER_KEY 에러

**원인**: RAILS_MASTER_KEY가 설정되지 않았거나 잘못됨

**해결**:
1. 로컬에서 `cat config/master.key` 실행
2. 출력된 값을 정확히 복사
3. Railway Variables에서 RAILS_MASTER_KEY 값 업데이트

---

## 📊 배포 후 확인사항

배포가 성공했다면 다음을 확인하세요:

1. ✅ 홈페이지에 "Hello Railway! 🚀" 표시
2. ✅ "Database is connected!" 메시지 표시
3. ✅ 3개의 샘플 메시지가 표시됨
4. ✅ Ruby 및 Rails 버전 정보 표시
5. ✅ Environment: production 표시

---

## 🎯 다음 단계

이 프로젝트는 Railway 배포 연습용 최소 프로젝트입니다. 실제 프로젝트 배포 시:

1. CORS 설정 (필요 시)
2. 커스텀 도메인 설정
3. 환경별 설정 분리
4. 로깅 및 모니터링 설정
5. 백업 및 스케일링 계획

---

**배포 완료!** 🎉

문제가 발생하면 Railway의 Deploy Logs를 확인하세요.
