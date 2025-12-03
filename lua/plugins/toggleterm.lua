return {
  'akinsho/toggleterm.nvim',
  version = "*",
  config = function()
    require("toggleterm").setup({
      size = 20,
      open_mapping = [[<c-\>]], -- Raccourci global pour ouvrir/fermer
      direction = 'float',      -- 'float' pour qu'il "flotte" au dessus de l'éditeur
      float_opts = {
        border = 'curved',
      },
    })
  end
}
