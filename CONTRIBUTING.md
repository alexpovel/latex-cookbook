# Contributing

Welcome to the project!

This file is a short guide on how to contribute to it.
The gist is: just go ahead and hack at it.

## Feature Requests, Enhancements, Bugs, Issues

Please feel free to submit issues about problems and bugs you encountered.

Features and enhancements you would like to see added can also go there, and we can
then see towards implementing them for you.
Chances are that what you seek is already possible with the (many) included packages,
and only an example in the cookbook showing how to do it (but no change to the `*.cls`
file) is needed.

## Developing Environment

The environment for compilation is taken care of by the Docker image as specified in
[the CI config file](.gitlab-ci.yml) (search for the `image` name on
[Dockerhub](https://hub.docker.com/)).
Refer to its `DOCKERFILE` for what it does exactly.

It would be greatly beneficial to use that Docker image for yourself.
It is guaranteed and proven to work (a succeeding pipeline implies a succeeding Docker
image).
Otherwise, it is not terribly hard to set up a local environment imitating that Docker
image.
For installation advice, refer to the cookbook PDF Preface chapter.

## Style

Being a LaTeX project, there are no generally agreed-upon guides, styles, best
practices and the like.
Everything is basically free-form.
A look at the source code will reveal the few (stylistic) choices chosen for this project:

- A line limit of about 90.
- Proper indentation (this is very important!) for readability and maintainability.
  This is also true for math environments, where indenting `\frac{}{}` and other
  multi-argument commands will do wonders for legibility.
  Proper indentation involves aligning opening and closing braces and all that jazz.
  Unfortunately, there is no formatter to automatically do this for LaTeX.
- Proper commenting and even links to stackexchange solutions will probably be helpful
  and avoid duplicate lookups of already-solved issues.
