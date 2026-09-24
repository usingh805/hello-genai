# COXA Daily Defect Health Report

## 1. Document Control

| Item | Value |
| --- | --- |
| Project | COXA |
| Product owner for this automation | Scrum Master |
| Initial audience | Upasana Singh (`upasana_singh@epam.com`) |
| Version | 1.0 - manual-first MVP |
| Status | Ready for implementation |
| Report schedule target | Daily at 12:00 PM IST after automation is enabled |

## 2. Purpose

Build an automated daily defect health report that identifies open Rally defects with mandatory fields missing. The report gives the Scrum Master a concise, actionable view of data-quality gaps so the gaps can be corrected manually in Rally.

The first version will generate and email an HTML report. It will not modify Rally defects, assign work, add comments, or create follow-up tasks.

## 3. Goals and Non-Goals

### Goals

- Retrieve all defects for the configured COXA Rally project.
- Select defects whose state is anything except `Closed`.
- Check the required fields for blank or whitespace-only values.
- Produce a readable HTML email containing one row per affected defect.
- Include enough context for the Scrum Master to open the defect and correct it manually.
- Run reproducibly from a local command using environment-based configuration.
- Fail clearly when Rally, configuration, or SMTP operations fail.

### Non-goals for version one

- Updating Rally defects automatically.
- Filtering only to the five team members; the report covers every open COXA defect.
- Validating date format, date ranges, overdue target dates, or field business rules.
- Trend dashboards or a historical reporting database.
- Automatic scheduling during the initial validation phase.
- Notifications through Teams, Slack, or other channels.

## 4. Users and Stakeholders

- **Primary user:** Scrum Master managing five people on the COXA project.
- **Initial recipient:** `upasana_singh@epam.com`.
- **Future recipients:** Configurable email addresses or a distribution list.
- **Data source owner:** Rally project administrators.

## 5. Functional Requirements

### FR-1: Configuration

The application must read runtime configuration from environment variables or an environment file that is excluded from version control.

Required configuration:

- `RALLY_API_KEY`: Rally API key.
- `RALLY_PROJECT_ID` or `RALLY_PROJECT_NAME`: the COXA project identifier. Prefer the immutable project ID when available.
- `RALLY_BASE_URL`: Rally API base URL, with the standard Rally URL as the default.
- `SMTP_HOST`: SMTP server hostname.
- `SMTP_PORT`: SMTP server port.
- `SMTP_USERNAME`: SMTP username, if required.
- `SMTP_PASSWORD`: SMTP password, if required; never log this value.
- `EMAIL_FROM`: sender address.
- `EMAIL_TO`: comma-separated recipient addresses; default recipient is `upasana_singh@epam.com`.
- `REPORT_TIMEZONE`: default `Asia/Kolkata`.

Optional configuration:

- `SMTP_USE_TLS`: whether to use TLS; default enabled.
- `REPORT_SUBJECT_PREFIX`: subject prefix, such as `[COXA]`.
- `RALLY_PAGE_SIZE`: page size for Rally requests.
- `LOG_LEVEL`: default `INFO`.

The application must validate required configuration before making external requests and report missing variable names without exposing secrets.

### FR-2: Rally defect retrieval

The application must:

1. Authenticate to Rally using `RALLY_API_KEY`.
2. Query defects within the configured COXA project.
3. Retrieve all matching defects, following pagination until all results are collected.
4. Select defects whose state is not `Closed`.
5. Extract the defect identifier, formatted defect reference, name, state, owner, target date, iteration, release date, RCA, resolution details, and Rally URL where available.

The project scope must be configured rather than hard-coded in application logic.

### FR-3: Mandatory-field validation

Each selected open defect must be checked for these mandatory fields:

| Field | Blank condition |
| --- | --- |
| Owner | Missing, null, empty, or whitespace-only value |
| Target Date | Missing, null, empty, or whitespace-only value |
| Iteration | Missing, null, empty, or whitespace-only value |
| Release Date | Missing, null, empty, or whitespace-only value |
| RCA | Missing, null, empty, or whitespace-only value |
| Resolution Details | Missing, null, empty, or whitespace-only value |

