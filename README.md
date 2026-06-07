# sampleapp

jinhee_tutorial 학습용 더미 Spring Boot 앱. CI/CD 자동 배포 파이프라인을 검증하는 게 유일한 목적.

## 기능

- `GET /` → `"Hello from sampleapp!"` 반환
- `GET /actuator/health/liveness` → `{"status":"UP"}`

## 스택

- Spring Boot 3.4.5 + Java 21
- PostgreSQL (JPA, 별도 DB `sampleapp`)
- Dockerfile multi-stage (gradle 빌드 → jre-alpine 실행)

## 배포

GitHub `main` 브랜치 push → Jenkins webhook → 빌드 → 배포 → Discord 알림.

페어 인프라 레포: [tletle7102/server](https://github.com/tletle7102/server)
