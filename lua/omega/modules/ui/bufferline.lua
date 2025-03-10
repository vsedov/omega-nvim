local bufferline_mod = {}

bufferline_mod.plugins = {
    ["bufferline.nvim"] = {
        "akinsho/bufferline.nvim",
        opt = true,
        setup = function()
            vim.api.nvim_create_autocmd({ "BufAdd", "TabEnter" }, {
                pattern = "*",
                group = vim.api.nvim_create_augroup("BufferLineLazyLoading", {}),
                callback = function()
                    local count = #vim.fn.getbufinfo({ buflisted = 1 })
                    if count >= 2 then
                        vim.cmd([[PackerLoad bufferline.nvim]])
                    end
                end,
            })
        end,
    },
}

bufferline_mod.configs = {
    ["bufferline.nvim"] = function()
        local colors = require("omega.colors").get()
        local groups = require("bufferline.groups")

        if not vim.g.defined_buf_line_functions then
            vim.g.toggle_icon = " "
            vim.g.defined_buf_line_functions = true
            vim.cmd([=[
                function! Switch_theme(a,b,c,d)
                lua require"ignis.modules.files.telescope".colorschemes()
                endfunction
                function! Close_buf(a,b,c,d)
                    lua vim.cmd([[wq]])
                endfunction
                function! Toggle_light(a,b,c,d)
                    lua require"omega.colors".toggle_light()
                endfunction
            ]=])
        end

        require("bufferline").setup({
            highlights = {
                background = {
                    guifg = colors.grey_fg,
                    guibg = colors.black2,
                    -- guibg = colors.black,
                },

                -- buffers
                buffer_selected = {
                    guifg = colors.white,
                    guibg = colors.grey_fg,
                    -- guibg = colors.black,
                    gui = "bold,italic",
                },

                duplicate_selected = {
                    guifg = colors.white,
                    -- guibg = colors.black,
                    guibg = colors.grey_fg,
                    gui = "bold,italic",
                },
                duplicate_visible = {
                    guifg = colors.white,
                    guibg = colors.black2,
                    gui = "bold,italic",
                },
                buffer_visible = {
                    guifg = colors.white,
                    -- guibg = colors.black2,
                    guibg = colors.black2,
                },

                buffer = {
                    guifg = colors.white,
                    -- guibg = colors.black2,
                    guibg = colors.black2,
                },

                -- for diagnostics = "nvim_lsp"
                error = {
                    guifg = colors.light_grey,
                    guibg = colors.black2,
                },
                error_diagnostic = {
                    guifg = colors.light_grey,
                    guibg = colors.black2,
                },

                -- close buttons
                close_button = {
                    guifg = colors.light_grey,
                    guibg = colors.black2,
                },
                close_button_visible = {
                    guifg = colors.light_grey,
                    guibg = colors.black2,
                },
                close_button_selected = {
                    guifg = colors.red,
                    guibg = colors.grey_fg,
                },
                fill = {
                    guifg = colors.grey_fg,
                    guibg = colors.darker_black,
                },
                indicator_selected = {
                    guifg = colors.black2,
                    guibg = colors.black,
                },

                -- modified
                modified = {
                    guifg = colors.red,
                    guibg = colors.black2,
                },
                modified_visible = {
                    guifg = colors.red,
                    guibg = colors.black2,
                },
                modified_selected = {
                    guifg = colors.green,
                    guibg = colors.grey_fg,
                },

                -- separators
                separator = {
                    guifg = colors.darker_black,
                    guibg = colors.black2,
                },
                separator_visible = {
                    guifg = colors.darker_black,
                    guibg = colors.black2,
                },
                separator_selected = {
                    guifg = colors.darker_black,
                    guibg = colors.grey_fg,
                },

                -- tabs
                tab = {
                    guifg = colors.light_grey,
                    guibg = colors.one_bg3,
                },
                duplicate = {
                    guifg = colors.light_grey,
                    guibg = colors.black2,
                },
                tab_selected = {
                    guifg = colors.black2,
                    guibg = colors.nord_blue,
                },
                tab_close = {
                    guifg = colors.red,
                    guibg = colors.darker_black,
                },
            },
            options = {
                close_icon = "",
                show_close_icon = false,
                separator_style = "slant",
                mode = "buffers",
                diagnostics = "nvim_diagnostic",
                always_show_bufferline = false,
                custom_areas = {
                    right = function()
                        local result = {}
                        -- TODO: readd
                        table.insert(result, {
                            text = "%@Toggle_light@ "
                                .. vim.g.toggle_icon
                                .. " %X ",
                            guifg = colors.blue,
                            guibg = colors.light_grey,
                        })

                        -- table.insert(result, {
                        --     text = "%@Switch_theme@  %X ",
                        --     guifg = colors.dark_purple,
                        --     guibg = colors.light_grey,
                        -- })

                        table.insert(result, {
                            text = "%@Close_buf@  %X",
                            guifg = colors.red,
                        })

                        return result
                    end,
                },
                groups = {
                    options = {
                        toggle_hidden_on_enter = true,
                    },
                    items = {
                        groups.builtin.ungrouped,
                        {
                            highlight = { guisp = colors.pink, gui = "underline" },
                            name = "tests",
                            icon = "",
                            matcher = function(buf)
                                return buf.filename:match("_spec")
                                    or buf.filename:match("test")
                            end,
                        },
                        {
                            highlight = {
                                guisp = colors.cyan,
                                gui = "underline",
                            },
                            name = "docs",
                            matcher = function(buf)
                                for _, ext in ipairs({ "md", "txt", "org", "norg", "wiki" }) do
                                    if
                                        ext
                                        == vim.fn.fnamemodify(buf.path, ":e")
                                    then
                                        return true
                                    end
                                end
                            end,
                        },
                    },
                },
            },
        })
        -- return bufline
    end,
}

bufferline_mod.keybindings = function()
    local wk = require("which-key")
    wk.register({
        b = {
            name = "﩯Buffer",
            ["b"] = { "<cmd>e #<CR>", "Switch to Other Buffer" },
            ["p"] = { "<cmd>BufferLineCyclePrev<CR>", "Previous Buffer" },
            ["["] = { "<cmd>BufferLineCyclePrev<CR>", "Previous Buffer" },
            ["n"] = { "<cmd>BufferLineCycleNext<CR>", "Next Buffer" },
            ["]"] = { "<cmd>BufferLineCycleNext<CR>", "Next Buffer" },
            ["d"] = {
                "<cmd>lua require('bufferline').handle_close(vim.fn.bufnr('%'))<cr>",
                "Delete Buffer",
            },
            ["g"] = { "<cmd>BufferLinePick<CR>", "Goto Buffer" },
        },
    }, {
        prefix = "<leader>",
        mode = "n",
    })
end

return bufferline_mod
