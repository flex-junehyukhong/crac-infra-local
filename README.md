# crac-infra-local

Kind + ArgoCD + Helm 기반 로컬 GitOps 환경

클러스터 이름: `crac-local` (control-plane 1개 + worker 2개)

## 사전 요구사항

- Docker
- Kind
- kubectl
- Helm

## 빠른 시작

```bash
# 환경 구축
./scripts/setup.sh

# 환경 삭제
./scripts/teardown.sh
```

## 구조

```
crac-infra-local/
├── .github/workflows/ci.yaml          # CI 파이프라인
├── kind/kind-config.yaml              # Kind 클러스터 설정
├── argocd/
│   ├── namespace.yaml                 # 네임스페이스 정의
│   └── applications/sample-app.yaml   # ArgoCD Application
├── helm-charts/sample-app/            # 샘플 애플리케이션 Helm 차트
│   ├── Chart.yaml
│   ├── values.yaml
│   └── templates/
├── scripts/
│   ├── setup.sh                       # 환경 구축 스크립트
│   ├── teardown.sh                    # 환경 삭제 스크립트
│   └── get-argocd-password.sh         # ArgoCD 비밀번호 조회
└── README.md
```

## 아키텍처

- **Kind cluster** (`kind/kind-config.yaml`): NodePort로 30080(ArgoCD), 30000(sample app) 포트 노출
- **ArgoCD Applications** (`argocd/applications/`): auto-sync 활성화된 GitOps 배포 정의, `helm-charts/` 경로 감시
- **Helm Charts** (`helm-charts/`): `sample` 네임스페이스에 배포되는 애플리케이션 정의

## 포트 매핑

| 포트  | 서비스     | URL |
|-------|------------|-----|
| 30080 | ArgoCD UI  | https://localhost:30080 |
| 30000 | Sample App | http://localhost:30000 |

## 사용 방법

### 1. ArgoCD Application 배포 (GitOps)

```bash
kubectl apply -f argocd/applications/sample-app.yaml
```

### 2. 수동 Helm 배포

```bash
helm install sample-app helm-charts/sample-app -n sample
```

### 3. ArgoCD 비밀번호 조회

```bash
./scripts/get-argocd-password.sh
```

## 유용한 명령어

```bash
# Helm 차트 검증
helm lint helm-charts/sample-app
helm template sample-app helm-charts/sample-app

# 클러스터 상태 확인
kubectl get nodes
kubectl get pods -A

# ArgoCD 상태 확인
kubectl get applications -n argocd
kubectl get pods -n sample

# 로그 확인
kubectl logs -n argocd deployment/argocd-server
```

## 새 애플리케이션 추가

1. `helm-charts/<app-name>/`에 Helm 차트 생성
2. `argocd/applications/<app-name>.yaml`에 ArgoCD Application 생성 (차트 경로 지정)
3. Git에 Push - ArgoCD가 자동으로 동기화

## 주요 설정 파일 설명

### CI/CD

| 파일 | 설명 |
|------|------|
| `.github/workflows/ci.yaml` | GitHub Actions CI 파이프라인. Helm lint, Kind 설정 검증, 매니페스트 렌더링 테스트 수행 |

### Kind 클러스터

| 파일 | 설명 |
|------|------|
| `kind/kind-config.yaml` | Kind 클러스터 구성 정의. control-plane 1개 + worker 2개 노드 구성, NodePort 포트 매핑 (30080, 30000) |

### ArgoCD

| 파일 | 설명 |
|------|------|
| `argocd/namespace.yaml` | `argocd`, `sample` 네임스페이스 정의. ArgoCD 컴포넌트와 애플리케이션 격리 |
| `argocd/applications/sample-app.yaml` | ArgoCD Application 리소스. Git 저장소 감시, auto-sync/prune/selfHeal 활성화로 GitOps 자동화 |

### Helm Chart

| 파일 | 설명 |
|------|------|
| `helm-charts/sample-app/Chart.yaml` | 차트 메타데이터. 차트 버전(0.1.0)과 앱 버전(1.0.0) 관리 |
| `helm-charts/sample-app/values.yaml` | 기본 설정값. 레플리카 수, 이미지(nginx:alpine), 리소스 제한, NodePort 설정 |
| `templates/deployment.yaml` | Deployment 템플릿. Pod 복제본 관리, Liveness/Readiness Probe 설정 |
| `templates/service.yaml` | Service 템플릿. NodePort 타입으로 외부 트래픽을 Pod로 라우팅 |
| `templates/_helpers.tpl` | 템플릿 헬퍼 함수. 이름, 레이블 생성 로직 정의 |
