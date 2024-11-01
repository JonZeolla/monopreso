# Monopreso

This is a monorepo of presentations developed with the wonderful `reveal.js` framework.

Some under-the-hood manipulation is needed in order to use `reveal.js` as a strict submodule (and use certain features like external Markdown[^1]), so
please use the `./start.sh` script to setup and run your presentation.

To print your presentation, start it and browse to http://localhost:8000/?showNotes=separate-page&print-pdf#/

## Getting Started

Ensure you have `docker`, `uv`, and `python3` installed locally, and the docker daemon is running.

Then, you can open a presentation via:

```bash
# Initialize the repo
task -v init

# List the available presentations
./start.sh --list

# Pick a presentation, and run it
./start.sh --preso=iac_security
```

There are also some demos which may require `pipenv`.

If you're actively working on a presentation or module, you can also use `task start` and it will start the presentation of the directory that you're in.

There are some other features you may want to look at, by passing `-h` or `--help`:

```bash
$ ./start.sh -h
Preferred Usage: ./start.sh --preso=PRESENTATION [--list] [--branding=BRANDING] [--no-open] [--no-cleanup]
--branding     Use the specified branding i.e. --branding=seiso
--list         List the available presentations
--preso        The presentation name i.e. --preso=dev_tls
--no-open      Don't open the presentation in Chrome automatically
--no-cleanup   Disable the cleanup prompt at the end
-h|--help      Usage details
```

You can combine these features, like:

```bash
./start.sh --preso=iac_security --no-open --no-cleanup --branding=seiso
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
