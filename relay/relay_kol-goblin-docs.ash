string PROJECT_ID = "donCannoli-burns-kol-goblin-docs";
string MATRIX_ID = "donCannoli-burns-kol-html-matrix";
string DOC_ROOT = "data/kol-goblin-docs/branches/";
string CUSTOM_MAP = "kol-goblin-docs/custom-docs.txt";

string [int] branch_ids;
string [string] branch_labels;
string [string] branch_paths;
string [string] branch_purposes;

void init_branches() {
    branch_ids[0] = "root";
    branch_ids[1] = "scripts";
    branch_ids[2] = "relay";
    branch_ids[3] = "data";
    branch_ids[4] = "sessions";
    branch_ids[5] = "git";
    branch_ids[6] = "settings";
    branch_ids[7] = "ccs";
    branch_ids[8] = "chats";
    branch_ids[9] = "planting";
    branch_ids[10] = "buffs";
    branch_ids[11] = "images";
    branch_ids[12] = "svn";

    branch_labels["root"] = "KoLmafia root";
    branch_labels["scripts"] = "scripts/";
    branch_labels["relay"] = "relay/";
    branch_labels["data"] = "data/";
    branch_labels["sessions"] = "sessions/";
    branch_labels["git"] = "git/";
    branch_labels["settings"] = "settings/";
    branch_labels["ccs"] = "ccs/";
    branch_labels["chats"] = "chats/";
    branch_labels["planting"] = "planting/";
    branch_labels["buffs"] = "buffs/";
    branch_labels["images"] = "images/";
    branch_labels["svn"] = "svn/";

    branch_paths["root"] = "~/.kolmafia/";
    branch_paths["scripts"] = "~/.kolmafia/scripts/";
    branch_paths["relay"] = "~/.kolmafia/relay/";
    branch_paths["data"] = "~/.kolmafia/data/";
    branch_paths["sessions"] = "~/.kolmafia/sessions/";
    branch_paths["git"] = "~/.kolmafia/git/";
    branch_paths["settings"] = "~/.kolmafia/settings/";
    branch_paths["ccs"] = "~/.kolmafia/ccs/";
    branch_paths["chats"] = "~/.kolmafia/chats/";
    branch_paths["planting"] = "~/.kolmafia/planting/";
    branch_paths["buffs"] = "~/.kolmafia/buffs/";
    branch_paths["images"] = "~/.kolmafia/images/";
    branch_paths["svn"] = "~/.kolmafia/svn/";

    branch_purposes["root"] = "Top-level map of the KoLmafia working root.";
    branch_purposes["scripts"] = "Executable ASH/JavaScript and callable automation.";
    branch_purposes["relay"] = "Relay-browser scripts and user-facing local UI assets.";
    branch_purposes["data"] = "Script data, generated indexes, caches, and agent-readable artifacts.";
    branch_purposes["sessions"] = "Session logs and active-session evidence.";
    branch_purposes["git"] = "KoLmafia-managed Git working copies.";
    branch_purposes["settings"] = "Global and per-character KoLmafia preferences.";
    branch_purposes["ccs"] = "Custom Combat Scripts and combat automation configuration.";
    branch_purposes["chats"] = "Human/social chat logs; observation only.";
    branch_purposes["planting"] = "Mushroom/planting plot state and local data.";
    branch_purposes["buffs"] = "Buffbot configuration and automation data.";
    branch_purposes["images"] = "Cached/local image assets used by relay and KoLmafia.";
    branch_purposes["svn"] = "Legacy SVN-managed script working copies.";
}

string h(string s) {
    return entity_encode(s);
}

boolean known_branch(string branch) {
    foreach i, id in branch_ids {
        if (id == branch) return true;
    }
    return false;
}

boolean safe_slug(string slug) {
    if (slug == "") return false;
    matcher m = create_matcher("^[A-Za-z0-9][A-Za-z0-9_-]{0,63}$", slug);
    return find(m);
}

string doc_path(string branch, string file) {
    return DOC_ROOT + branch + "/" + file;
}

string custom_key(string branch, string file) {
    return branch + "/" + file;
}

