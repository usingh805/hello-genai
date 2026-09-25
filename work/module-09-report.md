# Module 09 Completion Report

## Tracked Files
project_spec.md

## Backlog Commit History

## backlog.md Contents
# COXA Daily Defect Health Report Implementation Backlog

## Delivery Priorities

- Build the foundational project and configuration layer first.
- Implement core report behavior against deterministic fake data before connecting to Rally.
- Keep the requested phase order: Setup, Core Features, Integration, Testing, Documentation.
- Treat daily scheduling as documentation-only for the MVP.
- Do not modify Rally defects or expose API keys and SMTP credentials.

## Phase 1: Setup

### Project structure and tooling

- [ ] Create the `src/coxa_defect_report/` package.
- [ ] Add `__init__.py` and `__main__.py` entry-point modules.
- [ ] Add `tests/` with separate test modules for configuration, validation, reporting, Rally integration, email delivery, and runner behavior.
- [ ] Add `requirements.txt` with only the approved runtime and test dependencies.
- [ ] Add a supported Python version declaration for Python 3.11 or newer.
- [ ] Add or verify `.gitignore` entries for `.env`, virtual environments, caches, and generated artifacts.
- [ ] Create a local Python virtual environment and document how to activate it.

### Configuration foundation

- [ ] Define a typed configuration model in `config.py`.
- [ ] Load values from environment variables and an optional local environment file.
- [ ] Support `RALLY_API_KEY`.
- [ ] Support `RALLY_PROJECT_ID` or `RALLY_PROJECT_NAME`, requiring at least one.
- [ ] Support `RALLY_BASE_URL` with the standard Rally URL as the default.
- [ ] Support SMTP host, port, username, password, TLS setting, sender, and recipients.
- [ ] Support `REPORT_TIMEZONE` with `Asia/Kolkata` as the default.
- [ ] Support report subject prefix, Rally page size, and log level.
- [ ] Add `.env.example` containing placeholders only and no real credentials.
- [ ] Validate required configuration before making Rally or SMTP requests.
- [ ] Report missing variable names without printing secret values.

### Setup acceptance checks

- [ ] A clean checkout can install dependencies using the documented command.
- [ ] Configuration validation fails clearly when required values are missing.
- [ ] No secret or local environment file is tracked by Git.

## Phase 2: Core Features

### Domain models

- [ ] Define the internal defect model with reference, name, state, Rally URL, owner, target date, iteration, release date, RCA, and resolution details.
- [ ] Define a validation result containing the original defect, ordered missing fields, and completeness status.
- [ ] Define a report summary containing checked, affected, and complete counts.

### Defect validation

- [ ] Implement blank detection for null, empty, and whitespace-only values.
- [ ] Validate Owner, Target Date, Iteration, Release Date, RCA, and Resolution Details.
- [ ] Preserve the required field order in every missing-field list.
- [ ] Treat populated date strings as valid without parsing or business-rule checks.
- [ ] Exclude defects with no missing fields from affected-defect output.
- [ ] Keep validation free of network, filesystem, and email side effects.

### HTML report rendering

- [ ] Render the `COXA Daily Defect Health Report` title.
- [ ] Render the generation timestamp in the configured timezone.
- [ ] Render counts for open defects checked, affected defects, and complete defects.
- [ ] Render an all-clear message when no affected defects exist.
- [ ] Render one detail row per affected defect only.
- [ ] Include a clickable escaped Rally link and defect reference.
- [ ] Include escaped name, state, owner, missing fields, target date, iteration, and release date.
- [ ] Indicate whether RCA and Resolution Details are missing.
- [ ] Escape every Rally-provided value before inserting it into HTML.
- [ ] Ensure missing display values appear as `Missing`.

### Core acceptance checks

- [ ] A complete open defect produces no detail row.
- [ ] A defect missing one field names exactly that field.
- [ ] A defect missing several fields lists them deterministically.
- [ ] A report with zero affected defects clearly states that all checked open defects are complete.
- [ ] Defect names and other values containing HTML-special characters render safely.

## Phase 3: Integration

### Rally client

- [ ] Implement a Rally HTTP adapter in `rally_client.py` using the configured base URL and API key.
- [ ] Send the project scope using the configured project ID or project name rather than a hard-coded project.
- [ ] Request all fields required by the internal defect model.
- [ ] Implement page-size configuration and pagination until all results are collected.
- [ ] Map Rally response fields and nested display values into the internal defect model.
- [ ] Treat state `Closed` as closed and every other state as open.
- [ ] Handle authentication failures with an actionable error.
- [ ] Handle timeout, connection, HTTP, and malformed-response errors.
- [ ] Ensure request headers, API keys, and response secrets are never logged.

