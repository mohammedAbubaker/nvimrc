vim.g.mapleader= ' '

local data_path = vim.fn.stdpath("data") .. "/site/pack/plugins/start"
local plugins = {
    ["plenary.nvim"] = "https://github.com/nvim-lua/plenary.nvim",
    ["telescope.nvim"] = "https://github.com/nvim-telescope/telescope.nvim",
    ["citruszest.nvim"] = "https://github.com/zootedb0t/citruszest.nvim",
    ["mason.nvim"] = "https://github.com/williamboman/mason.nvim",
    ["mason-lspconfig.nvim"] = "https://github.com/williamboman/mason-lspconfig.nvim",
    ["nvim-lspconfig"] = "https://github.com/neovim/nvim-lspconfig",
    ["nvim-cmp"] = "https://github.com/hrsh7th/nvim-cmp",
    ["cmp-nvim-lsp"] = "https://github.com/hrsh7th/cmp-nvim-lsp",
    ["cmp-buffer"] = "https://github.com/hrsh7th/cmp-buffer",
    ["cmp-path"] = "https://github.com/hrsh7th/cmp-path",
    ["neo-tree.nvim"] = "https://github.com/nvim-neo-tree/neo-tree.nvim",
    ["nvim-web-devicons"] = "https://github.com/nvim-tree/nvim-web-devicons",
    ["leap.nvim"] = "https://github.com/ggandor/leap.nvim",
    ["lualine.nvim"] = "https://github.com/nvim-lualine/lualine.nvim",
    ["last-color.nvim"] = "https://github.com/raddari/last-color.nvim"
}

for name, url in pairs(plugins) do
    local install_path = data_path .. "/" .. name
    if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
        vim.fn.system({ "git", "clone", "--depth", "1", url, install_path })
    end
    vim.opt.runtimepath:append(install_path)
end

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.updatetime = 300
vim.cmd("syntax on")

local function load_colour()
    local ok, last_color = pcall(require, 'last-color')
    local theme = ok and last_color.recall() or 'citruszest'
    pcall(vim.cmd.colorscheme, theme)
end
vim.api.nvim_create_autocmd("VimEnter", { callback = load_colour })

local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

require('mason').setup()
require('mason-lspconfig').setup({
    handlers = {
        function(server_name)
            lspconfig[server_name].setup({ capabilities = capabilities })
        end,
        ["lua_ls"] = function()
            lspconfig.lua_ls.setup({
                capabilities = capabilities,
                settings = { Lua = { diagnostics = { globals = { 'vim' } } } }
            })
        end,
    }
})

vim.diagnostic.config({
    virtual_text = false,
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
        focused = false,
        style = "minimal",
        border = "rounded",
        source = "always",
        header = "",
        prefix = "",
    },
})

vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
        vim.diagnostic.open_float(nil, { focusable = false })
    end
})

vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local opts = { buffer = ev.buf }
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
        vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = ev.buf,
            callback = function() vim.lsp.buf.format({ async = false }) end,
        })
    end,
})

local cmp = require('cmp')
cmp.setup({
    mapping = cmp.mapping.preset.insert({
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<Tab>'] = cmp.mapping.confirm({ select = true }),
    }),
    sources = cmp.config.sources({ { name = 'nvim_lsp' }, { name = 'path' } }, { { name = 'buffer' } }),
    window = { completion = cmp.config.window.bordered(), documentation = cmp.config.window.bordered() }
})

require('neo-tree').setup({ filesystem = { follow_current_file = { enabled = true } } })
require('lualine').setup({ options = { theme = 'auto' } })

local tb = require('telescope.builtin')

vim.keymap.set('n', '<leader>ff', tb.find_files, { desc = "Find Files" })
vim.keymap.set('n', '<leader>fr', tb.oldfiles, { desc = "Recent Files" })
vim.keymap.set('n', '<leader>fb', tb.buffers, { desc = "Buffers" })

vim.keymap.set('n', '<leader>gf', tb.git_files, { desc = "Git Files" })
vim.keymap.set('n', '<leader>gs', tb.git_status, { desc = "Git Status" })

vim.keymap.set('n', '<leader>sg', tb.live_grep, { desc = "Search by Grep" })
vim.keymap.set('n', '<leader>sb', tb.current_buffer_fuzzy_find, { desc = "Search in Buffer" })

vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist, { desc = "Diagnostic List" })

vim.keymap.set('n', '<leader>t', tb.colorscheme, { desc = "Themes" })
