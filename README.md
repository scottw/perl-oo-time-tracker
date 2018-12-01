# Perl Object-Orientation

## Purpose

This repo contains Perl code that illustrates some of the differences between "classic" Perl object-orientation and "modern" Perl object-orientation using two classes that could be used to build a primitive time tracking application.

## Audience

The target audience for this is people who write software using classic OO techniques and are interested in testing the modern Perl OO waters.

## Disclaimer

This code is provided as-is. I do not recommend using it as the basis for anything other than its intended purpose to illustrate some of the differences between classic and modern object-oriented Perl. It should not be used as an illustration of good design or best OO practices. Please consult the [Moo](https://metacpan.org/pod/Moo) and [Moose](https://metacpan.org/pod/distribution/Moose/lib/Moose/Manual.pod) documentation to learn about the "right way" to do things in these systems.

## Setup

This repo includes a `cpanfile` for dependency management with `carton`. Once you have installed the dependencies, you may prepare the working directory with:

```
cd 1.0-classic
make next
```

which will create a new directory called `work`.

## Presentation

The `work` directory is the on-screen working directory that others will view. If you have a second (possibly private) terminal, the `SCRIPT.md` references commands you should run there, otherwise, you'll have to `cd` between directories frequently.

This repository assumes you will be using `carton` for dependency management and as such uses `carton exec --` for the `make test` commands in the `Makefile` in each sub-directory. If that doesn't work for you, feel free to change it or DIY.

## Resources

Slides associated with this code may be found here:

https://scottw.github.io/presentations/perl-object-orientation/
