local api = vim.api
local cmd = vim.cmd
local env = vim.env
local fn  = vim.fn
local key = vim.keymap.set
local opt = vim.opt

is_code = fn.exists'g:vscode' == 1
is_win  = fn.has'win32' == 1
is_gui  = vim.g.gonvim_running == 1
in_repo = fn.executable('git') and fn.system('git rev-parse --is-inside-work-tree')
in_venv = false
if in_repo and fn.executable('pipenv') then
  in_venv = env.PIPENV_ACTIVE
end
--if fn.empty(fn.glob(install_path)) > 0 then


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

opt.helplang = {'ja','en'}

opt.showtabline = 0
opt.showmode = false

opt.splitbelow = true
opt.splitright = true

opt.updatetime = 300
opt.signcolumn = 'yes'

if fn.executable('nyagos') then
  opt.sh = "nyagos"
  opt.shellcmdflag = "-k cls"
end

if in_venv then
  vim.g.python3_host_prog = fn.system 'which python3'
end



key("n", "gj", "j",  { noremap = true, silent = true })
key("n", "j",  "gj", { noremap = true, silent = true })
key("n", "gk", "k",  { noremap = true, silent = true })
key("n", "k",  "gk", { noremap = true, silent = true })

key("n", "s", "<Nop>", { noremap = true, silent = true })
key("n", "S", "<Nop>", { noremap = true, silent = true })
key("v", "s", "<Nop>", { noremap = true, silent = true })
key("v", "S", "<Nop>", { noremap = true, silent = true })

key("n", "q", "$", { noremap = true, silent = true })
key("o", "q", "$", { noremap = true, silent = true })
key("v", "q", "$", { noremap = true, silent = true })
key("n", "Q", "q", { noremap = true, silent = true })

key("n", "t", "0", { noremap = true, silent = true })
key("n", "T", "^", { noremap = true, silent = true })
key("o", "t", "0", { noremap = true, silent = true })
key("o", "T", "^", { noremap = true, silent = true })
key("v", "t", "0", { noremap = true, silent = true })
key("v", "T", "^", { noremap = true, silent = true })

key("n", "<", "<h",  { noremap = true, silent = true })
key("n", ">", ">l",  { noremap = true, silent = true })
key("v", "<", "<gv", { noremap = true, silent = true })
key("v", ">", ">gv", { noremap = true, silent = true })

key("n", "<Tab>",   "<C-w>w", { noremap = true, silent = true })
key("n", "<S-Tab>", "<C-w>W", { noremap = true, silent = true })

key("n", "(", ":bp<CR>", { noremap = true, silent = true })
key("n", ")", ":bn<CR>", { noremap = true, silent = true })

key("n", "<Space>", "<Nop>", {})
key("n", "<CR>", ":<C-u>noh<CR>", {})



