local M = {}

function M.pick_visits_labels()
  local fzf = require('fzf-lua')
  local visits = require('mini.visits')

  local labels = visits.list_labels('', nil)

  fzf.fzf_exec(labels, {
    prompt = 'Buffer labels> ',
    winopts = { persist = true },
    fzf_opts = { ['--no-clear'] = '' },
    actions = {
      ['default'] = function(selected)
        if #selected > 0 then
          local label = selected[1]
          M.pick_visits_paths(label)
        end
      end,
    },
  })
end

function M.pick_visits_paths(label)
  local fzf = require('fzf-lua')
  local visits = require('mini.visits')

  local paths = visits.list_paths(nil, { filter = label })

  fzf.fzf_exec(paths, {
    prompt = 'Buffer paths> ',
    winopts = { persist = true },
    actions = {
      ['default'] = function(selected)
        if #selected > 0 then
          local path = selected[1]
          vim.cmd('edit ' .. path)
        end
      end,
    },
  })
end

return M
