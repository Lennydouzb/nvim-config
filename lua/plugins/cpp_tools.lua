return {
    "Badhi/nvim-treesitter-cpp-tools",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
        require("nt-cpp-tools").setup({
            preview = {
                quit = 'q',
                accept = '<CR>'
            },
            header_extension = 'hpp',
            source_extension = 'cpp',
        })

        vim.keymap.set("n", "<leader>cg", function()
            local cpp_file = vim.fn.expand('%:p:r') .. '.cpp'
            local hpp_name = vim.fn.expand('%:t')
            
            -- 1. Si le .cpp n'existe pas, on le crée
            if vim.fn.filereadable(cpp_file) == 0 then
                vim.fn.writefile({'#include "' .. hpp_name .. '"', '', ''}, cpp_file)
            end
            
            -- 2. On FORCE l'ouverture du .cpp pour que le plugin le voie
            -- (Ça t'ouvrira gentiment le fichier sur la droite)
            vim.cmd('vsplit ' .. cpp_file)
            vim.cmd('wincmd p') -- On remet le curseur sur le .hpp à gauche
            
            -- 3. On laisse 50 millisecondes à Neovim pour charger le buffer, puis on tire !
            vim.defer_fn(function()
                vim.cmd("TSCppDefineClassFunc")
            end, 50)
            
        end, { desc = "Générer l'implémentation C++" })
    end,
}
