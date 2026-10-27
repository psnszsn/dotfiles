// Leader-key overlay ported from leadr (~/clonez/leadr): press a key sequence to
// run a Hyprland dispatcher. Toggle with `qs ipc call leadr toggle`.
import QtQuick
import QtQuick.Layouts
import QtQuick.LocalStorage
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets

Scope {
  id: leadr

  readonly property color fg: "#ffffff"
  readonly property color bg: Qt.rgba(43 / 255, 48 / 255, 59 / 255, 0.95)
  readonly property color accent: Qt.rgba(100 / 255, 114 / 255, 125 / 255, 0.6)
  readonly property string font: "monospace"

  // A binding is { key, label } plus one of:
  //   dispatch: a Hyprland dispatcher, run after the overlay closes
  //   group: nested bindings
  //   sticky: nested bindings that stay open, closing after `timeout` ms idle
  //   appClass: focus that app's window, or pick one with a fuzzy search if it has several
  //   launcher: fuzzy search all desktop apps
  // `takesFocus` marks dispatchers that focus a window: Hyprland refuses those while
  // an exclusive layer surface holds the keyboard, so sticky mode lets go of it first.
  function focus(args) { return { dispatch: `hl.dsp.focus(${args})`, takesFocus: true } }
  function dsp(cmd) { return { dispatch: cmd } }
  function app(cls) { return { appClass: cls } }
  function bind(key, label, action) { return Object.assign({ key, label }, action) }
  function directions(label, make) {
    return [["m", "l", "Left"], ["n", "d", "Down"], ["e", "u", "Up"], ["i", "r", "Right"]]
      .map(([key, dir, name]) => bind(key, `${label} ${name}`, make(dir)))
  }

  readonly property var bindings: [
    bind("a", "Fuzzy", { launcher: true }),
    bind("b", "Browser", app("firefox")),
    bind("g", "Ghostty", app("com.mitchellh.ghostty")),
    bind("t", "T3 Code", app("com.t3tools.T3Code")),
    bind("w", "Window", {
      timeout: 1500,
      sticky: directions("Focus", dir => focus(`{ direction = "${dir}" }`)),
    }),
    bind("d", "Displace", {
      timeout: 1500,
      sticky: directions("Move", dir => dsp(`hl.dsp.window.move({ direction = "${dir}" })`)).concat([
        bind("w", "Workspace", {
          timeout: 1500,
          sticky: directions("Move", dir => dsp(`hl.dsp.workspace.move({ monitor = "${dir}" })`)),
        }),
      ]),
    }),
  ]

  // Subjects only the Fuzzy picker lists, next to the desktop apps: Enter or Tab opens
  // their actions, which run a shell command once the overlay has closed (so a
  // screenshot doesn't capture it).
  function subject(title, icon, actions) { return { title, icon, actions } }
  function run(title, command) { return { title, command } }

  // grimblast names saved files by date; it notifies with the path.
  readonly property string screenshotDir: "$HOME/pictures/screenshots"
  function saveShot(target) {
    return `mkdir -p "${screenshotDir}" && XDG_SCREENSHOTS_DIR="${screenshotDir}" grimblast --notify save ${target}`;
  }

  readonly property var subjects: [
    subject("Screenshot", "org.gnome.Snapshot", [
      run("Copy area", "grimblast copy area"),
      run("Copy window", "grimblast copy active"),
      run("Copy monitor", "grimblast copy output"),
      run("Save area", saveShot("area")),
      run("Save window", saveShot("active")),
      run("Save monitor", saveShot("output")),
    ]),
  ]

  // Emoji opens from the Fuzzy picker into its own grid. emojis.json is Omarchy's list
  // (shell/plugins/emojis, MIT): [{ e: emoji, k: name and keywords }].
  property var emojis: []
  readonly property var emojiItems: emojis.map(emojiItem)
  readonly property int gridColumns: 10
  readonly property var emojiEntry: ({
    id: "emoji",
    title: "Emoji",
    fields: ["Emoji", "emoticon smiley"],
    details: ["Pick one to paste it", "Pick one to paste it"],
    glyph: "😀",
    run: learnQuery => {
      remember("emoji", learnQuery);
      openEmoji();
    },
  })

  FileView {
    path: Quickshell.shellPath("emojis.json")
    onLoaded: {
      try {
        leadr.emojis = JSON.parse(text());
      } catch (e) {
        console.warn("leadr: ignoring unreadable emoji list:", e);
      }
    }
  }

  property bool open: false
  // Each level is { bindings, timeout }, where timeout is 0 unless the level is sticky.
  property var stack: [{ bindings, timeout: 0 }]
  readonly property var current: stack[stack.length - 1].bindings
  property string pressed: ""
  readonly property int stickyTimeout: stack[stack.length - 1].timeout
  // Set while a sticky focus dispatcher runs without the keyboard.
  property bool released: false
  property string pendingDispatch: ""
  // A shell command to run once the overlay has closed.
  property string pendingCommand: ""
  // The cheatsheet stays centered. A search card centers when it opens, then the
  // first key in it pins its top edge here so it grows and shrinks downward
  // instead of re-centering on every resize.
  property int cardTop: -1

  // Fuzzy search view, shown instead of the cheatsheet: { label, hint, items, learn,
  // picks, alphabetical, grid, back }, or `launcher` instead of `items` for the desktop
  // apps. `picks` names the history map of last choices per query ("selected" by default).
  // `grid` lays the results out as cells (the emoji picker) instead of rows.
  // `back` is the parent search's state for a view opened from it (an actions list,
  // or a window picker), so going back restores its query and selection.
  // An item is { id, title, fields, details, icon or glyph, run(learnQuery), actions? }; `details`
  // gives the second line to show when the query matched the same-index field.
  property var search: null
  property string query: ""
  property int selected: 0
  readonly property var results: search ? rank(search, query) : []
  // DesktopEntries scans lazily, so binding this at startup starts the scan; it
  // also keeps the launcher current as apps are installed or removed.
  readonly property var apps: DesktopEntries.applications.values.filter(e => !e.noDisplay).map(appItem)
  readonly property var subjectItems: subjects.map(subjectItem)

  function itemsOf(view) { return view.launcher ? subjectItems.concat([emojiEntry], apps) : view.items }

  function show() {
    // Keeps focusHistoryID fresh for ordering the window picker.
    Hyprland.refreshToplevels();
    stack = [{ bindings, timeout: 0 }];
    search = null;
    pressed = "";
    released = false;
    // Drop a dispatch the last session queued, so it can't fire while we hold the keyboard.
    pendingDispatch = "";
    pendingCommand = "";
    closeFallback.stop();
    releaseFallback.stop();
    cardTop = -1;
    open = true;
  }

  function hide() {
    stickyTimer.stop();
    open = false;
    // Stops `results` re-ranking for a hidden overlay; show() starts from the cheatsheet anyway.
    search = null;
  }

  // Called before anything that can resize the overlay, while it's still centered.
  function pinTop() {
    if (open && cardTop < 0) cardTop = overlay.centeredTop;
  }

  // Sticky levels close after their timeout with no keys, counted from entering them
  // or from their last dispatch.
  function restartStickyTimer() {
    if (stickyTimeout !== 0) stickyTimer.restart();
    else stickyTimer.stop();
  }

  function handleKey(event) {
    // The search field normally has the keyboard; take it back if it slipped, and
    // type the key into it rather than dropping it.
    if (search) {
      searchInput.forceActiveFocus();
      const ctrl = event.modifiers & Qt.ControlModifier;
      if (!handleSearchKey(event) && !ctrl && event.text >= " ") {
        searchInput.insert(searchInput.cursorPosition, event.text);
      }
      return;
    }
    if (event.key === Qt.Key_Escape) {
      hide();
    } else if (event.key === Qt.Key_Backspace) {
      if (stack.length === 1) return hide();
      stack = stack.slice(0, -1);
      pressed = "";
      restartStickyTimer();
    } else {
      const binding = current.find(b => b.key === event.text);
      if (binding) activate(binding);
    }
  }

  // Runs before the search field sees the key; returns false to let the field edit
  // the query with it.
  function handleSearchKey(event) {
    pinTop();
    const ctrl = event.modifiers & Qt.ControlModifier;
    const nested = search.back !== undefined;
    // In a grid, Up/Down move by a row and Left/Right by a cell.
    const row = search.grid ? gridColumns : 1;
    if (event.key === Qt.Key_Escape) {
      if (query !== "") setQuery("");
      else nested ? goBack() : hide();
    } else if (event.key === Qt.Key_Tab) {
      nested ? goBack() : showActions();
    } else if (event.key === Qt.Key_Backtab) {
      if (nested) goBack();
    } else if (event.key === Qt.Key_Backspace && query === "") {
      if (nested) {
        goBack();
      } else {
        search = null;
        pressed = "";
        cardTop = -1;
      }
    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
      // Action lists learn the query typed in their parent; learning views their own.
      const result = results[selected];
      if (result) result.item.run(nested && !search.learn ? search.back.query : query);
    } else if (event.key === Qt.Key_Down || (ctrl && event.key === Qt.Key_N)) {
      moveSelection(row);
    } else if (event.key === Qt.Key_Up || (ctrl && event.key === Qt.Key_P)) {
      moveSelection(-row);
    } else if (search.grid && event.key === Qt.Key_Right) {
      moveSelection(1);
    } else if (search.grid && event.key === Qt.Key_Left) {
      moveSelection(-1);
    } else if (ctrl && event.key === Qt.Key_D) {
      moveSelection(search.grid ? gridColumns * 3 : halfPage);
    } else if (ctrl && event.key === Qt.Key_U) {
      moveSelection(search.grid ? -gridColumns * 3 : -halfPage);
    } else {
      return false;
    }
    return true;
  }

  // The results list shows up to 8 rows and the grid 6; Ctrl+D/U move half of that,
  // like vim.
  readonly property int halfPage: 4

  function moveSelection(by) {
    selected = Math.max(Math.min(selected + by, results.length - 1), 0);
  }

  function setQuery(text) {
    if (text === query) return;
    pinTop();
    query = text;
    selected = 0;
  }

  function activate(binding) {
    pressed = binding.key;
    const nested = binding.group ?? binding.sticky;
    if (nested) {
      stack = stack.concat([{ bindings: nested, timeout: binding.sticky ? binding.timeout : 0 }]);
      restartStickyTimer();
    } else if (binding.launcher) {
      openSearch({
        label: binding.label,
        hint: "↑↓ Select · ^D/^U Page · Enter → Choose · Tab → Actions · Backspace → Back · Esc → Clear/Close",
        launcher: true,
        learn: true,
        alphabetical: true,
      });
    } else if (binding.appClass) {
      const windows = windowsOf(cls => cls === binding.appClass);
      if (windows.length === 0) hide();
      else focusWindows(binding.label, windows);
    } else if (stickyTimeout === 0) {
      dispatchAfterClose(binding.dispatch);
    } else if (binding.takesFocus) {
      pendingDispatch = binding.dispatch;
      stickyTimer.stop();
      released = true;
      releaseFallback.restart();
    } else {
      Hyprland.dispatch(binding.dispatch);
      stickyTimer.restart();
    }
  }

  function openSearch(view) {
    // A search opened from the cheatsheet centers on its own size first.
    if (!search) cardTop = -1;
    search = view;
    query = "";
    selected = 0;
  }

  // The current search's state, for a view opened from it to go back to.
  function backState() {
    return search ? { search, query, selected } : undefined;
  }

  // Focuses the only window, or picks one with a fuzzy search. Opened from a search,
  // the picker goes back to it; from the cheatsheet, back to the cheatsheet.
  function focusWindows(label, windows) {
    if (windows.length === 1) return dispatchAfterClose(focusAddress(windows[0]));
    openSearch({
      label,
      hint: `↑↓ Select · Enter → Focus · Backspace → Back · Esc → Clear/${search ? "Back" : "Close"}`,
      items: windows.map(windowItem),
      back: backState(),
    });
  }

  // Learning ranks the emojis you pick most first, and remembers the pick per query
  // in its own map, so emoji picks don't replace the launcher's for the same query.
  function openEmoji() {
    openSearch({
      label: "Emoji",
      hint: "←↑↓→ Select · ^D/^U Page · Enter → Paste · Backspace → Back · Esc → Clear/Back",
      items: emojiItems,
      learn: true,
      picks: "emojiSelected",
      grid: true,
      back: backState(),
    });
  }

  // Pasted like Omarchy's omarchy-menu-emoji-insert: copy, then Shift+Insert once the
  // overlay has closed. The emoji stays on the clipboard, which is all you get
  // without wtype.
  function emojiItem(def) {
    const id = `emoji:${def.e}`;
    return {
      id,
      title: def.e,
      fields: [def.k],
      details: [def.k],
      icon: "",
      run: learnQuery => {
        remember(id, learnQuery, "emojiSelected");
        runAfterClose(`printf %s '${def.e}' | wl-copy && command -v wtype >/dev/null && sleep 0.15 && wtype -M shift -k Insert -m shift`);
      },
    };
  }

  // Tab on an app lists "Open" plus its desktop actions, like leadrgtk's Fuzzy Mode,
  // led by "Focus" while the app has windows open. Subjects list their own actions.
  function showActions(item = results[selected]?.item) {
    if (!item?.actions?.length) return;
    const back = backState();
    const windows = item.entry ? windowsOfEntry(item.entry) : [];
    const focusAction = {
      id: item.id,
      title: "Focus",
      fields: ["Focus"],
      details: [windows.length === 1 ? "1 window open" : `${windows.length} windows open`],
      icon: item.icon,
      run: learnQuery => {
        remember(item.id, learnQuery);
        focusWindows(item.title, windows);
      },
    };
    openSearch({
      label: item.title,
      hint: "Enter → Run action · Shift+Tab / Esc → Results",
      items: (windows.length > 0 ? [focusAction] : []).concat(item.actions),
      back,
    });
  }

  function goBack() {
    const back = search.back;
    search = back.search;
    query = back.query;
    selected = back.selected;
  }

  function appItem(entry) {
    const icon = Quickshell.iconPath(entry.icon, "application-x-executable");
    // Launch through uwsm like the Hyprland binds and fuzzel do.
    const launcher = target => learnQuery => {
      remember(entry.id, learnQuery);
      hide();
      Quickshell.execDetached(["uwsm", "app", "--", target]);
    };
    const action = (title, target) => ({
      id: entry.id, title, fields: [title], details: [entry.id], icon, run: launcher(target),
    });
    const open = launcher(`${entry.id}.desktop`);
    return {
      entry,
      id: entry.id,
      title: entry.name,
      fields: [entry.name, entry.comment, entry.id],
      details: [entry.id, entry.comment, entry.id],
      icon,
      // Focus the app if it's running; "Open" under Tab still starts a new instance.
      run: learnQuery => {
        const windows = windowsOfEntry(entry);
        if (windows.length === 0) return open(learnQuery);
        remember(entry.id, learnQuery);
        focusWindows(entry.name, windows);
      },
      actions: [{ id: entry.id, title: "Open", fields: ["Open"], details: [entry.id], icon, run: open }]
        .concat(entry.actions.map(a => action(a.name, `${entry.id}.desktop:${a.id}`))),
    };
  }

  function subjectItem(def) {
    const id = `subject:${def.title}`;
    const icon = Quickshell.iconPath(def.icon, "application-x-executable");
    const names = def.actions.map(a => a.title).join(" · ");
    const item = {
      id,
      title: def.title,
      fields: [def.title, names],
      details: [names, names],
      icon,
      actions: def.actions.map(a => ({
        id, title: a.title, fields: [a.title], details: [a.command], icon,
        run: learnQuery => {
          remember(id, learnQuery);
          runAfterClose(a.command);
        },
      })),
    };
    item.run = () => showActions(item);
    return item;
  }

  function windowItem(toplevel) {
    const cls = classOf(toplevel);
    const workspace = `workspace ${toplevel.workspace?.name ?? "?"}`;
    return {
      id: toplevel.address,
      title: toplevel.title,
      fields: [toplevel.title],
      details: [workspace],
      icon: Quickshell.iconPath(entryFor(cls)?.icon ?? "", "application-x-executable"),
      run: () => dispatchAfterClose(focusAddress(toplevel)),
    };
  }

  // Dispatch once Hyprland has unmapped the overlay, so a focus change isn't refused.
  function dispatchAfterClose(cmd) {
    pendingDispatch = cmd;
    closeFallback.restart();
    hide();
  }

  function runAfterClose(command) {
    pendingCommand = command;
    closeFallback.restart();
    hide();
  }

  // Most recently focused first; the focused window goes last, since you're
  // usually switching away from it.
  function windowsOf(matchClass) {
    const history = t => t.lastIpcObject?.focusHistoryID ?? Infinity;
    return Hyprland.toplevels.values
      .filter(t => matchClass(classOf(t)))
      .sort((a, b) => (a.activated - b.activated) || (history(a) - history(b)));
  }

  function classOf(toplevel) {
    return toplevel.wayland?.appId ?? toplevel.lastIpcObject?.class ?? "";
  }

  function windowsOfEntry(entry) {
    return windowsOf(cls => entryFor(cls)?.id === entry.id);
  }

  // The desktop entry a window class belongs to. heuristicLookup only knows ids and
  // StartupWMClass, which some apps get wrong (Helium declares helium-browser but its
  // windows are "helium"), so fall back to the entry whose executable is the class.
  function entryFor(cls) {
    const exe = e => (e.command[0] ?? "").split("/").pop().toLowerCase();
    return DesktopEntries.heuristicLookup(cls)
      ?? DesktopEntries.applications.values.find(e => !e.noDisplay && exe(e) === cls.toLowerCase())
      ?? null;
  }

  function focusAddress(toplevel) {
    const address = toplevel.address.startsWith("0x") ? toplevel.address : `0x${toplevel.address}`;
    return `hl.dsp.focus({ window = "address:${address}" })`;
  }

  // Each item scores as its best-matching field. With `learn`, the item last chosen
  // for this exact query wins and launch counts break close ties (leadrgtk's rules).
  // Ties fall back to title for `alphabetical` views, otherwise to the given order;
  // V4's sort isn't stable, so the index is compared explicitly.
  function rank(view, query) {
    const folded = query.toLowerCase();
    const preferred = view.learn && folded !== "" ? history[view.picks ?? "selected"][folded] : undefined;
    const results = [];
    itemsOf(view).forEach((item, i) => {
      let score = null;
      let field = 0;
      item.fields.forEach((text, f) => {
        const s = fuzzyScore(folded, text ?? "");
        if (s !== null && (score === null || s > score)) {
          score = s;
          field = f;
        }
      });
      if (score === null) return;
      if (view.learn) {
        if (item.id === preferred) score += 1000;
        score += Math.min(history.counts[item.id] ?? 0, folded === "" ? 1e6 : 16);
      }
      results.push({ item, field, score, i });
    });
    return results.sort((a, b) => (b.score - a.score)
      || (view.alphabetical ? a.item.title.localeCompare(b.item.title) : 0)
      || (a.i - b.i));
  }

  // Lowercased characters of each target string, kept across keystrokes so a search
  // over the ~1,900 emoji keyword lists doesn't refold them all on every key.
  readonly property var foldCache: new Map()
  // The two DP rows, reused across calls instead of allocated per item.
  readonly property var scoreRows: ({ a: [], b: [] })

  function foldedChars(text) {
    let chars = foldCache.get(text);
    if (!chars) {
      chars = Array.from(text.toLowerCase());
      foldCache.set(text, chars);
    }
    return chars;
  }

  // Port of leadr's src/fuzzy.zig: ordered-subsequence scoring that favours
  // consecutive, word-start and early matches. Returns null for no match.
  function fuzzyScore(query, target) {
    const q = Array.from(query.toLowerCase());
    const t = foldedChars(target);
    if (q.length === 0) return 0;
    if (q.length > t.length) return null;
    const missing = -1e9;
    const separator = c => " -_./(".includes(c);
    let previous = scoreRows.a;
    let current = scoreRows.b;
    for (let j = 0; j < t.length; j++) previous[j] = missing;
    for (let qi = 0; qi < q.length; qi++) {
      let bestGap = missing;
      for (let j = 0; j < t.length; j++) {
        if (j > 0) bestGap = Math.max(bestGap - 1, previous[j - 1] - 1);
        current[j] = missing;
        if (q[qi] !== t[j]) continue;
        const boundary = j === 0 || separator(t[j - 1]) ? 12 : 0;
        if (qi === 0) {
          current[j] = 16 + boundary - Math.min(j, 64);
        } else if (j > 0) {
          const prior = Math.max(bestGap, previous[j - 1] + 12);
          if (prior > missing / 2) current[j] = prior + 16 + boundary;
        }
      }
      [previous, current] = [current, previous];
    }
    // The rows are longer than t when an earlier target was; only t's part counts.
    let best = missing;
    for (let j = 0; j < t.length; j++) best = Math.max(best, previous[j] - Math.min(t.length - j - 1, 32));
    if (best <= missing / 2) return null;
    return best + (q.length === t.length ? 32 : 0);
  }

  function escapeHtml(text) {
    return text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  }

  // Bolds the query's characters, matched greedily left to right.
  function highlight(text, query) {
    const q = Array.from(query.toLowerCase());
    let matched = 0;
    return Array.from(text).map(c => {
      const hit = matched < q.length && c.toLowerCase() === q[matched];
      if (hit) matched++;
      return hit ? `<b>${escapeHtml(c)}</b>` : escapeHtml(c);
    }).join("");
  }

  // Launch counts per item id, and the last choice per exact query: the launcher's in
  // `selected`, the emoji grid's in `emojiSelected`. Kept in SQLite (Qt's LocalStorage):
  // loaded once at startup, then picks update their rows in place.
  function emptyHistory() { return { counts: {}, selected: {}, emojiSelected: {} } }
  property var history: emptyHistory()
  property var db: null
  // Picks not yet written. They're saved together a moment later, so the SQLite
  // commit never delays closing the overlay or launching what was picked.
  property var unsaved: []

  function remember(id, learnQuery, picks = "selected") {
    history.counts[id] = (history.counts[id] ?? 0) + 1;
    const folded = learnQuery.toLowerCase();
    if (folded !== "") history[picks][folded] = id;
    if (!db) return;
    unsaved.push({ id, picks, query: folded });
    saveTimer.restart();
  }

  function saveHistory() {
    if (!db || unsaved.length === 0) return;
    const rows = unsaved;
    unsaved = [];
    try {
      db.transaction(tx => rows.forEach(row => {
        tx.executeSql("INSERT INTO counts VALUES (?, 1) ON CONFLICT (id) DO UPDATE SET n = n + 1", [row.id]);
        if (row.query !== "") {
          tx.executeSql("INSERT OR REPLACE INTO picks VALUES (?, ?, ?)", [row.picks, row.query, row.id]);
        }
      }));
    } catch (e) {
      // Retrying would fail the same way on every pick; this session just stops saving.
      console.warn("leadr: couldn't save history, not saving the rest of this session:", e);
      db = null;
    }
  }

  Timer { id: saveTimer; interval: 1000; onTriggered: leadr.saveHistory() }

  Component.onCompleted: {
    try {
      // LocalStorage keeps every database in one engine-wide folder, so the name carries
      // this config's state dir to keep other Quickshell configs' picks out of it.
      const database = LocalStorage.openDatabaseSync(
        `leadr ${Quickshell.statePath("")}`, "", "leadr launch history", 1000000);
      // Schema changes go through changeVersion from the stored version, e.g. "1" → "2".
      if (database.version === "") {
        database.changeVersion("", "1", tx => {
          tx.executeSql("CREATE TABLE counts (id TEXT PRIMARY KEY, n INTEGER NOT NULL)");
          tx.executeSql("CREATE TABLE picks"
            + " (view TEXT NOT NULL, query TEXT NOT NULL, id TEXT NOT NULL, PRIMARY KEY (view, query))");
        });
      }
      const loaded = emptyHistory();
      database.readTransaction(tx => {
        const counts = tx.executeSql("SELECT id, n FROM counts").rows;
        for (let i = 0; i < counts.length; i++) loaded.counts[counts.item(i).id] = counts.item(i).n;
        const picks = tx.executeSql("SELECT view, query, id FROM picks").rows;
        for (let i = 0; i < picks.length; i++) {
          const row = picks.item(i);
          if (!loaded[row.view]) loaded[row.view] = {};
          loaded[row.view][row.query] = row.id;
        }
      });
      history = loaded;
      db = database;
    } catch (e) {
      console.warn("leadr: history disabled, couldn't open its database:", e);
    }
  }

  // A config reload or shell exit can land inside the save delay.
  Component.onDestruction: saveHistory()

  function runPending() {
    closeFallback.stop();
    if (pendingDispatch !== "") Hyprland.dispatch(pendingDispatch);
    if (pendingCommand !== "") Quickshell.execDetached(["sh", "-c", pendingCommand]);
    pendingDispatch = "";
    pendingCommand = "";
  }

  // Runs while released. hyprctl only exits after Hyprland has applied the
  // dispatcher, so taking the keyboard back on exit can't race it.
  function runReleased() {
    if (pendingDispatch === "" || releasedDispatch.running) return;
    releaseFallback.stop();
    releasedDispatch.command = ["hyprctl", "dispatch", pendingDispatch];
    pendingDispatch = "";
    releasedDispatch.running = true;
  }

  Process {
    id: releasedDispatch
    onExited: {
      leadr.released = false;
      if (leadr.open) leadr.restartStickyTimer();
    }
  }

  Connections {
    target: Hyprland
    function onRawEvent(event) {
      if (event.name === "closelayer" && event.data === "leadr") leadr.runPending();
    }
  }

  Timer {
    id: stickyTimer
    interval: leadr.stickyTimeout
    onTriggered: leadr.hide()
  }

  // Fallbacks in case the expected Wayland/IPC event never arrives.
  Timer { id: closeFallback; interval: 200; onTriggered: leadr.runPending() }
  Timer { id: releaseFallback; interval: 200; onTriggered: leadr.runReleased() }

  IpcHandler {
    target: "leadr"
    // `show`/`hide` would clash with `qs ipc show` on the command line.
    function toggle(): void { leadr.open ? leadr.hide() : leadr.show() }
    // Opens straight into the Fuzzy search, as if `a` was pressed; closes the overlay
    // if a search, or a view opened from one, is already showing.
    function fuzzy(): void {
      if (leadr.open && leadr.search) return leadr.hide();
      leadr.show();
      leadr.activate(leadr.bindings.find(b => b.launcher));
    }
  }

  PanelWindow {
    id: overlay
    readonly property int centeredTop: Math.max(0, Math.round(((screen?.height ?? 0) - implicitHeight) / 2))
    visible: leadr.open
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "leadr"
    WlrLayershell.keyboardFocus: leadr.released ? WlrKeyboardFocus.None : WlrKeyboardFocus.Exclusive
    // Anchored to the top only, so it stays centered horizontally.
    anchors.top: true
    margins.top: leadr.cardTop < 0 ? centeredTop
      : Math.max(0, Math.min(leadr.cardTop, (screen?.height ?? 0) - implicitHeight))
    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight

    Item {
      id: keyCatcher
      anchors.fill: parent
      focus: true
      Keys.onPressed: event => leadr.handleKey(event)
      // Losing the keyboard confirms Hyprland applied the release.
      onActiveFocusChanged: if (!activeFocus && leadr.released) leadr.runReleased()
    }

    RowLayout {
      id: content
      spacing: 24

      // The pressed-key box only accompanies the cheatsheet, not the search views.
      Rectangle {
        visible: !leadr.search
        Layout.alignment: Qt.AlignVCenter
        implicitWidth: 160
        implicitHeight: 160
        radius: 24
        color: leadr.bg

        Text {
          anchors.centerIn: parent
          text: leadr.pressed || "●"
          color: leadr.fg
          font.family: leadr.font
          font.pixelSize: 48
          font.bold: true
        }
      }

      ColumnLayout {
        spacing: 8

        Rectangle {
          visible: !leadr.search
          implicitWidth: rows.implicitWidth + 32
          implicitHeight: rows.implicitHeight + 32
          radius: 16
          color: leadr.bg

          ColumnLayout {
            id: rows
            anchors.centerIn: parent
            spacing: 4

            Repeater {
              model: leadr.current

              RowLayout {
                required property var modelData
                spacing: 12

                Rectangle {
                  implicitWidth: Math.max(24, keyText.implicitWidth) + 20
                  implicitHeight: keyText.implicitHeight + 8
                  radius: 6
                  color: leadr.accent

                  Text {
                    id: keyText
                    anchors.centerIn: parent
                    text: modelData.key
                    color: leadr.fg
                    font.family: leadr.font
                    font.bold: true
                  }
                }

                Text {
                  text: modelData.label + (modelData.group || modelData.sticky ? "  ›" : "")
                  color: leadr.fg
                  font.family: leadr.font
                }
              }
            }
          }
        }

        Rectangle {
          id: searchPanel
          readonly property int rowHeight: 48
          visible: !!leadr.search
          implicitWidth: 640
          implicitHeight: searchRows.implicitHeight + 32
          radius: 16
          color: leadr.bg

          ColumnLayout {
            id: searchRows
            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 16 }
            spacing: 8

            RowLayout {
              Layout.fillWidth: true
              spacing: 0

              Text {
                text: `${leadr.search?.label ?? ""} › `
                textFormat: Text.PlainText
                color: leadr.fg
                font.family: leadr.font
                font.bold: true
              }

              TextInput {
                id: searchInput
                Layout.fillWidth: true
                clip: true
                color: leadr.fg
                selectionColor: leadr.accent
                selectedTextColor: leadr.fg
                font.family: leadr.font
                Keys.onPressed: event => event.accepted = leadr.handleSearchKey(event)
                // Typing and input-method commits both land here.
                onTextChanged: leadr.setQuery(text)
                // The search field holds the keyboard while it's showing.
                onVisibleChanged: visible ? forceActiveFocus() : keyCatcher.forceActiveFocus()

                Connections {
                  target: leadr
                  function onQueryChanged() {
                    if (searchInput.text !== leadr.query) searchInput.text = leadr.query;
                  }
                }

                Text {
                  anchors.fill: parent
                  visible: !searchInput.text && !searchInput.preeditText
                  text: "Search…"
                  color: leadr.fg
                  opacity: 0.5
                  font: searchInput.font
                }
              }
            }

            ListView {
              id: resultList
              visible: !leadr.search?.grid
              Layout.fillWidth: true
              // Sized by the whole list, not the matches, so typing doesn't resize the panel.
              implicitHeight: Math.max(1, Math.min(leadr.search ? leadr.itemsOf(leadr.search).length : 0, 8)) * searchPanel.rowHeight
              clip: true
              boundsBehavior: Flickable.StopAtBounds
              model: visible ? leadr.results : []
              currentIndex: leadr.selected
              onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
              onModelChanged: positionViewAtBeginning()

              delegate: Rectangle {
                required property var modelData
                required property int index
                width: ListView.view.width
                height: searchPanel.rowHeight
                radius: 6
                color: index === leadr.selected ? leadr.accent : "transparent"

                RowLayout {
                  anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
                  spacing: 12

                  IconImage {
                    visible: !modelData.item.glyph
                    implicitSize: 32
                    source: modelData.item.icon ?? ""
                  }

                  // An item can show a character instead of an icon, like Emoji's 😀.
                  Text {
                    visible: !!modelData.item.glyph
                    Layout.preferredWidth: 32
                    horizontalAlignment: Text.AlignHCenter
                    text: modelData.item.glyph ?? ""
                    font.pixelSize: 26
                  }

                  ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2

                    Text {
                      Layout.fillWidth: true
                      text: modelData.field === 0 ? leadr.highlight(modelData.item.title, leadr.query) : leadr.escapeHtml(modelData.item.title)
                      textFormat: Text.StyledText
                      elide: Text.ElideRight
                      color: leadr.fg
                      font.family: leadr.font
                    }

                    Text {
                      readonly property string detail: modelData.item.details[modelData.field] ?? ""
                      Layout.fillWidth: true
                      visible: detail !== ""
                      text: modelData.field !== 0 ? leadr.highlight(detail, leadr.query) : leadr.escapeHtml(detail)
                      textFormat: Text.StyledText
                      elide: Text.ElideMiddle
                      color: leadr.fg
                      opacity: 0.6
                      font.family: leadr.font
                      font.pointSize: 9
                    }
                  }
                }
              }

              Text {
                // Children of a ListView land in its scrolling content otherwise.
                parent: resultList
                anchors.centerIn: parent
                visible: resultList.count === 0
                text: "No matches"
                color: leadr.fg
                opacity: 0.6
                font.family: leadr.font
              }
            }

            GridView {
              id: resultGrid
              visible: !!leadr.search?.grid
              Layout.fillWidth: true
              implicitHeight: 6 * cellHeight
              cellWidth: width / leadr.gridColumns
              cellHeight: cellWidth
              clip: true
              boundsBehavior: Flickable.StopAtBounds
              model: visible ? leadr.results : []
              currentIndex: leadr.selected
              onCurrentIndexChanged: positionViewAtIndex(currentIndex, GridView.Contain)
              onModelChanged: positionViewAtBeginning()

              delegate: Rectangle {
                required property var modelData
                required property int index
                width: GridView.view.cellWidth
                height: GridView.view.cellHeight
                radius: 6
                color: index === leadr.selected ? leadr.accent : "transparent"

                Text {
                  anchors.centerIn: parent
                  text: modelData.item.title
                  font.pixelSize: 32
                }
              }

              Text {
                parent: resultGrid
                anchors.centerIn: parent
                visible: resultGrid.count === 0
                text: "No matches"
                color: leadr.fg
                opacity: 0.6
                font.family: leadr.font
              }
            }

            // Grid cells have no second line, so the selected one's name goes here.
            Text {
              visible: resultGrid.visible
              Layout.fillWidth: true
              text: leadr.results[leadr.selected]?.item.details[0] ?? ""
              elide: Text.ElideRight
              color: leadr.fg
              opacity: 0.6
              font.family: leadr.font
              font.pointSize: 9
            }
          }
        }

        Text {
          text: leadr.search?.hint ?? "Backspace → Back · Esc → Close"
          color: leadr.fg
          opacity: 0.6
          font.family: leadr.font
        }
      }
    }
  }
}
