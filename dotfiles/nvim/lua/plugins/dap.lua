local dap_config = {
  adapters = {
    -- lldb = {
    --   lang = 'cpp',
    --   type = 'executable',
    --   binary = 'codelldb',
    --   name = 'lldb',
    --   port = 1300,
    -- },

    debugpy = {
      lang = 'python',
      type = 'executable',
      binary = 'debugpy',
      name = 'debugpy'
    },

  },

  -- TODO add to this structure?
  -- configurations = {
  -- }

}

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "williamboman/mason.nvim",

      {
        -- Nice DAP ui
        "rcarriga/nvim-dap-ui",
        config = function(_, _)
          local dap, dapui = require("dap"), require("dapui")
          --use nvim-dap events to open and close the windows automatically
          dap.listeners.after.event_initialized["dapui_config"] = function()
            dapui.open()
          end
          dap.listeners.before.event_terminated["dapui_config"] = function()
            dapui.close()
          end
          dap.listeners.before.event_exited["dapui_config"] = function()
            dapui.close()
          end

          require("dapui").setup({
            icons = { expanded = "", collapsed = "", current_frame = "" },
            mappings = {
              -- Use a table to apply multiple mappings
              expand = { "<CR>", "<2-LeftMouse>" },
              open = "o",
              remove = "d",
              edit = "e",
              repl = "r",
              toggle = "t",
            },
            -- Use this to override mappings for specific elements
            element_mappings = {
              -- Example:
              -- stacks = {
              --   open = "<CR>",
              --   expand = "o",
              -- }
            },
            -- Expand lines larger than the window
            -- Requires >= 0.7
            expand_lines = vim.fn.has("nvim-0.7") == 1,
            -- Layouts define sections of the screen to place windows.
            -- The position can be "left", "right", "top" or "bottom".
            -- The size specifies the height/width depending on position. It can be an Int
            -- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
            -- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
            -- Elements are the elements shown in the layout (in order).
            -- Layouts are opened in order so that earlier layouts take priority in window sizing.
            layouts = {
              {
                elements = {
                  -- Elements can be strings or table with id and size keys.
                  { id = "scopes", size = 0.25 },
                  "breakpoints",
                  "stacks",
                  "watches",
                },
                size = 40, -- 40 columns
                position = "left",
              },
              {
                elements = {
                  -- "console",
                  "repl"
                  -- {id = "repl", size = .75 },
                },
                size = 0.25, -- 25% of total lines
                position = "bottom",
              },
            },
            controls = {
              -- Requires Neovim nightly (or 0.8 when released)
              enabled = true,
              -- Display controls in this element
              element = "repl",
              icons = {
                pause = "",
                play = "",
                step_into = "",
                step_over = "",
                step_out = "",
                step_back = "",
                run_last = "",
                terminate = "",
              },
            },
            floating = {
              max_height = nil,  -- These can be integers or a float between 0 and 1.
              max_width = nil,   -- Floats will be treated as percentage of your screen.
              border = "single", -- Border style. Can be "single", "double" or "rounded"
              mappings = {
                close = { "q", "<Esc>" },
              },
            },
            windows = { indent = 1 },
            render = {
              max_type_length = nil, -- Can be integer or nil.
              max_value_lines = 100, -- Can be integer or nil.
            }
          })
        end
      },

      {
        -- Vscode like dap project file
        "ldelossa/nvim-dap-projects",
        config = function(_, _)
          -- require('nvim-dap-projects').config_paths = {"./test/nvim-dap.lua"}
          require('nvim-dap-projects').search_project_config()
        end
      },

      -- Add DAP section to whichkey
      {
        "folke/which-key.nvim",
        opts = {
          defaults = {
            ["<leader>d"] = { desc = "+debug" },
          },
        },
      },

    },

    cmd = {
      "DapContinue",
    },

    keys = {
      {
        "<leader>da",
        function() require("dap").continue() end,
        desc =
        "Continue"
      },
      {
        "<leader>df",
        function() require("dap").terminate() end,
        desc =
        "Terminate"
      },
      {
        "<leader>dB",
        function() require("dap").toggle_breakpoint(vim.fn.input('Breakpoint condition: ')) end,
        desc =
        "Conditional Breakpoint"
      },
      {
        "<leader>db",
        function() require("dap").toggle_breakpoint() end,
        desc =
        "Toggle Breakpoint"
      },
      {
        "<leader>dL",
        function()
          require("dap").toggle_breakpoint(nil, nil,
            vim.fn.input({ prompt = 'Log point message: ' }))
        end,
        desc =
        "Toggle Logpoint"
      },
      {
        "<leader>dc",
        function() require("dap").run_to_cursor() end,
        desc =
        "Run to Cursor"
      },
      {
        "<leader>dg",
        function() require("dap").goto_() end,
        desc =
        "Go to line (no execute)"
      },
      {
        "<leader>di",
        function() require("dap").step_into() end,
        desc =
        "Step Into"
      },
      {
        "<leader>dd",
        function() require("dap").down() end,
        desc =
        "Down"
      },
      {
        "<leader>du",
        function() require("dap").up() end,
        desc =
        "Up"
      },
      {
        "<leader>dl",
        function() require("dap").run_last() end,
        desc =
        "Run Last"
      },
      {
        "<leader>dk",
        function() require("dap").step_out() end,
        desc =
        "Step Out"
      },
      {
        "<leader>dj",
        function() require("dap").step_over() end,
        desc =
        "Step Over"
      },
      {
        "<leader>dp",
        function() require("dap").pause() end,
        desc =
        "Pause"
      },
      {
        "<leader>dr",
        function() require("dap").repl.toggle() end,
        desc =
        "Toggle REPL"
      },
      {
        "<leader>dt",
        function() require("dap").restart_frame() end,
        desc =
        "Restart frame"
      },
      {
        "<leader>dw",
        function() require("dap.ui.widgets").hover() end,
        desc =
        "Widgets"
      },
      {
        "<leader>dS",
        function() require("dap.ui.widgets").centered_float(require('dap.ui.widgets').scopes) end,
        desc =
        "Scopes"
      },
      {
        "<leader>ds",
        function() require("dap.ui.widgets").centered_float(require('dap.ui.widgets').frames) end,
        desc =
        "Frames"
      },
      {
        "<leader>dt",
        function() require("dap.ui.widgets").centered_float(require('dap.ui.widgets').threads) end,
        desc =
        "Threads"
      },
      {
        "<leader>ff",
        function() require("telescope").extensions.dap.frames() end,
        desc =
        "DAP frames"
      },
      {
        "<leader>fb",
        function() require("telescope").extensions.dap.list_breakpoints() end,
        desc =
        "DAP breakpoints"
      },
    },

    config = function(_, opts)
      local dap = require('dap')
      dap.set_log_level('trace')
      local mason_binary_dir = vim.fn.stdpath('data') .. '/mason/bin/'
      require("mason").setup(opts)
      local mr = require("mason-registry")

      local function program()
        return vim.fn.input({
          prompt = 'Path to executable: ',
          default = vim.fn.getcwd() .. '/',
          completion = 'file'
        })
      end

      -- make sure required Debug adapters are installed and configured
      for dap_name, dap_opts in pairs(dap_config.adapters) do
        -- Install using Mason if adapter is missing
        local p = mr.get_package(dap_opts.binary)
        if not p:is_installed() then
          p:install()
        end

        -- Setup adapters
        dap.adapters[dap_opts.lang] = {
          type = 'executable',
          command = mason_binary_dir .. dap_opts.binary,
          name = dap_name,
          port = dap_opts.port
        }
      end

      dap.adapters.cpp = {
        {
          type = 'server',
          port = '13000',
          executable = {
            command = 'codelldb',
            args = { '--port', '13000' },
          },
        },
        {
          type = 'server',
          port = '2331',
          executable = {
            command = [[C:\Program Files\SEGGER\JLink\JLinkGDBServerCL.exe]],
            args = { '-device', 'R7FA6M2AF',
              '-endian', 'little',
              '-if', 'SWD',
              '-speed', '4000',
              '-port', '2331',
              -- '-rtos', 'EmbOS',
            },
          },
        }
      }

      dap.adapters.c_local = {
        type = 'server',
        port = '13000',
        executable = {
          command = 'codelldb',
          args = { '--port', '13000' },
        },
      }

      dap.adapters.c = {
        -- id = 'iets',
        type = 'server',
        port = '3332',

        -- command = 'python debug_adapter_main.py',
        -- args = { "-e", "build/blinky.elf" },

        -- args = { "-f", "interface/ftdi/esp32_devkitj_v1.cfg",
        --   "-f", "target/esp32.cfg",
        --   "-c", "program_esp build/blink.bin 0x10000 verify" },
        -- executable = {
        --   command = 'openocd',
        --   args = { "-f", "interface/ftdi/esp32_devkitj_v1.cfg",
        --     "-f", "target/esp32.cfg",
        --     "-c", "program_esp build/blink.bin 0x10000 verify" },
        -- },

      }

      dap.configurations.c = {
        {
          name = "iets config",
          type = 'c',
          request = 'attach',
          program = 'build/blink.elf',
          stopOnEntry = true,
          port = 3332,
        },

        {
          name = "local",
          type = 'c_local',
          request = 'launch',
          program = 'a.out',
          stopOnEntry = false,
          port = 13000,
        },
      }

      -- Setup configurations
      dap.configurations.python = {
        {
          name = "Launch file",
          type = 'python',
          request = 'launch',
          program = "${file}",
          pythonPath = function()
            return '/usr/bin/python'
          end,
        },
      }

      dap.configurations.cpp = {
        {
          name = "lldb: Debug executable",
          type = 'cpp',
          request = 'launch',
          program = function()
            return vim.fn.input('Path to executable: ')
          end,
          runInTerminal = false,
          cwd = '${workspaceFolder}',
          stopOnEntry = false,
          args = {},
          port = 13000,
        },

        {
          name = "Clang10 + lldb",
          type = 'cpp',
          request = 'launch',
          program = function()
            return vim.fn.input('Path to executable: ')
          end,
        },

        {
          name = "codelldb: Launch",
          type = "codelldb",
          request = "launch",
          program = program,
          cwd = '${workspaceFolder}',
          args = {},
        },

        {
          name = "codelldb: Launch external",
          type = "codelldb",
          request = "launch",
          program = program,
          cwd = '${workspaceFolder}',
          args = {},
          terminal = 'external',
        },

        {
          name = "codelldb: Attach (select process)",
          type = 'codelldb',
          request = 'attach',
          pid = require('dap.utils').pick_process,
          args = {},
        },

        {
          name = "codelldb: Attach (input pid)",
          type = 'codelldb',
          request = 'attach',
          pid = function()
            return tonumber(vim.fn.input({ prompt = 'pid: ' }))
          end,
          args = {},
        },
      }

      -- Breakpoint styling
      vim.api.nvim_set_hl(0, "blue", { fg = "#3d59a1" })
      vim.api.nvim_set_hl(0, "green", { fg = "#9ece6a" })
      vim.api.nvim_set_hl(0, "yellow", { fg = "#FFFF00" })
      vim.api.nvim_set_hl(0, "orange", { fg = "#f09000" })

      vim.fn.sign_define('DapBreakpoint',
        { text ='', texthl = 'blue', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
      vim.fn.sign_define('DapBreakpointCondition',
        { text = 'ﳁ', texthl = 'blue', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
      vim.fn.sign_define('DapBreakpointRejected',
        { text = '', texthl = 'orange', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
      vim.fn.sign_define('DapStopped',
        { text = '', texthl = 'green', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })
      vim.fn.sign_define('DapLogPoint',
        { text = '', texthl = 'yellow', linehl = 'DapBreakpoint', numhl = 'DapBreakpoint' })

    end,

  },

}
