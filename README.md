# crac-infra-local

Kind + ArgoCD + Helm 기반 로컬 GitOps 환경

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

## 접속 정보

| 서비스 | URL | 인증 |
|--------|-----|------|
| ArgoCD | https://localhost:30080 | admin / (setup.sh 출력 참조) |
| Sample App | http://localhost:30000 | - |

## 사용 방법

### 1. ArgoCD Application 배포

```bash
# Git 저장소 URL 수정 후 적용
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
# 클러스터 상태 확인
kubectl get nodes
kubectl get pods -A

# ArgoCD 상태 확인
kubectl get applications -n argocd

# 로그 확인
kubectl logs -n argocd deployment/argocd-server
```