### Email delivery

- [ ] Implement `email_sender.py` with Python standard-library email and SMTP support.
- [ ] Create an HTML message with the configured sender and recipients.
- [ ] Use the subject format `[COXA] Daily Defect Health Report - YYYY-MM-DD`.
- [ ] Apply TLS when enabled by configuration.
- [ ] Support SMTP authentication when credentials are configured.
- [ ] Return an actionable failure for SMTP authentication, connection, or delivery errors.
- [ ] Ensure SMTP passwords never appear in exceptions, logs, or report output.

### Runner and command

- [ ] Implement `runner.py` to orchestrate configuration, Rally retrieval, filtering, validation, rendering, and delivery.
- [ ] Add dependency injection seams for fake Rally and email clients.
- [ ] Log run start and completion without secrets.
- [ ] Log retrieved, open, affected, and complete defect counts.
- [ ] Ensure failed Rally or SMTP operations stop the run and return a non-zero result.
- [ ] Expose the complete manual run through `python -m coxa_defect_report`.
- [ ] Confirm the runner never performs Rally write operations.

### Integration acceptance checks

- [ ] Fake Rally pages combine into one complete result set.
- [ ] Closed defects are excluded from the open-defect count and report details.
- [ ] A fake SMTP client receives the expected HTML body, sender, recipients, and subject.
- [ ] Rally and SMTP failures do not produce a misleading success result.

## Phase 4: Testing

### Unit tests

- [ ] Test null, empty, and whitespace-only values for all six mandatory fields.
- [ ] Test populated values, including arbitrary populated date strings.
- [ ] Test deterministic ordering of multiple missing fields.
- [ ] Test complete defects are excluded from affected rows.
- [ ] Test state filtering with `Closed` and non-closed values.
- [ ] Test summary counts for all-clear and affected reports.
- [ ] Test HTML escaping for names, states, links, and field values.
- [ ] Test `Missing` display values.
- [ ] Test configuration defaults and required-value failures.
- [ ] Test that configuration errors do not expose secret values.

### Integration-style tests

- [ ] Test Rally pagination with fake HTTP responses.
- [ ] Test Rally authentication and HTTP failure handling.
- [ ] Test malformed Rally response handling.
- [ ] Test SMTP message construction and delivery with a fake SMTP server or client.
- [ ] Test SMTP failure handling and non-zero runner behavior.
- [ ] Test end-to-end orchestration with fake Rally and email dependencies.

### Verification

- [ ] Run the complete test suite locally.
- [ ] Run a lint or type-check command if configured.
- [ ] Confirm no test fixture contains real API keys, passwords, or private credentials.
- [ ] Verify the manual acceptance fixture includes complete, partially complete, multi-gap, closed, and HTML-special-character defects.

## Phase 5: Documentation

### User and operator documentation

- [ ] Create `README.md` with project purpose and scope.
- [ ] Document Python version and dependency installation.
- [ ] Document virtual-environment setup and activation.
- [ ] Document every required and optional environment variable.
- [ ] Document how to copy `.env.example` to a local environment file without committing it.
- [ ] Document the manual command `python -m coxa_defect_report`.
- [ ] Document expected success and failure behavior.
- [ ] Document that the application does not modify Rally defects.
- [ ] Document the initial recipient and approved-recipient considerations.
- [ ] Document how to run the test suite.
- [ ] Document the manual acceptance test procedure.

### Report documentation

- [x] Maintain `reports/template.md` as the human-readable report template.
- [x] Maintain `reports/instructions.md` with field and quality-check guidance.
- [x] Maintain `reports/example.md` with a representative completed report.
- [ ] Align report documentation with the generated HTML report fields and missing-value rules.

### Scheduling and operations

- [ ] Document future scheduling at 12:00 PM in `Asia/Kolkata`.
- [ ] Describe approved scheduler options such as launchd, cron, GitHub Actions, or a managed job.
- [ ] Document required secret handling for the selected deployment environment.
- [ ] Document operational review of the first manual report with the Scrum Master.
- [ ] Document troubleshooting for configuration, Rally, and SMTP failures.

### Final release checks

- [ ] Confirm all acceptance criteria in `project_spec.md` are covered by implementation or tests.
- [ ] Confirm the report contains no credentials or unintended sensitive configuration.
- [ ] Confirm the README command works from a clean supported environment.
- [ ] Confirm scheduling remains documentation-only for the MVP.
