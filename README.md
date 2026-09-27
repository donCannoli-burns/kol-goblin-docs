# kol-goblin-docs

**Agent-first HTML5 branch map + editable KoLmafia relay documentation.**

`kol-goblin-docs` installs a relay UI and a set of HTML5 `README.html` files that explain what the major KoLmafia working areas are for. The intent is simple: an agent should be able to start from one top index, descend to the relevant local area, understand its role and risk class, and then verify the installed runtime before doing anything.

The project is designed for KoLmafia's Git script installer and was built against the current **r29307** source/release shape on 2026-09-27.

## Install

In the KoLmafia gCLI:

```text
git checkout https://github.com/donCannoli-burns/kol-goblin-docs
```

Then run the one-time setup:

```text
kol-goblin-docs setup
```

`setup`:

- preserves any existing `loginScript` / `logoutScript` commands,
- installs Goblin Docs wrapper hooks,
- creates the `update-llm` alias,
- writes the first runtime snapshot.

Open the relay browser and choose **kol-goblin-docs** from the normal relay-script drop-down menu.

## What gets installed

```text
~/.kolmafia/
├── relay/
│   └── relay_kol-goblin-docs.ash
├── scripts/
│   └── kol-goblin-docs.ash
└── data/
    └── kol-goblin-docs/
        ├── README.html
        ├── matrix.tsv
        ├── runtime.tsv                 # generated after setup/refresh
        ├── custom-docs.txt
        ├── backups/
        └── branches/
            ├── root/README.html
            ├── scripts/README.html
            ├── relay/README.html
            ├── data/README.html
            ├── sessions/README.html
            ├── git/README.html
            ├── settings/README.html
            ├── ccs/README.html
            ├── chats/README.html
            ├── planting/README.html
            ├── buffs/README.html
            ├── images/README.html
            └── svn/README.html
```

The repository also keeps a top-level `README.html` source index for humans/agents inspecting the Git working copy.

## Relay editor

The UI deliberately uses an old-school, low-friction layout:

- persistent branch tree,
- visible **Edit / Save / Reset** controls,
- HTML source textarea,
- sandboxed live preview,
- Undo / Redo,
- Bold / Italic / Code / Link insertion,
- Find / Replace,
- `Ctrl+S`, `Ctrl+Z`, `Ctrl+Y`, `Ctrl+F`,
- create additional HTML5 docs directly at the selected documentation branch root.

Writes are allowlisted to:

```text
data/kol-goblin-docs/branches/<known-branch>/
```

The relay cannot use its editor to write arbitrary KoLmafia files. Before each save it writes the previous copy into `data/kol-goblin-docs/backups/`.

## Command tool

```text
kol-goblin-docs status
kol-goblin-docs refresh [reason]
kol-goblin-docs setup
kol-goblin-docs install-hooks
kol-goblin-docs remove-hooks
kol-goblin-docs install-alias
kol-goblin-docs remove-alias
kol-goblin-docs update
```

### `update-llm`

After setup:

```text
update-llm
```

expands to:

```text
call kol-goblin-docs.ash update
```

which runs:

```text
git update donCannoli-burns-kol-goblin-docs
```

and then refreshes `data/kol-goblin-docs/runtime.tsv`.

### Login / logout / Git update behavior

KoLmafia natively runs `gitUpdateOnLogin` before its configured `loginScript`, so when KoLmafia's automatic Git update-on-login is enabled, the Goblin Docs login hook refreshes after that update.

For a **manual bare**:

```text
git update
```

KoLmafia does not expose a generic "post any git update" callback to this relay. Follow it with:

```text
kol-goblin-docs refresh git-update
```

or use `update-llm` when updating Goblin Docs itself.

## kol-html-matrix integration

Goblin Docs checks:

```ash
git_exists("donCannoli-burns-kol-html-matrix")
```

If true, the top index, relay UI, runtime snapshot, `matrix.tsv`, and relevant `root`, `relay`, `data`, and `git` README pages describe the sibling installation as:

```text
Git working copy:
~/.kolmafia/git/donCannoli-burns-kol-html-matrix/

User UI projection:
~/.kolmafia/relay/

Agent plane:
~/.kolmafia/data/html-matrix/
```

Goblin Docs records this relationship; it does **not** treat the presence of the matrix as permission to execute anything.

## Agent rule

A README is navigation and context, not authority.

The recommended operating order remains:

```text
inspect current state
→ identify the relevant area
→ read the local README
→ verify runtime truth
→ classify the action
→ obtain whatever approval/policy gate is required
→ execute only through the intended authority
→ read back the result
```

Future per-runtime agent permissions can be added as explicit documentation nodes without changing this baseline.

## Uninstall hooks first

If you want to remove the Git project, first restore prior lifecycle settings:

```text
kol-goblin-docs remove-hooks
kol-goblin-docs remove-alias
git delete donCannoli-burns-kol-goblin-docs
```

## Provenance

The directory map is grounded in current KoLmafia source constants (`buffs/`, `ccs/`, `chats/`, `planting/`, `relay/`, `scripts/`, `sessions/`, `svn/`, `git/`, plus `data/`, `images/`, and `settings/`). Login/logout wrappers are based on KoLmafia's current `loginScript` / `logoutScript` lifecycle behavior.

## License

MIT.
