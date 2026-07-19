---
name: commit-expert
description: Generate git commit messages from staged diffs
---

# Commit Message Prompt

**문서 상태**: Normative  
**대상 독자**: AI coding agent, maintainer

이 문서는 staged diff를 기반으로 커밋 메시지를 작성할 때 사용할 표준 프롬프트를 정의한다.
커밋 메시지를 요청받으면 아래 프롬프트를 우선 참고한다.

## 표준 프롬프트

```text
You are generating a git commit message from an attached staged git diff.

The attached file contains the full staged diff.
Analyze only the attached diff and write the final commit message in Korean.

Output rules:
- Output only the final commit message.
- Do not output explanations or commentary.
- Do not use markdown code fences.
- Do not invent anything that is not supported by the diff.
- Keep the wording practical, concise, and work-oriented.
- Use natural Korean commonly used in real development teams.
- Prefer concise titles using expressions like 적용, 정리, 분리, 수정, 연결 when appropriate.
- Avoid exaggerated, vague, or overly abstract wording.

Commit type rules:
- The title type must be exactly one of:
  feat, fix, config, refactor, test, docs, style
- Use exactly this title format:
  [type] 한 줄 요약

Type selection guide:
- feat: use when a new feature or capability is added for the user or caller
- fix: use when a bug, incorrect behavior, or broken flow is corrected and the behavior or result changes
- config: use for configuration, build, dependency, environment variable, lint/formatter, or CI-related changes
- refactor: use when code structure, implementation, internal logic, or formatting is improved without changing the behavior or result
- test: use for adding or modifying test code
- docs: use for README, guides, comments, or other documentation-only changes
- style: use when visible UI, layout, wording, or resource changes are made without changing functional behavior

Decision rules:
- If the visible result changes but functional behavior does not, prefer style.
- If the visible result stays the same and only code is reorganized, prefer refactor.
- If the behavior or result changes due to a bug fix or flow correction, prefer fix.
- If a new capability or feature is added, prefer feat.
- For config commits, make the title specific enough to show what was changed.

Required output structure:
[type] 한 줄 요약

WHY
- Keep this short and conservative.
- Write only what can be reasonably inferred from the diff.
- If the change is mostly documentation, cleanup, or file reorganization, keep WHY minimal.

상세
* Group changes by meaningful change units.
  - Describe the actual changes.
  - Add sub-details only when helpful.

Optional sections:
영향 범위
- Include only when the diff clearly affects API, DB/storage, or other screens/features.

테스트 / 검증
- Include only when tests were added/changed or the verification method is clearly visible from the diff.

ISSUE : #123
- Include only if an issue number is clearly identifiable from the branch name or provided context.

Formatting constraints:
- "상세" section is mandatory.
- "WHY" should normally be included, but keep it brief.
- Use these section titles exactly:
  WHY
  상세
  영향 범위
  테스트 / 검증
- Do not add colons after section titles.
- Use "-" under WHY and optional sections.
- Use "*" for top-level items under 상세.
- Use "-" for nested details under 상세.
- Omit optional sections entirely if not needed.
- Do not output empty section headers.
- Do not output placeholder text.
- Keep the message compact but specific.

Style guidance:
- The title must be short, practical, and as specific as possible.
- Especially for config commits, clearly describe what was changed.
- Prefer concrete wording over abstract wording.
- Do not write promotional or emotional expressions.
- Do not mention anything not present in the diff.
- Group related changes under meaningful detail items instead of listing files mechanically.
- Prefer concise noun-ending phrases in `WHY` and `영향 범위` bullets instead of full sentence endings like `필요했다`, `추가된다`, or `변경된다`.

Title examples to emulate:
- [feat] 라이더 상세 화면에 정산 내역 조회 기능 추가
- [fix] 로그인 만료 시 토큰 갱신 처리 오류 수정
- [config] eslint flat config 적용
- [refactor] 정산 금액 계산 로직 분리 및 함수 구조 정리
- [test] 정산 계산 서비스 단위 테스트 추가
- [docs] 개발 환경 실행 가이드 정리
- [style] 정산 상세 화면 버튼 간격 및 문구 수정

Context:
- Branch name: {{BRANCH_NAME}}
```
