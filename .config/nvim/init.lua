-- ============================================================================
-- Modern Neovim Configuration (init.lua) - Git Submodule Version
-- Using native Neovim package manager (no vim-plug needed)
-- ============================================================================

-- Plugins are managed via git submodules in:
--   ~/.config/nvim/pack/plugins/start/    (auto-loaded plugins)
--   ~/.config/nvim/pack/plugins/opt/      (manually loaded plugins)

-- ============================================================================
-- General Settings
-- ============================================================================

-- Leader key
vim.g.mapleader = ','

-- UI settings
vim.opt.termguicolors = true          -- Enable true-color UI
vim.opt.cursorline = true             -- Highlight current line
vim.opt.number = false                -- No line numbers by default
vim.opt.relativenumber = false
vim.opt.signcolumn = 'yes'            -- Always show sign column
vim.opt.showmode = false              -- Hide mode (shown in lualine)
vim.opt.wrap = false                  -- Don't wrap lines

-- Whitespace visualization
vim.opt.list = true
vim.opt.listchars = { tab = '▷⋅', trail = '⋅', nbsp = '⋅' }

-- Split behavior
vim.opt.splitbelow = true             -- Horizontal splits below
vim.opt.splitright = true             -- Vertical splits right

-- Buffer management
vim.opt.hidden = true                 -- Allow switching buffers without saving

-- Completion menu
vim.opt.completeopt = { 'menu', 'menuone', 'noselect' }
vim.opt.wildmode = { 'longest:full', 'full' }

-- Search settings
vim.opt.hlsearch = true               -- Highlight search results
vim.opt.incsearch = true              -- Incremental search
vim.opt.ignorecase = true             -- Case-insensitive search
vim.opt.smartcase = true              -- Case-sensitive if uppercase present

-- Indentation
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false             -- Keep literal tabs

-- File management
vim.opt.backup = true
vim.opt.backupdir = vim.fn.stdpath('config') .. '/backup//'
vim.opt.directory = vim.fn.stdpath('config') .. '/swap//'
vim.opt.undofile = true
vim.opt.undodir = vim.fn.stdpath('config') .. '/undo//'
vim.opt.undolevels = 10000

-- Performance
vim.opt.lazyredraw = true             -- Don't redraw during macros
vim.opt.updatetime = 300              -- Faster completion

-- Scrolling
vim.opt.scrolloff = 8                 -- Keep 8 lines visible above/below cursor
vim.opt.sidescrolloff = 8

-- Mouse support
vim.opt.mouse = 'a'                   -- Enable mouse support

-- ============================================================================
-- Key Mappings
-- ============================================================================

-- NvimTree toggle
vim.keymap.set('n', '<leader>n', ':NvimTreeToggle<CR>', { noremap = true, silent = true })

-- Buffer navigation
vim.keymap.set('n', '<F5>', ':buffers<CR>:buffer<Space>', { noremap = true })

-- Use Q for formatting
vim.keymap.set('n', 'Q', 'gq', { noremap = true })

-- Telescope keymaps
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { noremap = true, silent = true })

-- ============================================================================
-- Auto Commands
-- ============================================================================

-- Trim trailing whitespace on save
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*',
  callback = function()
    local save_cursor = vim.fn.getpos('.')
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setpos('.', save_cursor)
  end,
})

-- ============================================================================
-- Plugin Configurations
-- ============================================================================
-- Note: Plugins are loaded automatically from pack/plugins/start/

-- Check if plugins are installed
local function plugin_exists(plugin_path)
  local full_path = vim.fn.stdpath('config') .. '/pack/plugins/start/' .. plugin_path
  return vim.fn.isdirectory(full_path) == 1
end

-- Lualine setup
if plugin_exists('lualine.nvim') then
  require('lualine').setup({
    options = {
      theme = 'auto',
      icons_enabled = true,
      component_separators = { left = '|', right = '|' },
      section_separators = { left = '', right = '' },
    },
    sections = {
      lualine_a = {'mode'},
      lualine_b = {'branch', 'diff', 'diagnostics'},
      lualine_c = {'filename'},
      lualine_x = {'encoding', 'fileformat', 'filetype'},
      lualine_y = {'progress'},
      lualine_z = {'location'}
    },
    tabline = {
      lualine_a = {'buffers'},
      lualine_z = {'tabs'}
    },
  })
end

-- NvimTree setup
if plugin_exists('nvim-tree.lua') then
  require('nvim-tree').setup({
    sort_by = 'case_sensitive',
    view = {
      width = 30,
    },
    renderer = {
      group_empty = true,
    },
    filters = {
      custom = { '.swp', '.pyc' },
    },
    git = {
      enable = true,
      ignore = false,
    },
  })
end

-- Gitsigns setup
if plugin_exists('gitsigns.nvim') then
  require('gitsigns').setup({
    signs = {
      add          = { text = '+' },
      change       = { text = '~' },
      delete       = { text = '_' },
      topdelete    = { text = '‾' },
      changedelete = { text = '~' },
    },
  })
end

-- Telescope setup
if plugin_exists('telescope.nvim') then
  require('telescope').setup({
    defaults = {
      file_ignore_patterns = { 'node_modules', '.git/', '*.pyc' },
      mappings = {
        i = {
          ['<C-j>'] = 'move_selection_next',
          ['<C-k>'] = 'move_selection_previous',
        },
      },
    },
  })

  -- Load fzf extension if available
  if plugin_exists('telescope-fzf-native.nvim') then
    pcall(require('telescope').load_extension, 'fzf')
  end
