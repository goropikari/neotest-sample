vim.g.mapleader = ','
vim.g.maplocalleader = ','
vim.wo.number = true
vim.wo.signcolumn = 'yes'
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4

-- clipboard
vim.opt.clipboard = 'unnamedplus' -- Sync with system clipboard

-- https://neovim.io/doc/user/provider.html#clipboard-osc52
if vim.fn.has('wsl') == 1 or os.getenv('HOSTNAME') ~= nil then
  vim.g.clipboard = {
    name = 'OSC 52',
    copy = {
      ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    },
    paste = {
      -- https://github.com/neovim/neovim/discussions/28010#discussioncomment-9877494
      ['+'] = function()
        return {
          vim.fn.split(vim.fn.getreg(''), '\n'),
          vim.fn.getregtype(''),
        }
      end,
    },
  }
end

local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
      { '\nPress any key to exit...' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Setup lazy.nvim
require('lazy').setup({
  spec = {
    {
      'nvim-neotest/neotest',
      dependencies = {
        'nvim-neotest/nvim-nio',
        'nvim-lua/plenary.nvim',
        'antoinemadec/FixCursorHold.nvim',
        'nvim-treesitter/nvim-treesitter',
      },
      config = function()
        require('neotest').setup({
          adapters = {
            require('neotest-sample'),
          },
        })
      end,
    },
    {
      'goropikari/neotest-sample',
      dev = true,
    },
    {

      'nvim-treesitter/nvim-treesitter',
      version = '*',
      event = 'VeryLazy',
      dependencies = {
        'nvim-treesitter/nvim-treesitter-textobjects',
      },
      build = ':TSUpdate',
      config = function()
        vim.defer_fn(function()
          require('nvim-treesitter.configs').setup({
            ensure_installed = { 'lua' },
            auto_install = true,
            sync_install = false,
            ignore_install = {},
            modules = {},
            highlight = { enable = true },
            indent = { enable = true },
          })
        end, 0)
      end,
    },
  },
  dev = {
    path = '/workspaces',
    patterns = { 'goropikari' }, -- For example {"folke"}
    fallback = true, -- Fallback to git when local plugin doesn't exist
  },
  checker = { enabled = true },
})
