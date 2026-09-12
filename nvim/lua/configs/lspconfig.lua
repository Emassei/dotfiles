-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

local nvlsp = require "nvchad.configs.lspconfig"

local servers = { "html", "cssls", "pyright", "ts_ls" }

-- Configure LSP servers using new vim.lsp.config API
for _, server in ipairs(servers) do
  vim.lsp.config(server, {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  })
end

-- Enable all configured servers
vim.lsp.enable(servers)
