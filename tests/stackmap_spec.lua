local find_mapping = function(lhs)
  local maps = vim.api.nvim_get_keymap('n')
  for _, value in ipairs(maps) do
    if value.lhs == lhs then
      return value
    end
  end
end

describe("stackmap", function()
  before_each(function()
    pcall(vim.keymap.del, "n", "asdfasdf")
    require("stackmap")._stack = {}
  end)

  it("can be required", function()
    require("stackmap")
  end)

  it("can push a single mapping", function()
    local rhs = ":echo 'this is a test'<CR>"
    require("stackmap").push("test1", "n", {
      asdfasdf = rhs
    })
    local found = find_mapping("asdfasdf")
    assert.are.same(rhs, found.rhs)
  end)

  it("can push multiple mappings", function()
    local rhs = ":echo 'this is a test'<CR>"
    require("stackmap").push("test1", "n", {
      ["asdf_1"] = rhs .. '1',
      ["asdf_2"] = rhs .. '2',
    })

    local found_1 = find_mapping("asdf_1")
    assert.are.same(rhs .. "1", found_1.rhs)

    local found_2 = find_mapping("asdf_2")
    assert.are.same(rhs .. "2", found_2.rhs)
  end)

  it("pop can delete mappings; for non-existant keymaps", function()
    local rhs = ":echo 'this is a test'<CR>"
    require("stackmap").push("test1", "n", {
      asdfasdf = rhs
    })
    local found = find_mapping("asdfasdf")
    assert.are.same(rhs, found.rhs)

    require("stackmap").pop("test1", "n")

    local after_pop = find_mapping("asdfasdf")
    assert.are.same(nil, after_pop)
  end)

  it("pop can delete mappings; for existing keymaps", function()
    local og_rhs = ':echo OG mapping<CR>'
    vim.keymap.set('n', 'asdfasdf', og_rhs)

    local rhs = ":echo 'this is a test'<CR>"
    require("stackmap").push("test1", "n", {
      asdfasdf = rhs
    })
    local found = find_mapping("asdfasdf")
    assert.are.same(rhs, found.rhs)

    require("stackmap").pop("test1", "n")

    local after_pop = find_mapping("asdfasdf")
    assert.are.same(og_rhs, after_pop.rhs)
  end)

  it("pop can delete mappings; honors the mode specified", function()
    local og_rhs = ':echo OG mapping<CR>'
    vim.keymap.set('n', 'asdfasdf', og_rhs)

    local rhs = ":echo 'this is a test'<CR>"
    require("stackmap").push("test1", "n", {
      asdfasdf = rhs
    })
    local found = find_mapping("asdfasdf")
    assert.are.same(rhs, found.rhs)

    require("stackmap").pop("test1", "i")

    local after_pop = find_mapping("asdfasdf")
    assert.are.same(rhs, after_pop.rhs)
  end)
end)
