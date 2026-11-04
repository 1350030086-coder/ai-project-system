# WF-001 — Task Intake

## Status
Design and repository artifacts only. Import into n8n and configure credentials before activation. Production webhook is not called by this workflow.

## Flow
Webhook (POST) → Validate Payload → Normalize → Idempotency Check → Create Task ID → Persist Task → Log Status → Respond 202 → Send to WF-002 (disabled until configured).

## Contract
Accept JSON:
```json
{
  "source": "web|github|manual|n8n",
  "request": "Describe the desired outcome",
  "goal": "Optional concise goal",
  "deadline": "Optional ISO-8601 timestamp",
  "priority": "low|normal|high|urgent",
  "request_id": "Optional caller-provided idempotency key",
  "metadata": {}
}
```
Required: request (non-empty string), source (non-empty string). Reject malformed JSON, unsupported content type, oversized body, invalid priority, invalid deadline, and missing request. Return 400 for validation errors, 202 for accepted tasks, 409 for duplicate idempotency key.

## Normalized task
`task_id`, `source`, `request`, `goal`, `deadline`, `priority`, `status`, `created_at`, `idempotency_key`, `schema_version`, `metadata`.

Task ID: UUID v4. Idempotency key: request_id when supplied; otherwise hash of normalized source + request + caller identity. Persist idempotency key with a unique constraint in PostgreSQL; do not rely on workflow static data for concurrency safety.

## Reliability
- Retry transient persistence / planner handoff errors with exponential backoff and jitter, maximum 3 attempts.
- Never retry validation errors.
- Persist before handoff; use outbox/status=queued to avoid lost tasks.
- Use correlation_id/task_id in every log.
- Redact credentials, authorization headers, and secrets from logs.
- Dead-letter after retry exhaustion; alert and preserve task record.
- Keep planner handoff disabled until WF-002 endpoint and auth are configured.

## Security
Use n8n credentials for database and planner auth. Validate source against an allowlist where possible. Enforce request size limits and webhook authentication/signature. Production destructive actions are out of scope.

## Acceptance tests
1. Valid request → 202, UUID, queued record.
2. Missing request → 400, no record.
3. Invalid JSON/priority/deadline → 400.
4. Same idempotency key → 409 or original task response; only one record.
5. Database transient failure → bounded retry, then error workflow.
6. Planner unavailable → task remains queued; retry via outbox.
7. Logs include task/correlation ID and redact secrets.