end

-- Treesitter setup (OPTIONAL - archived, LSP provides syntax highlighting)
-- If you want treesitter, manually add: git submodule add https://github.com/nvim-treesitter/nvim-treesitter pack/plugins/start/nvim-treesitter
if plugin_exists('nvim-treesitter') then
  local ok, treesitter = pcall(require, 'nvim-treesitter.configs')
  if ok then
    treesitter.setup({
      ensure_installed = { 'lua', 'vim', 'vimdoc', 'python', 'javascript', 'typescript', 'bash', 'json', 'yaml' },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
      },
    })
  end
end

-- Enable built-in syntax highlighting (fallback if no treesitter)
vim.cmd('syntax on')

-- Indent-blankline setup
if plugin_exists('indent-blankline.nvim') then
  require('ibl').setup({
    indent = {
      char = '│',
    },
    scope = {
      enabled = true,
    },
  })
end

-- ============================================================================
-- LSP Configuration
-- ============================================================================

if plugin_exists('mason.nvim') then
  -- Mason setup (LSP installer)
  require('mason').setup({
    ui = {
      icons = {
        package_installed = '✓',
        package_pending = '➜',
        package_uninstalled = '✗',
      },
    },
  })

  -- Note: Install LSP servers manually via :Mason
  -- Recommended: lua_ls, pyright, typescript-language-server
end

-- LSP keymaps
local on_attach = function(client, bufnr)
  local opts = { noremap = true, silent = true, buffer = bufnr }

  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
  vim.keymap.set('n', '<leader>f', function() vim.lsp.buf.format({ async = true }) end, opts)
end

-- Configure LSP servers using modern vim.lsp.config API
local capabilities = vim.lsp.protocol.make_client_capabilities()

if plugin_exists('cmp-nvim-lsp') then
  capabilities = require('cmp_nvim_lsp').default_capabilities()
end

-- Lua Language Server
vim.lsp.config.lua_ls = {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml', '.git' },
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
}

-- Python Language Server
vim.lsp.config.pyright = {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', 'pyrightconfig.json', '.git' },
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'workspace',
      },
    },
  },
}

-- TypeScript/JavaScript Language Server
vim.lsp.config.ts_ls = {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' },
  root_markers = { 'tsconfig.json', 'jsconfig.json', 'package.json', '.git' },
}

-- Auto-enable LSP servers when opening relevant files
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'lua', 'python', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' },
  callback = function(args)
    local server_name = nil
    if args.match == 'lua' then
      server_name = 'lua_ls'
    elseif args.match == 'python' then
      server_name = 'pyright'
    elseif vim.tbl_contains({ 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }, args.match) then
      server_name = 'ts_ls'
    end

    if server_name then
      vim.lsp.enable(server_name)
      -- Apply on_attach callback
      local clients = vim.lsp.get_clients({ bufnr = args.buf, name = server_name })
      for _, client in ipairs(clients) do
        on_attach(client, args.buf)
      end
    end
  end,
})

-- ============================================================================
-- Completion Configuration (nvim-cmp)
-- ============================================================================

if plugin_exists('nvim-cmp') then
  local cmp = require('cmp')
  local luasnip_available = plugin_exists('LuaSnip')
  local luasnip = luasnip_available and require('luasnip') or nil

  cmp.setup({
    snippet = {
      expand = function(args)
        if luasnip_available then
          luasnip.lsp_expand(args.body)
        end
      end,
    },
    mapping = cmp.mapping.preset.insert({
      ['<C-b>'] = cmp.mapping.scroll_docs(-4),
      ['<C-f>'] = cmp.mapping.scroll_docs(4),
      ['<C-Space>'] = cmp.mapping.complete(),
      ['<C-e>'] = cmp.mapping.abort(),
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
      ['<Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip_available and luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { 'i', 's' }),
      ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip_available and luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { 'i', 's' }),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' },
      { name = 'buffer' },
      { name = 'path' },
    }),
  })
end

-- ============================================================================
-- Linting Configuration (nvim-lint)
-- ============================================================================

if plugin_exists('nvim-lint') then
  require('lint').linters_by_ft = {
    python = { 'flake8' },
    javascript = { 'eslint' },
    typescript = { 'eslint' },
    -- Add more linters as needed
  }

  -- Auto-lint on save and text changed
  vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
    callback = function()
      require('lint').try_lint()
    end,
  })
end

-- ============================================================================
-- Installation Instructions
-- ============================================================================

--[[


# Build telescope-fzf-native
cd ~/.config/nvim/pack/plugins/start/telescope-fzf-native.nvim
make

# REMOVE A PLUGIN:
git submodule deinit pack/plugins/start/plugin-name
git rm pack/plugins/start/plugin-name
git commit -m "Remove plugin-name"

]]

-- ============================================================================
-- Key Mappings Summary
-- ============================================================================

--[[
  <leader>n  - Toggle NvimTree
  <leader>ff - Find files (Telescope)
  <leader>fg - Live grep (Telescope)
  <leader>fb - Find buffers (Telescope)
  <leader>fh - Help tags (Telescope)
  gd         - Go to definition (LSP)
  gD         - Go to declaration (LSP)
  K          - Hover documentation (LSP)
  gi         - Go to implementation (LSP)
  gr         - Find references (LSP)
  <leader>ca - Code actions (LSP)
  <leader>rn - Rename symbol (LSP)
  <leader>f  - Format document (LSP)
  <C-k>      - Signature help (LSP)
  <F5>       - List and switch buffers
]]