boolean allowed_file(string branch, string file, string [string] custom_docs) {
    if (!known_branch(branch)) return false;
    if (file == "README.html") return true;
    return custom_docs contains custom_key(branch, file);
}

string starter_doc(string branch, string title) {
    return "<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\">"
        + "<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">"
        + "<title>" + h(title) + "</title>"
        + "<style>body{max-width:920px;margin:auto;padding:32px;background:#10100e;color:#ffffe3;font:15px/1.55 ui-monospace,monospace}"
        + "a{color:#f0cf9a}nav{display:flex;gap:8px;flex-wrap:wrap}nav a{border:1px solid #5a5a4e;padding:5px 8px;text-decoration:none}"
        + "h1,h2{font-family:Georgia,serif;font-weight:400}</style></head><body>"
        + "<nav><a href=\"../../README.html\">TOP INDEX</a><a href=\"README.html\">THIS LEVEL</a></nav>"
        + "<h1>" + h(title) + "</h1>"
        + "<p>Additional agent documentation for <code>" + h(branch_labels[branch]) + "</code>.</p>"
        + "<h2>Purpose</h2><p>Describe what this document covers and what it does not authorize.</p>"
        + "<h2>Agent notes</h2><ul><li>Verify runtime truth before acting.</li><li>Documentation is not execution permission.</li></ul>"
        + "</body></html>";
}

