# Contributing

Develop and test changes in a regular clone, not the bare-repository install in `$HOME`.
For the full workflow, read
[Set up a development clone](https://drts01.github.io/dotfiles/docs/contributing/development/).

## Prerequisites

Install Git, a POSIX shell, and [mise](https://mise.jdx.dev).
Use Bash and Zsh for their shell tests, and Podman or Docker for container tests.
Documentation builds initialize the Zola theme submodule when needed.

## Set up a clone

```bash
git clone https://github.com/drts01/dotfiles
cd dotfiles
sh .config/dotfiles/dev-setup.sh
```

Run setup before running mise tasks in a clone.
It creates ignored root development configs, links the tracked development lockfile,
and installs ordinary pre-commit hooks.
It stops instead of overwriting different local configs.
Do not run the bare-repository installer or `install:gitignore`/`install:git-hooks` here.

## Check a change

```bash
mise tasks ls
mise run lint
mise run shell:test
mise run bootstrap:test
mise run docs:check -- --skip-external-links
mise run docs:build
```

Run only the checks that apply to your change; `lint` can rewrite files.
See [Test the dotfiles](https://drts01.github.io/dotfiles/docs/contributing/testing/) for individual shell, doctor,
container, and smoke tests, and
[Write documentation](https://drts01.github.io/dotfiles/docs/contributing/documentation/) for page checks.

## Submit changes

Keep repository-only files under `.config/dotfiles/` or `.github/`;
every tracked file outside those directories may be deployed into `$HOME`.
Use [Conventional Commits](https://www.conventionalcommits.org) with a scope,
for example `fix(dotfiles): handle missing mise`.
See
[development guidance](https://drts01.github.io/dotfiles/docs/contributing/development/#protect-the-deployment-model)
for deployment boundaries, local excludes, tool pins, and hook setup.
