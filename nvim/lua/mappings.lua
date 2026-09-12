require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- Toggle statusline
map("n", "<leader>ts", function()
  if vim.o.laststatus == 0 then
    vim.o.laststatus = 3
  else
    vim.o.laststatus = 0
  end
end, { desc = "Toggle statusline" })

-- Toggle line wrap (long markdown table rows misalign when wrapped)
map("n", "<leader>tw", "<cmd>set wrap!<cr>", { desc = "Toggle line wrap" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
