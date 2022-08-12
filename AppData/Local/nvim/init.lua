local api = vim.api
local cmd = vim.cmd
local env = vim.env
local fn  = vim.fn
local key = vim.keymap.set
local opt = vim.opt

is_code = (fn.exists'g:vscode' == 1)
is_win  = (fn.has'win32' == 1)



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

opt.helplang = 'ja','en'

opt.updatetime = 300
opt.signcolumn = 'yes'



key("n", "<Space>", "<Nop>", {})

key("n", "gj", "j",  { noremap = true })
key("n", "j",  "gj", { noremap = true })
key("n", "gk", "k",  { noremap = true })
key("n", "k",  "gk", { noremap = true })

key("n", "q", "$", { noremap = true })
key("n", "Q", "q", { noremap = true })
key("n", "t", "0", { noremap = true })
key("n", "T", "^", { noremap = true })
key("v", "t", "0", { noremap = true })
key("v", "T", "^", { noremap = true })

key("n", "<", "<h",  { noremap = true })
key("n", ">", ">l",  { noremap = true })
key("v", "<", "<gv", { noremap = true })
key("v", ">", ">gv", { noremap = true })

key("n", "<Tab>",   "<C-w>w", { noremap = true })
key("n", "<S-Tab>", "<C-w>W", { noremap = true })

key("n", "(", ":bn<CR>", { noremap = true, silent = true })
key("n", ")", ":bp<CR>", { noremap = true, silent = true })



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

if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', packer_url, install_path})
end

local has_installed = function(pkg)
  local root = fn.stdpath('data') .. '/site/pack/packer/'
  return fn.glob(root..'start/'..pkg) or fn.glob(root..'opt/'..pkg)
end



cmd [[packadd packer.nvim]]
require('packer').startup { function()
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
        ignore_install = { 'help', 'TelescopePrompt' },
        highlight = {
          enable = not is_code,
          disable = { 'help', 'TelescopePrompt' },
        },
        endwise = {
          enable = true,
        }
      }
    end,
  }

  use {
   'mfussenegger/nvim-treehopper',
    requires = {{ 'nvim-treesitter/nvim-treesitter' }},
    config = function()
      require('tsht').config.hint_keys = {
        "A","S","D","F","G","H","J","K","L"
      }
    end
  }

  use {
    'RRethy/nvim-treesitter-endwise',
    requires = {{ 'nvim-treesitter/nvim-treesitter' }},
  }

  use {
    'kylechui/nvim-surround',
    config = function()
      require('nvim-surround').setup {
        aliases = {
          ['Q'] = { [[']], [["]], [[`]] },
          ['P'] = { '>', '}', ')', ']' },
          ['S'] = { [[']], [["]], [[`]], '>', '}', ')', ']' }
        }
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
        prefer_single_line_comments = true,
        ignore_whitespace = true
      })
    end
  }

 vim.opt.signcolumn = 'yes'
 use {
   'lewis6991/gitsigns.nvim',
   requires = {{ 'nvim-lua/plenary.nvim' }},
   config = function()
     require('gitsigns').setup {
       signs = {
         add = { text = '|' }, -- green
         change = { text = '|' }, -- blue
         delete = { text = '_' }, -- red
         topdelete = { text = '^' }, -- red
         changedelete = { text = '+' }, -- blue
       }
     }
   end
 }

  use {
    'RRethy/nvim-base16',
    requires = {{'nvim-treesitter/nvim-treesitter'}},
  }

  use {
    'nvim-treesitter/playground'
  }


  vim.opt.signcolumn = 'yes'
  use {
    'windwp/nvim-autopairs',
    requires = {{ 'nvim-treesitter/nvim-treesitter' }},
    config = function()
      local autopairs = require('nvim-autopairs')
      local rule = require('nvim-autopairs.rule')
      -- local cond = require('nvim-autopairs.conds')
      local endwise = require('nvim-autopairs.ts-rule').endwise
      autopairs.setup { check_ts = true }
      autopairs.add_rules {
        -- add space between parentheses
        rule(' ', ' '):with_pair(function(opts)
          local p = opts.line:sub(opts.col - 1, opts.col)
          return vim.tbl_contains({'()', '{}', '[]'}, p)
        end),
        rule('(', ')')
          :with_pair(function() return false end)
          :with_move(function(opts)
            return opts.prev_char:match('.%)') ~= nil
          end)
          :use_key(')'),
        rule('{', '}')
          :with_pair(function() return false end)
          :with_move(function(opts)
            return opts.prev_char:match('.%}') ~= nil
          end)
          :use_key('}'),
        rule('[', ']')
          :with_pair(function() return false end)
          :with_move(function(opts)
            return opts.prev_char:match('.%]') ~= nil
          end)
          :use_key(']'),
        -- for lua
        rule('[[', ']]', 'lua'),
        -- for fish shell
        endwise('if.*$', 'end', 'fish', 'if_statement'),
        endwise('for.*$', 'end', 'fish', 'for_statement'),
        endwise('begin$', 'end', 'fish', 'begin_statement'),
        endwise('while.*$', 'end', 'fish', 'while_statement'),
        endwise('switch.*$', 'end', 'fish', 'switch_statement'),
        endwise('function.*$', 'end', 'fish', 'function_definition'),
      }
    end
  }

  use {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
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
          component_separators = '',
          section_separators = '',
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'filename' },
          lualine_c = {},
          lualine_x = {},
          lualine_y = { 'encoding', 'fileformat', 'filetype' },
          lualine_z = { 'location' },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { 'filename' },
          lualine_x = { 'location' },
          lualine_y = {},
          lualine_z = {},
        },
        tabline = {}
      }
    end
  }

  use {
    'mfussenegger/nvim-lint',
    config = function()
      require('lint').linters_by_ft = {
        lua  = { 'luacheck' },
        yaml = { 'yamllint' },
      }
    end
  }

  if packer_bootstrap then
    require('packer').sync()
  end

