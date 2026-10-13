# notes/ — your own space

Everything in this folder is **yours**. Course updates never touch it, so `git pull` on either
machine never conflicts with what you write here.

## Conventions

| File | Use it for |
|---|---|
| [`progress.md`](progress.md) | What is done, scores, what to revisit — instead of ticking boxes in the course README |
| `00-01.md`, `00-02.md`, … | Notes and self-check answers for one module (create them as you go) |
| `machines.md` | Anything machine-specific you had to do (proxy settings, versions, workarounds) |
| `mistakes.md` | Every command or concept you got wrong, with the fix — reread it before mock exams |

## Workflow on either machine

```bash
cd ~/k8s-course
git pull                         # start of every session: get course updates and your notes from the other machine
# … study, lab, write notes …
git add notes/
git commit -m "notes: 00-03 lab and self-check"
git push                         # end of every session
```

Commit only `notes/` from the lab machines. Course content is updated from one place, so the two
never conflict.
