local utils = {}

function utils.border()
    return {
        { "╭", "FloatBorder" },
        { "─", "FloatBorder" },
        { "╮", "FloatBorder" },
        { "│", "FloatBorder" },
        { "╯", "FloatBorder" },
        { "─", "FloatBorder" },
        { "╰", "FloatBorder" },
        { "│", "FloatBorder" },
    }
end

function utils.bootstrap_impatient()
    local has_impatient = pcall(require, "impatient")
    if not has_impatient then
        -- Packer Bootstrapping
        local packer_path = vim.fn.stdpath("data")
            .. "/site/pack/packer/start/impatient.nvim"
        if vim.fn.empty(vim.fn.glob(packer_path)) > 0 then
            vim.notify("Bootstrapping impatient.nvim, please wait ...")
            vim.fn.system({
                "git",
                "clone",
                "--depth",
                "1",
                "https://github.com/lewis6991/impatient.nvim",
                packer_path,
            })
        end

        vim.cmd("packadd impatient.nvim")

        require("impatient").enable_profile()
    end
end

return utils
