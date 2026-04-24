return {
    {
        "Badhi/nvim-treesitter-cpp-tools",
        enabled = false,
    },

    {
        dir = vim.fn.stdpath("config"),
        name = "cpp-impl-generator",
        lazy = false,
        config = function()

            -- -------------------------------------------------------
            -- Parse le .hpp et retourne une liste de :
            --   { scope = "Outer::Inner", ret = "void", name = "foo", args = "(int x)" }
            -- Gère les classes imbriquées.
            -- -------------------------------------------------------
            local function parse_hpp(lines)
                local results = {}

                -- Stack des classes ouvertes : { name, brace_depth_at_open }
                local class_stack = {}
                local brace_depth = 0

                for _, line in ipairs(lines) do
                    local trimmed = line:match("^%s*(.-)%s*$")

                    -- Détecte ouverture de classe/struct
                    local class_name = trimmed:match("^class%s+([%w_]+)") or
                                       trimmed:match("^struct%s+([%w_]+)")

                    -- Compte les { et } sur la ligne AVANT de traiter les déclarations
                    local open_count  = select(2, trimmed:gsub("{", ""))
                    local close_count = select(2, trimmed:gsub("}", ""))

                    if class_name and trimmed:match("{") then
                        -- Classe ouverte sur la même ligne
                        brace_depth = brace_depth + open_count - close_count
                        table.insert(class_stack, { name = class_name, depth = brace_depth })
                    elseif class_name then
                        -- Classe déclarée sans { encore (on l'enregistre en attente)
                        table.insert(class_stack, { name = class_name, depth = nil, pending = true })
                    elseif trimmed:match("^{") and #class_stack > 0 then
                        local top = class_stack[#class_stack]
                        if top.pending then
                            brace_depth = brace_depth + open_count - close_count
                            top.depth   = brace_depth
                            top.pending = false
                        else
                            brace_depth = brace_depth + open_count - close_count
                        end
                    else
                        brace_depth = brace_depth + open_count - close_count
                    end

                    -- Dépile les classes dont on vient de fermer l'accolade
                    while #class_stack > 0 do
                        local top = class_stack[#class_stack]
                        if top.depth and brace_depth < top.depth then
                            table.remove(class_stack)
                        else
                            break
                        end
                    end

                    -- On ne traite les déclarations que si on est dans au moins une classe
                    if #class_stack == 0 then goto continue end

                    -- Ignore les lignes sans intérêt
                    if not trimmed:match(";$")              then goto continue end
                    if trimmed:match("^//")                 then goto continue end
                    if trimmed:match("^#")                  then goto continue end
                    if trimmed:match("^class%s")            then goto continue end
                    if trimmed:match("^struct%s")           then goto continue end
                    if trimmed:match("^private")            then goto continue end
                    if trimmed:match("^public")             then goto continue end
                    if trimmed:match("^protected")          then goto continue end
                    if trimmed:match("^friend")             then goto continue end
                    if trimmed:match("^typedef")            then goto continue end
                    if trimmed:match("^using")              then goto continue end
                    if trimmed:match("=%s*0%s*;$")          then goto continue end  -- pure virtual
                    if not trimmed:match("%(")              then goto continue end  -- pas une fonction

                    do
                        -- Construit le scope : "Outer::Inner"
                        local scope_parts = {}
                        for _, c in ipairs(class_stack) do
                            if not c.pending then
                                table.insert(scope_parts, c.name)
                            end
                        end
                        local scope = table.concat(scope_parts, "::")

                        -- Nettoie la déclaration
                        local decl = trimmed
                            :gsub(";$", "")
                            :gsub("^%s*virtual%s+", "")
                            :gsub("%s*override%s*$", "")
                            :gsub("%s*final%s*$", "")
                            :gsub("^%s*static%s+", "")
                            :gsub("^%s*explicit%s+", "")
                            :gsub("^%s*", "")

                        -- Extrait type_retour nom(args) et les potentiels modificateurs (comme const)
                        local ret, fname, args, qualifiers = decl:match("^(.-)%s+([%w_~][%w_]*)%s*(%b())(.*)")
                        if not ret then
                            -- Constructeur/destructeur (pas de type de retour)
                            fname, args, qualifiers = decl:match("^([%w_~][%w_]*)%s*(%b())(.*)")
                            ret = ""
                        end

                        if fname and args then
                            -- Retire les valeurs par défaut
                            args = args:gsub("%s*=%s*[^,)]+", "")
                            -- Ajoute le const (ou noexcept) à la fin des parenthèses
                            if qualifiers then
                                args = args .. qualifiers
                            end
                            table.insert(results, {
                                scope = scope,
                                ret   = ret,
                                name  = fname,
                                args  = args,
                            })
                        end
                    end

                    ::continue::
                end

                return results
            end

            -- -------------------------------------------------------
            -- Formate une entrée en définition C++ (accolade à la ligne)
            -- -------------------------------------------------------
            local function format_def(entry)
                local prefix = (entry.ret ~= "" and entry.ret .. " " or "")
                return prefix .. entry.scope .. "::" .. entry.name .. entry.args
            end

            -- -------------------------------------------------------
            -- Commande principale : <leader>ci depuis le .hpp
            -- -------------------------------------------------------
            vim.keymap.set("n", "<leader>ci", function()
                local hpp_path = vim.fn.expand("%:p")
                local cpp_path = vim.fn.expand("%:p:r") .. ".cpp"
                local hpp_name = vim.fn.expand("%:t")

                if not hpp_path:match("%.hpp$") and not hpp_path:match("%.h$") then
                    vim.notify("Pas dans un fichier .hpp / .h !", vim.log.levels.ERROR)
                    return
                end

                local hpp_lines = vim.fn.readfile(hpp_path)
                local all_decls = parse_hpp(hpp_lines)

                if #all_decls == 0 then
                    vim.notify("Aucune fonction à implémenter trouvée.", vim.log.levels.WARN)
                    return
                end

                -- Filtre les fonctions déjà présentes dans le .cpp
                local cpp_content = ""
                if vim.fn.filereadable(cpp_path) == 1 then
                    cpp_content = table.concat(vim.fn.readfile(cpp_path), "\n")
                end

                local to_add = {}
                for _, entry in ipairs(all_decls) do
                    local pattern = vim.pesc(entry.scope .. "::" .. entry.name) .. "%s*%("
                    if not cpp_content:match(pattern) then
                        table.insert(to_add, entry)
                    end
                end

                if #to_add == 0 then
                    vim.notify("Toutes les fonctions sont déjà implémentées !", vim.log.levels.INFO)
                    vim.cmd("vsplit " .. cpp_path)
                    return
                end

                local is_new_file = vim.fn.filereadable(cpp_path) == 0

                -- Construit les nouvelles lignes à écrire
                local new_lines = {}

                if is_new_file then
                    -- Fichier nouveau : header 42 sera appelé après, on prépare juste l'include
                    table.insert(new_lines, '#include "' .. hpp_name .. '"')
                    table.insert(new_lines, "")
                else
                    new_lines = vim.fn.readfile(cpp_path)
                    -- Retire les lignes vides en fin de fichier
                    while #new_lines > 0 and new_lines[#new_lines]:match("^%s*$") do
                        table.remove(new_lines)
                    end
                    table.insert(new_lines, "")

                    -- Ajoute l'include si absent
                    local has_include = false
                    for _, l in ipairs(new_lines) do
                        if l:match('#include%s*"' .. vim.pesc(hpp_name) .. '"') then
                            has_include = true; break
                        end
                    end
                    if not has_include then
                        table.insert(new_lines, 1, '#include "' .. hpp_name .. '"')
                        table.insert(new_lines, 2, "")
                    end
                end

                -- Corps des fonctions (accolade à la ligne)
                for _, entry in ipairs(to_add) do
                    table.insert(new_lines, format_def(entry))
                    table.insert(new_lines, "{")
                    table.insert(new_lines, "")
                    table.insert(new_lines, "}")
                    table.insert(new_lines, "")
                end

                vim.fn.writefile(new_lines, cpp_path)

                -- Ouvre le .cpp à droite
                vim.cmd("vsplit " .. cpp_path)

                -- Si nouveau fichier : appelle le header 42 (Stdheader)
                if is_new_file then
                    vim.defer_fn(function()
                        -- Place le curseur en ligne 1 pour que Stdheader l'insère en tête
                        vim.cmd("normal! gg")
                        local ok, _ = pcall(vim.cmd, "Stdheader")
                        if not ok then
                            vim.notify("42header non disponible, header ignoré.", vim.log.levels.WARN)
                        end
                    end, 100)
                end

                -- Place le curseur sur la première nouvelle fonction
                local first = to_add[1]
                vim.fn.search(vim.pesc(first.scope .. "::" .. first.name) .. "%s*(", "w")

                vim.notify(
                    "✅ " .. #to_add .. " fonction(s) ajoutée(s) dans " .. vim.fn.fnamemodify(cpp_path, ":t"),
                    vim.log.levels.INFO
                )
            end, { desc = "Implémenter hpp → cpp" })

        end,
    },
}
