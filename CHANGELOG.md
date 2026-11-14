# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### ⚠ BREAKING CHANGES

- **Zellij has been removed in favour of Rex.**
  - The `multiplexer` module, the zellij plugin installer, `cc-wt`, `zbash` and the
    `cc-zellij` shims are gone; `chezmoi apply` deletes their deployed files.

  **Migration:** re-run `chezmoi init` (or drop `multiplexer` from `modules` in
  `~/.config/chezmoi/chezmoi.toml`), and `brew uninstall zellij` if it is no longer needed.

- **Modules `cloud` and `macos_desktop` have been split into atomic modules.**
  - `cloud` → `gcloud` (Google Cloud SDK) + `colima` (container runtime)
  - `macos_desktop` → `aerospace` (window manager) + `onepassword` (password manager)

  **Migration:** existing users must re-run `chezmoi init` and reselect modules.
  Old names (`cloud`, `macos_desktop`) are no longer recognized.

### Bug Fixes

- Improve pre-commit configuration ([f5ae4c8](f5ae4c833f35b1d8fa77d5ca3240772e592258cf))

- Resolve shellcheck issues in Linux installation scripts ([a83843f](a83843f0ed31cc0909f4e8acda851d84214334be))

- Ensure POSIX shell compatibility in conda removal script ([866febb](866febb349e0c1954e54b05f39d693720dfde0af))

- Ensure POSIX shell compatibility in conda removal script ([a4c9c0b](a4c9c0bb021ffbb0221c7ea60f14edb97d94dcda))

- Update Linux installation scripts with proper fixes ([5074f00](5074f00cff4d358ad0377659581c8b153ae0b3ba))

- Ignore envrc ([c32db8e](c32db8e78c8141c08ff39066244b7f67694db1f4))

- Remove unnecessary remote install ([7c9d9d4](7c9d9d4ff78a1434f9a0b3f62a4b10d4bc61952c))

- Various fixes for macos ([d80f717](d80f717ec945b825a0637751ac2861cbc21a52d7))

- Missing fish config ([87035ea](87035ea78877602cedf234613a9fbdbffc8eabcf))

- Duplicated config file ([bc85bbf](bc85bbf8afdf69350656ab75ac59e8bfbc9f979c))

- Empty fish_theme ([b461912](b46191290b0cd15b05ea779c2e02d2e919cb5f38))

- Template issue ([ffe8703](ffe870332d25d65da05e661f1e4dad7b6605f998))

- Use updated delimiters for templating ([404b26a](404b26ae18c63f7d29e57c3bfc644d01020ba1fd))

- Do not install already installed fonts ([15736ee](15736ee168fda440141a39625308f4d3b01bca96))

- Loading order of functions ([f888f00](f888f003fad74551e8973cacd83990c93ccc9886))

- Incorrect test of nbdime config ([9e92487](9e9248769d6527a92b417a48eb55a981ed389c8c))

- Incorrect test of nbdime config ([88d3525](88d3525554374cb66166d18b4c34db9b146204b1))

- Do not automatically login ([38d267a](38d267a0ccffdbe716dc0b26b3e6c4a1b6aa09c6))

- Git tools installation ([a90a8a5](a90a8a53944f3406c4a3534d757f721bf40797b3))

- Wrong variable templates ([6be8fd0](6be8fd0818d0bfe1e84dfb8acdac7532cf79a729))

- On remote server git may be blocked ([0ebd5aa](0ebd5aad9b5a641b793fac073cb033efb8490d80))

- Disable kitty mapping ([4c7f3f0](4c7f3f0f389c8238b5b456005f5fae22097488ff))

- Remove annoying nbdime message ([8196943](8196943a2565274daeea68eabd4d19d43058f23a))

- Various fixes ([de21731](de21731916a408acc8683f3ddbf0becd740c1266))

- Typo in chezmoiignore ([fc00e4c](fc00e4c84ae5236aa558c4ee130173621c54e207))

- Ensure POSIX shell compatibility in conda removal script ([60ab163](60ab1636da3b21f05201c3ddd1e7b275493114b9))

- Correct chezmoi template delimiters in conda removal script ([a739142](a739142d0150089847ae4fec40e01c4c2e480b15))

- Simplify conda removal by removing PATH manipulation ([41994cc](41994cc3eb7815dbe7316968a410d3fd46c6510e))

- Path issue ([2b65553](2b6555373f52d0273996bd3a595693488b38f5fe))

- Improve terminal compatibility and error handling ([0285cd0](0285cd0f410660ed7359474bf8c8f0de08d1cb99))

- Improve conda removal script compatibility and add proper error handling ([6fea8bb](6fea8bb36e41a9350172a9885102cc307d3b5aea))

- Simplify Python tools installation and force upgrade existing packages ([9479314](9479314fa434af401c01f538878d0b0e25a97a23))

- Improve bat handling in VS Code terminal ([4183dc7](4183dc724826e1d2e43874ea2bc9c2d9b34a9313))

- Improve neovim installation script ([dce5282](dce528243c6facf52fe501e3320cb38e4b24bf35))

- Resolve pre-commit errors in shell scripts and documentation ([769305e](769305e0fa3c66cc5f301202728e06fbedcfa797))

- Remove pyright and TypeScript language servers and fix lazy package manager errors ([f3bce99](f3bce99b2dcd528bc88780b50ef4cc0101a826e9))

- Add Git version check for conflict style compatibility ([095f309](095f3094cc9a7ecb5503b14629b4248b958de72b))

- Remove tsserver specific case from Neovim config ([21c3b67](21c3b67db2abf1d96c5c7b5c44e2465a693fc462))

- Improve 1Password CLI installation with templating and better download handling ([a8c3e15](a8c3e15232b6036746bf7fdd450819090f31aabc))

- Update gitconfig template to handle empty name and email values ([0d2e253](0d2e253b2a689e417d24a1d3fd4bb181f2dde45e))

- Update Git version detection in dot_gitconfig.tmpl ([a606cb7](a606cb734ac8ea1537e41792c1e5a7e6a6e45d64))

- Update Git version detection in dot_gitconfig.tmpl and diff configuration ([e12b781](e12b7817da43ad3af4bbe45f7430cbb005311f8a))

- Correct Git version detection with proper whitespace trimming ([d8ef554](d8ef554940efe3e6e9d7ed7423f07dd0f5c99b03))

- Only execute fish shell in interactive sessions ([ee7696b](ee7696b5d89fb3e51c599ea7185776eed5e57c00))

- Prevent ssh agent forwarding issue but unsetting SSH_AUTH_SOCK ([530a20b](530a20b33272a8fa5bdcfad3c77658fcd676c082))

- Correct WezTerm configuration comments and resolve key binding conflict ([ed5cc91](ed5cc9164b350c308e654c5d93e7eba43779fd56))

- Add brew existence check before calling brew --prefix ([434d9b3](434d9b3d676acc7230e03a8a76cbeecb039c29fa))

- Use safe treesitter folding with fallback to indent ([a38e648](a38e648c94dec5e99e93afcedf49bd37ad1d5205))

- Use mktemp for safer temporary file handling ([815ab79](815ab79e1dfac533abda155f1a00bba619737824))

- Update mason plugin name to correct GitHub organization ([53ca671](53ca6713c7c9dea3ff3874a1cf12ce7ec8bf655c))

- Better image ([fd240b1](fd240b1835aa8a1c9b4af0209c776f293d28de7c))

- Better image ([034abcc](034abcc87b6bc0bcca51422bc26e6a4e44b9a922))

- Update template configuration for dynamic GitHub data ([6cec36d](6cec36d3c411d0de3c95e2bfebc51c00791754e0))

- Update WezTerm installation for Linux systems ([ae93773](ae93773d0ad0940bc27708777c7f23310441f683))

- Syntax and formatting in configuration files ([20b70b5](20b70b5e7d6ea0713cba00e711d34e13080fb804))

- Conflict markers ([b36c08d](b36c08d66271999bf9d82a60457508cc7d197d6b))

- Remove terminal reset on window focus to prevent blank screen issues ([7ece8f6](7ece8f63e751576a419bfc2453aad29f993f29de))

