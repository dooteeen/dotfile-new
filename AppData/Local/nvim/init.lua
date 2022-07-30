local api = vim.api
local cmd = vim.cmd
local fn  = vim.fn
local key = vim.keymap.set
local opt = vim.opt

local is_code = (fn.exists[[g:vscode]] == 1)
local is_win  = (fn.has[[win32]] == 1)


cmd [[language C]]

opt.mouse = 'a'
opt.title = true
if not is_code then opt.ambiwidth = 'double' end

opt.swapfile = false
opt.backup = false
opt.hidden = true
opt.clipboard:append({unnamedplus = true})

opt.number = true
opt.list = true
opt.smartindent = true
opt.visualbell = true

opt.showmatch = true

opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2

opt.ignorecase = true
opt.smartcase = true
opt.wrapscan = true

opt.whichwrap = 'b,s,h,l,<,>,[,]'
opt.backspace = 'indent,eol,start'
opt.fileformats = 'dos,unix,mac'

opt.helplang = 'ja', 'en'

opt.updatetime = 300



key("n", "gj", "j",  {noremap = true})
key("n", "j",  "gj", {noremap = true})
key("n", "gk", "k",  {noremap = true})
key("n", "k",  "gk", {noremap = true})

key("n", "q", "$", {noremap = true})
key("v", "q", "$", {noremap = true})
key("n", "Q", "q", {noremap = true})
key("v", "Q", "q", {noremap = true})

key("n", "<", "<h", {noremap = true})
key("n", ">", ">l", {noremap = true})
key("v", "<", "<gv", {noremap = true})
key("v", ">", ">gv", {noremap = true})

key("n", "<CR>", ":<C-u>noh<CR>", {noremap = true})
key("v", "<CR>", "=gv", {noremap = true})



-- move cursor to latest modified place.
api.nvim_create_autocmd({"BufReadPost"}, {
  pattern = {"*"},
  callback = function()
    api.nvim_exec('silent! normal! g`"zv', false)
  end,
})



-- install with packer.nvim

local packer_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local packer_url  = 'https://github.com/wbthomason/packer.nvim'
local install_path = is_win and string.gsub(packer_path, "/", "\\") or packer_path

vim.g.t1 = install_path
vim.g.t2 = is_win and 1 or 0

if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', packer_url, install_path})
end

local has_installed = function(pkg)
  local root = fn.stdpath('data') .. '/site/pack/packer/'
  return fn.glob(root..'start/'..pkg) or fn.glob(root..'opt/'..pkg)
end



cmd [[packadd packer.nvim]]
require('packer').startup({function()
  use 'wbthomason/packer.nvim'

  use {
    'phaazon/hop.nvim',
    branch = 'v2',
    config = function()
      require('hop').setup {
        keys = 'asdfghjklwertyuiopvbn',
        quit_key = 'q',
        multi_windows = true,
      }
    end
  }

  use {
    'nvim-treesitter/nvim-treesitter',
    run = function()
      require('nvim-treesitter.install').update({ with_sync = true })
    end,
    config = function()
      require('nvim-treesitter.configs').setup {
        sync_install = false,
        auto_install = true,
        highlight = { enable = vim.fn.has'g:vscode' == 0 }
      }
    end
  }

  if is_code then return nil end

  use 'gpanders/editorconfig.nvim'

  vim.g.kommentary_create_default_mappings = false
  use {
    'b3nj5m1n/kommentary',
    config = function()
      require('kommentary.config').configure_language("default", {
        ignore_whitespace = true
      })
    end
  }

  use {
    'lewis6991/gitsigns.nvim',
    config = function()
      require('gitsigns').setup()
    end
  }

  use {
    'RRethy/nvim-base16',
    requires = {{'nvim-treesitter/nvim-treesitter'}},
  }

  use {
    'windwp/nvim-autopairs',
    requires = {{'nvim-treesitter/nvim-treesitter'}},
    config = function()
      local Rule = require('nvim-autopairs.rule')
      local Cond = require('nvim-autopairs.conds')
      require('nvim-autopairs').setup {
        chars = { "{", "[", "(", [["]], [[']], [[`]] },
      }
    end
  }

  use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.0',
    requires = {
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-treesitter/nvim-treesitter' },
      { 'kyazdani42/nvim-web-devicons', opt = true },
    },
  }

  use {
    'nvim-lualine/lualine.nvim',
    requires = {{ 'kyazdani42/nvim-web-devicons', opt = true }},
    config = function()
      require('lualine').setup {
        options = {
          icons_enabled = true,
          theme = 'auto',
          component_separators = '|',
          section_separators = '',
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'filename'},
          lualine_c = {},
          lualine_x = {},
          lualine_y = {'encoding', 'fileformat', 'filetype'},
          lualine_z = {'location'},
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = {'filename'},
          lualine_x = {'location'},
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {}
      }
    end
  }

  if packer_bootstrap then
    require('packer').sync()
  end
end
})


-- plugins keymap
key("n", "<Space>", "<Nop>", {})
if has_installed("hop.nvim") then
  key("n", "<Space><Space>", ':<C-u>HopPattern<CR>', {})
end

if not is_code then

  if has_installed('kommentary.nvim') then
    key("n", "--", "<Plug>kommentary_line_default", {})
    key("n", "-",  "<Plug>kommentary_motion_default", {})
    key("v", "-",  "<Plug>kommentary_visual_default<C-c>", {})
  end

  if has_installed('telescope.nvim') then
    key("n", "<Space>b", "<Cmd>Telescope buffers theme=get_dropdown<CR>", {noremap=true})
    key("n", "<Space>c", "<Cmd>Telescope colorscheme theme=get_dropdown<CR>", {noremap=true})
    key("n", "<Space>f", "<Cmd>Telescope find_files hidden=true theme=get_dropdown<CR>", {noremap=true})
    key("n", "<Space>g", "<Cmd>Telescope git_files theme=get_dropdown<CR>", {noremap=true})
    key("n", "<Space>j", "<Cmd>Telescope current_buffer_fuzzy_find theme=get_dropdown<CR>", {noremap=true})
    key("n", "<Space>m", "<Cmd>Telescope oldfiles theme=get_dropdown<CR>", {noremap=true})
    key("n", "<Space>t", "<Cmd>Telescope treesitter theme=get_dropdown<CR>", {noremap=true})
  end

  if has_installed('nvim-base16') then
    require('base16-colorscheme').with_config {
      telescope = false
    }
    local scheme = is_win and 'onedark' or 'solarized-dark'
    vim.cmd("color base16-"..scheme)
  end

end
