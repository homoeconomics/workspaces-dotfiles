return {
  { import = "lazyvim.plugins.extras.lang.go" },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_organize_imports", lsp_format = "first" },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "folke/neoconf.nvim", cmd = "Neoconf", opts = {} },
    },
    opts = {
      servers = {
        yamlls = {
          settings = {
            yaml = {
              customTags = {
                -- These are all related to AWS CloudFormation.
                "!And sequence",
                "!Base64",
                "!Cidr sequence",
                "!Equals sequence",
                "!FindInMap sequence",
                "!GetAZs",
                "!GetAtt",
                "!If sequence",
                "!ImportValue",
                "!Join sequence",
                "!Length sequence",
                "!Not sequence",
                "!Or sequence",
                "!Ref",
                "!Select sequence",
                "!Split sequence",
                "!Sub",
                "!Transform scalar",
              },
            },
          },
        },
        bashls = {
          settings = {
            filetypes = { "sh", "bash", "zsh" },
          },
        },
        rubocop = {
          enabled = false,
        },
        gopls = {
          cmd = { "/home/bits/.local/bin/dd-gopls" },
          cmd_env = {
            GOPLS_DISABLE_MODULE_LOADS = "1",
          },
        },
        pyright = {
          -- Both settings are to let Ruff handle these tasks.
          settings = {
            pyright = {
              disableOrganizeImports = true,
            },
            python = {
              analysis = {
                ignore = { "*" },
              },
            },
          },
        },
      },
    },
  },
}
