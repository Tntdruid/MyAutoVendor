---
name: changelog-maintenance
description: "Maintain the MyAutoVendor changelog. Use when changing addon behavior, commands, settings, UI, translations, compatibility, installation, or any user-facing documentation. Update the README.md Changelog section before finishing the work."
---

# Changelog Maintenance

Keep the changelog in `README.md` accurate whenever a change affects addon users, addon behavior, configuration, compatibility, installation, commands, or public documentation.

## Workflow

1. Read the existing `## Changelog` section in `README.md` before editing it.
2. Decide whether the change is user-visible:
   - Add a changelog entry for behavior, bug fixes, features, UI, commands, settings, translations, compatibility, installation, or user-facing documentation.
   - Do not add entries for whitespace-only changes, internal refactors with no behavior change, or development-only tooling.
3. Add the change under `### Unreleased`, creating that heading immediately below `## Changelog` when it does not exist.
4. Use one concise bullet written for addon users. Start with a past-tense action such as `Added`, `Fixed`, `Changed`, or `Improved`.
5. Keep existing released version headings and entries intact. Never silently rewrite history.
6. If the user explicitly asks for a release, move the `Unreleased` bullets into the requested version heading and leave an empty `### Unreleased` heading above it.
7. Review the final diff and confirm that every user-visible change is represented once, without implementation details or duplicate bullets.

## Rules for MyAutoVendor

- The changelog lives in `README.md`; do not create a separate changelog file unless the user requests it.
- Follow the existing Markdown style and keep entries short.
- Mention the affected workflow when useful, for example vendor selling, keep lists, item-level settings, minimap UI, slash commands, or localization.
- Do not guess version numbers. Use `Unreleased` until a release version is supplied.
- If a change has both a fix and a feature, use separate bullets when that makes the result easier to scan.

## Completion Check

Before reporting the task complete, verify:

- `README.md` was checked for a changelog update.
- Every user-visible change has an `Unreleased` entry, unless it was intentionally released under a supplied version.
- The entry describes the user impact, not the code implementation.
- Existing release history remains unchanged.