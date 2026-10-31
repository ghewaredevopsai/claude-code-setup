#!/bin/bash
# SessionStart hook (.claude/settings.json). In a Claude Code cloud session it
# starts the test Postgres, creates the role and database the tests use if they
# are missing (an environment with no setup script has neither), and exports
# the DSN tests/test_pg_*.py need, the same values as .github/workflows/ci.yml.
# Does nothing on a local machine.
[ "${CLAUDE_CODE_REMOTE:-}" = "true" ] || exit 0

# init_db() GRANTs to agentgrow_app, so the role name matters.
pg_ready() {
  service postgresql start >/dev/null 2>&1 || return 1
  su postgres -c "psql -tAc \"SELECT 1 FROM pg_roles WHERE rolname='agentgrow_app'\"" | grep -q 1 \
    || su postgres -c "psql -qc \"CREATE ROLE agentgrow_app LOGIN SUPERUSER PASSWORD 'test'\"" || return 1
  su postgres -c "psql -tAc \"SELECT 1 FROM pg_database WHERE datname='agentgrow_test'\"" | grep -q 1 \
    || su postgres -c "createdb -O agentgrow_app agentgrow_test" || return 1
}

if pg_ready >/dev/null 2>&1; then
  echo "Cloud session: test Postgres ready (role agentgrow_app, db agentgrow_test); TEST_PG_DSN and REQUIRE_TEST_PG=1 are exported, so the real-database tests run here."
else
  echo "Cloud session: test Postgres setup FAILED (service start or role/db creation). tests/test_pg_*.py will fail under REQUIRE_TEST_PG=1; check that postgresql is installed and the session runs as root."
fi

if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  echo 'export TEST_PG_DSN=postgresql://agentgrow_app:test@localhost:5432/agentgrow_test' >> "$CLAUDE_ENV_FILE"
  echo 'export REQUIRE_TEST_PG=1' >> "$CLAUDE_ENV_FILE"
fi
