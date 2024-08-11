# Flair v2.1

Adding bounce to systems step!

Put files in folder called .dotfiles

In ~/.profile add

```
source ~/.secrets
source .dotfiles/.bashrc
source .dotfiles/.aliases
source ~/.dotfiles/git-completion.bash
source ~/.dotfiles/git-prompt.sh
```

# keep environment variables in a ~/.secrets
# when appropriate, don't forget to copy those secrets to new system.

# remember that these files do not reside in .dotfiles.
# you may want to copy them if important configs are in there
#
#  ~/.gitconfig
#  ~/.secret
