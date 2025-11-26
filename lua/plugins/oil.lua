return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local oil = require("oil")

    oil.setup({
      default_file_explorer = true,
      view_options = {
        show_hidden = true, -- affiche les fichiers cachés
      },
      float = {
        padding = 2,
        max_width = 80,
        max_height = 20,
      },
      win_options = {
        signcolumn = "no",
      },
      experimental = {
        watch_for_changes = true,
      },
      keymaps = {
        ['-'] = { "<CMD>Oil<CR>", desc = "Open parent directory" },
        ['<C-h>'] = false, -- débind C-hjkl pour compatibilité tmux
        ['<C-j>'] = false,
        ['<C-k>'] = false,
        ['<C-l>'] = false,
        ['<C-p>'] = false, -- conflit avec telescope git file
      },
    })

    -- Map global pour ouvrir Oil
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
  end,
}

