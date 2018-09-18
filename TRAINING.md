# Modern Perl Object-Orientation

This file may be used as a basis for giving training using the code illustrations found in this repository. If you are coming across this file outside of github, the repository may be found [here](https://github.com/scottw/perl-oo-time-tracker).

## Setup

To the trainer: to install the dependencies for this repository, you will need to install [Carton from CPAN](https://metacpan.org/pod/Carton). Once you have Carton installed, you may simply:

```sh
$ carton install
```

Once the dependencies are installed, the targets in the `Makefile` will work as written. The code in this presentation has been tested with Perl 5.8.9 and Perl 5.26.1.

## Introduction

Perl has several object systems to choose from, and none of them, with some exceptions, are exclusive. You can usually mix and match code from several paradigms to get your work done, but it's considered better to choose one and use it as far as it makes sense. Your code will generally be more readable and maintainable by sticking to one style.

We're going to look at the "classic" OO paradigm first.

## Classic Classes

Classic Perl object-orientation is not so much a "system" (contrasted with Moo or Moose) as a [set of conventions](http://perldoc.perl.org/perlootut.html). Packages are classes, objects are blessed references (often hash references), methods are subroutines in the class. Here are two examples of such a class.

### Timer class

(open `lib-classic/Timer.pm`)

We'll read this from top to bottom.

Here's the constructor (`new`): we bless the object so we can immediately use its methods. That's handy in case the methods have important business logic in them. You can see we're setting some appropriate default values of the current time or an empty string, etc.

The `start` method is both a getter and a setter; if a value is passed in, we use it to set the internal property. In either case we return the current value of the property.

All of the attributes of this class behave this way: `start`, `stop`, `duration`, `activity`. The only special case is `duration`, which is also called when `stop` is set. This is called a trigger.

Finally we have a `to_csv` method that returns a poor-man's comma-separated value line.

### Tracker class

(open `lib-classic/Tracker.pm`)

Let's now look at the Tracker class. The constructor only has the one attribute of `log_file`. The `log_file` accessor which behaves the same as the ones in the Timer class: we read in an optional value to write to the attribute, and in either case we return the current value of the attribute.

Then we have two utility methods: one to append a Timer event to a log, and another to read the log and summarize all of the events it finds.

### Classic size

If we look at the size of these classes, we can see it's pretty light:

```
$ wc -m lib-classic/T*.pm
    1354 lib-classic/Timer.pm
    1155 lib-classic/Tracker.pm
    2509 total
```

2509 bytes total for the Timer and Tracker classes.

## The Tests

As every good class should, we have two test files, one for each class, that exercise a few of the key features we want to implement and pitfalls we want to avoid. It's not complete, but you get the picture.

### Timer tests

Here is the test file for the Timer class (open `t/Timer.pm.t`).

We create a new Timer instance with all of it's fields set, then check to see if the duration was calculated properly. Etc.

### Tracker tests

Let's look at the test for the Tracker class (open `t/Tracker.pm.t`).

This is a little shorter than the Timer class; we create a new tracker, clear out the previous log file if it existed. Then we add a bunch of Timer events to the tracker object, which takes that timer and writes it to a log file.

We then calculate summary data by reading the log and returning a hash that contains the amount of time we logged in each activity.

### Running tests

To run the tests we can do this:

```sh
$ make test-classic
...
```

All we're doing here is invoking the `prove` utility (this is invoked through Carton so that our dependencies will be available):

```sh
$ cat Makefile
...
```

## Modern Classes

So you've seen how this works now. The test files could be used as inspiration for a real command-line application or web API, for example.

Let's now look at the modern Moo-based version of these two classes. By the way, everything that we cover here with Moo also works for Moose. Moose can do even more nice things than Moo, so if you are writing some Moo and hit the boundary of where Moo ends, you can just replace 'Moo' with 'Moose' in that class (after installing Moose) and it will keep working.

### Timer class

(open `lib-modern/Timer.pm`)

Here is the equivalent Timer class written using Moo. The first thing you'll notice is that there is no constructor. Moo provides that for us; it's just there, called `new` and we can run it anytime we need an object.

The constructor knows that any attributes we declare using `has` are also permitted to be passed in the constructor. You can override that default behavior if you want, but this is usually what we want.

We declare the same attributes that we had in the other class: `start`, `stop`, `duration`, and `activity`. The `to_csv` method is copied and pasted in from the classic Timer class. This demonstrates that this is just Perl—if you have something working using the classic way, you may be able to get it working with Moo without much effort.

### Tracker class

Here is the Tracker class. It's one `log_file` attribute is declared here. The `append_event` and `summary` methods are also copied and pasted from the classic Tracker class. No changes at all.

### Modern size

Another thing you may have noticed is how small the modern classes are. Let's look at the size in bytes:

```
$ wc -m lib-modern/T*.pm
     542 lib-modern/Timer.pm
     893 lib-modern/Tracker.pm
    1435 total
```

And comparing with the classic version:

```
$ wc -m lib-classic/T*.pm
    1354 lib-classic/Timer.pm
    1155 lib-classic/Tracker.pm
    2509 total
```

Our modern Timer class is less than half the size of its classic equivalent, and our modern Tracker class is about 3/4 the size of its classic equivalent. In all, the modern classes are just over half the size of the classic classes.

## Diving into Moo

Let's look again at the modern classes and see what we get besides no constructor.

(open `lib-modern/Timer.pm`)

One thing that people tend to freak out about is that the syntax looks different than what we're used to. This is true, but it's still Perl.

You know how in Perl, if you declare a subroutine up front, you can invoke it without parentheses? A lot of Perl's syntax works like this: `print`, `join`, `split`, etc. It allows you to write a subroutine that does something that looks like it's built into the syntax of the language.

Well, that's all that's going on here. `has` is a method that Moo exports. The first argument to `has` is the name of the attribute. It's customary to not quote the attribute name by using a fat-arrow afterward, but you can quote it if it makes you feel better.

The next argument is a list of key/value properties of the attribute. The only required one is `is`, which tells Moo what kinds of accessors to build for this attribute: a reader, maybe a writer, whether the attribute is calculated when it is created or when it is first used (this is 'lazy') and something called read-write-protected, which is a read-only attribute but with a private writer method for using inside your class.

There are a few other options used to build attributes, but we'll only talk about the ones in these files.

Next we have an `isa` property. This tells Moo that when the attribute is ever set, whether in the constructor or through its writer method, that Moo should make sure the supplied value matches the supplied type constraint. Here we say that `start`, `stop`, and `duration` are all `Int` attributes.

Under the hood, Perl just applies a regular expression and maybe some other stuff to test that. That comes from `Types::Standard`:

(run `perldoc -m Types::Standard`; search for `Int`)

The `start` and `stop` attributes are identical except that `stop` also has a trigger property. Remember in our classic code, when we supply a value for `stop`, it updates the `duration` attribute? This one way to do that in Moo.

The `duration` attribute is also identical to the `start` attribute except for the `is` property: for `duration` we're using `rwp` which stands for "read-write-protected". We need this because we don't want the public consumers of our class to set the value of `duration`, but we do want to be able set its value inside of our class as a calculated field, like we do here in the trigger for `stop`.

See this `_set_duration` in the trigger? That's the protected writer that Moo gives us. Anytime you make a `rwp` field, you get a `_set_(whatever)` method that you can use inside your class to change the value.

Moo also allows you to provide a default value for an attribute in the form of a subroutine. It needs to be a subroutine so it can be invoked later if the attribute is lazy, and still be correct if something inside the subroutine refers to something outside of the subroutine.

Please read the Moo or Moose manual pages for more information.

Now let's look at a couple of other nice things that maybe you already picked up on.

## Breaking Classic: type checks

Let's go back into our test files.

(open `t/Timer.pm.t`)

This last test checks to make sure we have a valid integer for the start method, but we didn't do an equivalent check for `stop`; ideally we used the same code and it should also fail in the same way as `start`. We'll add a test, just to make sure:

```perl
$timer = Timer->new(activity => 'golfing');
eval { $timer->stop('dork') };
like $@, qr/type.*int/i, 'stop type error';
```

And then we'll test it:

```sh
$ make test-classic
```

Ouch; Perl barfed, but didn't prevent us from setting a bad value on the object in the first place. As a general rule, we want to fail early and hard.

Let's test the Moo version:

```sh
$ make test-modern
```

Because we declared this attribute as `Int`, we get type constraint checks for free. If you look at the Moo-based class, you can see at a glance that any given attribute has a type constraint in place. We normally wouldn't even test that in a Moo-based class, because that's already been tested on CPAN.

## Breaking Classic: missing constructor attribute

Let's look at another:

(open `t/Tracker.t`)

Let's see what happens when we create a new Tracker object but don't supply a `log_file` attribute. It should blow up, right?

```perl
eval { $tracker = Tracker->new };
like $@, qr/log_file/, 'log file missing';
```

and test it:

```sh
$ make test-classic
...
```

The classic version doesn't complain at all. Were we to attempt to look at a summary or something we'd get some undefined value errors, and if we didn't have other checks, we might try writing or reading from an undefined file name.

In the Moo version:

(open `lib-modern/Tracker.pm`)

we have set the `log_file` attribute as 'required', which means that it *must* be supplied by the constructor or the object won't be created and it will die loudly.

```sh
$ make test-modern
...
```

Moo gives us all this nice stuff for free. The biggest win with using a modern object system—either Moo or Moose—is that all of the boilerplate syntax just disappears. All you're left with is the minimum declarations needed to safely build an object.

## Summary

We've illustrated a few of the key differences between classic Perl object-orientation and modern Perl object-orientation using Moo. Moose is an even richer object system, rivaling many so-called modern language object systems like Ruby, Python, and Java, and even has a few nifty tricks that they don't.

If you're accustomed to writing code in classic OO style, with a little practice, you'll find the modern equivalents a breath of fresh air: cleaner syntax and fewer ways to forget something important. The reduction in code itself will make your business logic pop out where today it may be buried in parameter guards and error checking. I recommend you give it a try.
