return {
  'akinsho/bufferline.nvim',
  version = "*",
  dependencies = 'nvim-tree/nvim-web-devicons', -- Pour les icônes de fichiers
  config = function()
    require("bufferline").setup{
      options = {
        mode = "buffers", -- Affiche les onglets comme dans VS Code
        separator_style = "slant", -- Style des onglets (slant, slope, thick, thin)
        diagnostics = "nvim_lsp", -- Affiche les erreurs directement dans l'onglet
        
        -- Cette partie est IMPORTANTE pour ton arborescence :
        -- Elle décale les onglets pour ne pas couvrir ton explorateur de fichiers
        offsets = {
            {
                filetype = "NvimTree", -- Si tu utilises NvimTree
                text = "File Explorer",
                highlight = "Directory",
                separator = true
            },
            {
                filetype = "neo-tree", -- Si tu utilises Neo-tree
                text = "File Explorer",
                highlight = "Directory",
                separator = true
            }
        }
      }
    }
  end,
}
