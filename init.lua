local vim = vim or {} -- 防止 lsp 报错找不到 vim
local set = vim.o
set.termguicolors = true -- 使得 neovim 配色生效
--set.clipboard = "unnamed" -- 复制到剪切板 待安装额外插件
set.number = true         -- 显示行号
set.relativenumber = true -- 显示相对行号
set.cursorline = true     -- 高亮光标所在行

set.autoindent = true     -- 新起一行时自动对齐缩进
set.expandtab = true      -- 使用空格而非 Tab 进行缩进
set.tabstop = 4           -- 用两个空格代替 Tab
set.shiftwidth = 4        -- > 或者 < 时用两个空格缩进

-- 高亮被复制的代码
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
    pattern = { "*" },
    callback = function()
        vim.highlight.on_yank({
            timeout = 500,
        })
    end
})

-- 开启 VIM 时创建 sign
vim.api.nvim_create_autocmd({ "VimEnter" }, {
    pattern = { "*" },
    callback = function()
        local command = string.format(
            "sign define %s text=%s texthl=%s linehl=%s",
            "Congratulations", "🎉", "Congratulations", ""
        )
        -- 执行命令
        vim.api.nvim_command(command)
    end
})
vim.api.nvim_create_autocmd({ "CursorMoved" }, {
    pattern = { "*" },
    callback = function()
        local row = vim.api.nvim_win_get_cursor(0)[1]
        local command = string.format("sign place 200 name=Congratulations line=%d", row)
        vim.api.nvim_command(command)
    end
})

-- leader key
vim.g.mapleader = " "

-- layvim 安装，确保前面已经执行过 vim.g.mapleader = " "
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- 使用 lazyvim 安装其他插件
require("lazy").setup({
    "RRethy/nvim-base16",     -- 配色
    {
        "tpope/vim-fugitive", -- Git 操作
        config = function()
            -- 命令映射
            vim.cmd.cnoreabbrev([[git Git]]) -- 配合插件 tpope/vim-fugitive 使用
        end
    },
    { -- 在最左边提示修改
        "lewis6991/gitsigns.nvim",
        config = function()
            require("gitsigns").setup()
        end
    },
    { "folke/persistence.nvim", opts = { dir = vim.fn.expand(vim.fn.stdpath("state") .. "/sessions/") } }, -- 保存上一次退出的状态
    { "folke/which-key.nvim",   opts = { notify = false } },                                               -- 命令提示
    {                                                                                                      -- 文件搜索
        "nvim-telescope/telescope.nvim",
        tag = "0.1.1",
        dependencies = {
            'nvim-lua/plenary.nvim' }
    },
    { "williamboman/mason.nvim", build = ":MasonUpdate" },                                 -- LSP 配置管理插件
    { "neovim/nvim-lspconfig",   dependencies = { "williamboman/mason-lspconfig.nvim" } }, -- LSP 配置
    {                                                                                      -- 代码补全插件
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-cmdline",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-vsnip",
            "saadparwaiz1/cmp_luasnip",
            "lukas-reineke/cmp-under-comparator",
            "L3MON4D3/LuaSnip",
            "saadparwaiz1/cmp_luasnip"
        }
    },
})
require("mason").setup()
require("mason-lspconfig").setup()

-- 使用 which-key 管理 key-binding
local wk = require("which-key")
wk.register(
    {
        name = "new split",
        ["<Leader>v"] = { "<C-w>v", noremap = true, silent = true, "new vertical split" },
        ["<Leader>s"] = { "<C-w>s", noremap = true, silent = true, "new horizontal split" },
    }
)

wk.register(
    {
        name = "moving",
        ["<C-l>"] = { "<C-w>l", noremap = true, silent = true, "move to the split on the right" },
        ["<C-h>"] = { "<C-w>h", noremap = true, silent = true, "move to the split on the left" },
        ["<C-k>"] = { "<C-w>k", noremap = true, silent = true, "move to the split above" },
        ["<C-j>"] = { "<C-w>k", noremap = true, silent = true, "move to the split below" },

        j = { [[v:count ? 'j' : 'gj']], noremap = true, expr = true, "move to the visual line below" },
        k = { [[v:count ? 'k' : 'gk']], noremap = true, expr = true, "move to the visual line above" },

        ["<C-n>"] = { "<C-o>", noremap = true, "move to the previous position" },
        ["<C-m>"] = { "<C-i>", noremap = true, "move to the next position" },
    }
)

wk.register(
    {
        name = "key binding for Telescope",
        ["<Leader>ff"] = { ":Telescope find_files<CR>", noremap = true, "find file by name" },
        ["<Leader>F"] = { ":Telescope live_grep<CR>", noremap = true, "grep file" },
        ["<Leader>r"] = { ":Telescope resume<CR>", noremap = true, "resume" },
        ["<Leader>o"] = { ":Telescope oldfiles<CR>", noremap = true, "resume" },
    }
)

wk.register(
    {
        name = "Gitsigns",
        ["<Leader>hs"] = { ":Gitsigns preview_hunk<CR>", noremap = true, "find file by name" },
        ["<Leader>hn"] = { ":Gitsigns next_hunk<CR>", noremap = true, "find file by name" },
        ["<Leader>hp"] = { ":Gitsigns prev_hunk<CR>", noremap = true, "find file by name" },
    }
)

