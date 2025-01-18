local M = {}

local types = require('neotest.types')
local lib = require('neotest.lib')

M.name = 'neotest-sample'

---Find the project root directory given a current directory to work from.
---Should no root be found, the adapter can still be used in a non-project context if a test file matches.
---@async
---@param dir string @Directory to treat as cwd
---@return string | nil @Absolute root dir of test suite
function M.root(dir)
  return dir
end

---Filter directories when searching for test files
---@async
---@param name string Name of directory
---@param rel_path string Path to directory, relative to root
---@param root string Root directory of project
---@return boolean
function M.filter_dir(name, rel_path, root)
  return false
end

---@async
---@param file_path string
---@return boolean
function M.is_test_file(file_path)
  -- return vim.fn.fnamemodify(file_path, ':t') == 'test.lua'
  vim.print(file_path)
  return true
end

---Given a file path, parse all the tests within it.
---@async
---@param file_path string Absolute file path
---@return neotest.Tree | nil
function M.discover_positions(file_path)
  local data = {
    {
      id = file_path,
      name = file_path, -- summary で表示される親の名前
      path = file_path,
      range = { 0, 0, 0, 0 },
      type = 'file',
    },
    {
      id = file_path .. '::test_hoge',
      name = 'test_hoge',
      path = file_path,
      range = { 0, 0, 0, 0 },
      type = 'test',
      input_file = 'hoge.in',
      output_file = 'hoge.out',
    },
    {
      id = file_path .. '::test_piyo',
      name = 'test_piyo',
      path = file_path,
      range = { 0, 0, 0, 0 },
      type = 'test',
      input_file = 'piyo.in',
      output_file = 'piyo.out',
    },
  }

  -- from_list は第1要素が親
  local res = types.Tree.from_list(data, function(pos)
    return pos.id
  end)
  return res

  -- for lua
  -- local query = [[
  --               (function_declaration
  --                       name: (identifier) @test.name
  --                       (#match? @test.name "^test_")
  --               ) @test.definition
  --       ]]
  --
  -- local res = lib.treesitter.parse_positions(file_path, query)
  -- vim.print(res)
  -- return res
end

---@param args neotest.RunArgs
---@return nil | neotest.RunSpec | neotest.RunSpec[]
function M.build_spec(args)
  local commands = {}

  for _, node in args.tree:iter() do
    if node.type == 'test' then
      local command = {
        command = 'echo ' .. node.input_file .. ' ' .. node.output_file,
        pos_id = node.id,
      }
      table.insert(commands, command)
    end
  end
  return commands
end

---@async
---@param spec neotest.RunSpec
---@param result neotest.StrategyResult
---@param tree neotest.Tree
---@return table<string, neotest.Result>
function M.results(spec, result, tree)
  local pos_id = spec.pos_id
  return { [pos_id] = {
    status = result.code == 0 and 'passed' or 'failed',
  } }
end

return M
