CREATE TABLE IF NOT EXISTS agent_tasks (
  task_id UUID PRIMARY KEY,
  source TEXT NOT NULL,
  request TEXT NOT NULL,
  goal TEXT,
  deadline TIMESTAMPTZ,
  priority TEXT NOT NULL CHECK (priority IN ('low','normal','high','urgent')),
  status TEXT NOT NULL CHECK (status IN ('queued','processing','completed','failed','dead_letter')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  idempotency_key TEXT NOT NULL UNIQUE,
  schema_version INTEGER NOT NULL DEFAULT 1,
  metadata JSONB NOT NULL DEFAULT '{}'::jsonb,
  last_error TEXT
);

CREATE INDEX IF NOT EXISTS agent_tasks_status_created_idx
  ON agent_tasks (status, created_at);