end
}

-- plugins keymap

if not is_code and not packer_bootstrap then

  if has_installed('kommentary.nvim') then
    key("n", "--", "<Plug>kommentary_line_default", {})
    key("n", "-",  "<Plug>kommentary_motion_default", {})
    key("v", "-",  "<Plug>kommentary_visual_default<C-c>", {})
  end

  if has_installed('telescope.nvim') then
    local pickers = {
      { key = 'b', fn = function(x, y) x.buffers(y)     end },
      { key = 'c', fn = function(x, y) x.colorscheme(y) end },
      { key = 'f', fn = function(x, y) x.find_files(y)  end },
      { key = 'g', fn = function(x, y) x.git_files(y)   end },
      { key = 'j', fn = function(x, y) x.current_buffer_fuzzy_find(y) end },
      { key = 'k', fn = function(x, y) x.keymaps(y)     end },
      { key = 'm', fn = function(x, y) x.oldfiles(y)    end },
    }
    for _, p in pairs(pickers) do
      key('n', '<Space>'..p.key, function()
        p.fn(require('telescope.builtin'), require('telescope.themes').get_dropdown {
          borderchars = {
            prompt =  {'', '', '', '', '', '', '', ''},
            results = {'', '', '', '', '', '', '', ''},
            preview = {'', '', '', '', '', '', '', ''},
          }
        })
      end, { noremap = true })
    end
    if has_installed("hop.nvim") then
      key("n", "<Space>h", ':<C-u>HopPattern<CR>', {})
    end
    if has_installed('nvim-treehopper') then
      key("n", '<Space>t', function() require('tsht').move{side='start'} end, { noremap = true })
      key("n", '<Space>T', function() require('tsht').move{side='end'}   end, { noremap = true })
    end
  end

  if has_installed('nvim-base16') then
    local base16 = require('base16-colorscheme')
    base16.with_config { telescope = true }
    local using_scheme = is_win and 'onedark' or 'solarized-dark'
    cmd("color base16-"..using_scheme)
    -- overwrite colorscheme
    api.nvim_set_hl(0, 'VertSplit', { fg = base16.colors.base02, bg = nil })
    local color_assigns = {
      { target = 'TSField', reference = 'TSVariable' },
      { target = 'TSParameter', reference = 'TSVariable' },
      { target = 'TSConstructor', reference = 'TSText' },
      { target = 'TSPunctDelimiter', reference = 'TSText' },
      { target = 'TSStringRegex', reference = 'TSConstant' },
    }
    for _, p in pairs(color_assigns) do
      api.nvim_set_hl(0, p.target, { link = p.reference })
    end
  end

  if has_installed('nvim-lint') then
    api.nvim_create_autocmd({ 'BufWritePost' }, {
      callback = function()
        require('lint').try_lint()
      end
    })
    require('lint.linters.luacheck').args = {
      '--only', '0'
    }
  end

end
