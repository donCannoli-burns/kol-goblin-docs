string PROJECT_ID = "donCannoli-burns-kol-goblin-docs";
string MATRIX_ID = "donCannoli-burns-kol-html-matrix";
string LOGIN_WRAPPER = "call kol-goblin-docs.ash login";
string LOGOUT_WRAPPER = "call kol-goblin-docs.ash logout";
string PREV_LOGIN_PROP = "kolGoblinDocsPreviousLoginScript";
string PREV_LOGOUT_PROP = "kolGoblinDocsPreviousLogoutScript";

string strip_ws(string value) {
    matcher edges = create_matcher("^\\s+|\\s+$", value);
    return replace_all(edges, "");
}

void refresh_snapshot(string reason) {
    string [string] runtime;
    runtime["generated_at"] = now_to_string("yyyy-MM-dd'T'HH:mm:ss");
    runtime["reason"] = reason;
    runtime["kolmafia_version"] = get_version();
    runtime["kolmafia_revision"] = to_string(get_revision());
    runtime["player"] = my_name();
    runtime["goblin_docs_git_installed"] = to_string(git_exists(PROJECT_ID));
    runtime["html_matrix_installed"] = to_string(git_exists(MATRIX_ID));
    runtime["html_matrix_git_path"] = "~/.kolmafia/git/donCannoli-burns-kol-html-matrix/";
    runtime["html_matrix_ui_path"] = "~/.kolmafia/relay/";
    runtime["html_matrix_agent_plane"] = "~/.kolmafia/data/html-matrix/";
    runtime["loginScript"] = get_property("loginScript");
    runtime["logoutScript"] = get_property("logoutScript");
    runtime["authority_note"] = "Documentation and observation are not execution permission.";
    if (map_to_file(runtime, "kol-goblin-docs/runtime.tsv")) {
        set_property("kolGoblinDocsLastRefresh", runtime["generated_at"]);
        set_property("kolGoblinDocsLastRefreshReason", reason);
        print("kol-goblin-docs: refreshed runtime snapshot (" + reason + ").", "green");
    } else {
        print("kol-goblin-docs: failed to write data/kol-goblin-docs/runtime.tsv", "red");
    }
}

void install_hooks() {
    string login_now = get_property("loginScript");
    string logout_now = get_property("logoutScript");

    if (login_now != LOGIN_WRAPPER) {
        if (login_now != "") set_property(PREV_LOGIN_PROP, login_now);
        set_property("loginScript", LOGIN_WRAPPER);
    }

    if (logout_now != LOGOUT_WRAPPER) {
        if (logout_now != "") set_property(PREV_LOGOUT_PROP, logout_now);
        set_property("logoutScript", LOGOUT_WRAPPER);
    }

    print("kol-goblin-docs: login/logout hooks installed.", "green");
    print("Existing hook commands, when present, were preserved and will be replayed by the wrapper.", "gray");
}

void remove_hooks() {
    if (get_property("loginScript") == LOGIN_WRAPPER) {
        set_property("loginScript", get_property(PREV_LOGIN_PROP));
    }
    if (get_property("logoutScript") == LOGOUT_WRAPPER) {
        set_property("logoutScript", get_property(PREV_LOGOUT_PROP));
    }
    print("kol-goblin-docs: hooks removed; preserved prior settings restored where applicable.", "green");
}

void run_previous(string which) {
    string previous = which == "login" ? get_property(PREV_LOGIN_PROP) : get_property(PREV_LOGOUT_PROP);
    string wrapper = which == "login" ? LOGIN_WRAPPER : LOGOUT_WRAPPER;
    if (previous != "" && previous != wrapper) {
        print("kol-goblin-docs: replaying preserved " + which + " hook: " + previous, "gray");
        cli_execute(previous);
    }
}

void install_alias() {
    cli_execute("alias update-llm => call kol-goblin-docs.ash update");
    print("kol-goblin-docs: installed alias update-llm.", "green");
}

void remove_alias() {
    cli_execute("unalias update-llm");
    print("kol-goblin-docs: removed alias update-llm.", "green");
}

void do_update() {
    if (!git_exists(PROJECT_ID)) {
        print("kol-goblin-docs: Git project id not found: " + PROJECT_ID, "red");
        print("Install with: git checkout https://github.com/donCannoli-burns/kol-goblin-docs", "gray");
        return;
    }

    print("kol-goblin-docs: running git update " + PROJECT_ID + " ...", "blue");
    boolean ok = cli_execute("git update " + PROJECT_ID);
    refresh_snapshot(ok ? "update-llm" : "update-llm-failed");
    if (!ok) print("kol-goblin-docs: git update reported failure; inspect gCLI output.", "red");
}

void status() {
    print("kol-goblin-docs", "blue");
    print("  KoLmafia: " + get_version() + " / r" + get_revision());
    print("  Git installed: " + git_exists(PROJECT_ID));
    print("  HTML matrix installed: " + git_exists(MATRIX_ID));
    if (git_exists(MATRIX_ID)) {
        print("  HTML matrix UI: ~/.kolmafia/relay/");
        print("  HTML matrix agent plane: ~/.kolmafia/data/html-matrix/");
    }
    print("  loginScript: " + get_property("loginScript"));
    print("  logoutScript: " + get_property("logoutScript"));
    print("  last refresh: " + get_property("kolGoblinDocsLastRefresh") + " (" + get_property("kolGoblinDocsLastRefreshReason") + ")");
    print("  relay UI: select kol-goblin-docs from the relay browser script drop-down");
}

void help() {
    print("kol-goblin-docs commands:", "blue");
    print("  status                 Show install/runtime integration state");
    print("  refresh [reason]       Refresh data/kol-goblin-docs/runtime.tsv");
    print("  setup                  Install login/logout wrappers + update-llm alias");
    print("  install-hooks          Install lifecycle wrappers while preserving prior settings");
    print("  remove-hooks           Restore preserved prior login/logout settings");
    print("  install-alias          Create update-llm => call kol-goblin-docs.ash update");
    print("  remove-alias           Remove update-llm alias");
    print("  update                 Git update this project, then refresh runtime snapshot");
    print("  login / logout         Lifecycle entrypoints; refresh then replay prior hook");
    print("");
    print("After a manual bare `git update`, run: kol-goblin-docs refresh git-update");
}

void main(string command) {
    string cmd = strip_ws(command);
    string lower = to_lower_case(cmd);

    if (lower == "" || lower == "status") {
        status();
        return;
    }

    if (lower == "help") {
        help();
        return;
    }

    if (lower == "setup") {
        install_hooks();
        install_alias();
        refresh_snapshot("setup");
        return;
    }

    if (lower == "install-hooks") {
        install_hooks();
        refresh_snapshot("install-hooks");
        return;
    }

    if (lower == "remove-hooks") {
        remove_hooks();
        refresh_snapshot("remove-hooks");
        return;
    }

    if (lower == "install-alias") {
        install_alias();
        return;
    }

    if (lower == "remove-alias") {
        remove_alias();
        return;
    }

    if (lower == "update") {
        do_update();
        return;
    }

    if (lower == "login" || lower == "logout") {
        refresh_snapshot(lower);
        run_previous(lower);
        return;
    }

    if (lower == "refresh" || starts_with(lower, "refresh ")) {
        string reason = "manual";
        if (length(cmd) > 7) reason = strip_ws(substring(cmd, 7));
        if (reason == "") reason = "manual";
        refresh_snapshot(reason);
        return;
    }

    print("kol-goblin-docs: unknown command: " + command, "red");
    help();
}
