# Decision log

Design- and model-affecting choices for this project, from **2026-07-14** forward.
Reversible choices are EXECUTE-and-logged by agents; substantive ones are routed
through `dq` → `/decisions` and recorded here on resolution. This file is the
permanent, inspectable record of *why this project is shaped the way it is*.

**Provenance note:** anything in this repo predating this log is **unattributed and
not settled** — it may be Jesse's choice or an agent's, reviewed or not. `north_star.md`
(if present) is Jesse's, as of its date. Agents: do not cite pre-log code or structure
as "already decided" — promote load-bearing pre-log choices through `dq` (substantive)
or `dlog` (reversible) before building on them.
See `~/workspace/docs/decision-log.md` for the convention.

---

## 2026-07-14 — CRAN prep: URL migration + dynamic CITATION
- **Choice:** Pointed all package URLs (DESCRIPTION, CITATION, README.Rmd, _pkgdown.yml) at the jessebrandtdata org and jessebrandtdata.github.io; CITATION reads version from DESCRIPTION via meta$Version; added north_star.md/.worktrees/cran-comments.md to .Rbuildignore; added cran-comments.md
- **Why:** Repo moved to the jessebrandtdata org (old URLs 404/redirect, urlchecker flagged them); hardcoded 0.0.0.9000 in CITATION was stale; north_star.md triggered the only R CMD check NOTE
- **Reversible:** yes · **Decided by:** agent
