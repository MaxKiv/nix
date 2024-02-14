local map = vim.keymap.set

map("v", "<", "<gv", { desc = "reselect after indenting" })
map("v", ">", ">gv", { desc = "reselect after indenting" })

-- Paste over currently selected text without yanking it
map("v", "p", '"_dP', { desc = "keep paste buffer" })

-- Switch buffers
map("n", "<S-h>", ":bprevious<CR>", { desc = "previous buffer" })
map("n", "<S-l>", ":bnext<CR>", { desc = "next buffer" })

-- Move to next blank line without messing with jumplist
map("n", "<A-j>", "g'}", { desc = "paragraph jump  w/o jumplist" })
map("n", "<A-k>", "g'{", { desc = "paragraph jump  w/o jumplist" })

-- exit  terminal mode
vim.cmd([[:tnoremap <Esc> <C-\><C-n>]])
