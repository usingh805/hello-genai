# Jira and Confluence Automation Ideas

## 1. Weekly Delivery Health Report

**Problem it solves:**
Managers often spend time manually collecting sprint progress, overdue work, blockers, and risks from Jira. This automation creates a weekly summary and publishes it to a Confluence page.

**Data needed:**
- Jira project and board details
- Issue status, priority, assignee, and due date
- Sprint name, start date, end date, and completion status
- Story points or other estimates
- Blocker labels, linked issues, and comments

## 2. Automatic Risk and Escalation Tracker

**Problem it solves:**
Important risks can remain hidden in issue comments or scattered across projects. This automation identifies at-risk Jira work and maintains a Confluence risk register for manager review.

**Data needed:**
- Issues past their due dates or with approaching due dates
- Issue status, priority, assignee, and project
- Blocker labels and unresolved dependencies
- Recent comments and status changes
- Links between related Jira issues
- Risk owner and escalation rules

## 3. Team Capacity and Workload Overview

**Problem it solves:**
Managers may not have a clear view of uneven workloads or upcoming capacity gaps. This automation summarizes assigned work and publishes a planning view in Confluence.

**Data needed:**
- Jira assignees and team membership
- Open issues and their priorities
- Story points, estimates, or time remaining
- Sprint assignments and planned work dates
- Issue status and completion history
- Team availability, holidays, and planned leave
