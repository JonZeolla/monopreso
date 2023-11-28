# Monopreso

This is a monorepo of presentations developed with the wonderful `reveal.js` framework.

Some under-the-hood manipulation is needed in order to use `reveal.js` as a strict submodule (and use certain features like external Markdown[^1]), so
please use the `./start.sh` script to setup and run your presentation.

To print your presentation, start it and browse to http://localhost:8000/?showNotes=separate-page&print-pdf#/

## Getting Started

Ensure you have `docker`, `pipenv`, and `python3` installed locally, and the docker daemon is running.

Then, you can open a presentation via:

```bash
# Initialize the repo
task -v init

# List the available presentations
./start.sh --list

# Pick a presentation, and run it
./start --preso=iac_security
```

You can also specify custom branding from supported brandings, for instance:

```bash
./start --preso=iac_security --branding=seiso
```

If you'd like to create a new module or presentation, run `./create.sh -h` and go from there.

## Updates

Update the asciinema javascript and css using the artifacts here[^2].

Also, you can run the following to update the project dependencies.

```bash
task update
```

[^1]: https://revealjs.com/installation/#full-setup
[^2]: https://github.com/asciinema/asciinema-player/releases
