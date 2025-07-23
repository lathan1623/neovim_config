-- TESTING -- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.smarttab = true

vim.keymap.set("v", "<leader>c", [[:w !clip.exe<CR>]], { noremap = true, silent = true })

vim.api.nvim_create_autocmd('TermOpen', {
    group = vim.api.nvim_create_augroup('custom-term-open', { clear = true }),
    callback = function()
        vim.opt.number = false
        vim.opt.relativenumber = false
    end,
})

vim.keymap.set("n", "<leader>st", function()
    vim.cmd.vnew()
    vim.cmd.term()
    vim.cmd("wincmd J")
    vim.api.nvim_win_set_height(0, 5)
    vim.cmd("startinsert")
end)

if vim.fn.has('wsl') == 1 then
  vim.g.clipboard = {
    name = 'WslClipboard',
    copy = {
      ['+'] = 'clip.exe',
      ['*'] = 'clip.exe',
    },
    paste = {
      ['+'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
      ['*'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    },
    cache_enabled = 0,
  }
end

-- Setup lazy.nvim
require("lazy").setup({
    spec = {
      {
            'abecodes/tabout.nvim',
            lazy = false,
            config = function()
              require('tabout').setup {
                tabkey = '<Tab>', -- key to trigger tabout, set to an empty string to disable
                backwards_tabkey = '<S-Tab>', -- key to trigger backwards tabout, set to an empty string to disable
                act_as_tab = true, -- shift content if tab out is not possible
                act_as_shift_tab = false, -- reverse shift content if tab out is not possible (if your keyboard/terminal supports <S-Tab>)
                default_tab = '<C-t>', -- shift default action (only at the beginning of a line, otherwise <TAB> is used)
                default_shift_tab = '<C-d>', -- reverse shift default action,
                enable_backwards = true, -- well ...
                completion = false, -- if the tabkey is used in a completion pum
                tabouts = {
                  { open = "'", close = "'" },
                  { open = '"', close = '"' },
                  { open = '`', close = '`' },
                  { open = '(', close = ')' },
                  { open = '[', close = ']' },
                  { open = '{', close = '}' }
                },
                ignore_beginning = true, --[[ if the cursor is at the beginning of a filled element it will rather tab out than shift the content ]]
                exclude = {} -- tabout will ignore these filetypes
              }
            end,
            dependencies = { -- These are optional
              "nvim-treesitter/nvim-treesitter",
              "L3MON4D3/LuaSnip",
              "hrsh7th/nvim-cmp"
            },
            opt = true,  -- Set this to true if the plugin is optional
            event = 'InsertCharPre', -- Set the event to 'InsertCharPre' for better compatibility
            priority = 1000,
          },
          {
            "L3MON4D3/LuaSnip",
            keys = function()
              -- Disable default tab keybinding in LuaSnip
              return {}
            end,
          },
                {
                    "vim-airline/vim-airline"
        },
        {
            'tpope/vim-fugitive',
            config = function()
                vim.keymap.set('n', '<leader>gs', vim.cmd.Git)
            end
        },  
        {
          "dmtrKovalenko/fold-imports.nvim",
          opts = {},
          event = "BufRead"
        },
        {
            "blazkowolf/gruber-darker.nvim",
            config = function()
                vim.cmd.colorscheme("gruber-darker")
            end
        },
        {
            'nvim-treesitter/nvim-treesitter',
            build = ':TSUpdate',
            opts = {
                ensure_installed = { 'rust', 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc', 'go', 'java', 'javascript', 'typescript' },
                auto_install = true,
                highlight = {
                    enable = true,
                },
                autotag = {
                  enable = true,
                }
            },
            config = function(_, opts)
              require("nvim-treesitter").setup(opts)
            end,
        },
        {
          "windwp/nvim-ts-autotag",
          event = "InsertEnter",
          dependencies = { "nvim-treesitter/nvim-treesitter"},
          config = function()
            require("nvim-ts-autotag").setup({
              opts = {
                enable_close = true,
                enable_rename = true,
                enable_close_on_slash = false,
              },
            })
          end,
        },
        {
            'nvim-telescope/telescope.nvim',
            event = 'VimEnter',
            branch = '0.1.x',
            dependencies = {
                'nvim-lua/plenary.nvim',
                'debugloop/telescope-undo.nvim',
                {
                    'nvim-telescope/telescope-fzf-native.nvim',
                    build = 'make',
                    cond = function()
                        return vim.fn.executable 'make' == 1
                    end,
                },
                { 'nvim-telescope/telescope-ui-select.nvim' },
            },
            config = function()
                require('telescope').setup {
                    extensions = {
                        undo = {
                            -- telescope-undo.nvim config see below
                        },
                        ['ui-select'] = {
                            require('telescope.themes').get_dropdown(),
                        },
                    },
                }

                pcall(require('telescope').load_extension, 'undo')
                pcall(require('telescope').load_extension, 'fzf')
                pcall(require('telescope').load_extension, 'ui-select')

                local builtin = require('telescope.builtin')

                vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'Telescope find files' })
                vim.keymap.set('n', '<leader>u', "<cmd>Telescope undo<cr>") 
                vim.keymap.set('n', '<C-p>', builtin.git_files, { desc = 'Git find files' })
                vim.keymap.set('n', '<leader>ps', function()
                  builtin.grep_string({ search = vim.fn.input("Grep > ") });
                end)
            end
        },
        {
            'williamboman/mason.nvim',
            lazy = false,
            opts = {},
        },

        -- Autocompletion
        {
            'hrsh7th/nvim-cmp',
            event = 'InsertEnter',
            config = function()
                local cmp = require('cmp')
                local SelectBehavior = require('cmp.types.cmp').SelectBehavior

                cmp.setup({
                    sources = {
                        {name = 'nvim_lsp'},
                    },
                    mapping = cmp.mapping.preset.insert({
                        ['<C-Space>'] = cmp.mapping.complete(),
                        ['<C-U>'] = cmp.mapping.scroll_docs(-4),
                        ['<C-D>'] = cmp.mapping.scroll_docs(4),
                        ['<C-e>'] = cmp.mapping.abort(),
                        ['<C-y>'] = cmp.mapping.confirm({ select = true }),
                        ['<Tab>'] = cmp.mapping.select_next_item({behavior = SelectBehavior.Select}),
                        ['<S-Tab>'] = cmp.mapping.select_prev_item({behavior = SelectBehavior.Select}),
                    }),
                    snippet = {
                        expand = function(args)
                            vim.snippet.expand(args.body)
                        end,
                    },
                })
            end
        },

  -- LSP
  {
    'neovim/nvim-lspconfig',
    cmd = {'LspInfo', 'LspInstall', 'LspStart'},
    event = {'BufReadPre', 'BufNewFile'},
    dependencies = {
      {'hrsh7th/cmp-nvim-lsp'},
      {'williamboman/mason.nvim'},
      {'williamboman/mason-lspconfig.nvim'},
    },
    init = function()
      -- Reserve a space in the gutter
      -- This will avoid an annoying layout shift in the screen
      vim.opt.signcolumn = 'yes'
    end,
    config = function()
      local lspconfig = require('lspconfig')
      lspconfig.rust_analyzer.setup({
        on_attach = function(client, bufnr)
        vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
      end
      })

      local lsp_defaults = require('lspconfig').util.default_config

      -- Add cmp_nvim_lsp capabilities settings to lspconfig
      -- This should be executed before you configure any language server
      lsp_defaults.capabilities = vim.tbl_deep_extend(
        'force',
        lsp_defaults.capabilities,
        require('cmp_nvim_lsp').default_capabilities()
      )

      -- LspAttach is where you enable features that only work
      -- if there is a language server active in the file
      vim.api.nvim_create_autocmd('LspAttach', {
        desc = 'LSP actions',
        callback = function(event)
          local opts = {buffer = event.buf}

          vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
          vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
          vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
          vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
          vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
          vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
          vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
          vim.keymap.set('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
          vim.keymap.set({'n', 'x'}, '<F3>', '<cmd>lua vim.lsp.buf.format({async = true})<cr>', opts)
          vim.keymap.set('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
        end,
      })

      require('mason-lspconfig').setup({
        ensure_installed = {},
        handlers = {
          -- this first function is the "default handler"
          -- it applies to every language server without a "custom handler"
          function(server_name)
            require('lspconfig')[server_name].setup({})
          end,
        }
      })
    end
  },
  {

  },
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
    -- use opts = {} for passing setup options
    -- this is equivalent to setup({}) function
  },
  {
    "simrat39/rust-tools.nvim",
    ft = { "rust" },
    dependencies = {
      "neovim/nvim-lspconfig",
      "mfussenegger/nvim-dap",
      "nvim-lua/plenary.nvim",
    },
    config = function()
      local rt = require("rust-tools")
      local dap = require("dap")

      dap.configurations.rust = {
        {
          name = "Debug executable",
          type = "rt_lldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable", vim.fn.getcwd() .. "/target/debug/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
        },
      }

      rt.setup({
        server = {
          standalone = false,
          settings = {
            ["rust-analyzer"] = {
              checkOnSave = {
                command = "clippy",
              },
            },
          },
        },

        dap = {
          adapter = require("rust-tools.dap").get_codelldb_adapter(
            vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb",
            vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/lldb/lib/liblldb.so"
          ),
        },
      })
    end,
  }
  },
    checker = { enabled = true }
})





