-- Remap
-- highlight
vim.g.mapleader = ' '
vim.keymap.set('n', '<leader>e', '<Cmd>Neotree float toggle <CR>')
-- End Remap

-- Line Numbers
vim.cmd [[set number relativenumber]]
vim.cmd([[au VimEnter * highlight MatchParen ctermbg=blue guibg=lightblue]])
vim.cmd([[set tabstop=4]])
vim.cmd([[set shiftwidth=4]])
vim.cmd([[set expandtab]])

-- End Line Numbers

-- Packer
vim.cmd [[packadd packer.nvim]]
-- Enable Rainbow Parenthesis
require('packer').startup(function(use)
  -- Packer can manage itself
  	use 'wbthomason/packer.nvim'
	-- Telescope 
	use {
		'nvim-telescope/telescope.nvim', tag = '0.1.6',
		requires = { {'nvim-lua/plenary.nvim'} }
	}

	local telescope = require('telescope.builtin')
	vim.keymap.set('n', '<leader>pf', telescope.find_files, {})
	vim.keymap.set('n', '<C-p>', telescope.git_files, {})
	-- End Telescope
	
	-- Theme
	use { "zootedb0t/citruszest.nvim" }
	vim.cmd('colorscheme blue')
	-- End Theme

    vim.cmd('autocmd vimenter * hi Normal guibg=NONE ctermbg=NONE')
	
	-- Treesitter
	use ('nvim-treesitter/nvim-treesitter', {run = ':TSUpdate'})
	require'nvim-treesitter.configs'.setup {
		-- A list of parser names, or "all" (the five listed parsers should always be installed)
		ensure_installed = {"python", "c", "lua", "vim", "vimdoc", "query" },

		-- Install parsers synchronously (only applied to `ensure_installed`)
		sync_install = false,

		-- Automatically install missing parsers when entering buffer
		-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
		auto_install = true,

		---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
		-- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false,
		},
	}
	-- End Treesitter
	
	-- LSP
	use {
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v3.x',
		requires = {
			{'williamboman/mason.nvim'},
			{'williamboman/mason-lspconfig.nvim'},

			{'neovim/nvim-lspconfig'},
			{'hrsh7th/nvim-cmp'},
			{'hrsh7th/cmp-nvim-lsp'},
			{'L3MON4D3/LuaSnip'},
		}
	}

	local lsp = require('lsp-zero')
	require('mason').setup({})
	require('mason-lspconfig').setup({
		-- Replace the language servers listed here
		-- with the ones you want to install
		ensure_installed = {
			'ruff',
			'rust_analyzer',
			'lua_ls',
			'gopls'
		},
		handlers = {
			function(server_name)
				require('lspconfig')[server_name].setup({})
			end,
		}
	})
		
	vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
	vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
	vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
	vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

	lsp.preset('recommended')

	lsp.set_preferences({
		sign_icons = {}
	})

	local lspconfig = require('lspconfig')
	lspconfig.pylsp.setup {}
	-- Use LspAttach autocommand to only map the following keys
	-- after the language server attaches to the current buffer
	vim.api.nvim_create_autocmd('LspAttach', {
		group = vim.api.nvim_create_augroup('UserLspConfig', {}),
		callback = function(ev)
			-- Enable completion triggered by <c-x><c-o>
			vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

			-- Buffer local mappings.
			-- See `:help vim.lsp.*` for documentation on any of the below functions
			local opts = { buffer = ev.buf }
			vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
			vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
			vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
			vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
			vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
			vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
			vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
			vim.keymap.set('n', '<space>wl', function()
				print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
			end, opts)
			vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
			vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
			vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
			vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
			vim.keymap.set('n', '<space>f', function()
				vim.lsp.buf.format { async = true }
			end, opts)
		end,
	})
	

	  local cmp = require'cmp'

	  cmp.setup({
		  snippet = {
			  -- REQUIRED - you must specify a snippet engine
			  expand = function(args)
				  vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
				  -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
				  -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
				  -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
				  -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
			  end,
		  },

		  window = {
			  -- completion = cmp.config.window.bordered(),
			  -- documentation = cmp.config.window.bordered(),
		  },
		  mapping = cmp.mapping.preset.insert({
			  ['<C-b>'] = cmp.mapping.scroll_docs(-4),
			  ['<C-f>'] = cmp.mapping.scroll_docs(4),
			  ['<C-e>'] = cmp.mapping.abort(),
			  ['<Tab>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		  }),
		  sources = cmp.config.sources({
			  { name = 'nvim_lsp' },
			  { name = 'vsnip' }, -- For vsnip users.
			  -- { name = 'luasnip' }, -- For luasnip users.
			  -- { name = 'ultisnips' }, -- For ultisnips users.
			  -- { name = 'snippy' }, -- For snippy users.
		  }, {
			  { name = 'buffer' },
		  })
	  })

	
	local lsp_flags = {
		debounce_text_changes = 10,
	}
	-- End LSP
	-- NeoTree
	use {
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		requires = { 
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
			"MunifTanjim/nui.nvim",
			-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
		}
	}

	require('neo-tree').setup({
		filesystem = {
			follow_current_file = {
				enabled = true
			}
		}
	})
	-- End NeoTree
	
	-- Leap
	use {
		"ggandor/leap.nvim"
	}
	require('leap').create_default_mappings()
	-- End Leap
	
	-- LuaLine
	use {
		'nvim-lualine/lualine.nvim',
		requires = { 'nvim-tree/nvim-web-devicons', opt = true }
	}

	require('lualine').setup {
		options = {
			icons_enabled = true,
			theme = 'auto',
			component_separators = { left = '|', right = '|'},
			section_separators = { left = '', right = ''},
			disabled_filetypes = {
				statusline = {},
				winbar = {},
			},
			ignore_focus = {},
			always_divide_middle = true,
			globalstatus = false,
			refresh = {
				statusline = 1000,
				tabline = 1000,
				winbar = 1000,
			}
		},
		sections = {
			lualine_a = {'mode'},
			lualine_b = {'branch', 'diff', 'diagnostics'},
			lualine_c = {'filename'},
			lualine_x = {'encoding', 'fileformat', 'filetype'},
			lualine_y = {'progress'},
			lualine_z = {'location'}
		},
		inactive_sections = {
			lualine_a = {},
			lualine_b = {},
			lualine_c = {'filename'},
			lualine_x = {'location'},
			lualine_y = {},
			lualine_z = {}
		},
		tabline = {},
		winbar = {},
		inactive_winbar = {},
		extensions = {}
	}
	-- End LuaLine
end)
-- End Packer
