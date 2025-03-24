# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]


### Bug Fixes

- Improve pre-commit configuration ([f5ae4c8](f5ae4c833f35b1d8fa77d5ca3240772e592258cf))

- Resolve shellcheck issues in Linux installation scripts ([a83843f](a83843f0ed31cc0909f4e8acda851d84214334be))

- Ensure POSIX shell compatibility in conda removal script ([866febb](866febb349e0c1954e54b05f39d693720dfde0af))

- Ensure POSIX shell compatibility in conda removal script ([a4c9c0b](a4c9c0bb021ffbb0221c7ea60f14edb97d94dcda))

- Update Linux installation scripts with proper fixes ([5074f00](5074f00cff4d358ad0377659581c8b153ae0b3ba))

- Ignore envrc ([c32db8e](c32db8e78c8141c08ff39066244b7f67694db1f4))

- Remove unnecessary remote install ([7c9d9d4](7c9d9d4ff78a1434f9a0b3f62a4b10d4bc61952c))

- Various fixes for macos ([d80f717](d80f717ec945b825a0637751ac2861cbc21a52d7))


### Chores

- Add changelog generation with git-cliff ([06599d3](06599d32c438158bc0f62cb0b80d84a932d80c1b))

- Update README with recent changes ([aedab3c](aedab3c5956f7785eccb1597945eff167b2a5750))

- Update changelog configuration ([a02a7c4](a02a7c4121ddd3720b7d5091c77b1fec5221cfba))

- Update chezmoiignore patterns ([b0d5c15](b0d5c151b283d146fe4c502f12f05aa449dc7316))

- Add gitignore for generated files ([33fb917](33fb9176157657b2f04f6fac20128ae507e68695))

- Pre-push fixes ([044cc87](044cc8762df206fe283b71476db0c45db342ed48))


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


### Docs

- Add TEST.md with instructions for testing without modifying local system ([0c3b498](0c3b4988f83add15d04b57626ca554845bb74230))

- Update documentation for theme system and Nerd Fonts ([37c18c0](37c18c0d82712a17c700b4ffc2ffc38bc325e66a))

- Add contribution and tools description ([6f9de05](6f9de056af0a39a314828aa80f7bfceb715a7baa))


### Refactor

- Remove individual macOS install scripts in favor of consolidated packages ([0065b92](0065b9237ee05092f5288d85fb742db1a327f106))

<!-- generated by git-cliff -->