A populated field passes version-one validation, even if its date is overdue or its value has another business-rule issue. Date parsing and business-rule validation are explicitly deferred.

The validator must return the exact list of missing fields for each defect. A defect with no missing fields must not appear in the email detail table.

### FR-4: HTML report

The report must include:

- Report title: `COXA Daily Defect Health Report`.
- Report generation timestamp in `Asia/Kolkata`.
- Count of all open defects checked.
- Count of defects with one or more missing mandatory fields.
- Count of defects that passed the completeness check.
- A table containing only affected defects.

The affected-defect table must include:

- Defect reference and clickable Rally link.
- Defect name.
- Current state.
- Owner, displaying `Missing` where blank.
- Missing mandatory fields.
- Target Date.
- Iteration.
- Release Date.
- A short indication that RCA or Resolution Details is missing when applicable.

The report must remain useful when there are zero affected defects. In that case, it must clearly state that all checked open defects have the mandatory fields populated and may omit the empty detail table.

HTML values originating from Rally must be escaped before insertion into the email.

### FR-5: Email delivery

The application must send the generated report as an HTML email through the configured SMTP server.

- Subject format: `[COXA] Daily Defect Health Report - YYYY-MM-DD`.
- Sender and recipients must come from configuration.
- The email body must be HTML.
- SMTP credentials must never appear in logs or report output.
- A failed email send must result in a non-zero process exit code and an actionable error message.

### FR-6: Manual execution

The first release must support a documented command that performs one complete run, for example:

```bash
python -m coxa_defect_report
```

The command must retrieve data, validate it, render the report, and send the email. A future scheduler may invoke the same command daily at 12:00 PM IST.

### FR-7: Logging and errors

The application must log operational events without secrets, including:

- Start and end of a run.
- Number of Rally records retrieved.
- Number of open defects checked.
- Number of affected defects.
- Email delivery success or failure.

The application must handle and clearly report:

- Missing or invalid configuration.
- Rally authentication failure.
- Rally timeout, connection, or API errors.
- Unexpected Rally response data.
- SMTP authentication, connection, or delivery errors.

A failed run must not send a misleading success report. Non-zero exit status is required for failed runs.

## 6. Proposed Technical Design

### 6.1 Technology

- Python 3.11 or newer, matching the repository's available environment.
- A Rally HTTP client or a small HTTP adapter using the project's approved dependency approach.
- Python standard-library email and SMTP support unless an existing email provider library is required.
- HTML generated from a small escaping-aware renderer or template.
- `pytest` for automated tests.

### 6.2 Suggested module boundaries

```text
module08-task/
  project_spec.md
  README.md
  requirements.txt
  .env.example
  src/
    coxa_defect_report/
      __init__.py
      __main__.py
      config.py
      rally_client.py
      models.py
      validator.py
      report.py
      email_sender.py
      runner.py
  tests/
    test_config.py
    test_validator.py
    test_report.py
    test_runner.py
```

The exact layout may follow the repository's existing Python conventions, but the boundaries should remain recognizable:

- `config`: environment parsing and validation.
- `rally_client`: Rally authentication, query, pagination, and response mapping.
- `models`: typed internal defect and report models.
- `validator`: mandatory-field checks with no network or email side effects.
- `report`: HTML rendering and summary calculations.
- `email_sender`: SMTP connection and message delivery.
- `runner`: orchestration, logging, exit behavior, and dependency injection for tests.

### 6.3 Processing flow

```text
Load configuration
  -> Validate configuration
  -> Query Rally defects for configured project
  -> Retrieve all pages
  -> Keep defects whose state is not Closed
  -> Validate six mandatory fields
  -> Calculate summary counts
  -> Render escaped HTML
  -> Send HTML email via SMTP
  -> Log result and exit
```

## 7. Data Contract

The internal defect model should contain, at minimum:

- `reference`: stable Rally defect identifier.
- `name`: defect name.
- `state`: current Rally state.
- `rally_url`: direct link when available.
- `owner`: display value or blank.
- `target_date`: display value or blank.
- `iteration`: display value or blank.
- `release_date`: display value or blank.
- `rca`: display value or blank.
- `resolution_details`: display value or blank.