wk.register(
  {
    name = "Gitsigns",
    ["<Leader>hs"] = { ":Gitsigns preview_hunk<CR>", noremap = true, "preview hunk" },
    ["<Leader>hn"] = { ":Gitsigns next_hunk<CR>", noremap = true, "goto next hunk" },
    ["<Leader>hp"] = { ":Gitsigns prev_hunk<CR>", noremap = true, "goto prev hunk" },
  }
)

wk.register(
  {
    name = "Diagnostic",
    ["<Leader>dn"] = { ":lua vim.diagnostic.goto_next()<CR>", noremap = true, "goto next diagnostic" },
    ["<Leader>dp"] = { ":lua vim.diagnostic.goto_prev()<CR>", noremap = true, "goto prev diagnostic" },
  }
)

wk.register(
  {
    name = "Window Resize",
    ["<Leader>whmax"] = { ":horizontal resize " .. math.floor(vim.o.lines) .. "<CR>", noremap = true, "max the current window in horizontal direction." },
    ["<Leader>wvmax"] = { ":vertical resize " .. math.floor(vim.o.columns) .. "<CR>", noremap = true, "max the current window in vertical direction." },
    ["<Leader>whmin"] = { ":horizontal resize " .. math.floor(vim.o.lines * 0.3) .. "<CR>", noremap = true, "min the current window in horizontal direction." },
    ["<Leader>wvmin"] = { ":vertical resize " .. math.floor(vim.o.columns * 0.3) .. "<CR>", noremap = true, "min the current window in vertical direction." },
    ["<Leader>wh+"] = { ":horizontal resize +10<CR>", noremap = true, "add horizontal size" },
    ["<Leader>wh-"] = { ":horizontal resize -10<CR>", noremap = true, "sub horizontal size" },
    ["<Leader>wv+"] = { ":vertical resize +10<CR>", noremap = true, "add vertical size" },
    ["<Leader>wv-"] = { ":vertical resize -10<CR>", noremap = true, "sub vertical size" },
    ["<Leader>w="] = { "<C-w>=", noremap = true, "resize all windows" },
  }
)

-- 关闭 persistence 的自动保存状态
vim.api.nvim_create_autocmd({ "VimEnter" }, {
    pattern = { "*" },
    callback = function()
        require("persistence").stop()
    end
})

wk.register(
    {
        name = "persistence state",
        ["<Leader>res"] = {
            function()
                require("persistence").start();       -- 启动，退出时自动保存状态
                require("persistence").load({ last = true }); -- 恢复至前一次退出时的状态
                print("restored to the state of the last exit");
            end,
            noremap = true,
            "restore to the state of the last exit"
        }
    }
)

-- LSP 的 keybinding
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local opts = function(desc)
            local dict = { buffer = ev.buf, desc = desc }
            return dict
        end
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts("vim.lsp.buf.declaration"))
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts("vim.lsp.buf.definition"))
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts("vim.lsp.buf.hover"))
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts("vim.lsp.buf.implementation"))
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts("vim.lsp.buf.signature_help"))
        vim.keymap.set('n', '<Leader>D', vim.lsp.buf.type_definition, opts("vim.lsp.buf.type_definition"))
        vim.keymap.set('n', '<Leader>rename', vim.lsp.buf.rename, opts("vim.lsp.buf.rename"))
        vim.keymap.set({ 'n', 'v' }, '<Leader>ca', vim.lsp.buf.code_action, opts("vim.lsp.buf.code_action"))
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts("vim.lsp.buf.references"))
        vim.keymap.set('n', '<Leader>workspace', vim.lsp.buf.add_workspace_folder,
            opts("vim.lsp.buf.add_workspace_folder"))
        vim.keymap.set('n', '<Leader>format', function() vim.lsp.buf.format { async = true } end, opts("format code"))
        vim.keymap.set('v', '=', function() vim.lsp.buf.format {} end, opts("format code in selection"))
    end,
})


-- 代码补全
local cmp = require 'cmp'
cmp.setup({
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
            -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
        end,
    },
    window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    sources = cmp.config.sources({
            { name = 'nvim_lsp' },
            -- { name = 'vsnip' }, -- For vsnip users.
            { name = 'luasnip' }, -- For luasnip users.
            -- { name = 'ultisnips' }, -- For ultisnips users.
            -- { name = 'snippy' }, -- For snippy users.
        },
        {
            { name = 'buffer' },
        })
})
-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
    sources = cmp.config.sources({
        { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
    }, {
        { name = 'buffer' },
    })
})
-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})
-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})

-- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- 设置 lua 的 LSP
require("lspconfig").lua_ls.setup({ capabilities = capabilities })
-- 设置 CPP 的 LSP
require("lspconfig").clangd.setup({ capabilities = capabilities })
-- 设置 Python 的 LSP
require("lspconfig").pylsp.setup({ capabilities = capabilities })
-- 设置 Bash 的 LSP
require("lspconfig").bashls.setup({ capabilities = capabilities })
-- 设置 typescript 的 LSP
require("lspconfig").ts_ls.setup({ capabilities = capabilities })
-- 设置 json 的 LSP
require("lspconfig").jsonls.setup({ capabilities = capabilities })

-- color scheme
vim.cmd.colorscheme("base16-standardized-dark")
-- vim.cmd.colorscheme("base16-gruvbox-dark-soft")
-- vim.cmd.colorscheme("base16-tender")
-- vim.cmd.colorscheme("base16-gruvbox-material-dark-soft")
