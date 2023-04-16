-- load with :lua require('stackmap')
-- clear with :lua package.loaded['stackmap'] = nil
-- vim.keymap.set
-- vim.api.nvim_get_keymap(mode)
-- nmap "keymap" to see what exists
print("stackmap loaded v2")

-- create a module
local M = {}

M._stack = {}

local find_mapping = function(maps, lhs)
  for _, value in ipairs(maps) do
    if value.lhs == lhs then
      return value
    end
  end
end

-- M.setup = function(opts)
--   print("Options:", opts)
-- end

M.push = function(name, mode, mappings)
  local maps = vim.api.nvim_get_keymap(mode)

  -- cache existing mappings
  local existing_maps = {}
  for lhs, _ in pairs(mappings) do
    local existing = find_mapping(maps, lhs)
    if existing then
      existing_maps[lhs] = existing
    end
  end

  M._stack[name] = M._stack[name] or {}

  M._stack[name][mode] = {
    existing = existing_maps,
    mappings = mappings,
  }

  for lhs, rhs in pairs(mappings) do
    vim.keymap.set(mode, lhs, rhs)
  end
end

M.pop = function(name, mode)
  local state = M._stack[name][mode]
  M._stack[name][mode] = nil

  if state then
    for lhs, _ in pairs(state.mappings) do
      if state.existing[lhs] then
        local prior_rhs = state.existing[lhs].rhs
        vim.keymap.set(mode, lhs, prior_rhs)
      else
        vim.keymap.del(mode, lhs)
      end
    end
  end

end

return M
