# NixVim: LSP, Telescope, Treesitter, statusline — Stylix auto-themes
{ ... }:
{
  programs.nixvim = {
    enable = true;

    globals.mapleader = " ";

    opts = {
      number = true;
      relativenumber = true;
      shiftwidth = 2;
      tabstop = 2;
      expandtab = true;
      wrap = false;
      scrolloff = 8;
    };

    plugins = {
      web-devicons.enable = true;
      lualine.enable = true;
      neo-tree.enable = true;
      telescope.enable = true;
      treesitter.enable = true;

      conform-nvim = {
        enable = true;
        settings = {
          format_on_save = {
            timeout_ms = 500;
            lsp_format = "fallback";
          };
        };
      };

      lsp = {
        enable = true;
        servers = {
          nil_ls.enable = true;
          pyright.enable = true;
          ts_ls.enable = true;
        };
      };
    };

    keymaps = [
      { key = "<leader>ff"; action = "<cmd>Telescope find_files<cr>"; options.desc = "Find files"; }
      { key = "<leader>fg"; action = "<cmd>Telescope live_grep<cr>"; options.desc = "Live grep"; }
      { key = "<leader>e"; action = "<cmd>Neotree toggle<cr>"; options.desc = "Toggle file tree"; }
    ];
  };
}