- Properly quote path variable in 1Password CLI script ([c856bc2](c856bc27f77742bf564ba47ce9455c54b1e8d588))

- Improve WezTerm terminal compatibility and scrolling ([34d5c68](34d5c68e62aa8c528f4ea072c74e49ad88402616))

- Optimize lsp_lines plugin configuration ([898bdea](898bdea8e900695b39380dc86975608aac8696ea))

- Improve diagnostics toggle and plugin loading ([02a5fee](02a5feec392ee09332badec89a55ab58a4fbf58d))

- Handle multiline GitHub command extraction ([45491f8](45491f829ddede659c8ebf3979b2ec37fbbe5c0a))

- Remove cliff from commits ([a86742c](a86742c18b5b972f299e618f334032c43c5ee897))

- Skip copilot installation if already installed ([134894c](134894c710ee77649e8d90b85ac2d744eb455030))

- Change branch.autoSetupMerge from 'always' to 'simple' (#57) ([e5b229f](e5b229fa362766c1a5fb72053579622b72c68221))

- Set vscode as default mergetool, remove fugitive (#58) ([bdae882](bdae8828695f8ea55569009f27e4cd27faf31e20))

- Manage abbreviations via chezmoi ([58178b3](58178b34d22f8bd7c8c877ee70692b6d44ee454e))

- Use target paths so module gating actually fires ([e4659bb](e4659bbdf1e230e82e57e8bc4b9f8bf9d736c014))

- Silence shellcheck SC1091 for nvm.sh source directive ([6901f9a](6901f9aa5457938be17c1f0edff49767de9d1dfb))

- Chezmoi path is literal, not glob — use stripComponents=1 ([f983272](f98327244cb0839f30f2a2dc6dcebc73202d3707))

- Allow mamba (no longer blocked) ([d384a20](d384a207eb50a62311d666caa8bd633e41e9b7c5))

- Replace dead links + tighten path-existence regex ([2e8bd61](2e8bd6197b1799bc68ed78f848f121a124e6f280))

- Replace per-package brew tests with generic iterator + install yq ([b115426](b1154260905433e2a3bc860d49fdcc9bf6b01730))

- Convert to .sh.tmpl with auto-update + safer install ([5d28cf3](5d28cf38c76aeb60bad750c7c954ee6acc8d65d7))

- Bootstrap brew on PATH after fresh install + harden CI ([9fc6fd4](9fc6fd4862b70e2f98b9075397b9f1d7f26c7329))

- Rewrite readme path-existence as a chezmoi-managed check ([b701b7a](b701b7ae3fd80d3f3ae3ba1e60ed32da48dc0f2a))

- Always install fish to ~/.local/bin, ignore system fish ([0abc8c8](0abc8c8bc4cf43ac763307d86414322a6609552a))

- Bug fixes from review ([eab50e5](eab50e557e6e4be3fd7b7544fedbb85571ad5183))

- Gate git-extras and 1password installs by module (#88) ([da6c218](da6c218328cebd0cddb3d2e5931425b3032bdcc8))

- Make python-tools install hash-gated (#89) ([1ca13ad](1ca13ad9116db71494fb6d3ec7f1cc325e4bc31b))

- Restore line-1 shebang; add render-then-shellcheck and fish syntax tests (#91) ([480b9ff](480b9fff24f745ce36700cafb91df8d559933fd9))

- Drop uv duplicate, dead libc, tautology; add OS/init/externals/module-gating tests (#92) ([8efb909](8efb909f51b4cc4a39488ad6adabcb0159570374))

- Restore init.lua.tmpl — file has darwin-conditional template logic (#96) ([eb7780e](eb7780efa6325573f5540e113ed67f50a4d93ed8))

- Restore .tmpl extension on dotfiles_doctor so OS directives render ([d02de5b](d02de5bc6277ff91478dd53d6da4f557a3a9eff2))

- Use gh --jq instead of --template in review completions ([9f9b9e0](9f9b9e0dbc1b992ef826738a4d815e0f803e1e0d))

- Restore launch.fish and watch-file.fish dropped by the artefiles merge ([aa5664f](aa5664f8bf2f61119d60a7f3c84d0ee07075283c))

- Exclude tests/ and docs/ from being materialized ([86f8cf0](86f8cf0d1207c40d224ed028600f7fe0c88b671c))

- Restore fgit and fdeep aliases dropped by the artefiles merge ([2a5a8c4](2a5a8c46ce9aec35a1072fe0dec7d5d434f68602))

- Correct op:// vault name for the jj/git signing key ([f206d02](f206d02bc61f80ebb332bb72b1cfaf34f8f0acaa))

- Exclude the whole .config/Code and Library/.../Code trees per-OS ([5f8dd95](5f8dd9574944a2755f664c73eec281bbca18339b))

- Move vcsigns diff-base navigation off ]r / [r ([8f3032d](8f3032d4618fca1177be581b5444c18b0beeeeb1))

- Bound the treesitter context to four lines ([233e52f](233e52f525fcd1942928ca3d5cb60f1f40388f83))

- Keep the visual-mode maps out of select mode ([a0a594b](a0a594bb793ae5e850ef8a706cc29547b55462b2))

- Run the macro instead of typing it on the command line ([7908ec4](7908ec4e16d91e08531ee6c5dbde8eb4cf34632d))

- Create the daily file before a quick note capture ([3e33052](3e330525a3e776f6a28570fdecd138eecef28b07))

- Resolve the review export path from the file being commented ([6798293](6798293d9039463b44ea99fde9cb53b78253758b))

- Open notebooks as text instead of raw JSON ([82849f2](82849f26bea682ce3863e279c0b19b40581aa319))

- Drop the empty plugin spec that would break a fresh apply ([757174c](757174c652e238659d8e008f28f28bce46108d9f))

- Declare the review keymaps so which-key can show them ([474adcc](474adcc8c8c54d4949f49ee285b8ce20ccc07780))

- Load better-n before the motions it observes ([f68e57c](f68e57ce7de533d93201185ec2c0bbdbc1f4d9f0))

- Drop nvim-chezmoi's misnested window option ([6978c57](6978c577fb8609e167e2231cacfb328c00f98a56))

- Clear person_name after the capture that set it ([95675e4](95675e4a32b3b1202def595e10deef13fcffe25c))

- Wire better-n's n/N mappings so hlslens runs ([5322154](53221549b2aa594efa92f0707b60b64e5e76edb5))

- Stop formatting c and cpp on save ([6334afd](6334afd004201a660255eed444283cd1dafd68c4))

- Stop forcing wrap on every buffer read ([4eaacb9](4eaacb94ffae403a69a743ebd2be9944d8b96b31))

- Scope the diagnostic jumps to the attached buffer ([cd3796a](cd3796a17b5cd0082dbc0a9cef2d4f3263e749e1))

- Keep the diagnostic jumps off orgmode's timestamp maps ([16973dc](16973dc28320395ab56ec5e5a3e76c21efe5c831))

- Escape the org keyword patterns in scan_people_files ([9e542a6](9e542a697cdc19dbc1da3c0025a486cbffd126ed))

- Stop a background buffer from unscoping vimtex's jumpoptions ([d99c546](d99c546929e33b318304f530a70676301589fdea))

- Arm coderpad mode only on CODERPAD=1 and silence snacks.words ([3709b0e](3709b0e0735ed4dfecfb19c650a00d8aec0a5d7d))

- Route the org project and export commands through vim.ui ([598534d](598534d9e74902222f5485e4cfe26bceb50b15e3))

- Resolve renames to their destination in JjReview's file list ([4e0801d](4e0801d404d3dcc396b10e91d97f23d98fb8d3c6))

- Call guess-indent's setup so it detects indentation ([4338163](43381636e00e2269c0a3e750cbe6ee674bba7013))

- Keep the review comment list out of vcsigns' diffview ([012fe74](012fe742e362b1e85e63aab92bb9497536bc9a46))

- Hand ]b/[b to vcsigns explicitly and correct the comments ([38a3cbf](38a3cbf3bfd1ef31b9df9faef527a5a854703adf))

- Anchor the hipatterns keywords to a trailing colon ([75dc6d7](75dc6d7a56f102afaf33de0dca3114c43c8ffe07))

- Skip the cursor restore in commit-message and scratch buffers ([756ee75](756ee75f917d632fa6c0ecde1dd0020d72fd5f93))

- Load vim-eunuch on its remaining commands ([7276770](7276770b5a497072eb6f102884b0b77749140f1f))

- Restore the cursor on BufWinEnter so the filetype guard applies ([1ee2328](1ee23282b0e427f38e61e698fb20ca789a1fba53))

- Load vimtex on :VimtexInverseSearch so Skim can reach it ([6984d34](6984d34c25b6d5d092173be9a110eb2efaa18baf))

- Fzf Tab picker keeps ~ and $ live and handles quoted, glob and mid-token input ([494aa90](494aa906af8f34ad50b503995fae7d6dd46cc5c1))

- Match config.fish to the live file on macOS ([31556f8](31556f8d3f80296b70c6dacd76865211d57d341b))

- Read 1Password secrets by vault and item id ([6468c0d](6468c0db54df9499de77a4dd3649257015044271))

- Track the start point of every new branch and document the live settings ([431fc11](431fc1174173270cd2208df4371845af4f296d96))

- Reuse a new session's first window when a pane attaches to it ([32145b1](32145b1a35a94f36da8c336804e2ea995724e8ae))

### Chores

- Update README with recent changes ([aedab3c](aedab3c5956f7785eccb1597945eff167b2a5750))

- Update chezmoiignore patterns ([b0d5c15](b0d5c151b283d146fe4c502f12f05aa449dc7316))

- Add gitignore for generated files ([33fb917](33fb9176157657b2f04f6fac20128ae507e68695))

- Pre-push fixes ([044cc87](044cc8762df206fe283b71476db0c45db342ed48))

- Remove catppuccin fish plugin to avoid duplication with terminal theme ([25ddeec](25ddeec4747119bf3cb92f033de54d9a47c069d4))

- Better error messages ([0238912](0238912922f78b90072ade4a4a65860372375d0f))

- Add comment ([57a8122](57a81222f314a5697a1e52e7a4ee3c3b0275bc51))

- Remove unused test-variables script ([02f240b](02f240b7620848fa46267e1b983f5ffd10ddd005))

- Update fisher script and add rsync plugin ([5a63d80](5a63d803ae2d3f3da8891f26f9f7b9fe48e6edc1))

- Exclude external dependencies on non-Linux systems ([42b7614](42b7614f098edb1f2389276ec2f1e9215e51a986))

- Add Linux external dependencies configuration ([3b06707](3b067072c9e6fb9f1323e5712aa0cfdb560be591))

- Remove deprecated fish functions and profile templates ([28e1a9a](28e1a9aa81277dcb83f7ee6b0128004323b6588a))

- Configure Git LFS for PNG files ([9efd3eb](9efd3ebcb7e0c3e4de24f51ba53b82969126fcc5))

- Remove unused colorscheme ([dbc8514](dbc85140045de97af083a311c9fb4b12a136d59e))

- Remove outdated command template files ([f56ca61](f56ca61bf7bf32d6a6abd14577dcb9c22a36da39))

- Correct local config file path ([3f4e433](3f4e433e0d63d2b036b0da6e13db5bcb2d9a599d))

- Add 1Password desktop app to macOS casks ([adad5b0](adad5b028a4a00432cac01d56218d46876a08624))

- Disable gcloud and pixi modules ([94e650c](94e650c3cfbd475f409b07169f988aea85c67a98))

- Backup ([e97f163](e97f1634289138d086f6c4c6671ef7fe447ad6bf))

- Update gitgnore to exclude .context directory ([03decba](03decbaed5ad411ca45a6ce0ef25e8fb27e493a7))

- Point the skills alias at gh skill ([8680008](8680008f66fe8217dbe1f79357930b8f5f464c2c))

- Update chezmoiscripts and packages.yaml ([587e504](587e504311dceaa3d51c1e4e6b9ba60cdcdd6753))

- Update config and README ([ff71476](ff714764d7e245634dae7043272b9d0819feb5f8))

- Update external tools list ([82f3e03](82f3e03ae0975ebb8471995ad1717553734424b3))

- Adjust bat and starship config ([b740ade](b740ade4bbed7575e34e95f7476380ae64cd32b4))

- Update ignore and pre-commit config ([d024d7b](d024d7b3f97867857dc984bbbd34f0939e0a153f))

- Update install scripts ([076b205](076b20538f01419aa8bebfe72b5d954a13680656))

- Add global gitattributes ([682a3fe](682a3fe0058c42070129c70e6fc86365ff8f3805))

- Remove config ([42d27d3](42d27d34dc8c599fab343ceb47382819569eee5b))

- Update docs and fish aliases ([9113350](9113350976380eebc2855d5c8de0fbe8fb5bc640))

- Remove duplicate script run_onchange_after_install-fisher.sh ([98d481f](98d481f543c1add2e5ebfb5ef09223ed86bfa0ae))

- Drop references to non-existent files ([d19d655](d19d655200e37c0d39f095a38b55294859a7cd57))

- Remove wezterm references ([df68f12](df68f1212f0fcd72281fb0b2de101293bce9bcbe))

- Remove glab references ([94ec76e](94ec76ec797ce416c1dd502040030f9639f86d3a))

- Resolve mergiraf version via codeberg API at render time ([2677387](26773874d4d8b8cb20ab3470a7fc11d347f74f94))

- Merge artefactory/artefiles upstream, resolved ([f66f530](f66f530b40ab3e3a49ad177c2b6d167c8807b9f2))

- Sync claude/nvim/starship/agents.md config from live customizations ([f2ee924](f2ee924ebfb6331165e39a15fb13da4055f017ba))

- Sync templated configs (atuin/fish/jj/zellij/ssh) from live customizations ([2598150](25981501d46a036a7567b748aac60ab53cf5e6ae))

- Remove claudecode/code-preview plugin configs no longer in use ([1b1be70](1b1be70124eb0f33fcc4dc435b18e7545615ba8e))

- Merge artefiles-sync into reconcile-live-config ([72beace](72beace8b2748e17c58476e045cf39575b754d00))

- Stop managing .claude/settings.json ([c3afa7d](c3afa7da0e12f21e6617bdf6514797a4d7cea918))

- Refresh plugin lockfile ([3cf3b29](3cf3b29c6941bc26605baa6087eeafe5ccd79b0a))

- Ignore local review comment files ([0d6a034](0d6a0345742185e3b8acbe45ac4f94fb2a826058))

- Manage nvim quickfix-review plugin config ([9c6cf7f](9c6cf7fc666c90a12cd5d82f3d0df805dd97afdc))

- Drop the kickstart placeholder from the plugin directory ([158cf2d](158cf2dfd1c011aa63cab5bf6d10b51a7bf554d6))

- Track the config files chezmoi was not managing ([ff9c6b7](ff9c6b7b3c51ec42724638bd8527b840afafa554))

- Drop the redundant plenary declarations ([40214a0](40214a0cea748a43751f2f0d84abc1d9462f7010))

- Drop orgmode's unused nvim-treesitter dependency ([90c91be](90c91be2cceebcf46fddeb9094000e8b41c3d21e))

- Drop the unreachable direnv spec ([7c41770](7c417703aa3e874a42ab825203e90b58d81fa7ae))

- Drop dead spec declarations ([4c789f6](4c789f671ca677dbfeec4d018613f582e0150d2d))

- Drop the code-preview picker for a plugin that is not installed ([0461dab](0461daba24f1f5164c025c2399fe9ee9bac0d829))

- Drop the unused orgmode helpers ([1789a0f](1789a0f89fdb33a3435868b4fa0b3d45a0e9ba93))

- Drop the orgmode settings orgmode does not read ([1e8b5bd](1e8b5bd25f117f38e11f7222110ce202ac1fd9c6))

- Name nvim-hlslens the same way in both specs ([05def9d](05def9dcaa2e2768e105d0bd75501c30a34abc71))

- Drop the custom theme detection and remove retired targets ([427c8d3](427c8d3650fff4fd24ef0d0a2474a05efe27cffd))

- Remove the old WezTerm config ([528ac91](528ac915221261f87b4d044dcf0a6e7b94d16e66))

- Sync AGENTS.md and global gitignore, document tab-pick ([625c973](625c973987226f2bbe20425acfba2bdda6928dca))

### Features

- Update README and add Git template with pre-commit hooks ([18a9e42](18a9e424e26485c793ab74eef1007d36ebe08cbd))

- Add pre-push hook for changelog generation ([5dfd99d](5dfd99d225e3d9aa474dee129f5c449f84867729))

- Add VSCode as git diff and merge tool ([73a4b0a](73a4b0a89f54fae66051ca64863309be063d513a))

- Add VSCode installation scripts with Pylance extension ([f63bfe1](f63bfe1e9d3ecb550f982a6e233f615711a6be30))

- Add Homebrew installation script and configuration ([9ba174c](9ba174ca7ee4d78c9cf0469c07587b9b6d8bc058))

- Add Google Cloud SDK installation scripts ([62b09e2](62b09e2f3a05c1b80cc411eb3ffba26e90fe3187))

- Add Nerd Fonts installation script ([e42159e](e42159e1c2a1fb6b1c29fb30f5ba166d6e8aaf8e))

- Add Docker testing infrastructure ([812f928](812f928b0c6c271d0e9ad5cd6d3518e5e84b5688))

- Add theme system with USER_THEME environment variable ([f43deb6](f43deb60fb0e0156dfedda0054fa12d252c3922d))

- Add Gruvbox Material theme support ([606b13d](606b13d95f3ba6915bd54a6551822eae1cbc7917))

- Update bat configuration for theme support ([316e955](316e95578a4b06f6094b79a00c0423cb14554cda))

- Update direnv configuration for uv support ([e84bbc9](e84bbc9b35f534a49d33e8339d999416b18b7a9a))

- Update config files for improved user experience ([621ac7f](621ac7f76b79ca2cefbb26708c3bf635d09e99dd))

- Improve Linux installation scripts for better reliability (part 1) ([223f559](223f559107a36154c654feab00605de37be4eb54))

- Add Nerd Fonts installation script ([dcae7a5](dcae7a598de3bca9e3f4c59c2638e4266f407891))

- Add Docker testing infrastructure ([3505d5b](3505d5b46c15807cba425d57f0cb50146e368ad4))

- Add theme system with USER_THEME environment variable ([224599f](224599f8f86be79de5c7bc0d4623abffdddcf222))

- Add Gruvbox Material theme support ([5f3df89](5f3df89bd1f3d18540cd54f9cea9fe3817fd08df))

- Improve uv installation script ([7058bc0](7058bc074bfd309e921780cebd77a8a99b0be669))

- Add chezmoi configuration and 1Password CLI installer ([cfa310a](cfa310aa76aaf2349de9d3cb4b4705c0d77088c5))

- Add packages data and consolidated installer for macOS ([6432480](6432480ed6a384a72b9a15e5c929311ad4495d20))

- Add test variables script and bat theme installer ([b06f625](b06f625a261dfc708abc23e5f0622932e7c5c66d))

- Add configuration for aerospace and atuin ([802f6d5](802f6d5881330c08522e61d806934eb2534586eb))

- Add 1Password SSH agent integration ([feb03e3](feb03e3f2d2428ec1923236c534b9e3d0418da4d))

- Add python tools ([1c18a1a](1c18a1ad1e928e961453af75c1a444c400c7371f))

- Add wezterm config ([7cb6170](7cb61707153395f7cc0c72ce8b59917a88294945))

- Fisher plugin manager for fish ([8f7ab2a](8f7ab2a0112aeb0e325dded058e075bb9f9be562))

- Use nvim as default editor ([720950e](720950e1641fa3e7a9cd7c2008cc16d103dab6a4))

- Remove possibly buggy agent ([18228b5](18228b5c0cea54b54ab092e07987db9a0da3fce1))

- Add 1password desktop ([8022676](80226763b28b8af0d157dafb6677d49bf57a6253))

- Remove 1password ([85c29e6](85c29e63777e044a05e16f41c51ecfc61ef59f49))

- Add github cli tool ([b158aae](b158aae92b56f9f7d309859d8de1c0b3fef75c82))

- Add doctor function for debugging ([e42c786](e42c7864065e2a0f03fc8e3f339f05af260d1800))

- Add git-extras ([d44712f](d44712ffc15d78e2263ead2cdecd1a5807dd7279))

- Uv install on linux ([9dfdc7d](9dfdc7dafe4f5163c18ab629bd1562062b171ee9))

- Re-add gitignore and changelog ([1fa0bf3](1fa0bf36aef27b935a84bb33897a9e0b0614ec8f))

- Installation of fisher for fish plugins ([e8c226e](e8c226ec90d41cddcff6da3cebb4629f826bdb64))

- Do not install already installed fonts ([435212d](435212d66c9f8b027dd3ed5dd578079a170d9d13))

- Avoid reinstalling existing themes and components ([548e503](548e503cb6906651bb0bb90b4ee82d78bad93731))

- Improve chezmoi integration ([087d833](087d8332602d7a0060a5925af7418170540357c7))

- Only install fira code font ([baae163](baae163353b1f7ca6dc39bd55bcefd6d07ebfb24))

- Improve Nerd Font installation with fast detection ([25b9407](25b9407eb630d37a0a652f53cea4d251742b239d))

- Add notebook diff config using nbdime ([731e1b8](731e1b8e2b8a677e2fe184212da764d27163b0ab))

- Shorthand for git urls ([fa63eba](fa63ebaebb11fa78c6fc8ec56ba8b7dceff30789))

- Installation updates ([a261efe](a261efe25090a1de09575a976f0873a932e7d1e2))

- Make watch-files friendlier ([f6e8534](f6e8534c623fcc7e7e6404b5ce7d79e92e735fef))

- Build neovim from source for better compatibility ([2484246](248424666f1ca8c4b47fb5381c58887075a8d9c2))

- Improve conda removal script with PATH cleaning ([ced3520](ced3520158d9527056612c80f9cae57f2a9527d9))

- Build neovim from source for better compatibility ([6ba96a4](6ba96a4ffca2349e63fb71a1b8c676e4def66de3))

- Use github cli to dynamically configure git user info ([136c9bf](136c9bf0784d8f2b32aa75dfc72e68a958e4d687))

- Make github auth mandatory for installation ([6b11b6b](6b11b6b874eb386250cdd9db94842028a551fe35))

- Improve errors handling in the script ([4fca49b](4fca49b007425a199916bb42a8e541fddac5d99f))

- Configure inline diff display for git and chezmoi ([cb9e064](cb9e064746f213ec0b9b4b9927a26bb5a4778c8e))

- Add 1password-cli to macOS packages ([e48bfa1](e48bfa1d161256c1fbbe6144621855611acf131a))

- Add 1Password CLI installation script for Linux ([850ce20](850ce20de81dec3fe548f27da46f0da603ba29e0))

- Add 1Password CLI integration to fish shell ([4f9afcc](4f9afcc321e90b131106ce04aa643052617775b4))

- Add Catppuccin Mocha as default fish theme ([fbe2fde](fbe2fdeeb811beb1e57b285ddfa4f4f2f59099dc))

- Enhance Git difftastic configuration with syntax highlighting ([bab5428](bab5428852a20aa98ab30bac00a3a718f2530480))

- Add GitHub Copilot CLI extension installation script ([91492a5](91492a55bb046f79e9aa90ed43c4cddf5328f6eb))

- Upgrade shared WezTerm configuration with enhanced settings ([4d3505b](4d3505b2f6e12436d30685f4f7832e9e95724afa))

- Update shared WezTerm config with personal config improvements ([11c6bad](11c6bad704bcf363c780ede7f44a2b424582fc72))

- Add credential helper and update merge/diff args in chezmoi config ([63ca394](63ca394d03c38dd447b4a3051cc25a45a8edae33))

- Configure Atuin sync frequency and filter mode ([2beb159](2beb1595246d9b920f2edf36bf59bc2c76b3c08f))

- Improve WezTerm TERM setting and Atuin key binding in fish config ([80ff570](80ff5705b71e7f041c766b40c21b07075ad5761d))

- Refine Git configuration with updated pager, aliases, and credential helper logic ([7a2ee4a](7a2ee4adf60777f0ff65b2ae263af44d28a2b412))

- Exclude macOS GUI configurations on SSH sessions ([0283933](02839334bf7ea6aa1b15f813f82c00c3bcd086df))

- Ssh-agent configuration ([f64a41f](f64a41fa1b2c6568b0f286ab623688890d70f206))

- Add helper function to use fugitive with chezmoi diff ([d1cd7e0](d1cd7e0a190020cec86d4d71fb3247168f826ee3))

- Add op plugins config ([4e08b28](4e08b2816c2412d048ca30e90441f96b0d4a1f98))

- Enhance neovim org-mode and org-roam integration ([b376956](b3769564af55f9f3494411b73f0a5a4310550a10))

- Add GitHub Copilot CLI integration ([5165bee](5165bee515beccaf6aa735f53a9e132664240ccb))

- Add comprehensive unified Git plugin for Neovim ([2d7824c](2d7824c026520c8ff8c56601ba551b6e67d473b1))

- Enhance SSH config with improved stability and 1Password integration ([7acc3dd](7acc3dda73837ca0c1115aba91ec8274633e8dca))

- Add LaTeX configuration with latexmkrc ([8cd0366](8cd036651b71cfc69256a6d45f0d2e14ad8b148a))

- Remove chezmoi.toml.tmpl ([b92ea4c](b92ea4cf76accb22b8e49b3158882b1c25909ac0))

- Add chezmoi aliases to fish shell ([31d9832](31d9832044de33bd9a204f5797ff3e8073548269))

- Update and refine Neovim plugin configurations ([b80eabe](b80eabe185b782504b79223428432bf6671aaf50))

- Enhance Git configuration with signing and aliases ([fc0263d](fc0263df84797ec844dd03748d69baa3f26334d3))

- Conditionally include Colima SSH config ([0b7dd84](0b7dd841d82e5a6c1926bec37d79b0891565cfbc))

- Remove gruvbox-material.lua ([ee74fcc](ee74fcc4f8cdfebda041b93d3259039d9c6a9fd2))

- Update atuin keybinding to 'up' ([ceb5ef8](ceb5ef83a09cdd5d9bc76aad6e645c379c26933d))

- Enhance Git configuration with signing and aliases ([102a574](102a57447bada41d46ead8a1c03d21be9fa4dcd5))

- Update atuin keybinding to 'up' ([f945f13](f945f13075b572cb065de8cf6f591d08dd228750))

- Remove unused Git visualization plugins ([35168d0](35168d0f54063d1f0f11af468111cbb3bc2d9756))

- Add Claude Code integration plugin ([157da7d](157da7dcea41e6101a134ae74af776fa3f6ca3c7))

- Enhance agentask and agentcommit functions ([492a996](492a99667c5838e3aec72cafe913ada1ac4d33ac))

- Enhance PR generation with AI model selection ([c1bd924](c1bd924cc7faac904b0177e78edb74789d94c61f))

- Allow editing of generated commands ([511e244](511e24469d4a3832b834d6b44f03f0ffd414efda))

- Simplify AI commit message output ([0288ecb](0288ecba1c2d1c7b2b73bdcbfc3ceccab913c0f1))

- Add codex agent support ([ec40496](ec40496821ce21112bc409b5b29a272f9792def3))

- Add nvim-origami plugin ([9c0354d](9c0354dd0ecb68452906cd960e2620308cc09741))

- Add claude-powered agent functions for Git workflow ([fbdf365](fbdf365e82b7ee1fc310745c3934307c6864bfd5))

- Update command templates for more clarity ([6b02d9c](6b02d9cf73d4f682e12b22730e87869f38ffad76))

- Update LSP configurations for Neovim ([48777e5](48777e525e52d12200494a14d6999d4344696edb))

- Update plugin configurations for fzf-lua, lsp_lines, and trouble ([343f61d](343f61d2fd196e26ee04aaa4449e4d136c065953))

- Update configs ([6f108cb](6f108cba909c4bbfe683dbe0091eb73da8014f4e))

- Replace wezterm by ghostty and zellij ([bcbe594](bcbe594f72c013dbf2d529b7d47d5bea49cf338c))

- Integrate mergiraf and configure jj ([eebdc91](eebdc91fe3642073bda64f120bd34dcc850373d6))

- Migrate linux tools to chezmoiexternal and remove pixi ([99532e7](99532e79658ff9bd3ba4392b8702efdd4b5133da))

- Add automatic installation script for zellij plugins ([4a4cbd4](4a4cbd4149c97f6f523e37a31a822dd742345df6))

- Various updates ([76170f1](76170f1ae866d8e2cba5d820417e42f7bacba13b))

- Update tooling and hooks ([9ed770a](9ed770a54c8290ba8da1d2c510041ea8eeecd4ca))

- Add new org-roam workflow ([470f17f](470f17f51bceb5c8f63c2636c1cad9ab178a85f1))

- Simplify nvim config & reconcile chezmoi source with live ([8adb9bb](8adb9bb747bf4530fe9cb3b7b6ed4b85a2f1f893))

- Adopt skills CLI workflow with custom-skills, agents.md, and tool symlinks ([55a41ce](55a41ced30dce309a7325d56649dcda3919e3657))

- Add custom compact-help layout with compact-bar and status-bar ([f771883](f771883aa2c0388040741a9e162a4c19ca4afb9a))

- Capture remote registry skills in manifest ([bd0c457](bd0c45722200d5f2c744ddaaf3f188686a1d2563))

- Declare bun runtime dependency and switch CLI to bunx ([be4cc68](be4cc6876cb35eb5623c5ab48367241bac85e8b4))

- Add tmux/git shims mapping claude --worktree to jj workspace + zellij floating pane ([ddfd55c](ddfd55ced63f05e3ac1548d2a080eef13829db5b))

- Add cc-wt launcher for claude worktrees as zellij floating panes ([823a96d](823a96d6c3e1d6506ed54a79541a85264e24ee8d))

- Add zellij skill running bash in visible floating panes ([7d400f5](7d400f580ac14740513b98cc186f0eee5846bbd9))

- Provision agent skills with gh skill instead of bunx ([f4bfb7e](f4bfb7e73a40bd5f491c99280f24b216addc8ca4))

- Atuin desktop on macos ([49bfebd](49bfebde479eb60a1db8f69986e5261ddb81d20f))

- Update fish shell configuration ([db0b2a4](db0b2a4caa294b76e21c6f6b346b2aabb0197dae))

- Configure mergiraf merge driver ([b375c69](b375c69327e4f5d2bb8c3d66cf2557ec2d8bea42))

- Update config and add fisher installer ([4502ebf](4502ebf6eed9cfad278b0ae1436f3feae8d6c5d3))

- Add config ([5cfaba1](5cfaba1df051ad27b6ee2e26f239617523fe41f4))

- Install FiraCode Nerd Font via Homebrew cask (#60) ([7c6e4d8](7c6e4d8ec2708fc8ef6f08755d016d9c7655f284))

- Install VSCode and extensions automatically (#61) ([4645629](4645629203a9ad9c1b60b227674b91b5fdfedba4))

- Add tilde sign config for mac user of ghostty (#56) ([978542c](978542cbb8149f5302a675c7a0f29b148e072ea6))

- Add common abbreviations for fish ([f76cb79](f76cb79533a4903a5982861db8e30372bf69e016))

- Implement core + opt-in module system ([54a617e](54a617e6892cf4fd192209e868281d936f6788e8))

- Uv config to protect user from recent (<7 days) malicious packages ([7ac6c6a](7ac6c6acfbb1cc69a6b684d8e6c37093422e28e1))

- Remove and block Docker Desktop ([302831b](302831b56fe642ed9a1e2aad5acba5805ba5b483))

- Warn when Docker Desktop or conda are installed ([590b385](590b385e35cc3450a6d3f12ceb3f4944d276c6e1))

- Add gh to core brews ([028a325](028a3255302ac3d8456ae61d436b65f6513d0dbd))

- Add chezmoi script to install gh via tarball ([606d114](606d114a7659b957d791014e22ff1d932f2c9e1c))

- Ship default settings.json via create_ template ([8cc711b](8cc711bfcada2fe178bca7c4f13955d48555e091))

- Re-run fish installer when upstream releases a new version ([3e8e402](3e8e40270c4ff2c23a0cb523893ebc7599bb4c29))

- Re-add git-extras to git_advanced module (#85) ([b64eaa6](b64eaa65d4a1b0868c5be6d413bdfc69c1c1777c))

- Add direnv extension (#87) ([edf3137](edf31375fb3eeca232ab5d8da60f9a4b73f7a9eb))

- Add procs, dysk, sd, hyperfine, choose to darwin core ([00200e4](00200e4eaeceac637fbd84e1e928fa01d153e92e))

- Route Tab completion through an fzf picker ([0ca88bb](0ca88bbc41bd21eeee2bdb15d2472cfde4dcf92e))

- Add tuicr code review TUI to git_advanced ([fe08719](fe0871993f6b40ca3b809022b7201b7f7dcb6950))

- Add review command wrapping tuicr, discoverable via Tab ([9a7b1d3](9a7b1d3c204c5cfa4630ebf5cbdeaa88d4548f62))

- Auto-install curated agent skills via gh skill ([73c884d](73c884d4bca20bcad40de55d49bac770bba9dd30))

- Install agent skills from artefactory/skills, not a hardcoded list ([c6db78b](c6db78bd47124a51dbab40039c47497adbae6159))

- Adopt untracked fish functions, completions, and conf.d hooks ([b014715](b014715fa57e985fefa0625d0acb17d1fc173c00))

- Add nvim AGENTS.md, lazy-lock.json, tuicr config, gitignore_global, shell profiles ([e719619](e7196198298cf1c36e99ba8e92d5850c4051d24d))

- Add zjstatus status bar matching starship theme, bind layout-manager ([ef62d82](ef62d8213e81cf65e3b10927f25797a8ec660780))

- Reconcile artitrack launcher-passthrough into fuzzy_complete ([f5b7494](f5b74940d90499a44ad689190a671947b14f7824))

- Replace gitsigns with vcsigns for jj+git sign support ([e011783](e0117831fdcd31f65188bebefb107a6ed397f389))

- Add claudecode.nvim for in-editor Claude Code sessions ([551bf5b](551bf5b49ea62537909b1d0a18a515575de11e07))

- Add jj.nvim and :JjReview for commentable chain review ([c9c5722](c9c57223bcf12779902789a5297f6b6ddc131b37))

- Add :ReviewImport to restore review comments from the export file ([67f75c3](67f75c352595925a8dda5262273bfde8058ad3d7))

- Preview diffs in the :JjReview file picker ([4d25cf1](4d25cf1d995ef87608b6b24f06954ac823963717))

- Complete revsets and paths for :JjReview ([30b1177](30b117779214411cb53cdd313af28421bae61a52))

- Pick the vcsigns diff base from a revset list ([e4507ac](e4507ac5a53f409a273d76d86a16bb21ea9b704a))

- Add snacks.input for floating vim.ui.input prompts ([b03602f](b03602fcbdce3664aaef6a17b46a28a9e1f2ac26))

- Reach jj.nvim from <leader>j ([4393941](4393941d0a90432472e9f323c1248258eb6bcdeb))

- Write review comments in a float instead of a prompt ([95ae350](95ae3506815a7f3f79b7d9035e5d711ea5e087df))

- Make the jumplist behave like browser history ([9290db1](9290db11c8e7f814d4ed04d64ac4e9bf8655ca4d))

- Jump to a beamer frame or section by title through fzf-lua ([43a9ec2](43a9ec2b7583584e5c06d5debd0aca462f584d23))

- Set winborder for uniform float borders ([074cd64](074cd64d6cc3c6238a22c23260c74cbd7ca696f4))

- Add inc-rename for live LSP rename preview ([307087a](307087a6e072e1655190c5bd8055cee5f15acd98))

- Add persistence.nvim for per-directory session restore ([957bdd8](957bdd8d439fa80aa11e4f9d4f5b962919deebb0))

- Host the claudecode terminal in snacks ([a110157](a110157a0a0e68d95aef69d7cd641b56efb7312c))

- Forward-search Skim to the cursor after every compile ([cb48ff3](cb48ff30129fc247f3540986e69ad1580ec5d425))

- Add Rex config replacing the zellij keymap ([9ce69b5](9ce69b599cc1a6b26e086d928206a28fa6482c0d))

- Label panes with their project and toggle the sidebar ([fc6a6c0](fc6a6c0322e6629c6debc393809125f8635e09be))

- Launch each agent in its own Rex window ([a9c734f](a9c734f0af531563bfa043436d4a5863b5ba4fd6))

- Attach panes to their project's Rex session with use rex ([268facc](268facc1a6853c5fcb9fb11ac8139fc8a25e5780))

- **BREAKING**: Drop direnv use rex and rex-attach ([b4dc7f8](b4dc7f8dc94643caf2399747e21ba7cd22bdc9eb))

- New_agent popup and session/tab key bindings ([726cadb](726cadb96a42352dd74cbf30598ae19e609875b0))

- Smarter Tab completion: zoxide guard, picker preview, faster reload ([e9a6295](e9a629596498eca47bdf31aef79b47caf34d7566))

- Megamerge workflow config with its fish functions and tests ([6ae6697](6ae6697144763f9c9926cea6b261d37d97d1b8ab))

- Org-based review flow with difftastic and synced lockfile ([daa539c](daa539c8fb9c6f49edb105078feca4959ec5c1ff))

- Fzf tab picker and restructured key bindings ([58eebaa](58eebaaf00b12ef03053bff8c09a088f62cd09aa))

- Regroup aerospace bindings and add ghostty macOS symbol keys ([78ebd82](78ebd82bd346429b0f765c7371d5f9228c52e854))

- Track the scout agent, terse output style and status line ([575cabf](575cabf575f40d123c4d9836d7b6026d96fafbcb))

### Fix

- Set TERM consistently to xterm-256color in fish and wezterm config ([c047bfa](c047bfa48cc1306b6758dca9f492481e9867c5b4))

- Remove Catppuccin Mocha theme setting from fish config ([c3cb605](c3cb60578fb7db3170c246cadae1dd3ec6190e10))

- Update Neovim AppImage download URL to use stable release path ([6ea0933](6ea09339e120d16e508104e070cb4db0f9408aa6))

### Tests

- Enhance Docker testing infrastructure ([abc6780](abc678058ad690f1b4f3bcf1580d5d335e2bc788))

- Regression guard for wezterm/glab references ([0b21553](0b2155341397bba88e1edf44a245c8a5b3d14316))

- Cover casks and per-module brews/casks (#90) ([4b3d0d5](4b3d0d5d4436861dc2b4d5a9881365bcaf28b7cc))

- Cover all rendered .chezmoiscripts under both OSes (#94) ([7673202](7673202548be71de0ebef02478ed66a503c18ba0))

- Catch leftover template directives in rendered .tmpl output ([882e547](882e547c2aa2d6f82a051c356ffe21c73a9ae37d))

### Ci

- Scaffold hermetic bats test suite and GitHub Actions (#67) ([921ea5b](921ea5bb9d60962ee7213dfd818f54a557239c0c))

- Allow gh pr create so workflow opens PRs after pushing ([75309a8](75309a8814ef5eebc1c9a95f40706104796411b2))

- Add workflow_dispatch trigger to ci + installer ([13584a2](13584a295463a3d2cbffb41f31079c28d676d7f7))

### Doc

- Indicate that you might need to restart IDE for fish to appear in terminal options ([a09d647](a09d64758dbe54cb0c0c56fd057c6a1b87e974f4))

### Docs

- Add TEST.md with instructions for testing without modifying local system ([0c3b498](0c3b4988f83add15d04b57626ca554845bb74230))

- Update documentation for theme system and Nerd Fonts ([37c18c0](37c18c0d82712a17c700b4ffc2ffc38bc325e66a))

- Add contribution and tools description ([6f9de05](6f9de056af0a39a314828aa80f7bfceb715a7baa))

- Add theme switching to readme ([5897c03](5897c03435c0f84cc5c8242f33d4effe3a357807))

- Gh cli config ([09a56ae](09a56aecb1d4f552b8653f1a85a646de147f4b1a))

- Update uv description ([42be809](42be809ffbc8e8adae90f1b5bcb05d49dfd64152))

- Update the documentation ([3b8bb9f](3b8bb9fb96e5826b505aa28811b5f98877e379ec))

- Add Jupyter notebook integration documentation ([3598dd4](3598dd42e572d7f450f810f59774feefbc392046))

- Add git-extras installation and usage documentation ([1fef6eb](1fef6eb7cb04bea2690205c2f1c668c7120bea66))

- Comprehensive documentation improvements ([6181813](61818135dea7d5dcc9fdf8dc89fa2416566f4d5e))

- Update changelog ([c47990e](c47990e5cfee7168ff1a888b0174200f0e236486))

- Update readme ([031f4b2](031f4b2f2584bf38f532178665b96a1ea10b2702))

- Improve script documentation and POSIX compatibility ([3fc70b4](3fc70b472d1ea3d4fc05119cc9fb76b0d037d4a4))

- Reorganize and enhance CHEATSHEET.md ([f9e7518](f9e7518186d1263edfc1601ccab0e74bcb8a12ab))

- Update README with GitHub Copilot CLI extension information ([d9abc5c](d9abc5ccf38dc9182d2449ca4c159651206757db))

- Add development workflow guidelines to CLAUDE.md ([c5ffcaa](c5ffcaa50e050e303ea2347ea1d5b253ebfedb70))

- Add comprehensive changelog management guidelines to CLAUDE.md ([3457355](345735547e19565421055154e9ed05a3ab7ad22e))

- Update CHANGELOG with recent features and fixes ([c62a57a](c62a57a03a295a0c06de8d104bf2fbdbc3b6b299))

- Improve documentation with enhanced readability ([795bac9](795bac92f2ca45c51319f583c8c6e152e54668f0))

- Improve chezmoi documentation with cross-platform parity guidelines ([74cb46e](74cb46e9c32006ae6e8c80417b0444f00ec96a8b))

- Add comprehensive Neovim Git integration shortcuts to cheatsheet ([ca5749a](ca5749a5de331200fe6498ef72493fc056419f52))

- Add new command documentation files ([4761d93](4761d93e323dfb5b6fc2bea3c20a232e904f2983))

- Add pre-commit hook analysis requirements ([4e07920](4e07920e326f408eaf31c3a5ae30fb9b2e8fd7e6))

- Enhance gemini command documentation ([facd4f3](facd4f3a1fff5b59e7fd4e74a370e63330a63246))

- Update core behavior and tool usage guidelines ([c15d43a](c15d43a2a995437451a6db90f4b347d2e196d139))

- Update tool usage guidelines and help messages ([7e1c6ef](7e1c6efa0493f163a414c2bf86c5edf401fba6b4))

- Update command templates for clarity and precision ([f67b9c7](f67b9c7deb3cae2bc90318009fe161d64a88b9de))

- Document cc-wt launcher and zellij zbash skill in README and CHEATSHEET ([6bb484b](6bb484b4ca5cdb4573b9b03afaaa80f6ad344078))

- Document zbash floating-pane execution and cc-wt workspace launcher ([6631004](66310040d01bc2853def1aa112db27ea4ea2a7db))

- Warn against long-lived procs in zbash, fix jq and cc-wt notes ([42c98a6](42c98a6cead0bec3f5221dfd028d3bf2d6b28fe4))

- Document gh skill provisioning in README and CHEATSHEET ([092a77a](092a77a5f19c26e3fc50df1a0f6a6ef355ae9dae))

- Update documentation files ([d33094c](d33094c38f0b1090365943c85556d54c725a59d4))

- Add terminal restart note to post-installation steps (#59) ([cbd1c09](cbd1c09df23a199942a11634c1e28238a6fa35db))

- Rewrite Quick Start, fix mismatches, clarify chsh (#71) ([91e910a](91e910af4cca068400b00903afb2d3b09ae888fa))

- Add starship customization links (#86) ([bdd5524](bdd55249f35108a458731a2d104f7a3408f4aa0b))

- Document the fzf Tab picker and review command ([eeb546c](eeb546c1ba3d11a565a27f01b00cdc30fa3802c3))

- Describe the vimtex keymaps in which-key ([ebb3392](ebb339223611abab3114b7547d0cde8e4e99a407))

- Replace the tuicr review workflow with the nvim local review ([45b3f67](45b3f6784538471e80658c01e80afe1fe47ce3d5))

- State what jumplist stacking actually does ([5ce3dd4](5ce3dd4aa0612ef3b2ba5d3aac00eb6d35863829))

- Point the textobject note at the merged mini spec ([898430a](898430a35718ec9d961a28a58083d61a7c4608d3))

- State the measured reasons for chezmoi.vim and hunk ([aa6532e](aa6532e05666d88b7e0b7c8f3f6b08a1655105be))

- State that person_name is not cleared after capture ([8882793](88827936f78c90f82146c22757b79f280981c4c3))

- Correct the stale cross-references ([a63fa71](a63fa716c8d4e149b1e439f0e8db2a6b4c0891de))

- Correct the stale org and vimtex cross-references ([f863581](f863581f62ab4134990090013d9e81f9fc44811d))

- Say what the six undocumented plugin specs are for ([fc77b2e](fc77b2e7ac7e98fb428f05076d09237ab8fc6a6d))

- Describe the non-leader keymaps for which-key ([ab23b9d](ab23b9db5b88942087baca7c02cca54d4bd899fc))

- Describe what quicker actually adds to the quickfix ([c0d25c7](c0d25c7853ddb7b5fe7ee49144acb89b54678ec5))

- Tell callers to give unattended agents a prompt and a permission mode ([fb21689](fb21689f02a6274f879ed6905062ffd4b93affb9))

- Slim AGENTS.md and route external tools through the Haiku scout ([060e463](060e4634f875be2a1a8d8d8594f7c57727e116d3))

- Say what an unwatched agent still blocks on and point AGENTS.md at rex-agent -h ([57e6e68](57e6e6836629ae4002da9dce214c11ccdb3000ce))

### Enhance

- Fish abbreviations file generation ([c08eed2](c08eed28412b804807749b87f9d15c04d096689d))

### Perf

- Defer org-roam and orgmode off the startup path ([1411088](1411088b57f3d0d73f505271025510ebb4d07cbc))

- Load org-roam on org files and commands, not VeryLazy ([65da641](65da641fbec04e97aaf972c20b1e182a021ac037))

- Give the remaining always-on specs load triggers ([0501958](0501958e48678f730270d7220377f67a8eb72268))

- Disable unused builtin plugins and change detection ([e394764](e39476427b058a4c1ba24d8e0dc0e227d2fa1109))

- Load nvim-chezmoi from the chezmoi source tree only ([cdc1861](cdc1861fbed82f51161984dc13bc9725f28d31e9))

- Drop navic's unused nvim-lspconfig dependency ([c2170de](c2170dee9c0f03373066b1e6f633e33b587dbbec))

- Load blink.cmp on insert and cmdline, not VimEnter ([452644e](452644e15d99232f7ac2d859f7efc3af1b6ac81e))

- Load origami on a buffer rather than on VeryLazy ([3f9fac7](3f9fac7658fed4ce3f50bc3993eab6d360e30003))

- Load orgmode from org files and its own entry points ([26b122c](26b122c1e181aad04ef7ebca8699b8264a5fb884))

### Refactor

- Remove individual macOS install scripts in favor of consolidated packages ([0065b92](0065b9237ee05092f5288d85fb742db1a327f106))

- Change Git LFS to opt-in approach with template gitattributes ([fac95a5](fac95a52de3364d579f14fa1c0af3514946eccc4))

- Remove old chezmoi config file ([8eb5c08](8eb5c08877f409aee7181497f7d6bf1607ef63b8))

- Improve WezTerm installation script for SSH and terminfo ([47d0297](47d0297591a007dff399a25ff1087df7bf30a346))

- Update package list and tool configurations ([7968bc9](7968bc92c9c36e9f39a5bcf8d025d6a4f2adf138))

- Improve GitHub email retrieval for chezmoi template ([77967e3](77967e3cc56688867a44f5545d75f280a5f2fdac))

- Update package list with new tools ([4b9354d](4b9354d0ff287ce54279e10d1bb6b59a59ffbe6f))

- Consolidate conda-related aliases ([f5124de](f5124dec1506c5c90842f6302e08f68744fbb300))

- Enhance eza and fd aliases with icons and advanced configurations ([99d8a4e](99d8a4e28d6188838baf9e6e149534c1114ab7aa))

- Add codespell ignore instructions inline ([36280b2](36280b220468631675579a4df790cda7294a8aa3))

- Add codespell ignore instructions inline ([c9a7aed](c9a7aed76e7af1ccdcfd5132966f30f31a6f504b))

- Remove separate flog and fugitive nvim plugins ([67667a7](67667a7b7cc73a894fea889debc25ed2e519421a))

- Improve Neovim configuration ([43f0f68](43f0f686b4549df5ce117b8f1e8e1aaaca1bf62c))

- Update Neovim plugin loading and event triggers ([1dfcab2](1dfcab2de2f66a0618ab46ad10df4dbead653a29))

- Consolidate Git and GitHub workflow documentation ([761acfc](761acfced7abdb7a94562febe49fcd27d5c2fe29))

- Disable specific keybindings in vimtex.lua ([c161d89](c161d8971927badb019f40d0d43ce9fafdb7360e))

- Add codespell ignore instructions inline ([c2624b8](c2624b8b1380c3cf5f9eb75788accc659c003ec2))

- Improve Neovim configuration ([bbc43a0](bbc43a09a1aabc3f22a072e1e664ac1b9ff0db32))

- Consolidate Git and GitHub workflow documentation ([7563f8c](7563f8c1322e6e8c61104e15b085f5b28419397b))

- Improve script maintainability ([b35b6c7](b35b6c7b638f427417fa233106b3e18ebc829934))

- Enhance issue generation and UX ([ef89937](ef89937129270bca1306e616a1a02d0481124089))

- Improve AI response parsing for gh commands ([fa19693](fa1969305ca78b1e33d71d20460a1c7286c32c94))

- Standardize agent functions with utilities ([73d97b9](73d97b9ef86417ff64c23e77e5c1e431c2b9bee6))

- Replace trouble.nvim with fzf-lua for diagnostics and TODOs ([24d8cc5](24d8cc5816dc99ffea6d0c21c602f3ffc6972eeb))

- Enhance fzf-lua and conform.nvim keymaps ([107fc7f](107fc7fb50783102cbe7e3e20a66c64c00ef3862))

- Make local skill installer manifest-driven ([bdd249d](bdd249d9cce5536cf4d10bd0dd92bc9537696f0a))

- Adopt AGENTS.md as canonical config name with CLAUDE.md and GEMINI.md symlinks ([d7f69de](d7f69de70e63339d03cc129ee62b59c0ddb0baee))

- Drop custom-skills tree, now published as chicham/skills ([ff6b1aa](ff6b1aa39105289ec9c100910f04419a978c1a4e))

- Discover skills from the repo instead of a hand-written path list ([4ade483](4ade483a9c5e4a2c4aa7e98f867b786892646074))

- Move extension list from shell script into packages.yaml ([fbe1030](fbe10300a28287469cd29dc8fc650ac2ad623bcf))

- **BREAKING**: Split cloud and macos_desktop into atomic modules ([0bc6702](0bc6702e3ed8dc7ca73aab69d2ef7821a91fce2f))

- Use official gh.io installer, drop gh extension script ([a843979](a843979c2b784107be95397aa3360304a0492f57))

- Remove redundant aerospace and linux-script gates (#93) ([58e8533](58e8533fb0a7e5b8b2a1dae52fb7fb3ca0eb311e))

- Lean on chezmoi externals/attributes; drop redundant install scripts and template wrappers (#95) ([49fabb8](49fabb882115fd8b1694846f4b935019f411690d))

- Use vimtex's own fzf-lua picker for the table of contents ([9add52b](9add52ba22e6200bcfa3a61bcefa48e2e4fb450a))

- Scope the jumplist stacking to LaTeX buffers ([ca58432](ca584327a3ae3aa8b800d2dd4ec5aea0cf0194af))

- Move the org capture helpers out of the global table ([dae8d97](dae8d9787518e7b2a758fe0381e25c59f9245991))

- Consolidate the mini specs into one file ([25d4377](25d4377c14cad470f3d90d5fc3525fb0fe19f994))

- Replace vim-better-whitespace with mini.trailspace ([386a45e](386a45e769cefdbd77f8db1b76782d612c5c3d96))

- Replace treesj with mini.splitjoin ([c2c939f](c2c939f6ae5d1075193fc7f80d8e2711c10029c5))

- Replace nvim-web-devicons with mini.icons ([d9c2793](d9c279369697168b6ddbb065a489b5174980ba51))

- Replace todo-comments with mini.hipatterns ([aa83077](aa8307770848baa8f68b1bfefccc76e63cf2a8ab))

- Replace archived twilight with Snacks.dim ([a2dc734](a2dc734350c5c40f1dcac3f2e1bac5ea4d2ec1ca))

- Replace the doc-highlight autocmds with snacks.words ([77c0381](77c03819121f63ffbb5ae38dc63960aafc5b5dd9))

- Move options into lua/custom/config/options.lua ([12ff7a6](12ff7a6f35899afabaaa21c3185fd10b6aa033c5))

- Move the fold keymaps and helpers into origami.lua ([37a6106](37a610696a171708abdd7f63759e436901f2d1c5))

- Move keymaps and autocmds into lua/custom/config ([de0a2c3](de0a2c3d1c67aa40f4f794c919cec8709a1b2afd))

- Move the small inline specs into lua/custom/plugins ([991f6b0](991f6b087b4fbefedb545f2d1837a89c0026c82f))

- Move the treesitter spec into lua/custom/plugins ([148cf7f](148cf7f53d603768b38e96839749b3947269fae9))

- Move the conform spec into lua/custom/plugins ([b29e70b](b29e70b9992c25150abffb0270705cccf7fb1d3b))

- Move the blink.cmp spec into lua/custom/plugins ([9165e4b](9165e4b8054abd704e792ee1623859021fea3021))

- Move the lspconfig spec into lua/custom/plugins ([6ef14d5](6ef14d5b8f1ca12e570ca09b08fafa1bf9e2906c))

- Move the coderpad and blink toggles into lua/custom ([8a87616](8a876167603bc540b19553875cd22e8c1b9babf5))

- Let nvim-various-textobjs load on its keys ([eed07dd](eed07ddf2b36a6bb55f4c73559f50e14b2d2e4e0))

- Move the fzf-lua goto pickers under <leader>g ([8481d2a](8481d2a960bf2c7c42d4405225ad75bfa5297bee))

- Free <leader>q for the quickfix toggles ([6902179](6902179bcb1aad06328670a0316d377fd414ebbe))

- Use orgmode's native blink source ([75c71b7](75c71b7140c05a21262886e1faa5dafbb0c12829))

- Share one fzf-or-ui.select picker across the org helpers ([c8d8af8](c8d8af8524bb4c76166cda84bccbc82228dd50e8))

- Move the format and inlay-hint maps off the review prefix ([e226380](e2263808eec1a6a5ce12f4aea0c48ae519d8eb1a))

- Use direnv's standard layout uv and fish hook ([8ff6fe4](8ff6fe4d3fafa780776d3c0de6d385ad7a36060b))

- Run tool inits directly and drop the fish 4.3 migration files ([ba5c067](ba5c0675cc6e03413dc5fade17e3252685dd28a6))

- Adopt the live fzf and atuin key-binding setup ([694b2a4](694b2a4709d1fe1910825b9565df3c868a75ae83))

- **BREAKING**: Drop zellij in favour of rex ([b0e62e3](b0e62e3ec58f9336d70d3abb3d71c0a81360f046))

### Style

- Pin the lua format and reindent the tree to match ([b27839a](b27839a02e344ab62212d682529458c111442e87))

<!-- generated by git-cliff -->
