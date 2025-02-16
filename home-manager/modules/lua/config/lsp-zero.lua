local lsp_zero = require('lsp-zero')
local cmp_action = require('lsp-zero').cmp_action()

lsp_zero.on_attach(function(client, bufnr)
  lsp_zero.default_keymaps({buffer = bufnr})
end)

-- Define the devenv_lsp functionality
local devenv_lsp = {}

local function find_rust_bin()
    local bin = "/Users/rishi/sandbox/cachix/devenv/target/debug/devenv"
    if vim.fn.executable(bin) == 1 then
        return bin
    end
	vim.notify("Development binary not found. Have you built the project?", vim.log.levels.ERROR)
    return nil
end

local function find_root_dir(fname)
    local found = vim.fs.find({'devenv.nix'}, { upward = true, path = fname })[1]
    if not found then
        vim.notify("No devenv.nix found. Using current working directory.", vim.log.levels.WARN)
    end
    return found and vim.fs.dirname(found) or vim.fn.getcwd()
end

devenv_lsp.start = function()
    local rust_bin = find_rust_bin()
    if not rust_bin then return end

    local root_dir = find_root_dir(vim.fn.expand('%:p'))
    local client = vim.lsp.start({
        name = "devenv-lsp",
        cmd = { rust_bin, "-v", "lsp" },
        root_dir = root_dir,
		cmd_env = { DEVENV_NIX = "/nix/store/6saa848x89d55faz7i7v8wzzjnbr0kx9-nix-devenv-2.24.0pre20241213_bde6a1a" }
    })
    if not client then
        vim.notify("Failed to start devenv LSP. Check logs for details.", vim.log.levels.ERROR)
    end
end

local group = vim.api.nvim_create_augroup("devenv-lsp", { clear = true })

devenv_lsp.setup = function ()
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = {"nix"},
        callback = function()
            pcall(devenv_lsp.start)
        end,
    })
end

devenv_lsp.setup()

require('lspconfig').rust_analyzer.setup{}
require('lspconfig').pyright.setup{}
require('lspconfig').clangd.setup{}
require('lspconfig').terraformls.setup{}
require('lspconfig').zls.setup{}
require('lspconfig').gopls.setup{}

vim.api.nvim_create_autocmd({"BufWritePre"}, {
  pattern = {"*.tf", "*.tfvars"},
  callback = function()
    vim.lsp.buf.format()
  end,
})

local lsp_configurations = require('lspconfig.configs')

lsp_zero.set_sign_icons({
  error = '✘',
  warn = '▲',
  hint = '⚑',
  info = '»'
})

local cmp = require('cmp')
local lspkind = require('lspkind')

cmp.setup({
	formatting = {
		format = lspkind.cmp_format(),
	},
	mapping = cmp.mapping.preset.insert({
		['<CR>'] = cmp.mapping.confirm({select = false}),
		['<Tab>'] = cmp_action.luasnip_supertab(),
		['<S-Tab>'] = cmp_action.luasnip_shift_supertab(),
		-- ['<C-Space>'] = cmp.mapping.complete(),
	}),
	snippet = {
		expand = function(args)
			require('luasnip').lsp_expand(args.body)
		end,
	},
	preselect = 'item',
	completion = {
		completeopt = 'menu,menuone,noinsert',
	},
})