user_augroup = 'user-init'
api.nvim_create_augroup(user_augroup, { clear = false })
api.nvim_create_autocmd({"TermOpen"}, {
  group = user_augroup,
  command = "startinsert",
})
api.nvim_create_autocmd({"BufReadPost"}, {
  group = user_augroup,
  pattern = {"*"},
  callback = function()
    -- move cursor to latest modified place.
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

local is_plugged = function(pkg)
  local root = vim.fn.stdpath('data') .. '/site/pack/packer'
  return vim.fn.glob(root..'start/') or vim.fn.glob(root..'opt/'..pkg)
end



cmd [[packadd packer.nvim]]
require('packer').startup { function()
  use 'wbthomason/packer.nvim'

  use {
    'phaazon/hop.nvim',
    branch = 'v2',
    config = function()
      require('hop').setup {
        keys = 'adefghjklnoprstuvw',
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
        endwise = { enable = true, },
        highlight = {
          enable = not is_code,
          disable = { 'help', 'TelescopePrompt' },
        },
        -- extension: textobjects
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymap = {
              ['aa'] = '@parameter.outer',
              ['ia'] = '@parameter.inner',
              ['ab'] = '@block.outer',
              ['ib'] = '@block.inner',
              ['ac'] = '@comment.outer',
              ['ic'] = '@comment.outer',
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ai'] = '@conditional.outer',
              ['ii'] = '@conditional.inner',
            }
          }
        }
      }
    end,
  }

  use {
    'nvim-treesitter/nvim-treesitter-textobjects',
    requires = {{ 'nvim-treesitter/nvim-treesitter' }},
  }

  use {
   'mfussenegger/nvim-treehopper',
    requires = {{ 'nvim-treesitter/nvim-treesitter' }},
    config = function()
      require('tsht').config.hint_keys = {
        "a", "b", "c", "d", "e", "f", "g", "h", "i",
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
      require('nvim-surround').setup()
    end
  }

  use {
    'windwp/nvim-autopairs',
    requires = {{ 'nvim-treesitter/nvim-treesitter' }},
    config = function()
      local autopairs = require('nvim-autopairs')
      local rule = require('nvim-autopairs.rule')
      -- local cond = require('nvim-autopairs.conds')
      local endwise = require('nvim-autopairs.ts-rule').endwise
      local smart_space = function(left, right)
        return require('nvim-autopairs.rule')(left, right)
          :with_pair(function() return false end)
          :with_move(function(opts)
            return opts.prev_char:match('.%'..right) ~= nil
          end)
          :use_key(right)
      end
      autopairs.setup { check_ts = true }
      autopairs.add_rules {
        -- add space between parentheses
        rule(' ', ' '):with_pair(function(opts)
          local p = opts.line:sub(opts.col - 1, opts.col)
          return vim.tbl_contains({'()', '{}', '[]'}, p)
        end),
        smart_space('(', ')'),
        smart_space('{', '}'),
        smart_space('[', ']'),
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
    'rmagatti/alternate-toggler',
    config = function()
      require('alternate-toggler').setup {
        alternates = {
          ["1"]    = "0",
          ["true"] = "false",
          ["True"] = "False",
          ["TRUE"] = "FALSE",
          ["Yes"]  = "No",
          ["YES"]  = "NO",
          ["On"]   = "Off",
          ["ON"]   = "OFF",
          ["<="]   = ">=",
          ["<"]    = ">",
          ["+"]    = "-",
          ["==="]  = "!==",
          ["=="]   = "!=",
        }
      }
    end
  }


  if is_code then return nil end


  -- for LSP and complition
  use {
    'VonHeikemen/lsp-zero.nvim',
    requires = {
      -- LSP support with debugger
      { 'nvim-lua/plenary.nvim' },
      { 'neovim/nvim-lspconfig' },
      { 'williamboman/mason.nvim' },
      { 'williamboman/mason-lspconfig.nvim' },
      { 'jose-elias-alvarez/null-ls.nvim' },

      -- for snippets
      { 'L3MON4D3/LuaSnip' },
      { 'rafamadriz/friendly-snippets' },

      -- for complition
      { 'hrsh7th/nvim-cmp' },
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-path' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-nvim-lua' },
      { 'saadparwaiz1/cmp_luasnip' },
    },
    config = function()
      local lsp = require('lsp-zero')
      lsp.set_preferences {
        suggest_lsp_servers = true,
        setup_servers_on_start = true,
        set_lsp_keymaps = true,
        configurate_diagnostics = true,
        cmp_capabilities = true,
        manage_nvim_cmp = true,
        call_servers = 'local',
        sign_icons = {
          error = '!',
          warn  = '!',
          hint  = '?',
          info  = '?',
        }
      }

      local null = require('null-ls')
      local null_opts = lsp.build_options('null-ls', {})
      null.setup {
        on_attach = null_opts.on_attach,
      }

      lsp.setup()
    end
  }

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
         add = { text = '+' }, -- green
         change = { text = '~' }, -- blue
         delete = { text = '_' }, -- red
         topdelete = { text = '^' }, -- red
         changedelete = { text = '=' }, -- blue
       }
     }
   end
 }

  use {
    'RRethy/nvim-base16',
    requires = {{ 'nvim-treesitter/nvim-treesitter' }},
  }

  use {
    'xiyaowong/nvim-transparent',
    requires = {{ 'RRethy/nvim-base16' }},
    config = function()
      require('transparent').setup {
        enable = not is_gui,
        extra_groups = {
          'VertSplit',
          'GitGutterChange',
          'GitGutterAdd',
          'GitGutterDelete',
        }
      }
    end
  }

  use {
    'nvim-treesitter/playground'
  }

  use {
    'LhKipp/nvim-nu',
    requires = {{ 'nvim-treesitter/nvim-treesitter' }},
    run = ':TSInstall nu',
    config = function()
      require('nu').setup {}
    end
  }

  use {
    'akinsho/toggleterm.nvim',
    tag = '*',
    config = function()
      require('toggleterm').setup {
        open_mapping = '@@',
        direction = 'float',
        float_opts = {
          border = 'single',
        }
      }
    end
  }

  use {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    requires = {
      { 'nvim-lua/plenary.nvim' },
      { 'nvim-treesitter/nvim-treesitter' },
      { 'nvim-telescope/telescope-project.nvim' },
      { 'kyazdani42/nvim-web-devicons', opt = true },
    },
    config = function()
      require('telescope').setup {
        extensions = {
          project = {
            base_dirs = {
              '~/Projects',
              '~/.local/share',
              '~/ghq'
            }
          }
        }
      }
    end
  }

  use {
    'nvim-lualine/lualine.nvim',
    requires = {
      { 'RRethy/nvim-base16' },
      { 'kyazdani42/nvim-web-devicons', opt = true },
    },
    config = function()
      require('lualine').setup {
        options = {
          icons_enabled = true,
          -- theme = is_win and 'onedark' or 'solarized_dark',
          theme = 'base16',
          component_separators = '',
          section_separators = '',
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'filename' },
          lualine_c = {},
          lualine_x = { 'encoding', 'fileformat', 'filetype' },
          lualine_y = {},
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

  if packer_bootstrap then
    require('packer').sync()
  end

end,
config = {
  display = { open_fn = require('packer.util').float }
}}

-- plugins keymap

if not packer_bootstrap then

  if is_plugged('kommentary.nvim') then
    key('n', '--', '<Plug>kommentary_line_default', {})
    key('n', '-',  '<Plug>kommentary_motion_default', {})
    key('v', '-',  '<Plug>kommentary_visual_default<C-c>', {})
  end

  if is_plugged('alternate-toggler') then
    key('n', '$', ':<C-u>ToggleAlternate<Cr>', { noremap = true, silent = true })
  end

  if is_plugged('hop.nvim') then
    key('n', '<Space><Space>', ':<C-u>HopPattern<CR>', {})
  end

  if is_plugged('nvim-treehopper') then
    key('o', '<Space>', ':<C-u>lua require("tsht").nodes()<Cr>', { noremap = false, silent = true, })
    key('x', '<Space>', ':lua require("tsht").nodes()<Cr>', { noremap = true, silent = true, })
  end

  if is_plugged('telescope.nvim') then
    local pickers = {
      { key = 'b', is_ext = false, fn = function(x, y) x.buffers(y)     end },
      { key = 'c', is_ext = false, fn = function(x, y) x.colorscheme(y) end },
      { key = 'd', is_ext = false, fn = function(x, y) x.diagnostics(y) end },
      { key = 'f', is_ext = false, fn = function(x, y) x.find_files(y)  end },
      { key = 'g', is_ext = false, fn = function(x, y) x.git_files(y)   end },
      { key = 'j', is_ext = false, fn = function(x, y) x.current_buffer_fuzzy_find(y) end },
      { key = 'k', is_ext = false, fn = function(x, y) x.keymaps(y)     end },
      { key = 'l', is_ext = false, fn = function(x, y) x.filetypes(y) end },
      { key = 'm', is_ext = false, fn = function(x, y) x.oldfiles(y)    end },
      { key = 'p', is_ext = true,  fn = function(x, y) x.project.project(y) end },
      { key = 'q', is_ext = false, fn = function(x, y) x.quickfix(y) end },
      { key = 'y', is_ext = false, fn = function(x, y) x.registers(y) end },
    }
    for _, p in pairs(pickers) do
      local src = p.is_ext and require('telescope').extensions or require('telescope.builtin')
      local empty = {'', '', '', '', '', '', '', ''}
      key('n', '<Space>'..p.key, function()
        p.fn(src, require('telescope.themes').get_ivy {
          borderchars = {
            prompt =  empty,
            results = empty,
            preview = empty,
          }
        })
      end, { noremap = true })
    end
  end

  if is_plugged('nvim-base16') then
    local base16 = require('base16-colorscheme')
    local using_scheme = is_win and 'onedark' or 'solarized-dark'
    function postfix_color()
      -- overwrite colorscheme with:
      --   monotone: 00-07 (center: 3-4)
      --   red:      08   orange:   09   yellow:   0A
      --   green:    0B   cyan:     0C   blue:     0D
      --   magenta:  0E   brown:    0F
      local api = vim.api
      local colors = base16.colors
      local is_light = string.find(api.nvim_exec('color', true), "light")
      local fg = is_light and colors.base00 or colors.base07
      local bg = is_light and colors.base07 or colors.base00
      api.nvim_set_hl(0, 'VertSplit', { fg = colors.base01, bg = bg })
      -- overwrite colorscheme ... hop.nvim
      api.nvim_set_hl(0, 'HopNextKey',   { fg = colors.base0E, bold = true })
      api.nvim_set_hl(0, 'HopNextKey1',  { fg = colors.base0D, bold = true })
      api.nvim_set_hl(0, 'HopNextKey2',  { fg = bg, bold = false })
      api.nvim_set_hl(0, 'HopPreview',   { fg = colors.base00, bg = colors.base0A })
      api.nvim_set_hl(0, 'HopUnmatched', { link = 'Comment' })
      api.nvim_set_hl(0, 'HopCursor',    { link = 'Cursor' })
      -- overwrite colorscheme ... nvim-treesitter
      api.nvim_set_hl(0, 'TSField',          { link = 'TSVariable' })
      api.nvim_set_hl(0, 'TSParameter',      { link = 'TSVariable' })
      api.nvim_set_hl(0, 'TSException',      { link = 'TSConditional' })
      api.nvim_set_hl(0, 'TSConstructor',    { link = 'TSText' })
      api.nvim_set_hl(0, 'TSPunctDelimiter', { link = 'TSText' })
      api.nvim_set_hl(0, 'TSStringRegex',    { link = 'TSConstant' })
      -- overwrite colorscheme ... nvim-lspconfig
      api.nvim_set_hl(0, 'DiagnosticSignError', { fg = bg, bg = colors.base08, bold = true })
      api.nvim_set_hl(0, 'DiagnosticSignWarn',  { fg = colors.base09, bold = true })
      api.nvim_set_hl(0, 'DiagnosticSignHint',  { fg = colors.base03, bold = true })
      api.nvim_set_hl(0, 'DiagnosticSignInfo',  { fg = colors.base03, bold = true })
      -- overwrite colorscheme ... nvim-treehopper
      api.nvim_set_hl(0, 'TSNodeKey',  { fg = colors.base0B, bold = true })
    end
    api.nvim_create_augroup('base16_posthook', { clear = true })
    api.nvim_create_autocmd({ 'ColorScheme' }, {
      group = 'base16_posthook',
      callback = postfix_color,
    })
    base16.with_config { telescope = true }
    vim.cmd("color base16-"..using_scheme)
  end

end
