vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

-- Let nvim auto-detect the clipboard provider (xclip is installed).

vim.schedule(function()
  require "mappings"
end)

-- Helper function to find the project root
local function find_project_root()
  local root_files = { ".git", "pyproject.toml", "package.json" }
  local cwd = vim.fn.getcwd()
  for _, filename in ipairs(root_files) do
    if vim.fn.glob(cwd .. "/" .. filename) ~= "" then
      return cwd
    end
  end
  return nil
end

-- Auto-command to format files on save if project configs exist
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.py", "*.js", "*.ts", "*.jsx", "*.tsx" },
  callback = function()
    local project_root = find_project_root()
    if project_root then
      local cmd
      if vim.bo.filetype == "python" then
        cmd = string.format("black --config %s/pyproject.toml %%", project_root)
      else
        cmd = string.format("prettier --config %s/.prettierrc --write %%", project_root)
      end
      vim.fn.system(cmd)
    end
  end,
})
