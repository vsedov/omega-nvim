---@type OmegaModule
local snippets_mod = {}

snippets_mod.plugins = {
    ["LuaSnip"] = {
        "L3MON4D3/LuaSnip",
        module = "luasnip",
    },
    ["friendly-snippets"] = {
        "~/neovim_plugins/friendly-snippets",
        event = "InsertEnter",
        after = "LuaSnip",
    },
}

snippets_mod.configs = {
    ["LuaSnip"] = function()
        local ls_types = require("luasnip.util.types")
        local util = require("luasnip.util.util")

        require("luasnip.config").setup({
            history = true,
            region_check_events = "CursorMoved",
            delete_check_events = "TextChangedI",
            updateevents = "TextChanged,TextChangedI,InsertLeave",
            enable_autosnippets = true,
            ext_opts = {
                [ls_types.choiceNode] = {
                    active = {
                        virt_text = { { " ", "Keyword" } },
                    },
                },
                [ls_types.insertNode] = {
                    active = {
                        virt_text = { { "●", "Special" } },
                    },
                },
            },
            parser_nested_assembler = function(_, snippet)
                local select = function(snip, no_move)
                    snip.parent:enter_node(snip.indx)
                    -- upon deletion, extmarks of inner nodes should shift to end of
                    -- placeholder-text.
                    for _, node in ipairs(snip.nodes) do
                        node:set_mark_rgrav(true, true)
                    end

                    -- SELECT all text inside the snippet.
                    if not no_move then
                        vim.api.nvim_feedkeys(
                            vim.api.nvim_replace_termcodes(
                                "<Esc>",
                                true,
                                false,
                                true
                            ),
                            "n",
                            true
                        )
                        local pos_begin, pos_end = snip.mark:pos_begin_end()
                        util.normal_move_on(pos_begin)
                        vim.api.nvim_feedkeys(
                            vim.api.nvim_replace_termcodes(
                                "v",
                                true,
                                false,
                                true
                            ),
                            "n",
                            true
                        )
                        util.normal_move_before(pos_end)
                        vim.api.nvim_feedkeys(
                            vim.api.nvim_replace_termcodes(
                                "o<C-G>",
                                true,
                                false,
                                true
                            ),
                            "n",
                            true
                        )
                    end
                end
                function snippet:jump_into(dir, no_move)
                    if self.active then
                        -- inside snippet, but not selected.
                        if dir == 1 then
                            self:input_leave()
                            return self.next:jump_into(dir, no_move)
                        else
                            select(self, no_move)
                            return self
                        end
                    else
                        -- jumping in from outside snippet.
                        self:input_enter()
                        if dir == 1 then
                            select(self, no_move)
                            return self
                        else
                            return self.inner_last:jump_into(dir, no_move)
                        end
                    end
                end

                -- this is called only if the snippet is currently selected.
                function snippet:jump_from(dir, no_move)
                    if dir == 1 then
                        return self.inner_first:jump_into(dir, no_move)
                    else
                        self:input_leave()
                        return self.prev:jump_into(dir, no_move)
                    end
                end

                return snippet
            end,
        })
        require("omega.modules.completion.snippets.choice_popup")
        require("omega.modules.completion.snippets.lua")
        require("omega.modules.completion.snippets.general")
        require("omega.modules.completion.snippets.tex")
        require("omega.modules.completion.snippets.tex_circuits")
        require("omega.modules.completion.snippets.tex_math")
        require("luasnip/loaders/from_vscode").load({
            paths = {
                "~/.local/share/nvim/site/pack/packer/opt/friendly-snippets",
            },
        })
    end,
}

return snippets_mod
