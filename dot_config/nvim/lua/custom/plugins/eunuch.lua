-- UNIX file operations that keep the buffer in sync with the filesystem:
-- `:Move`/`:Rename` renames the file *and* the buffer, `:Delete` wipes both,
-- `:SudoWrite` saves a root-owned file, `:Mkdir` creates the parent directory
-- of a new file. Doing any of these with `:!mv` leaves the buffer pointing at
-- a path that no longer exists.
return {
  "tpope/vim-eunuch",
  -- Every command the plugin defines, because `cmd` is also the load trigger:
  -- one left out is one that errors as unknown until something else happens to
  -- pull the plugin in.
  cmd = {
    "Cfind",
    "Chmod",
    "Clocate",
    "Copy",
    "Delete",
    "Duplicate",
    "Lfind",
    "Llocate",
    "Mkdir",
    "Move",
    "Remove",
    "Rename",
    "SudoEdit",
    "SudoWrite",
    "Unlink",
    "W",
    "Wall",
  },
}
