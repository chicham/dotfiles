-- UNIX file operations that keep the buffer in sync with the filesystem:
-- `:Move`/`:Rename` renames the file *and* the buffer, `:Delete` wipes both,
-- `:SudoWrite` saves a root-owned file, `:Mkdir` creates the parent directory
-- of a new file. Doing any of these with `:!mv` leaves the buffer pointing at
-- a path that no longer exists.
return {
  "tpope/vim-eunuch",
  cmd = {
    "Remove",
    "Delete",
    "Move",
    "Chmod",
    "Mkdir",
    "Cfind",
    "Clocate",
    "Lfind",
    "Wall",
    "SudoWrite",
    "SudoEdit",
  },
}
