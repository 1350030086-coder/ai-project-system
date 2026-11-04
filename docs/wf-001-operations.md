# WF-001 Installation and Operations

1. Import `workflows/wf-001-task-intake.json` into n8n.
2. Configure a PostgreSQL credential and create the table using `scripts/wf-001/schema.sql`.
3. Configure a webhook authentication credential or signature verification. Do not expose the production URL in logs or client-side code.
4. Set the workflow response mode to respond through the Respond to Webhook node.
5. Set planner handoff URL/auth only after WF-002 exists; keep the handoff disabled until then.
6. Activate first in a test workflow/environment. Verify all acceptance tests.
7. Monitor the Error Trigger workflow and queued/dead-letter counts.
8. Export the tested workflow JSON to Git and version it. Do not commit credentials or secret values.

## Response codes
202 accepted; 400 invalid payload; 401/403 authentication failure; 409 duplicate; 429 rate limited; 500 internal failure.
