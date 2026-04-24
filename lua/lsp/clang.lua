local M = {}

M.setup = function()
	local lspconfig = require("lspconfig")
	local capabilities = require('cmp_nvim_lsp').default_capabilities()

	lspconfig.clangd.setup {
		cmd = {
			"clangd",
			"--background-index",
			"-j=12",
			"--query-driver=/usr/bin/**/clang-*,/bin/clang,/bin/clang++,/usr/bin/gcc,/usr/bin/g++",
			"--clang-tidy",
			"--clang-tidy-checks=*",
			"--all-scopes-completion",
			"--cross-file-rename",
			"--completion-style=detailed",
			"--header-insertion-decorators",
			"--header-insertion=iwyu",
			"--pch-storage=memory",
		},
			capabilities = capabilities,
			filetypes = { "c", "cpp", "objc", "objcpp", "tpp" , "hpp"},
			root_dir = function(fname)
				local util = require("lspconfig.util")
				-- Il va chercher un Makefile, un .git, etc.
				-- S'il ne trouve RIEN, il prend le dossier du fichier actuel (dirname)
				return util.root_pattern("Makefile", ".git", "compile_commands.json")(fname) or util.path.dirname(fname)
				end,
				single_file_support = true,
			on_attach = function(_, bufnr)
				-- Utilise Espace + c + a
				M.new_keymap(bufnr, "n", "<leader>ca", M.quick_fix_first) 
				end,	}
				end

M.quick_fix_first = function()
	vim.lsp.buf.code_action()
end

M.new_keymap = function(bufnr, mode, shortcut, func)
	vim.api.nvim_buf_set_keymap(bufnr, mode, shortcut, "", {
			noremap = true,
			silent = true,
			callback = func
			})
end

return M
