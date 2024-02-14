local opt = vim.opt

-- General
vim.g.cmdheigth = 2
opt.errorbells = false
opt.wrap = false
opt.updatetime = 100
opt.termguicolors = true
opt.clipboard = "unnamedplus"
opt.undodir = (os.getenv("HOME") or "") .. "/.vim/undodir"
opt.undofile = true
opt.timeoutlen = 400 -- time to wait for a mapped sequence to complete (in milliseconds)
opt.ttimeoutlen = 0  -- Time in milliseconds to wait for a key code sequence to complete
opt.showmode = false -- Dont show mode since we have a statusline
opt.cursorline = true
opt.grepprg = "rg --vimgrep"
opt.list = true -- Show some invisible characters (tabs...

-- Searching
opt.smartcase = true
opt.ignorecase = true
opt.incsearch = true
opt.hlsearch = false

-- Scrolling
opt.scrolloff = 999 -- Cursor is always centered pew pew

-- Set window title to current file
opt.title = true

-- Text behaviour (dinhmai74 dotfiles)
-- o.formatoptions = o.formatoptions
--                    + 't'    -- auto-wrap text using textwidth
--                    + 'c'    -- auto-wrap comments using textwidth
--                    + 'r'    -- auto insert comment leader on pressing enter
--                    - 'o'    -- don't insert comment leader on pressing o
--                    + 'q'    -- format comments with gq
--                    - 'a'    -- don't autoformat the paragraphs (use some formatter instead)
--                    + 'n'    -- autoformat numbered list
--                    - '2'    -- I am a programmer and not a writer
--                    + 'j'    -- Join comments smartly
-- See :help vim.opt
opt.formatoptions = 'tcrqnj'
-- opt.formatoptions:append { "t", "c", "r", "q", "n", "j" }
-- opt.formatoptions:remove { "o", "a", "2"}
opt.joinspaces = false

-- Gutter
opt.relativenumber = true
opt.nu = true
opt.signcolumn = "yes"
vim.cmd([[highlight clear SignColumn]])

-- Tabs
opt.tabstop = 8
opt.shiftwidth = 8
opt.expandtab = true
opt.smartindent = true

-- Back to the 80s
opt.colorcolumn = "80"

-- Please no
opt.swapfile = false
opt.backup = false
opt.modelines = 0

-- Neovide
if vim.g.neovide then
  vim.opt.guifont = { "Hasklug NFM", ":10" }
  vim.g.neovide_scale_factor = 0.8
  vim.g.neovide_scroll_animation_length = 0.15
  vim.g.neovide_cursor_animation_length = 0.08
  vim.g.neovide_cursor_trail_size = 0.4
  vim.g.neovide_profiler = false
end
