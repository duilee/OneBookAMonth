# 🎭 Claude Orchestration System

## 개요
Claude Code의 글로벌 에이전트들을 체계적으로 관리하고 실행하는 오케스트레이션 시스템입니다. 구조화된 워크플로우와 템플릿 기반 협업을 통해 에이전트 간 효율적인 소통과 일관된 품질을 보장합니다.

---

## 🚀 빠른 시작 가이드

### 1. 새 프로젝트 시작
```bash
# workflow-orchestrator를 사용하여 새 프로젝트 초기화
"새 프로젝트를 시작하고 싶어"
```

오케스트레이터가 자동으로:
- 프로젝트 구조 생성
- 템플릿 준비
- project-context.md 초기화
- 첫 번째 에이전트(product-owner) 추천

### 2. 에이전트 체인 실행
```
product-owner (제품 비전) → market-researcher (시장 검증) → 
tech-lead (기술 설계) → designer (UI/UX) → ios-developer (구현)
```

각 에이전트가 자동으로:
- 적절한 템플릿 로드
- 이전 에이전트의 산출물 참조
- 다음 에이전트 추천

---

## 📁 디렉토리 구조

```
~/.claude/orchestration/
├── core-config.yaml         # 시스템 설정
├── agents/                  # 에이전트 정의
│   ├── workflow-orchestrator.md
│   ├── product-owner-integrated.md
│   ├── market-researcher-integrated.md
│   ├── tech-lead-integrated.md
│   ├── designer-integrated.md
│   └── ios-developer-integrated.md
├── templates/               # 문서 템플릿
│   ├── prd-template.md
│   ├── technical-spec-template.md
│   ├── design-spec-template.md
│   ├── story-template.md
│   └── project-context-template.md
├── workflows/               # 워크플로우 정의
│   └── workflow-protocol.md
├── checklists/              # 체크리스트
│   └── agent-handoff-checklist.md
├── tasks/                   # 실행 태스크
│   ├── init-project.md
│   └── execute-workflow.md
└── README.md               # 이 문서
```

---

## 🎯 주요 기능

### 1. 구조화된 템플릿
- **PRD Template**: 제품 요구사항 문서
- **Technical Spec**: 기술 명세서
- **Design Spec**: 디자인 시스템 명세
- **Story Template**: 개발 스토리 추적
- **Project Context**: 프로젝트 상태 관리

### 2. 자동 워크플로우
- 에이전트 간 자동 핸드오프
- 품질 게이트 검증
- 진행 상황 추적
- 컨텍스트 보존

### 3. 한국어 지원
- 사용자와는 한국어로 소통
- 문서는 영어로 작성
- 명확한 상태 보고

---

## 👥 에이전트 역할

### workflow-orchestrator
- **역할**: 전체 워크플로우 관리
- **책임**: 에이전트 체인 실행, 품질 검증, 상태 추적

### product-owner (Expert Product Owner)
- **역할**: 제품 비전 수립
- **산출물**: PRD (Executive Summary, Product Vision)
- **다음**: market-researcher

### market-researcher
- **역할**: 시장 검증 및 분석
- **산출물**: Market Analysis, Validation Scores
- **다음**: tech-lead

### tech-lead
- **역할**: 기술 아키텍처 설계
- **산출물**: Technical Specification, API Design
- **다음**: designer

### designer
- **역할**: UI/UX 디자인
- **산출물**: Design System, Component Library
- **다음**: ios-developer

### ios-developer
- **역할**: 구현 및 테스트
- **산출물**: Source Code, Tests, Documentation
- **다음**: Release

---

## 📝 사용 예제

### 예제 1: PRD 작성
```korean
User: "AI 기반 피트니스 앱 아이디어가 있어"

Orchestrator: "새로운 프로젝트를 시작하겠습니다. product-owner 에이전트를 활성화할까요?"

User: "응"

Product-owner: "혁신적인 아이디어네요! PRD 템플릿을 사용하여 체계적으로 정리하겠습니다..."
[자동으로 PRD 템플릿 로드 및 작성]
```

### 예제 2: 진행 상황 확인
```korean
User: "현재 프로젝트 상태 알려줘"

Orchestrator: "프로젝트 진행 상황입니다:
- 현재 단계: Technical Architecture (3/5)
- 완료: PRD ✅, Market Validation ✅
- 진행 중: Tech Spec 작성 (70%)
- 다음: UI/UX Design"
```

### 예제 3: 에이전트 전환
```korean
Tech-lead: "기술 명세 작성이 완료되었습니다.

✅ 완료 항목:
- 시스템 아키텍처: 마이크로서비스
- API 설계: 30개 엔드포인트
- 성능 목표: <200ms 응답

다음은 designer 에이전트로 UI/UX 설계를 진행하시겠습니까?"
```

---

## 🔧 고급 사용법

### 병렬 실행
특정 에이전트들은 병렬로 실행 가능:
- market-researcher & designer (PRD 완료 후)
- 여러 개발자 (다른 기능 구현 시)

### 품질 게이트
각 단계 전환 시 자동 검증:
- PRD → Tech: 비전 명확성, 성공 지표
- Tech → Design: 아키텍처, API 명세
- Design → Dev: 모든 화면, 에셋 export

### 컨텍스트 관리
project-context.md가 자동 업데이트:
- 에이전트 작업 완료 시
- 중요 결정 시
- 블로커 발생 시

---

## 📊 성과 지표

### 예상 개선 효과
- **생산성**: 30-40% 향상
- **재작업**: 80% 감소
- **정보 손실**: 90% 감소
- **문서 품질**: 일관성 확보

### 측정 방법
```yaml
metrics:
  handoff_time: < 2 hours (이전: 4+ hours)
  rework_rate: < 10% (이전: 20-30%)
  context_loss: < 5% (이전: 15-20%)
  quality_gate_pass: > 95% (이전: 70%)
```

---

## 🐛 문제 해결

### 템플릿을 찾을 수 없을 때
```bash
ls ~/.claude/orchestration/templates/
# 템플릿 목록 확인
```

### 에이전트가 응답하지 않을 때
```korean
"workflow-orchestrator를 사용하여 현재 상태 확인"
```

### 컨텍스트가 손실되었을 때
```korean
"project-context.md를 확인하고 복구"
```

---

## 🚦 시작하기

### Step 1: 시스템 확인
```bash
# 설치 확인
ls ~/.claude/orchestration/
```

### Step 2: 첫 프로젝트
```korean
"workflow-orchestrator를 사용하여 새 프로젝트 시작"
```

### Step 3: 워크플로우 실행
```korean
"product-owner으로 제품 비전 수립"
```

---

## 📚 추가 문서

- [Workflow Protocol](workflows/workflow-protocol.md)
- [Agent Handoff Checklist](checklists/agent-handoff-checklist.md)
- [Template Guide](templates/)
- [Core Configuration](core-config.yaml)

---

## 🎉 시작할 준비가 되셨나요?

이제 오케스트레이션 시스템이 준비되었습니다! 

**첫 명령어**: 
```korean
"새로운 앱 프로젝트를 시작하고 싶어"
```

오케스트레이터가 안내해드릴 것입니다. 🚀

---

*Version 2.0.0 | Last Updated: 2024-12-29*
*Fully integrated agent system with orchestration enhancements*