void render() {
    init_branches();

    string [string] custom_docs;
    file_to_map(CUSTOM_MAP, custom_docs);

    string [string] fields = form_fields();
    string message = "";
    string branch = fields["branch"];
    string file = fields["file"];

    if (branch == "") branch = get_property("kolGoblinDocsLastBranch");
    if (!known_branch(branch)) branch = "root";
    if (file == "") file = get_property("kolGoblinDocsLastFile");
    if (file == "") file = "README.html";
    if (!allowed_file(branch, file, custom_docs)) file = "README.html";

    string action = fields["action"];

    if (action == "newdoc") {
        string new_branch = fields["branch"];
        string slug = fields["slug"];
        string title = fields["title"];
        string clean_title = title == "" ? slug : title;
        clean_title = to_string(replace_string(clean_title, "\t", " "));
        clean_title = to_string(replace_string(clean_title, "\r", " "));
        clean_title = to_string(replace_string(clean_title, "\n", " "));
        if (!known_branch(new_branch)) {
            message = "New document rejected: unknown branch.";
        } else if (!safe_slug(slug)) {
            message = "New document rejected: slug must use letters, numbers, _ or -.";
        } else {
            string new_file = slug + ".html";
            string key = custom_key(new_branch, new_file);
            if (custom_docs contains key) {
                message = "New document rejected: that branch/file already exists.";
            } else {
                custom_docs[key] = clean_title;
                boolean map_ok = map_to_file(custom_docs, CUSTOM_MAP);
                boolean file_ok = buffer_to_file(starter_doc(new_branch, custom_docs[key]).to_buffer(), doc_path(new_branch, new_file));
                if (map_ok && file_ok) {
                    branch = new_branch;
                    file = new_file;
                    message = "Created " + branch + "/" + file + ".";
                } else {
                    message = "Could not create the document or update the custom-doc index.";
                }
            }
        }
    } else if (action == "save") {
        string save_branch = fields["branch"];
        string save_file = fields["file"];
        if (!allowed_file(save_branch, save_file, custom_docs)) {
            message = "Save rejected: target is outside the Goblin Docs branch allowlist.";
        } else {
            string target = doc_path(save_branch, save_file);
            string backup = "data/kol-goblin-docs/backups/" + save_branch + "--" + to_string(replace_string(save_file, "/", "_")) + ".bak.html";
            buffer_to_file(file_to_buffer(target), backup);
            boolean ok = buffer_to_file(fields["content"].to_buffer(), target);
            if (ok) {
                branch = save_branch;
                file = save_file;
                message = "Saved " + branch + "/" + file + ". Last saved copy moved to backups/.";
            } else {
                message = "Save failed; no success was reported by buffer_to_file().";
            }
        }
    }

    set_property("kolGoblinDocsLastBranch", branch);
    set_property("kolGoblinDocsLastFile", file);

    string content = to_string(file_to_buffer(doc_path(branch, file)));
    boolean matrix_installed = git_exists(MATRIX_ID);
    boolean self_installed = git_exists(PROJECT_ID);

    buffer page;
    page.append("<!doctype html><html lang=\"en\"><head><meta charset=\"utf-8\">");
    page.append("<meta name=\"viewport\" content=\"width=device-width,initial-scale=1\">");
    page.append("<title>kol-goblin-docs</title><style>");
    page.append(":root{color-scheme:dark;--bg:#10100e;--panel:#151511;--panel2:#1c1c18;--field:#0d0d0b;--line:#5a5a4e;--hair:rgba(255,255,227,.11);--text:#ffffe3;--muted:#9b9b88;--accent:#d5ae71;--green:#62b982;--bad:#ef6a63}"
      + "*{box-sizing:border-box}html,body{height:100%;margin:0}body{background:#10100e;color:var(--text);font:13px/1.45 ui-monospace,Consolas,monospace;overflow:hidden}"
      + "button,input,textarea{font:inherit;color:inherit}button{cursor:pointer}.app{height:100%;display:grid;grid-template-rows:64px minmax(0,1fr)}"
      + "header{display:flex;align-items:center;gap:12px;padding:0 16px;border-bottom:1px solid var(--hair);background:#151511}header strong{font:400 1.25rem Georgia,serif;letter-spacing:.04em}header .spacer{flex:1}.chip{border:1px solid var(--line);padding:5px 7px;color:var(--muted)}.chip.ok{color:var(--green)}"
      + ".shell{min-height:0;display:grid;grid-template-columns:250px minmax(0,1fr) 260px}.nav,.side{overflow:auto;background:#131310;padding:14px;border-right:1px solid var(--hair)}.side{border-right:0;border-left:1px solid var(--hair)}"
      + ".nav h2,.side h2{font:400 1rem Georgia,serif;margin:4px 0 10px}.branch{display:block;color:var(--text);text-decoration:none;padding:8px 9px;border-left:2px solid transparent}.branch:hover{background:#1c1c18}.branch.active{border-left-color:var(--accent);background:rgba(213,174,113,.08)}.branch small{display:block;color:var(--muted)}"
      + ".work{min-width:0;overflow:auto;padding:18px}.crumb{color:var(--muted);margin-bottom:8px}.toolbar{display:flex;gap:6px;flex-wrap:wrap;align-items:center;position:sticky;top:-18px;background:#10100ef2;padding:10px 0;border-bottom:1px solid var(--hair);z-index:5}"
      + "button,.btn{border:1px solid var(--line);background:#1a1a16;padding:7px 9px;text-decoration:none}button:hover,.btn:hover{border-color:var(--accent)}button.primary{background:var(--text);color:#10100e;border-color:var(--text)}button:disabled{opacity:.4;cursor:not-allowed}"
      + ".editor-grid{display:grid;grid-template-rows:minmax(320px,1fr) minmax(240px,.72fr);gap:12px;height:calc(100vh - 166px)}textarea{width:100%;height:100%;resize:none;background:#0d0d0b;border:1px solid var(--line);padding:14px;line-height:1.55;tab-size:2;white-space:pre;font-size:13px}textarea[readonly]{color:#c8c8b4}iframe{width:100%;height:100%;border:1px solid var(--line);background:white}"
      + ".label{font-size:.68rem;letter-spacing:.13em;text-transform:uppercase;color:var(--muted);margin:10px 0 6px}.status{padding:8px 10px;border-left:2px solid var(--accent);background:rgba(213,174,113,.07);margin-bottom:10px}.good{border-left-color:var(--green)}.bad{border-left-color:var(--bad)}"
      + ".side input{width:100%;background:#0d0d0b;border:1px solid var(--line);padding:8px;margin:4px 0 8px}.side form{border-top:1px solid var(--hair);margin-top:16px;padding-top:14px}.doclink{display:block;color:#f0cf9a;padding:5px 0}.muted{color:var(--muted)}"
      + "@media(max-width:900px){.shell{grid-template-columns:190px minmax(0,1fr)}.side{display:none}}@media(max-width:650px){body{overflow:auto}.app{display:block}.shell{display:block}.nav{max-height:34vh}.work{overflow:visible}.editor-grid{height:auto;grid-template-rows:55vh 45vh}}");
    page.append("</style></head><body><div class=\"app\"><header><strong>kol-goblin-docs</strong><span class=\"chip\">r" + get_revision() + "</span>");
    page.append("<span class=\"chip " + (matrix_installed ? "ok" : "") + "\">HTML MATRIX: " + (matrix_installed ? "INSTALLED" : "NOT DETECTED") + "</span>");
    page.append("<span class=\"spacer\"></span><span class=\"chip\">" + h(branch_labels[branch]) + "</span></header><div class=\"shell\">");

    page.append("<nav class=\"nav\"><h2>Branch index</h2>");
    foreach i, id in branch_ids {
        page.append("<a class=\"branch " + (id == branch ? "active" : "") + "\" href=\"relay_kol-goblin-docs.ash?branch=" + id + "&file=README.html\">"
            + h(branch_labels[id]) + "<small>" + h(branch_purposes[id]) + "</small></a>");
    }
    page.append("</nav>");

    page.append("<main class=\"work\"><div class=\"crumb\">TOP / " + h(branch_labels[branch]) + " / " + h(file) + "</div>");
    if (message != "") page.append("<div class=\"status\">" + h(message) + "</div>");

    page.append("<form id=\"editForm\" method=\"post\" action=\"relay_kol-goblin-docs.ash\">"
        + "<input type=\"hidden\" name=\"action\" value=\"save\"><input type=\"hidden\" name=\"branch\" value=\"" + h(branch) + "\">"
        + "<input type=\"hidden\" name=\"file\" value=\"" + h(file) + "\">"
        + "<div class=\"toolbar\"><button type=\"button\" id=\"editBtn\" class=\"primary\">Edit</button>"
        + "<button type=\"submit\" id=\"saveBtn\" disabled>Save <span class=\"muted\">Ctrl+S</span></button>"
        + "<button type=\"button\" id=\"resetBtn\" disabled>Reset</button>"
        + "<button type=\"button\" id=\"undoBtn\" disabled>Undo</button><button type=\"button\" id=\"redoBtn\" disabled>Redo</button>"
        + "<button type=\"button\" data-wrap=\"strong\">Bold</button><button type=\"button\" data-wrap=\"em\">Italic</button>"
        + "<button type=\"button\" data-wrap=\"code\">Code</button><button type=\"button\" id=\"linkBtn\">Link</button>"
        + "<button type=\"button\" id=\"findBtn\">Find/Replace</button><span id=\"dirty\" class=\"muted\">READ ONLY</span></div>"
        + "<div class=\"editor-grid\"><textarea id=\"editor\" name=\"content\" readonly spellcheck=\"false\">" + h(content) + "</textarea>"
        + "<iframe id=\"preview\" sandbox title=\"HTML preview\"></iframe></div></form></main>");

    page.append("<aside class=\"side\"><h2>This level</h2><div class=\"muted\">" + h(branch_paths[branch]) + "</div>"
        + "<p>" + h(branch_purposes[branch]) + "</p>"
        + "<a class=\"doclink\" href=\"relay_kol-goblin-docs.ash?branch=" + branch + "&file=README.html\">README.html</a>");

    foreach key, title in custom_docs {
        if (starts_with(key, branch + "/")) {
            string custom_file = substring(key, length(branch) + 1);
            page.append("<a class=\"doclink\" href=\"relay_kol-goblin-docs.ash?branch=" + branch + "&file=" + custom_file + "\">" + h(title) + "</a>");
        }
    }

    page.append("<form method=\"post\" action=\"relay_kol-goblin-docs.ash\"><h2>Add HTML5 doc</h2>"
        + "<input type=\"hidden\" name=\"action\" value=\"newdoc\"><input type=\"hidden\" name=\"branch\" value=\"" + branch + "\">"
        + "<label>Title<input name=\"title\" placeholder=\"Agent permission notes\"></label>"
        + "<label>File slug<input name=\"slug\" placeholder=\"agent-permissions\" pattern=\"[A-Za-z0-9][A-Za-z0-9_-]{0,63}\" required></label>"
        + "<button type=\"submit\">Create at branch root</button></form>");

    page.append("<div class=\"label\">Runtime</div><div class=\"muted\">Goblin repo: " + (self_installed ? "installed" : "relay copy active") + "<br>"
        + "KoLmafia: " + h(get_version()) + " / r" + get_revision() + "<br>"
        + "Matrix plane: " + (matrix_installed ? "~/.kolmafia/data/html-matrix/" : "not detected") + "</div></aside></div></div>");

    page.append("<script>");
    page.append("const e=document.getElementById('editor'),p=document.getElementById('preview'),edit=document.getElementById('editBtn'),save=document.getElementById('saveBtn'),reset=document.getElementById('resetBtn'),undoB=document.getElementById('undoBtn'),redoB=document.getElementById('redoBtn'),dirty=document.getElementById('dirty');"
      + "let original=e.value,hist=[e.value],hi=0,editable=false;"
      + "function preview(){p.srcdoc=e.value} preview();"
      + "function setEdit(v){editable=v;e.readOnly=!v;save.disabled=!v;reset.disabled=!v;undoB.disabled=!v;redoB.disabled=!v;dirty.textContent=v?(e.value===original?'EDITING / CLEAN':'EDITING / UNSAVED'):'READ ONLY';if(v)e.focus()}"
      + "edit.onclick=()=>setEdit(true);"
      + "function push(){if(!editable)return;if(hist[hi]===e.value)return;hist=hist.slice(0,hi+1);hist.push(e.value);if(hist.length>80)hist.shift();else hi++;dirty.textContent=e.value===original?'EDITING / CLEAN':'EDITING / UNSAVED';preview()}"
      + "e.addEventListener('input',push);"
      + "undoB.onclick=()=>{if(hi>0){hi--;e.value=hist[hi];preview();dirty.textContent='EDITING / UNSAVED'}};"
      + "redoB.onclick=()=>{if(hi<hist.length-1){hi++;e.value=hist[hi];preview();dirty.textContent='EDITING / UNSAVED'}};"
      + "reset.onclick=()=>{if(!editable)return;e.value=original;hist=[original];hi=0;preview();dirty.textContent='EDITING / CLEAN'};"
      + "function wrap(tag,attrs=''){if(!editable)setEdit(true);const a=e.selectionStart,b=e.selectionEnd,sel=e.value.slice(a,b),open='<'+tag+attrs+'>',close='</'+tag+'>';e.setRangeText(open+sel+close,a,b,'select');push()}"
      + "document.querySelectorAll('[data-wrap]').forEach(b=>b.onclick=()=>wrap(b.dataset.wrap));"
      + "document.getElementById('linkBtn').onclick=()=>{const u=prompt('Link URL');if(u!==null)wrap('a',' href=\"'+u.replace(/\"/g,'&quot;')+'\"')};"
      + "document.getElementById('findBtn').onclick=()=>{if(!editable)setEdit(true);const q=prompt('Find text');if(!q)return;const r=prompt('Replace with (Cancel = select next match)');const start=e.selectionEnd||0;let i=e.value.indexOf(q,start);if(i<0)i=e.value.indexOf(q);if(i<0){alert('Not found');return}if(r===null){e.focus();e.setSelectionRange(i,i+q.length)}else{e.setRangeText(r,i,i+q.length,'end');push()}};"
      + "e.addEventListener('keydown',ev=>{if(ev.key==='Tab'&&editable){ev.preventDefault();e.setRangeText('  ',e.selectionStart,e.selectionEnd,'end');push()}});"
      + "document.addEventListener('keydown',ev=>{if(!(ev.ctrlKey||ev.metaKey))return;const k=ev.key.toLowerCase();if(k==='s'){ev.preventDefault();if(editable)document.getElementById('editForm').requestSubmit()}else if((k==='y'||(k==='z'&&ev.shiftKey))&&editable){ev.preventDefault();redoB.click()}else if(k==='z'&&editable){ev.preventDefault();undoB.click()}else if(k==='f'&&editable){ev.preventDefault();document.getElementById('findBtn').click()}});");
    page.append("</script></body></html>");
    write(to_string(page));
}

void main() {
    render();
}
