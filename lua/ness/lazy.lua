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

require("lazy").setup({
  -- Plenary (Telescope Req.)
  "nvim-lua/plenary.nvim",

  -- FZF Solver
  "nvim-telescope/telescope-fzf-native.nvim",

  -- Entry Finder
  "sharkdp/fd",

  -- Telescope
  {"nvim-telescope/telescope.nvim", tag='0.1.4'},

  -- Colorscheme
  {
    "rebelot/kanagawa.nvim",
    lazy = false, -- Load During Starup
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme kanagawa-wave]])
    end,
  },

  -- Treeshitter
  {
    "nvim-treesitter/nvim-treesitter",
    event = "VeryLazy",
    ensure_installed = {
      "c", "lua", "vim", "cpp", "typescript",
    },
    auto_install = true, 
    highlight = {enable = true}, 
    build = ":TSUpdate"
  },

  -- Lualine 
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons", opt = true }
  },

  -- Greeter
  {
    "goolord/alpha-nvim",
    config = function()
      require'alpha'.setup(require'alpha.themes.dashboard'.config)
    end
  },

  -- Bufferline 
  {
    "akinsho/bufferline.nvim",
    version="*",
    dependencies = "nvim-tree/nvim-web-devicons",
    keys = {
      {"<leader>bp", "<Cmd>BufferLineTogglePin<CR>", desc = "Toggle pin"},
      {"<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev buffer"},
      {"<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer"}
    }
  },

  -- Autopairing
  {
    "echasnovski/mini.pairs",
    version = "*"
  },

  -- Remove Buffers
  {
    "echasnovski/mini.bufremove",
    version = "*",
    keys = {
      {
        "<leader>bd",
        function()
          local bd = require("mini.bufremove").delete
          if vim.bo.modified then
            local choice = vim.fn.confirm(("Save changes to %q?"):format(vim.fn.bufname()), "&Yes\n&No\n&Cancel")
            if choice == 1 then -- Yes
              vim.cmd.write()
              bd(0)
            elseif choice == 2 then -- No
              bd(0, true)
            end
          else
            bd(0)
          end
        end,
        desc = "Delete Buffer",
      }
    }
  },

  -- Indent Scope
  {
    "echasnovski/mini.indentscope",
    version = "*",
    opts = {
      symbol = "│",
      options = { try_as_border = true },
    },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "help",
          "alpha",
          "neo-tree",
          "lazy",
          "mason",
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      }) end,
      config = function (_,opts)
        require("mini.indentscope").setup(opts)
      end
    },

    -- Scope Lines
    {
      "lukas-reineke/indent-blankline.nvim",
      main = "ibl",
      opts = {
        indent = {
          char = "|",
          tab_char = "|",
        },
        scope = { enabled = false },
        exclude = {
          filetypes = {
            "help",
            "alpha",
            "neo-tree",
            "lazy",
            "mason"
          }
        }
      },
    },

    -- Illuminate
    {
      "RRethy/vim-illuminate",
      opts = {
        delay = 200,
        providers = {"lsp"}
      },
      config = function (_,opts)
        require("illuminate").configure(opts)
      end
    },

    -- Comment 
    {
      "echasnovski/mini.comment",
      version = "*"
    },

    -- Neo Tree
    {
      "nvim-neo-tree/neo-tree.nvim",
      branch = "v3.x",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim"
      },
      cmd = "Neotree",
      keys = {
        {
          "<leader>fe",
          function()
            require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
          end,
          desc = "Explorer NeoTree (cwd)",
        },
        { "<leader>e", "<leader>fe", desc = "Explorer NeoTree (cwd)", remap = true},
      },
      deactivate = function()
        vim.cmd([[Neotree close]])
      end,
      opts = {
        filesystem ={
          filtered_items = {
            hide_gitignored = false,
            always_show = {
              ".gitignored"
            },
            hide_dotfiles = false
          },
          hijack_netrw_behavior = "open_default",
          use_libuv_file_watcher = true
        }
      },
      config = function (_,opts)
        require("neo-tree").setup(opts)
      end
    },

    -- Neogit
    {
      "NeogitOrg/neogit",
      dependencies = {
        "nvim-lua/plenary.nvim",         -- required
        "sindrets/diffview.nvim",        -- optional - Diff integration

        -- Only one of these is needed, not both.
        "nvim-telescope/telescope.nvim", -- optional
        "ibhagwan/fzf-lua",              -- optional
      },
      config = true
    },

    -- Which Key
    {
      "folke/which-key.nvim",
      event = "VeryLazy",
      opts = {}
    },

    -- Snippets
    {
      "L3MON4D3/LuaSnip",
      dependencies = {
        "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
      opts = {
        history = true,
        delete_check_events = "TextChanged",
      },
      -- stylua: ignore
      keys = {
        {
          "<tab>",
          function()
            return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
          end,
          expr = true, silent = true, mode = "i",
        },
        { "<tab>", function() require("luasnip").jump(1) end, mode = "s" },
        { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
      },
    },

    {
      "hrsh7th/nvim-cmp",
      version = false, -- last release is way too old
      event = "InsertEnter",
      dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "saadparwaiz1/cmp_luasnip",
      },
      opts = function()
        vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
        local cmp = require("cmp")
        local defaults = require("cmp.config.default")()
        return {
          completion = {
            completeopt = "menu,menuone,noinsert",
          },
          snippet = {
            expand = function(args)
              require("luasnip").lsp_expand(args.body)
            end,
          },
          mapping = cmp.mapping.preset.insert({
            ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
            ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-e>"] = cmp.mapping.abort(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
            ["<S-CR>"] = cmp.mapping.confirm({
              behavior = cmp.ConfirmBehavior.Replace,
              select = true,
            }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
            ["<C-CR>"] = function(fallback)
              cmp.abort()
              fallback()
            end,
          }),
          sources = cmp.config.sources({
            { name = "nvim_lsp" },
            { name = "luasnip" },
            { name = "path" },
          }, {
            { name = "buffer" },
          }),
          experimental = {
            ghost_text = {
              hl_group = "CmpGhostText",
            },
          },
          sorting = defaults.sorting,
        }
      end,
      config = function(_, opts)
        for _, source in ipairs(opts.sources) do
          source.group_index = source.group_index or 1
        end
        require("cmp").setup(opts)
      end,
    },

    -- LSP
    {
      "williamboman/mason.nvim",
      cmd = "Mason",
      keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
      build = ":MasonUpdate",
      opts = {
        ensure_installed = {
          "stylua",
          "shfmt",
          -- "flake8",
        },
      },
      config = function(_, opts)
        require("mason").setup(opts)
        local mr = require("mason-registry")
        mr:on("package:install:success", function()
          vim.defer_fn(function()
            -- trigger FileType event to possibly load this newly installed LSP server
            require("lazy.core.handler.event").trigger({
              event = "FileType",
              buf = vim.api.nvim_get_current_buf(),
            })
          end, 100)
        end)
        local function ensure_installed()
          for _, tool in ipairs(opts.ensure_installed) do
            local p = mr.get_package(tool)
            if not p:is_installed() then
              p:install()
            end
          end
        end
        if mr.refresh then
          mr.refresh(ensure_installed)
        else
          ensure_installed()
        end
      end,
    },

    {
      "neovim/nvim-lspconfig",
      dependencies = {
        { "williamboman/mason.nvim"},
        "williamboman/mason-lspconfig.nvim"
      },
      opts = {
        inlay_hints = {
          enabled = false,
        },
        capabilities = {},
        format = {
          formatting_options = nil,
          timeout_ms = nil,
        },
        servers = {
          lua_ls = {
            settings = {
              Lua = {
                workspace = {
                  checkThirdParty = false,
                },
                completion = {
                  callSnippet = "Replace",
                },
              },
            },
          },
        },
        setup = {},
      },
      config = function(_, opts)
        local servers = opts.servers
        local capabilities = require('cmp_nvim_lsp').default_capabilities()

        local function setup(server)
          local server_opts = vim.tbl_deep_extend("force", {
                capabilities = capabilities
              }, servers[server] or {})

              if opts.setup[server] then
                if opts.setup[server](server, server_opts) then
                  return
                end
              elseif opts.setup["*"] then
                if opts.setup["*"](server, server_opts) then
                  return
                end
              end
              require("lspconfig")[server].setup(server_opts)
            end

            -- get all the servers that are available through mason-lspconfig
            local have_mason, mlsp = pcall(require, "mason-lspconfig")
            local all_mslp_servers = {}
            if have_mason then
              all_mslp_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)
            end

            local ensure_installed = {} ---@type string[]
            for server, server_opts in pairs(servers) do
              if server_opts then
                server_opts = server_opts == true and {} or server_opts
                -- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
                if server_opts.mason == false or not vim.tbl_contains(all_mslp_servers, server) then
                  setup(server)
                else
                  ensure_installed[#ensure_installed + 1] = server
                end
              end
            end

            if have_mason then
              mlsp.setup({ ensure_installed = ensure_installed, handlers = { setup } })
            end
          end,
        }
      })
