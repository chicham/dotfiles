-- Resolves a jj conflict in a two-way diff instead of the three-way marker
-- soup: `:JJDiffConflicts` on a conflicted file opens the two sides side by
-- side, and the merged result is what you save. jj writes conflicts into the
-- file itself rather than to a staging area, so a merge tool that understands
-- jj's marker format is what makes them editable.
return {
  "rafikdraoui/jj-diffconflicts",
  cmd = "JJDiffConflicts",
}
