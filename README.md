# Morrish
Commands that makes things easier for me, mostly wrappers around long tedious commands.

### Script Usage

1. Clone it
2. Source it by adding it to your .zshrc/.bashrc:
    - `source ~/dev/morrish/index.sh`

### Hook Usage

1. Clone it
2. Update your Git config to point at the hooks:
    - `git config --global core.hooksPath ~/dev/morrish/hooks`

Updating it only requires a Git pull of the project

### Environment variables
For some arguments it's easier to have environment variables configured

Some scripts will attempt to source `$HOME/.morrish.env`, an example .env file is at the root of the repo and can be moved to your home directory with your own values.