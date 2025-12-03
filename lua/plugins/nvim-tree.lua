return {
  "nvim-tree/nvim-tree.lua",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "akinsho/toggleterm.nvim", -- J'ajoute ToggleTerm ici pour être sûr qu'il soit là
  },
  config = function()
    -- 1. Configuration de ToggleTerm (si pas déjà fait ailleurs)
    require("toggleterm").setup({
      size = 20,
      open_mapping = [[<c-\>]],
      direction = 'float', -- 'float' pour superposition, ou 'tab' pour plein écran
      float_opts = { border = 'curved' }
    })

    -- 2. Fonction pour attacher les raccourcis à nvim-tree
    local function my_on_attach(bufnr)
      local api = require "nvim-tree.api"

      local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      -- Charge les raccourcis par défaut (o pour ouvrir, a pour créer, etc.)
      api.config.mappings.default_on_attach(bufnr)

      -- --- TA FONCTION PERSO ---
      local function open_term_in_dir()
        local node = api.tree.get_node_under_cursor()
        local path = node.absolute_path

        -- Si on est sur un fichier, on prend le dossier parent
        if node.type == 'file' then
          path = vim.fn.fnamemodify(path, ":h")
        end

        -- Ouvre le terminal dans ce dossier
        -- Change 'float' par 'tab' si tu veux que ça remplace tout l'écran
        vim.cmd("ToggleTerm direction=float dir=" .. path)
      end

      -- On lie la touche "T" (Maj + t) à cette action
      vim.keymap.set('n', 't', open_term_in_dir, opts('Ouvrir Terminal Ici'))
    end

    -- 3. Configuration de Nvim-tree
    require("nvim-tree").setup({
      on_attach = my_on_attach, -- IMPORTANT : on lie la fonction ici
      view = {
        width = 30,
        side = "left",
      },
      renderer = {
        highlight_git = true,
        highlight_opened_files = "all",
      },
      actions = {
        open_file = {
          quit_on_open = false,
        },
      },
    })
  end,
}
