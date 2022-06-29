# Confluent CLI Fish Completions

Fish shell completions file for the Confluent v2 CLI

If you are are a regular user of Confluent you will be familiar with the CLI tool. It comes with completion scripts for bash and zsh but sadly not for fish. This completions file addresses that. 

This dynamically pulls completion hints from the CLI binary itself (using the hidden `confluent __complete xxx` command, so should be reactive in the face of new commands getting added in the future. 

- [Confluent CLI](https://docs.confluent.io/confluent-cli/current/overview.html)
- [Fish shell](https://fishshell.com/)

## Usage 

Add `confluent.fish` to `~/.config/fish/completions` 

## Credit 

This completion file is a _very_ lightly modified reproduction of the fish completions provided with [podman](https://github.com/containers/podman). I can take very little credit for it, but I do reccomend checking out the latest version of it [here](https://github.com/containers/podman/blob/dd924c4078c1c0b3167b4f5bf8975ef4d6bc9e26/vendor/github.com/spf13/cobra/fish_completions.go), as they update it fairly regularly and it is the best base I have found for building dynamic fish completion scripts. 
