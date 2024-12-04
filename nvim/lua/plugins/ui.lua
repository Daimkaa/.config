return {
  { "sphamba/smear-cursor.nvim" },
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        mode = "buffers",
        -- separator_style = "slant",
        show_buffer_close_icons = false,
        show_close_icon = false,
      },
    },
  },
  -- {
  --   "b0o/incline.nvim",
  --   dependencies = { "craftzdog/solarized-osaka.nvim" },
  --   event = "BufReadPre",
  --   priority = 1200,
  --   config = function()
  --     local colors = require("solarized-osaka.colors").setup()
  --     require("incline").setup({
  --       highlight = {
  --         groups = {
  --           InclineNormal = { guibg = colors.magenta500, guifg = colors.base04 },
  --           InclineNormalNC = { guifg = colors.violet500, guibg = colors.base03 },
  --         },
  --       },
  --       window = { margin = { vertical = 0, horizontal = 1 } },
  --       hide = {
  --         cursorline = true,
  --       },
  --       render = function(props)
  --         local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
  --         if vim.bo[props.buf].modified then
  --           filename = "[+] " .. filename
  --         end
  --
  --         local icon, color = require("nvim-web-devicons").get_icon_color(filename)
  --         return { { icon, guifg = color }, { " " }, { filename } }
  --       end,
  --     })
  --   end,
  -- },
  {
    "echasnovski/mini.starter",
    version = false, -- wait till new 0.7.0 release to put it back on semver
    event = "VimEnter",
    opts = function()
      local logo = table.concat({
        "████████╗██╗  ██╗███████╗███╗   ███╗██╗   ██╗██╗   ██╗██╗     ███╗   ██╗ ",
        "╚══██╔══╝██║  ██║██╔════╝████╗ ████║██║   ██║██║   ██║██║     ████╗  ██║ ",
        "   ██║   ███████║█████╗  ██╔████╔██║██║   ██║██║   ██║██║     ██╔██╗ ██║ ",
        "   ██║   ██╔══██║██╔══╝  ██║╚██╔╝██║██║   ██║██║   ██║██║     ██║╚██╗██║ ",
        "   ██║   ██║  ██║███████╗██║ ╚═╝ ██║╚██████╔╝╚██████╔╝███████╗██║ ╚████║ ",
        "   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═══╝ ",
      }, "\n")
      local pad = string.rep(" ", 22)
      local new_section = function(name, action, section)
        return { name = name, action = action, section = pad .. section }
      end

      local starter = require("mini.starter")
    --stylua: ignore
    local config = {
      evaluate_single = true,
      header = logo,
      items = {
        new_section("Find file",       LazyVim.pick(),                        "Telescope"),
        new_section("New file",        "ene | startinsert",                   "Built-in"),
        new_section("Recent files",    LazyVim.pick("oldfiles"),              "Telescope"),
        new_section("Select Session",  "lua require('persistence').select()", "Session"),
        new_section("Find text",       LazyVim.pick("live_grep"),             "Telescope"),
        new_section("Config",          LazyVim.pick.config_files(),           "Config"),
        new_section("Restore session", [[lua require("persistence").load()]], "Session"),
        new_section("Lazy Extras",     "LazyExtras",                          "Config"),
        new_section("Lazy",            "Lazy",                                "Config"),
        new_section("Quit",            "qa",                                  "Built-in"),
      },
      content_hooks = {
        starter.gen_hook.adding_bullet(pad .. "░ ", false),
        starter.gen_hook.aligning("center", "center"),
      },
    }
      return config
    end,
    config = function(_, config)
      -- close Lazy and re-open when starter is ready
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "MiniStarterOpened",
          callback = function()
            require("lazy").show()
          end,
        })
      end

      local starter = require("mini.starter")
      starter.setup(config)

      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyVimStarted",
        callback = function(ev)
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          local pad_footer = string.rep(" ", 8)
          starter.config.footer = pad_footer .. "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
          -- INFO: based on @echasnovski's recommendation (thanks a lot!!!)
          if vim.bo[ev.buf].filetype == "ministarter" then
            pcall(starter.refresh)
          end
        end,
      })
    end,
  },
}