The validation result should contain:

- The original defect.
- `missing_fields`: ordered list using the field labels in the requirements table.
- `is_complete`: boolean derived from `missing_fields`.

## 8. Security and Privacy

- Store API keys, SMTP credentials, and other secrets only in environment variables or the approved secret store.
- Do not commit `.env` files or credentials.
- Provide `.env.example` with placeholder values only.
- Do not log request headers, API keys, passwords, or full SMTP configuration containing secrets.
- Use TLS for SMTP when supported and configured.
- Escape Rally-provided values to prevent HTML injection in the email.
- Limit report recipients to approved project stakeholders.
- The report contains project defect data and should be treated as internal information.

## 9. Testing Requirements

### Unit tests

- Blank, null, and whitespace-only values are detected for every mandatory field.
- Populated values pass, including populated date strings without date parsing.
- A complete defect is excluded from the affected-defect rows.
- A defect with multiple missing fields lists all missing fields deterministically.
- Rally state `Closed` is excluded; any other state is treated as open.
- HTML escaping works for defect names and other Rally-provided content.
- Zero-affected-defect reports render the success message.
- Configuration validation identifies missing variables without exposing secret values.

### Integration-style tests with fakes

- Rally pagination combines all pages.
- Rally API errors stop processing and return failure.
- SMTP delivery receives an HTML message with the expected subject and recipient.
- SMTP errors return failure and do not claim successful delivery.

### Manual acceptance test

Use a safe Rally test scope or mocked fixture containing:

- One complete open defect.
- One defect missing one field.
- One defect missing several fields.
- One closed defect with missing fields.
- Rally values containing HTML-special characters.

Verify that only the two incomplete open defects appear, each missing field is named, the closed defect is absent, and the email contains working Rally links.

## 10. Acceptance Criteria

The MVP is complete when:

1. A configured run retrieves every defect in the COXA project and checks every defect whose state is not `Closed`.
2. The six mandatory fields are checked using blank-only rules.
3. The email identifies each incomplete defect, its missing fields, its state, and a direct Rally link.
4. A run with no incomplete defects sends a clear all-clear report.
5. Missing configuration, Rally failures, and SMTP failures produce a non-zero result and an actionable log message.
6. No Rally defect is modified by the application.
7. Automated tests cover validation, filtering, rendering, configuration, and failure paths.
8. A README documents setup, environment variables, the manual run command, and the future scheduling step.

## 11. Operational Runbook

### Initial setup

1. Confirm the COXA Rally project ID or project name.
2. Obtain an approved Rally API key.
3. Confirm SMTP host, port, TLS requirements, sender, and recipient settings.
4. Copy `.env.example` to a local environment file without committing it.
5. Install dependencies in the repository's supported Python environment.
6. Run the test suite.
7. Run one manual report against the intended COXA scope.
8. Review the email with the Scrum Master before enabling a daily schedule.

### Future scheduling

After manual output is accepted, schedule the same CLI command at 12:00 PM in `Asia/Kolkata` using an approved runtime such as launchd, cron, GitHub Actions, or a managed job. The scheduling mechanism is intentionally outside the MVP implementation.

## 12. Open Decisions Before Implementation

- Confirm the immutable Rally project ID or exact project name for COXA.
- Confirm the Rally API endpoint and response field names for the six mandatory fields.
- Confirm SMTP server details and whether SMTP credentials are required.
- Confirm whether the initial recipient should remain only `upasana_singh@epam.com` or become a distribution list.
- Confirm whether Rally uses the literal state value `Closed` and whether state comparisons are case-sensitive.
- Confirm whether the five team members should be shown as metadata in a future version; they are not a filter in version one.

## 13. Deferred Enhancements

- Configurable recipient groups and per-team ownership views.
- Date-format and overdue-date validation.
- Daily result persistence and trend metrics.
- Automatic Rally comments or follow-up workflow, subject to approval.
- Teams or Slack delivery.
- Retry and backoff policies for transient Rally and SMTP failures.
- Scheduled deployment and monitoring.
