local api = vim.api

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Remove trailing whitespace on save
local TrimWhiteSpaceGrp = api.nvim_create_augroup(
  "TrimWhiteSpaceGrp", { clear = true })
api.nvim_create_autocmd("BufWritePre", {
  pattern = { "!*.md" },
  command = [[:%s/\s\+$//e]],
  group = TrimWhiteSpaceGrp,
})

-- Reset formatoptions after opening a buffer, make sure no auto comment on 'o'
api.nvim_create_autocmd(
  { "BufReadPost", "BufEnter" },
  { command = [[set formatoptions=tcrqnj]] }
)

-- go to last loc when opening a buffer
api.nvim_create_autocmd(
  "BufReadPost",
  { command = [[if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g`\"" | endif]] }
)

-- windows to close with "q"
api.nvim_create_autocmd("FileType", {
  pattern = { "help", "startuptime", "qf", "fugitive", "null-ls-info", "dap-float" },
  command = [[nnoremap <buffer><silent> q :close<CR>]],
})
api.nvim_create_autocmd("FileType", { pattern = "man", command = [[nnoremap <buffer><silent> q :quit<CR>]] })

-- Enable spell checking for certain file types
api.nvim_create_autocmd(
  { "BufRead", "BufNewFile" },
  {
    pattern = { "*.txt", "*.md", "*.tex" },
    callback = function()
      vim.opt.spell = true
      vim.opt.spelllang = "en,nl"
    end,
  }
)

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, { command = "checktime" })

-- Wrap and spell for markdown and git commits
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.textwidth = 80
  end,
})

-- Set filetype groovy for JenkinsFiles
vim.api.nvim_exec([[augroup jenk_ft
  au!
  autocmd BufNewFile,BufRead JenkinsFile   set filetype=groovy
augroup END]], false)

-- set formatprog = rustfmt when entering rust buffers
api.nvim_create_autocmd("BufEnter", { pattern = "*.rs", callback = function ()
  vim.cmd([[set fp=rustfmt]])
end})
api.nvim_create_autocmd("BufLeave", { pattern = "*.rs", callback = function ()
  vim.cmd([[set fp=]])
end})
-- api.nvim_create_autocmd("BufEnter", { pattern = "*.rs", command = [[set fp=rustfmt]] })
-- api.nvim_create_autocmd("BufLeave", { pattern = "*.rs", command = [[set fp=]] })
