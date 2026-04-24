return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ':TSUpdate', -- Use `build` instead of `run` for Lazy.nvim
        config = function()
            require('nvim-treesitter').setup {
                ensure_installed = { "lua", "c", "markdown", "cpp"},
				auto_install = true,
                highlight = {
                    enable = true,
                    use_languagetree = true,
                },
                indent = { enable = true },
            }
        end,
    },
    {
        "nvim-treesitter/playground",
        cmd = "TSPlaygroundToggle",
        config = function()
        end,
    }
}
