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


### Tests

- Enhance Docker testing infrastructure ([abc6780](abc678058ad690f1b4f3bcf1580d5d335e2bc788))


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


### Refactor

- Remove individual macOS install scripts in favor of consolidated packages ([0065b92](0065b9237ee05092f5288d85fb742db1a327f106))

<!-- generated by git-cliff -->
