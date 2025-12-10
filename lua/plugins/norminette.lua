return {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local null_ls = require("null-ls")

        -- 1. Configuration Norminette
        local norminette = {
            method = null_ls.methods.DIAGNOSTICS,
            filetypes = { "c", "h" },
            generator = null_ls.generator({
                command = "norminette",
                args = { "$FILENAME" },
                to_stdin = false,
                format = "line",
                check_exit_code = function(code)
                    return code <= 1
                end,
                on_output = function(line, params)
                    local row, col, msg = line:match("%(line:%s*(%d+),%s*col:%s*(%d+)%):%s*(.*)")
                    if row then
                        return {
                            row = tonumber(row),
                            col = tonumber(col),
                            message = msg,
                            severity = vim.diagnostic.severity.ERROR,
                            source = "Norminette",
                        }
                    end
                end,
            }),
        }

        null_ls.setup({ sources = { norminette } })

        -- 2. Configuration visuelle de base
        vim.diagnostic.config({
            virtual_text = true,
            signs = true,
            underline = true,
            update_in_insert = false, -- Empêche la mise à jour, mais ne cache pas
        })

        -- 3. LE TRUC MAGIQUE : Cacher en insertion, Montrer en normal
        
        -- Quand tu entres en mode Insertion (i) -> On cache tout
        vim.api.nvim_create_autocmd("InsertEnter", {
            pattern = "*",
            callback = function()
                vim.diagnostic.config({
                    virtual_text = false,
                    signs = false,
                    underline = false,
                })
            end,
        })

        -- Quand tu sors du mode Insertion (Esc) -> On réactive tout
        vim.api.nvim_create_autocmd("InsertLeave", {
            pattern = "*",
            callback = function()
                vim.diagnostic.config({
                    virtual_text = true,
                    signs = true,
                    underline = true,
                })
            end,
        })
    end,
}
