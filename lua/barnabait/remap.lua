vim.g.mapleader = ' '

local function goto_definition()
	vim.lsp.buf.definition()
	vim.cmd('normal! zz')
end

vim.keymap.set("n", "<leader>gd", goto_definition)
vim.keymap.set("n", "<leader>di", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>fc", vim.lsp.buf.format)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("x", "<leader>p", [["_dP]])

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

vim.api.nvim_create_user_command('W', 'w', {})

-- =========================================================
-- GÉNÉRATEUR 42 INDESTRUCTIBLE (Zéro Plugin)
-- =========================================================
vim.api.nvim_create_user_command("Class42", function(opts)
    -- Récupère le nom de la classe passé en argument
    local class_name = opts.args
    if class_name == nil or class_name == "" then
        class_name = vim.fn.input("Nom de la classe 42 : ")
    end
    if class_name == "" then return end

    local hpp_file = class_name .. ".hpp"
    local cpp_file = class_name .. ".cpp"

    -- Template du HPP
    local hpp_content = {
        "#pragma once",
        "",
        "#include <iostream>",
        "#include <string>",
        "",
        "class " .. class_name .. " {",
        "    private:",
        "        ",
        "    public:",
        "        " .. class_name .. "();",
        "        " .. class_name .. "(const " .. class_name .. "& other);",
        "        " .. class_name .. "& operator=(const " .. class_name .. "& other);",
        "        ~" .. class_name .. "();",
        "};"
    }

    -- Template du CPP
    local cpp_content = {
        '#include "' .. class_name .. '.hpp"',
        "",
        class_name .. "::" .. class_name .. "() {",
        '    std::cout << "' .. class_name .. ' default constructor called" << std::endl;',
        "}",
        "",
        class_name .. "::" .. class_name .. "(const " .. class_name .. "& other) {",
        '    std::cout << "' .. class_name .. ' copy constructor called" << std::endl;',
        "    *this = other;",
        "}",
        "",
        class_name .. "& " .. class_name .. "::operator=(const " .. class_name .. "& other) {",
        '    std::cout << "' .. class_name .. ' assignment operator called" << std::endl;',
        "    if (this != &other) {",
        "        // copy attributes",
        "    }",
        "    return *this;",
        "}",
        "",
        class_name .. "::~" .. class_name .. "() {",
        '    std::cout << "' .. class_name .. ' destructor called" << std::endl;',
        "}"
    }

    -- Écriture brute sur le disque dur
    vim.fn.writefile(hpp_content, hpp_file)
    vim.fn.writefile(cpp_content, cpp_file)

    -- Ouvre les deux fichiers côte à côte
    vim.cmd("edit " .. hpp_file)
    vim.cmd("vsplit " .. cpp_file)
    
    print("✨ Forme canonique de " .. class_name .. " générée avec succès !")
end, { nargs = "?" })

-- On garde ton raccourci préféré pour lancer la commande !
vim.keymap.set("n", "<leader>cg", ":Class42<CR>", { desc = "Générer Classe 42" })

