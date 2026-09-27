# AGENTS.md — kol-goblin-docs

Start at `data/kol-goblin-docs/README.html`.

Rules:

1. Treat every `README.html` as navigation/context, not execution authority.
2. Verify installed KoLmafia runtime truth before depending on a command/function.
3. User-editable docs are restricted to `data/kol-goblin-docs/branches/<known-branch>/`.
4. Do not infer permission from the presence of `kol-html-matrix`.
5. If `git_exists("donCannoli-burns-kol-html-matrix")` is true:
   - working copy: `~/.kolmafia/git/donCannoli-burns-kol-html-matrix/`
   - UI projection: `~/.kolmafia/relay/`
   - agent plane: `~/.kolmafia/data/html-matrix/`
6. Add new permissions later as explicit policy/runtime nodes; never as vague prose implication.
7. Preserve user-edited HTML docs across ordinary reads. Before automated rewrites, inspect `custom-docs.txt` and the backup directory.
