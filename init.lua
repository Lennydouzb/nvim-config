-- ************************************************************************** --
--                                                                            --
--                                                        :::      ::::::::   --
--   init.lua                                           :+:      :+:    :+:   --
--                                                    +:+ +:+         +:+     --
--   By: babonnet <babonnet@42angouleme.fr>         +#+  +:+       +#+        --
--                                                +#+#+#+#+#+   +#+           --
--   Created: 2024/04/16 16:29:45 by babonnet          #+#    #+#             --
--   Updated: 2025/11/26 17:04:27 by ldesboui         ###   ########.fr       --
--                                                                            --
-- ************************************************************************** --

-- Get version table: {major, minor, patch}
local version = vim.version()

if version.major == 0 and version.minor < 9 then
  vim.notify(
    string.format(
      "⚠️ Your Neovim version is %d.%d.%d. This config requires at least 0.9.0.",
      version.major,
      version.minor,
      version.patch
    ),
    vim.log.levels.WARN
  )
  return  -- Stop config loading gracefully
else
	require('barnabait')
end
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
-- Ouvre NvimTree au démarrage
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    require("nvim-tree.api").tree.open()
  end
})
vim.cmd([[
  highlight NvimTreeFolderIcon guifg=#c678dd
  highlight NvimTreeFolderName guifg=#c678dd
  highlight NvimTreeOpenedFolderName guifg=#c678dd gui=bold
]])
vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    local tree_win = require("nvim-tree.api").tree.winid()
    if tree_win and vim.api.nvim_win_is_valid(tree_win) then
      vim.api.nvim_win_close(tree_win, true)
    end
  end
})

