-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Leader key (must be before plugins)
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- ── Core settings ─────────────────────────────────────────────────────────────
local opt = vim.opt
opt.number         = true
opt.relativenumber = false
opt.expandtab      = true
opt.shiftwidth     = 2
opt.tabstop        = 2
opt.smartindent    = true
opt.wrap           = false
opt.linebreak      = true   -- wrap at word boundaries when wrap is on
opt.scrolloff      = 8
opt.sidescrolloff  = 8
opt.hlsearch       = true
opt.incsearch      = true
opt.ignorecase     = true
opt.smartcase      = true
opt.termguicolors  = true
opt.updatetime     = 250
opt.signcolumn     = "yes"
opt.clipboard      = "unnamedplus"
opt.undofile       = true   -- persistent undo
opt.conceallevel   = 2      -- hide LaTeX markup for cleaner editing
opt.spelllang      = "en_us"

-- Soft-wrap lines for prose / LaTeX writing
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "plaintex", "context" },
  callback = function()
    vim.opt_local.wrap         = true
    vim.opt_local.spell        = true
    vim.opt_local.textwidth    = 0
    vim.opt_local.conceallevel = 0
    vim.opt_local.number       = true
    vim.opt_local.autoindent   = false
    vim.opt_local.smartindent  = false
    vim.opt_local.indentexpr   = ""
  end,
})

-- ── Plugins ───────────────────────────────────────────────────────────────────
require("lazy").setup({

  -- Colour scheme
  {
    "rebelot/kanagawa.nvim",
    lazy = false, priority = 1000,
    config = function() vim.cmd("colorscheme kanagawa") end,
  },

  -- LaTeX integration
  {
    "lervag/vimtex",
    lazy = false,
    init = function()
      vim.g.vimtex_view_method        = "zathura"   -- change to "skim" on macOS
      vim.g.vimtex_compiler_method    = "latexmk"
      vim.g.vimtex_compiler_latexmk   = {
        aux_dir  = ".aux",
        out_dir  = ".out",
        callback = 1,
        continuous = 1,
        executable = "latexmk",
        options  = {
          "-pdf",
          "-shell-escape",
          "-verbose",
          "-file-line-error",
          "-synctex=1",
          "-interaction=nonstopmode",
        },
      }
      vim.g.vimtex_syntax_enabled     = 1
      vim.g.vimtex_fold_enabled       = 0
      vim.g.vimtex_indent_enabled     = 0
      vim.g.vimtex_view_automatic     = 0
      vim.g.vimtex_quickfix_mode      = 0
      vim.g.vimtex_toc_config         = { split_pos = "vert rightbelow", split_width = 40 }
      vim.g.tex_flavor                = "latex"
    end,
  },

  -- Snippet engine (UltiSnips)
  {
    "SirVer/ultisnips",
    dependencies = { "honza/vim-snippets" },
    init = function()
      vim.g.UltiSnipsExpandTrigger       = "<tab>"
      vim.g.UltiSnipsJumpForwardTrigger  = "<tab>"
      vim.g.UltiSnipsJumpBackwardTrigger = "<s-tab>"
      vim.g.UltiSnipsEditSplit           = "vertical"
      -- Look for snippets in nvim config dir first
      vim.g.UltiSnipsSnippetDirectories  = { vim.fn.stdpath("config") .. "/UltiSnips", "UltiSnips" }
    end,
  },

  -- Completion engine
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp",
      "quangnguyen30192/cmp-nvim-ultisnips",
      "micangl/cmp-vimtex",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          expand = function(args) vim.fn["UltiSnips#Anon"](args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"]   = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]   = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]   = cmp.mapping.abort(),
          ["<CR>"]    = cmp.mapping.confirm({ select = false }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "ultisnips" },
          { name = "vimtex" },
        }, {
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function() require("nvim-tree").setup() end,
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function() require("telescope").setup() end,
  },

  -- Status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({ options = { theme = "kanagawa" } })
    end,
  },

  -- Treesitter (parser installation; highlighting via neovim's built-in engine)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      -- nvim-treesitter 1.0+ removed the configs module; use install API directly
      vim.schedule(function()
        require("nvim-treesitter.install").install(
          { "latex", "lua", "python", "bash", "markdown" },
          { skip_installed = true }
        )
      end)
    end,
  },

  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function() require("nvim-autopairs").setup() end,
  },

  -- Surround
  { "kylechui/nvim-surround", event = "VeryLazy",
    config = function() require("nvim-surround").setup() end },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    config = function() require("gitsigns").setup() end,
  },

  -- Which-key (discoverable keymaps)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function() require("which-key").setup() end,
  },

}, {
  ui = { border = "rounded" },
})

-- ── Key mappings ──────────────────────────────────────────────────────────────
local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

-- Auto-save on leaving insert mode or when focus is lost
vim.api.nvim_create_autocmd({ "InsertLeave", "FocusLost", "BufLeave" }, {
  callback = function()
    if vim.bo.modified and vim.bo.buftype == "" and vim.fn.expand("%") ~= "" then
      vim.cmd("silent! write")
    end
  end,
})

-- General
map("n", "<leader>e",  ":NvimTreeToggle<CR>",                  "File explorer")
map("n", "<C-f>",      "/",                                    "Search in file")
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>",        "Find files")
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>",         "Live grep")
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>",           "Buffers")
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>",         "Help")
map("n", "<Esc>",      ":noh<CR>",                             "Clear search highlight")

-- VimTeX
map("n", "<localleader>ll", "<plug>(vimtex-compile)",          "Compile LaTeX")
map("n", "<localleader>lv", "<plug>(vimtex-view)",             "View PDF")
map("n", "<localleader>lk", "<plug>(vimtex-stop)",             "Stop compiler")
map("n", "<localleader>lc", "<plug>(vimtex-clean)",            "Clean aux files")
map("n", "<localleader>lt", "<plug>(vimtex-toc-open)",         "Open TOC")
map("n", "<localleader>le", "<plug>(vimtex-errors)",           "Show errors")
map("n", "<localleader>li", "<plug>(vimtex-info)",             "VimTeX info")

-- UltiSnips
map("n", "<leader>us", ":UltiSnipsEdit<CR>",                   "Edit snippets")
