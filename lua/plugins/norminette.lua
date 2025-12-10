return {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        local null_ls = require("null-ls")        
        -- Configuration personnalisée pour lire la sortie de la Norminette
        local norminette = {
            method = null_ls.methods.DIAGNOSTICS,
            filetypes = { "c", "h" },
            generator = null_ls.generator({
                command = "norminette",
                args = { "$FILENAME" },
                to_stdin = false,
                format = "line",
                check_exit_code = function(code)
                    return code <= 1 -- La norminette renvoie 1 si erreur, 0 si ok
                end,
                on_output = function(line, params)
                    -- Analyse de la ligne renvoyée par la norminette
                    -- Format typique : "Error: TYPE (line: 10, col: 5): message"
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

        null_ls.setup({
            sources = {
                norminette,
            },
        })
    end,
}
