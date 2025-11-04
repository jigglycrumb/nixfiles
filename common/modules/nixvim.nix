{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let

  enable =
    attrs:
    builtins.listToAttrs (
      map (name: {
        name = name;
        value.enable = true;
      }) attrs
    );

  luaToViml =
    s:
    let
      lines = lib.splitString "\n" s;
      nonEmptyLines = builtins.filter (line: line != "") lines;
      processed = map (
        line: if line == builtins.head nonEmptyLines then "lua " + line else "\\ " + line
      ) nonEmptyLines;
    in
    lib.concatStringsSep "\n" processed;

  mkSources =
    sources: map (source: if lib.isAttrs source then source else { name = source; }) sources;

in
{
  programs.nixvim = {
    enable = true;

    # We can set the leader key:
    globals.mapleader = ",";

    extraPackages = with pkgs; [
      isort
      ruff
      stylua
      typstfmt
      prettierd
    ];

    extraConfigLua = ''
      -- init transparent.nvim
      require('transparent').setup()
      require('transparent').clear_prefix('NeoTree')
      -- require('transparent').clear_prefix('lualine')

      -- automatically update pywal colors
      local fwatch = require('fwatch')
      -- NOTE: using ~ or $HOME instead of the full path doesn't seem to work
      -- This is a problem porting this config to other platforms like Mac OS
      local colorfile = '/home/${username}/.cache/wal/colors-wal.vim'
      fwatch.watch(colorfile, 'colorscheme pywal')

      -- ui things
      -- MiniMap.open()

      -- vim.g.neominimap = {
      --   layout = 'split',
      --   split = {
      --     -- Automatically close the split window when it is the last window
      --     close_if_last_window = true,
      --   },
      -- }

      -- highlight patterns
      local hipatterns = require('mini.hipatterns')
      hipatterns.setup({
        highlighters = {
          -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
          fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
          hack  = { pattern = '%f[%w]()HACK()%f[%W]',  group = 'MiniHipatternsHack'  },
          todo  = { pattern = '%f[%w]()TODO()%f[%W]',  group = 'MiniHipatternsTodo'  },
          note  = { pattern = '%f[%w]()NOTE()%f[%W]',  group = 'MiniHipatternsNote'  },

          -- Highlight hex color strings (`#rrggbb`) using that color
          hex_color = hipatterns.gen_highlighter.hex_color(),
        },
      })

      -- pet helpers
      local actions = require('telescope.actions')
      local action_state = require('telescope.actions.state')

      local pets = { '🦆', '🪿', '🐧', '🐤', '🦢', '🐈', '🐌', '🐢', '🦑', '🦐', '🦀', '🐟', '🦔', '🦋', '🐞', '🪳', '🐜' }

      local pet_default_speed = '7'
      local pet_speed = {
        ['🐌'] = '2',
        ['🐞'] = '3',
        ['🐢'] = '4',
        ['🦋'] = '7',
        ['🐜'] = '15',
        ['🪳'] = '20',
        ['🦔'] = '25',

        ['🦆'] = '5',
        ['🪿'] = '5',
        ['🐧'] = '3',
        ['🐤'] = '1',
        ['🦢'] = '3',
      }

      function Bird()
        local birds = { '🦆', '🪿', '🐧', '🐤', '🦢' }
        local birdIndex = math.random(1, #birds) -- or short math.random(#birds)
        local bird = birds[birdIndex]
        local speed = pet_speed[bird]
        if speed == nil then
          speed = pet_default_speed
        end
        require('duck').hatch(bird, speed)
      end

      function Pet()
        local petIndex = math.random(1, #pets)
        local pet = pets[petIndex]
        local speed = pet_speed[pet]
        if speed == nil then
          speed = pet_default_speed
        end
        require('duck').hatch(pet, speed)
      end

      function Zoo()
        local size = 15
        for i = 1,size
        do
          Pet()
        end
      end

      function Rogue()
        require('duck').hatch('@', 5)
      end

      function SelectPet()
        require('telescope.pickers').new({}, {
          prompt_title = 'Select Pet',
          finder = require('telescope.finders').new_table({
            results = pets,
          }),
          sorter = require('telescope.sorters').get_generic_fuzzy_sorter(),
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              local selection = action_state.get_selected_entry()
              actions.close(prompt_bufnr)

              -- Defer the number input to ensure the environment is ready
              vim.defer_fn(function()
                local speed = pet_speed[selection[1]]

                if speed == nil then
                  local input_opts = {
                    prompt = 'Choose speed: ',
                    default = '7',
                  }

                  vim.ui.input(input_opts, function(input)
                    local number = tonumber(input) or 7.0
                    require('duck').hatch(selection[1], number)
                  end)
                else
                  require('duck').hatch(selection[1], speed)
                end
              end, 100)
            end)
            return true
          end
        }):find()
      end
    '';

    extraConfigVim = ''
      colorscheme pywal
    '';

    keymaps = [
      # back to normal mode shortcut
      {
        mode = [ "i" "v" ];
        key = "qq";
        action = "<ESC>";
        options.desc = "Back to normal mode";
      }
      {
        mode = [ "i" ];
        key = "jj";
        action = "<ESC>";
        options.desc = "Back to normal mode";
      }

      # toggle file tree - ALT + b
      {
        key = "<A-b>";
        action = "<CMD>Neotree toggle<CR>";
        options.desc = "Toggle file tree";
      }
      
      # toggle code minimap - ALT + m
      {
        key = "<A-m>";
        action = "<CMD>Neominimap toggle<CR>";
        options.desc = "Toggle minimap";
      }

      # system clipboard
      {
        key = "<leader>y";
        action = "\"+y<CR>";
        options.desc = "Yank to system clipboard";
      }

      # session or "workspace" switcher - ALT + w
      {
        key = "<A-w>";
        action = "<CMD>Telescope session-lens search_session<CR>";
        options.desc = "Switch session";
      }

      # fuzzy file picker - ALT + f
      {
        key = "<A-f>";
        action = "<CMD>Telescope fd<CR>";
        options.desc = "Jump to file";
      }

      # live grep - ALT + g
      {
        key = "<A-g>";
        action = "<CMD>Telescope live_grep<CR>";
        options.desc = "Search files";
      }

      # floating file manager (yazi) - ALT + a
      {
        key = "<A-a>";
        action = "<CMD>Yazi cwd<CR>";
        options.desc = "File manager";
      }

      # find and replace panel
      {
        key = "<leader>fr";
        action = "<CMD>GrugFar :vnew<CR>";
        options.desc = "Find & Replace";
      }


      # tabs - ALT + key
      # commands powered by barbar.nvim
      # https://vimawesome.com/plugin/barbar-nvim

      {
        key = "<A-t>";
        action = "<CMD>enew<CR>";
        options.desc = "New tab";
      }
      {
        key = "<A-c>";
        action = "<CMD>BufferClose<CR>";
        options.desc = "Close tab";
      }
      {
        key = "<A-C>";
        action = "<CMD>BufferClose!<CR>";
        options.desc = "Close tab (force)";
      }
      {
        key = "<A-,>";
        action = "<CMD>BufferPrevious<CR>";
        options.desc = "Previous tab";
      }
      {
        key = "<A-.>";
        action = "<CMD>BufferNext<CR>";
        options.desc = "Next tab";
      }
      {
        key = "<A-<>";
        action = "<CMD>BufferMovePrevious<CR>";
        options.desc = "Move tab left";
      }
      {
        key = "<A->>";
        action = "<CMD>BufferMoveNext<CR>";
        options.desc = "Move tab right";
      }
      {
        key = "<A-1>";
        action = "<CMD>BufferGoto 1<CR>";
        options.desc = "Switch to tab 1";
      }
      {
        key = "<A-2>";
        action = "<CMD>BufferGoto 2<CR>";
        options.desc = "Switch to tab 2";
      }
      {
        key = "<A-3>";
        action = "<CMD>BufferGoto 3<CR>";
        options.desc = "Switch to tab 3";
      }
      {
        key = "<A-4>";
        action = "<CMD>BufferGoto 4<CR>";
        options.desc = "Switch to tab 4";
      }
      {
        key = "<A-5>";
        action = "<CMD>BufferGoto 5<CR>";
        options.desc = "Switch to tab 5";
      }
      {
        key = "<A-6>";
        action = "<CMD>BufferGoto 6<CR>";
        options.desc = "Switch to tab 6";
      }
      {
        key = "<A-7>";
        action = "<CMD>BufferGoto 7<CR>";
        options.desc = "Switch to tab 7";
      }
      {
        key = "<A-8>";
        action = "<CMD>BufferGoto 8<CR>";
        options.desc = "Switch to tab 8";
      }
      {
        key = "<A-9>";
        action = "<CMD>BufferLast<CR>";
        options.desc = "Switch to last tab";
      }
      {
        key = "<A-p>";
        action = "<CMD>BufferPin<CR>";
        options.desc ="Pin/Unpin tab";
      }

      # tab jump mode - Ctrl+s
      {
        key = "<C-s>";
        action = "<CMD>BufferPick<CR>";
        options.desc = "Pick tab";
      }

      # sfx
      {
        key = "<leader>fml";
        action = "<CMD>CellularAutomaton make_it_rain<CR>";
        options.desc = "Let it rain";
      }
      {
        key = "<leader>brb";
        action = "<CMD>CellularAutomaton game_of_life<CR>";
        options.desc = "Game Of Life";
      }

      # pets
      {
        key = "<leader>pb";
        action = "<CMD>lua Bird()<CR>";
        options.desc = "Spawn bird";
      }
      {
        key = "<leader>pp";
        action = "<CMD>lua Pet()<CR>";
        options.desc = "Spawn pet";
      }
      {
        key = "<leader>pz";
        action = "<CMD>lua Zoo()<CR>";
        options.desc = "Spawn zoo";
      }
      {
        key = "<leader>ps";
        action = "<CMD>lua SelectPet()<CR>";
        options.desc = "Spawn selected pet";
      }
      {
        key = "<leader>pr";
        action = "<CMD>lua Rogue()<CR>";
        options.desc = "Spawn rogue";
      }
      {
        key = "<leader>pk";
        action = "<CMD>lua require('duck').cook_all()<CR>";
        options.desc = "Kill pets :⁽";
      }

    ];

    opts = {
      autoread = true; # automatically reload buffers
      number = true; # show line numbers
      numberwidth = 3; # width of line number column
      shiftwidth = 2; # tab width
      expandtab = true; # replace tabs with spaces
      relativenumber = true; # Show relative line numbers
      winborder = "rounded"; # border for code preview windows
      signcolumn = "yes"; # always draw the sign column
      smartindent = true;
    };

    plugins = {

      # automatic session save/load
      auto-session.enable = true;

      # tabs
      barbar = {
        enable = true;
        # keymaps.movePrevious.key = "<C-m>"; # BufferMovePrevious
        # keymaps.moveNext.key = "<C-m>"; # BufferMoveNext
      };

      # autocompletion
      cmp = {
        enable = true;
        autoEnableSources = true;
        settings = {
          window = {
            completion = {
              scrollbar = false;
              scrolloff = 2;
              border = "rounded";
              winhighlight = "Normal:CmpPmenu,CursorLine:PmenuSel,Search:None";
            };
            documentation.maxHeight = "math.floor(vim.o.lines / 2)";
          };
          # preselect = "None";
          # snippet.expand = "function(args) require('luasnip').lsp_expand(args.body) end";
          matching.disallowPartialFuzzyMatching = false;
          sources = mkSources [
            "nvim_lsp"
            "treesitter"
            "fuzzy-path"
            "path"
            "buffer"
            "copilot"
          ];

          mapping = {
            "<C-Space>" = "cmp.mapping.complete()";
            # "<C-d>" = "cmp.mapping.scroll_docs(-4)";
            "<C-e>" = "cmp.mapping.close()";
            # "<C-f>" = "cmp.mapping.scroll_docs(4)";
            "<CR>" = "cmp.mapping.confirm({ select = true })";
            "<S-Tab>" = "cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'})";
            "<Tab>" = "cmp.mapping(cmp.mapping.select_next_item(), {'i', 's'})";
          };

          # mapping = {
          #   "<C-j>" = "cmp.mapping.scroll_docs(-4)";
          #   "<C-e>" = "cmp.mapping.close()";
          #   "<C-k>" = "cmp.mapping.scroll_docs(4)";
          #   "<CR>" = "cmp.mapping.confirm({ select = false })";
          #   "<C-Space>" = ''
          #     cmp.mapping(function(fallback)
          #       if cmp.visible() then
          #         cmp.close()
          #       else
          #         cmp.complete()
          #       end
          #     end, { "i", "n", "v" })
          #   '';
          #   "<C-Tab>" = ''
          #     cmp.mapping(function(fallback)
          #       if cmp.visible() then
          #         cmp.select_next_item()
          #       elseif luasnip.expand_or_jumpable() then
          #         luasnip.expand_or_locally_jumpable()
          #       elseif HasWordsBefore() then
          #         cmp.complete()
          #       else
          #         ${
          #           if config.programs.nixvim.plugins.intellitab.enable then
          #             "vim.cmd[[silent! lua require('intellitab').indent()]]"
          #           else
          #             "fallback()"
          #         }
          #       end
          #     end, { "i", "s" })
          #   '';
          #   "<S-Tab>" = ''
          #     cmp.mapping(function(fallback)
          #       if cmp.visible() then
          #         cmp.select_prev_item()
          #       elseif luasnip.jumpable(-1) then
          #         luasnip.jump(-1)
          #       else
          #         fallback()
          #       end
          #     end, { "i", "s" })
          #   '';
          # };
        };
      };

      # formatting
      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            bash = [ "shellcheck" ];
            nix = [ "nixfmt" ];
            lua = [ "stylua" ];
            c = [ "clang-format" ];
            cpp = [ "clang-format" ];
            python = [
              "isort"
              "ruff_fix"
              "ruff_format"
            ];
            javascript = [
              [
                "prettierd"
                "prettier"
              ]
            ];
            typescript = [
              [
                "prettierd"
                "prettier"
              ]
            ];
            typst = [ "typstfmt" ];
            html = [ "htmlbeautifier" ];
            css = [ "stylelint" ];
            _ = "trim_whitespace";
          };
          formatters = {
            shellcheck = {
              command = lib.getExe pkgs.shellcheck;
            };
          };
        };
      };

      # fix conflict warnings with cmp
      copilot-lua.settings = {
        suggestion.enabled = false;
        panel.enabled = false;
      };

      direnv.enable = true;
      flash.enable = true; # search labels
      fugitive.enable = true; # git command integration
      gitsigns.enable = true; # git markers
      godot.enable = true;
      grug-far.enable = true; # find and replace

      # indentation hints
      indent-blankline = {
        enable = true;
        settings.indent.char = "¦";
      };

      lint.enable = true; # lint support ??

      lspkind.enable = true;
      lsp = {
        enable = true;
        inlayHints = true;
        servers =
          enable [
            "ts_ls"
            "bashls"
            "clangd"
            "cssls"
            "lua_ls"
            "eslint"
            "html"
            "jsonls"
            "nil_ls"
            "tailwindcss"
            # "typst_lsp"
            "yamlls"
            "docker_compose_language_service"
          ]
          // {
            # FIXME Autostart ruff for files that exist on disk
            ruff = {
              enable = true;
              autostart = false;
            };
            rust_analyzer = {
              enable = false; # Handled by rustacean
              installCargo = true;
              installRustc = true;
            };
            hls = {
              enable = true;
              installGhc = true;
            };
          };
      };

      lualine.enable = true; # bottom status line

      # file tree
      neo-tree = {
        enable = true;
        settings = {
          add_blank_line_at_top = true;
          close_if_last_window = true;
          filesystem = {
            filtered_items = {
              hide_dotfiles = false;
              hide_gitignored = false;
              hide_by_pattern = [ ".git" ];
            };
            follow_current_file.enabled = true;
            use_libuv_file_watcher = true;
          };
          # source_selector.statusline = true;
          source_selector.winbar = true;
        };
      };

      # notifications
      notify = {
        enable = true;
        settings = {
          render = "minimal";
          stages = "slide";
          timeout = 4000;
          topDown = true;
          fps = 60;
        };
      };

      # mini.nvim plugin suite
      mini = {
        enable = true;
        mockDevIcons = true;
        modules = {
          clue = { }; # next key clue
          comment = { }; # comment lines in/out
          cursorword = { }; # highlight current word at cursor
          hipatterns = { }; # highlight TODO, FIXME and other patterns
          icons = { }; # icons

          # highlight current scope
          indentscope = {
            draw.delay = 0;
            symbol = "|";
          };

          # move multi-line selection
          move = {
            # Module mappings. Use `''` (empty string) to disable one.
            mappings = {
              # Move visual selection in Visual mode. Defaults are Alt (Meta) + hjkl.
              left = "<M-h>";
              right = "<M-l>";
              down = "<M-j>";
              up = "<M-k>";

              # Move current line in Normal mode
              line_left = "<M-h>";
              line_right = "<M-l>";
              line_down = "<M-j>";
              line_up = "<M-k>";
            };

            # Options which control moving behavior
            options = {
              # Automatically reindent selection during linewise vertical move
              reindent_linewise = true;
            };
          };

          pairs = { }; # automatic bracket pairs
          # statusline = { }; # bottom bar - looks promising but has problems with transparent.nvim in the current config
          trailspace = { }; # highlight trailing whitespace
        };
      };

      numbertoggle.enable = true; # relative line numbers in normal, absolute in insert mode 
      nvim-surround.enable = true; # deal with surrounding characters

      # ollama = {
      #   enable = true;
      # };

      # file explorer
      oil = {
        enable = true;
        settings = {
          default_file_explorer = false;
        };
      };

      # overseer.enable = true; # task runner
      render-markdown.enable = true;
      smear-cursor.enable = true;

      # snacks.enable = true; # enable snacks (bigfile, notifier, quickfile, statuscolumn, words) - doesn't seem to do anything?
      telescope.enable = true; # fuzzy finder

      # floating terminal, ALT + s
      toggleterm = {
        enable = true;
        settings = {
          direction = "float";
          open_mapping = "[[<M-s>]]";
          float_opts.border = "curved";
        };
      };

      transparent.enable = true; # transparency
      trouble.enable = true; # sidebar showing code problems

      # syntax highlighting
      treesitter = {
        enable = true;

        grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
          arduino
          astro
          awk
          bash
          c
          css
          csv
          cue
          dockerfile
          gdscript
          git_config
          gitignore
          gomod
          gosum
          javascript
          jq
          jsdoc
          json
          lua
          make
          markdown
          nix
          php
          python
          regex
          scss
          sql
          svelte
          toml
          tsx
          typescript
          vim
          vimdoc
          vue
          xml
          yaml
        ];

        settings.highlight.enable = true;
      };

      ts-comments.enable = true; # better comment highlighting
      typescript-tools.enable = true; # something with typescript
      which-key.enable = true; # key hints
      yazi.enable = true; # file manager
    };

    extraPlugins = with pkgs.vimPlugins; [
      pywal-nvim # dynamic color scheme

      # gremlins
      {
        plugin = (
          pkgs.vimUtils.buildVimPlugin rec {
            name = "vim-unicode-homoglyphs";
            src = pkgs.fetchFromGitHub {
              owner = "Konfekt";
              repo = name;
              rev = "c52e957edd1dcc679d221903b7e623ba15b155fb";
              hash = "sha256-zOQ1uAu3EJ8O+WSRtODGkC1WTlOOh13Dmkjg5IkkLqE=";
            };
          }
        );
      }

      {
        plugin = (
          pkgs.vimUtils.buildVimPlugin rec {
            name = "vim-troll-stopper";
            src = pkgs.fetchFromGitHub {
              owner = "vim-utils";
              repo = name;
              rev = "24a9db129cd2e3aa2dcd79742b6cb82a53afef6c";
              hash = "sha256-5Fa/zK5f6CtRL+adQj8x41GnwmPWPV1+nCQta8djfqs=";
            };
          }
        );
      }

      # pets
      {
        plugin = (
          pkgs.vimUtils.buildVimPlugin rec {
            name = "duck.nvim";
            src = pkgs.fetchFromGitHub {
              owner = "tamton-aquib";
              repo = name;
              rev = "d8a6b08af440e5a0e2b3b357e2f78bb1883272cd";
              hash = "sha256-97QSkZHpHLq1XyLNhPz88i9VuWy6ux7ZFNJx/g44K2A=";
            };
          }
        );
      }

      # sfx
      {
        plugin = (
          pkgs.vimUtils.buildVimPlugin rec {
            name = "cellular-automaton.nvim";
            src = pkgs.fetchFromGitHub {
              owner = "Eandrju";
              repo = name;
              rev = "11aea08aa084f9d523b0142c2cd9441b8ede09ed";
              hash = "sha256-nIv7ISRk0+yWd1lGEwAV6u1U7EFQj/T9F8pU6O0Wf0s=";
            };
          }
        );
      }

      {
        plugin = pkgs.vimUtils.buildVimPlugin rec {
          name = "inlay-hints.nvim";
          src = pkgs.fetchFromGitHub {
            owner = "MysticalDevil";
            repo = name;
            rev = "1d5bd49a43f8423bc56f5c95ebe8fe3f3b96ed58";
            hash = "sha256-E6+h9YIMRlot0umYchGYRr94bimBosunVyyvhmdwjIo=";
          };
        };
        config = luaToViml ''require("inlay-hints").setup({})'';
      }

      # watch files - needed for pywal to pick up new colors
      {
        plugin = (
          pkgs.vimUtils.buildVimPlugin rec {
            name = "fwatch.nvim";
            src = pkgs.fetchFromGitHub {
              owner = "rktjmp";
              repo = name;
              rev = "a691f7349dc66285cd75a1a698dd28bca45f2bf8";
              hash = "sha256-GyTx/t6yH2jXwVHVldppcKmEN77YDC1feAYW5G/FEnk=";
            };
          }
        );
      }

      # code mini map
      # {
      #   plugin = (
      #     pkgs.vimUtils.buildVimPlugin rec {
      #       name = "neominimap.nvim";
      #       src = pkgs.fetchFromGitHub {
      #         owner = "isrothy";
      #         repo = name;
      #         rev = "505e756fc96d05a7c372792fe76e346aa0ed9240";
      #         hash = "sha256-HQEgVk3xdIihg0kVV83PikOo008DblDhxGGswKryvMo=";
      #       };
      #     }
      #   );
      # }

      # requires nvim compiled with +sound
      # {
      #   plugin = (
      #     pkgs.vimUtils.buildVimPlugin rec {
      #       name = "typewriter.vim";
      #       src = pkgs.fetchFromGitHub {
      #         owner = "AndrewRadev";
      #         repo = name;
      #         rev = "514eeb4df6d9ff8926dd535afa8ca3b9514f36f0";
      #         hash = "sha256-nsqFSG7qel1FM+s7CDceG4IhWgPpnWM1jm/jar0ywiw=";
      #       };
      #     }
      #   );
      # }

      # hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    ];

  };
}
