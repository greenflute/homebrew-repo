# Homebrew repository

Personal Homebrew tap for Tokcos and other useful macOS software.

## Add the tap

```sh
brew tap greenflute/repo
```

## Tokcos

```sh
brew install tokcos-cli
brew install --cask tokcos-work
```

## MoonBit

```sh
brew install moonbit
```

The official MoonBit VS Code extension currently looks for its toolchain under
`$MOON_HOME/bin` (default: `~/.moon/bin`) instead of using commands installed
through Homebrew, so it does not automatically discover this installation. For
VS Code use, let the official extension manage its own toolchain for now.
