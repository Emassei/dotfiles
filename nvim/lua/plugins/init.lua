return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = require "configs.conform",
  },

  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    opts = {
      window = {
        width = 80,
        options = {
          number = false,
          relativenumber = false,
          cursorline = false,
          linebreak = true,
          wrap = true,
        },
      },
      plugins = {
        options = {
          enabled = true,
          ruler = true,
        },
        gitsigns = { enabled = false },
        tmux = { enabled = true },
      },
      on_open = function()
        vim.o.ruler = true
        vim.o.rulerformat = "%l/%L %P"
        pcall(vim.cmd, "IBLDisable")
      end,
      on_close = function()
        pcall(vim.cmd, "IBLEnable")
      end,
    },
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {},
  },

  {
    "nvim-treesitter/nvim-treesitter",
    -- The frozen master branch ships markdown queries that crash nvim 0.12's
    -- built-in markdown highlighter ("attempt to call method 'range'").
    -- Delete them so nvim falls back to its own bundled queries; re-runs
    -- after every plugin update in case they come back.
    init = function()
      for _, lang in ipairs { "markdown", "markdown_inline" } do
        local q = vim.fn.stdpath "data" .. "/lazy/nvim-treesitter/queries/" .. lang
        if vim.uv.fs_stat(q) then
          vim.fn.delete(q, "rf")
        end
      end
    end,
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "python",
        "javascript",
        "typescript",
      },
    },
  },
}
