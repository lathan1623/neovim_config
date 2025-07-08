# Master List of Commands in This Config

**Note:** `<leader>` is mapped to `' '` (spacebar).

---

## Search

| Command        | Action                                |
|----------------|----------------------------------------|
| `<leader>pf`   | Telescope find files                   |
| `<leader>u`    | Telescope undo                         |
| `<C-p>`        | Git find files                         |
| `<leader>ps`   | Grep (requires `ripgrep` to be installed) |

---

## LSP

| Command        | Action                                |
|----------------|----------------------------------------|
| `<C-u>`        | Scroll up in docs                      |
| `<C-d>`        | Scroll down in docs                    |
| `<C-e>`        | Autocomplete abort                     |
| `<C-y>`        | Autocomplete accept                    |
| `<Tab>`        | Select next autocomplete item          |
| `<S-Tab>`      | Select previous autocomplete item      |
| `:Mason`       | View available LSPs                    |

---

## Common LSP Actions

| Command        | Action                                |
|----------------|----------------------------------------|
| `K`            | Hover                                  |
| `gd`           | Go to definition                       |
| `gD`           | Go to declaration                      |
| `gi`           | Go to implementation                   |
| `go`           | Go to type definition                  |
| `gr`           | Go to references                       |
| `gs`           | Signature help                         |
| `<F2>`         | Rename                                 |
| `x`            | Format                                 |
| `<F4>`         | Code action                            |
