-- get_current_session
local _get_current_session = ya.sync(function(state)
  local tabs = cx.tabs

  local session = {
    active_idx = tabs.idx,
    tabs = {},
  }

  for idx, tab in ipairs(tabs) do
    session.tabs[idx] = {
      cwd = tostring(tab.current.cwd):gsub("\\", "/"),
      sort = {
        by = tab.pref.sort_by,
        sensitive = tab.pref.sort_sensitive,
        reverse = tab.pref.sort_reverse,
        dir_first = tab.pref.sort_dir_first,
        translit = tab.pref.sort_translit,
      },
      linemode = tab.pref.linemode,
      show_hidden = tab.pref.show_hidden and "show" or "hide",
    }
  end

  return session
end)

-- _save_and_quit
local _save_and_quit = ya.sync(function(state)
  local session = _get_current_session()
  ps.pub_to(0, state.event, session)
  ya.emit("quit", {})
end)

-- restore_session
local _restore_session = ya.sync(function(state)
  session = state.session

  for idx, tab in ipairs(session.tabs) do
    if idx == 1 then
      ya.emit("cd", { tab.cwd })
    else
      ya.emit("tab_create", { tab.cwd })
    end
    ya.emit("sort", tab.sort)
    ya.emit("linemode", { tab.linemode })
    ya.emit("hidden", { tab.show_hidden })
  end

  ya.emit("tab_switch", { session.active_idx - 1 })
    
  state.restored = true
end)

return {
  setup = function(state, opts)
    state.restored = false
    state.event = "@autosession-event"

    ps.sub_remote(state.event, function(body)
      if not state.restored then
        state.session = body
        _restore_session()
      end
    end)
  end,

  entry = function(_, job)
    local action = job.args[1]
    if action == "save-and-quit" then
      _save_and_quit()
    end
  end,
}
