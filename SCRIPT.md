# A Brief History of Object-Orientation in Perl

<note>This script is the outline for the presentation, including when to change to a slide and the text that accompanies the slide. Text not in a slide block is narration to use while looking at code.

A section that looks like this:

```
[
  `path/to/file1`
  `path/to/file2`
]
```

Indicates that you will be looking at two files simultaneously in your publicly viewable terminal, typically side-by-side, but do whatever works for your environment.

A section in triple-backtick escaped quotes indicates a command that you should run. If the block is marked `# private` then it is not meant for display. Otherwise, run the commands in the block in a shell that all can see.
</note>

```sh # private
cd 1.0-classic
make next
```

<slide title="a-brief-history-of-object-orientation-in-perl">
Welcome!

The purpose of this presentation is to illustrate so-called "classic" object-orientation in Perl and contrast it with modern object-orientation. Along the way we'll highlight OO patterns that apply in either paradigm.

The context for our discussion will be a time tracking application. We're not going to write a full application, but we will write the classes that would make such an application possible, and we'll be able to see how that comes together in some of the unit tests we'll write.

We'll be starting with classic OO Perl code and updating it in small incremental checkpoints.
</slide>

## Checkpoint 1.0: Classic OO

<slide title="'Classic' Perl OO Conventions">
Classic object-orientation in Perl is less of a "system" than a set of conventions:

1, 2, 3

We'll look now at the classes for our time tracker, written in a classic OO style [terminal]
</slide>

Our project is simple:

```shell # private
cd 1.0-classic
make next
```

```shell
cd work
tree
```

Let's look at the Timer class first.

## Timer

[
  `work/lib/Timer.pm`
]

In classic Perl OO, we must supply the constructor, and convention says that it should be called `new()`, but it doesn't *have* to be called `new()`. You'll occasionally come across a module on CPAN that uses some other word for the constructor.

Perl methods always receive the class name or a reference to the object as their first argument. In the case of `new()`, it receives the class name, so with:

```perl
Timer->new(...);
```

perl passes the string "Timer", which is the class name, as the first argument to `new`, just as we see in here in the constructor, so we shift that off of the argument list and save it for later.

In our Timer constructor, we initialize the object with any arguments passed into us, none of which are required. Then we return the object to the caller so they can have a handle to the object.

The next 4 methods are essentially identical. They're simple accessors on the attributes of the object.

In `start` we have some simple validation checks to make sure that we're passed a number rather than something else. In `stop` we have this thing called a trigger that calculates the duration whenever `stop` is invoked.

The `duration` attribute is calculated from stop minus start. The `activity` attribute is just a string, like "working" or "taking a break".

Finally we have a `to_csv` method here that serializes the important fields of our object as a string of comma-separated values.

Let's look at the tests for this Timer class:

[
  `t/Timer.pm.t`
]

This is a typical test file: we start with Test::More, Perl's built-in test harness. We load the Timer class to make sure we don't have any compile errors and also so we can use the class.

We create some new timers in a variety of ways, invoke methods on them, check for side effects in the object like the duration. Finally we add a test for the correct data type for `start` to make sure it fails when we get bad data.

I've mentioned before, and this idea comes from _Working Effectively with Legacy Code_, tests act like a vice on a workbench, holding the behavior of your code constant while we change and improve the structure of the code. We will be running our tests throughout our work.

### Tracker

Let's look now at the Tracker class.

[
  `lib/Tracker.pm`
]

The Tracker class is responsible for aggregating Timer objects, serializing and writing them to a file, and then summarizing those timers so that we can see how much time we spent working versus meetings or something.

Here is our constructor `new`. The Tracker class has one attribute named `ledger_file` which is where we're storing the timer events.

The `append_event` method accepts a timer object, opens the ledger file, serializes the timer and writes it to the ledger. 

The `summary` method loops over the ledger and deserializes the entries back into Timer objects so we can work with them through their encapsulated business logic.

In Classic OO Perl, there is no real distinction between attribute accessors like `ledger_file` and object methods like `append_event` and `summary`. In principle we understand they serve different purposes, but in practice they tend to blend together without additional syntax or comments.

We also have a test file for `Tracker.pm`:

[
  `t/Tracker.pm.t`
]

Much like the Timer tests, we load the Tracker class, create a new Tracker and pass in the ledger file as an argument. We then append a bunch of Timers to the ledger, then run the `summary` method to make sure we get what we expect.

Let's run the test:

```sh
make test
```

How much code do we have here for these two simple classes?

```
$ wc -m lib/*.pm
    1287 lib/Timer.pm
    1099 lib/Tracker.pm
    2386 total
```

Ok, about 2k.

## Checkpoint 1.9: Dependency Inversion Principle

We have at least one design flaw in this classic OO code. Did you spot it?

[
  `lib/Tracker.pm`
]

There's no way we can easily unit test this, because we've tied our implementation to the file system through the ledger. Notice here in `append_event` and `summary` we're creating file handles and then then doing filesystem operations, which couples our Tracker class to its storage.

This brings us to our first OO principle.

<slide title="design-patterns">
> Commit only to an interface defined by an abstract class.

The core problem we are trying to solve with the Tracker class is modeling a time tracker, and while a ledger is a necessary part of that, it's not the core part.

The Tracker class shouldn't care about how the ledger is implemented: we might store timer data in a log file, we might store timer data in a database, or in memory. The point is that we don't want our model to know about *how* events are stored, just that we *can* store and retrieve events.

By defining an interface that stores and retrieves events, and depending on that interface rather than on a concrete implementation, we can allow our application to be tested in different contexts and also change how data is stored without changing our Tracker class.
</slide>

<slide title="extract-ledger">
What we're going to do now is rather than hard-coding the implementation of a ledger inside of our Tracker class, we're going to create a new class that implements this idea of a ledger. It will have its own interface and our Tracker class will use it to store and retrieve Timer events.
</slide>

[
 `work/lib/Tracker.pm`
 `1.9-extract-ledger/lib/Tracker.pm`
]

Here on the left is our current code, on the right is what we want it to become. The first thing we notice is this `ledger_file` attribute, which normally receives a file name, will become instead a ledger-like object that "does" ledgering.

This will be the Tracker class's handle to the ledger. The ledger must be given to us from outside of this class, so whatever invokes the Tracker constructor—likely the application or the unit tests—must first create a ledger and then pass that to the Tracker constructor. We'll also rename the `ledger_file` accessor to reflect that change.

We can see how we'll use this ledger in `append_event`: rather than the Tracker class being responsible for writing the Timer object to file, we'll just hand the serialized Timer off to the ledger object's `append` method for it to take care of.

And the `summary` method works in the same way: rather than opening the ledger and reading each of its entries and deserializing them back into Timer objects, we'll move the concern of the ledger out into the `scan` method, and we'll keep the Tracker's concern of dealing with the Timer objects in the Tracker class.

We need somewhere to put this ledger behavior, so we'll make a new class called `Ledger::File` that looks like this:

[
 `work/lib/Tracker.pm`
 `1.9-extract-ledger/lib/Ledger/File.pm`
]

This Ledger class accepts the `ledger_file` attribute we were using in the Tracker class. It also needs to implement `append` and `scan`. We've mostly moved the logic from Tracker.pm `append_event` into the Ledger::File `append` method: open a file for append, write the string to it, close the file.

The `scan` method is also taken from `summary`: open the file for reading, while loop over all the lines, but rather than implementing business logic, we just invoke a subroutine that was given to us.

[
 `1.9-extract-ledger/lib/Tracker.pm`
 `1.9-extract-ledger/lib/Ledger/File.pm`
]

We could have made a method that returned all of the Timer events as a list, but if we were calculating summaries for, say, all of the employees of the federal government, we wouldn't be able to fit all of that into memory. Using this functional programming technique of a closure, we don't have to and it still keeps the concerns of the Tracker separate from the concerns of the Ledger.

And we'll want to update our tests: rather than passing in a `ledger_file` string, we'll pass in a new Ledger object.

[
  `t/Tracker.pm.t`
  `1.9-extract-ledger/t/Tracker.pm.t`
]

This is a form of dependency injection: the Tracker class asks its caller to provide the ledger object when the Tracker object is created.

[
  `1.9-extract-ledger/t/Ledger.pm.t`
]

And we have tests for our ledger class.

Because you didn't come here to see me type, I'm going to apply all these changes we just talked about:

```sh # private
cd ../1.9-extract-ledger
make next
```

Let's run the tests:

```sh
make test
```

## Checkpoint 2.0: Extract Class

Now that we've *extracted* and *abstracted* the idea of a ledger into a separate class, we can finally fix our unit tests for the Tracker class. We'll do this by standing up an in-memory ledger:

[
  `work/lib/Ledger/File.pm`
  `2.0-memory-ledger/lib/Ledger/Memory.pm`
]

We can see this implements the same interface as the file-based ledger.

We'll use this new ledger implementation in our tests:

[
  `work/t/Tracker.pm.t`
  `2.0-memory-ledger/t/Ledger.pm.t`
]

```sh # private
cd ../2.0-memory-ledger
make next
```

and test again:

```sh
make test
```

Now we can truly unit test `Tracker` without any side effects. We could unit test it in a read-only container, for example. No file system, database, or any other storage service required.

All we need in our Tracker class is *something* that implements a ledger-like interface. Now we are programming to an interface, not an implementation. Programming to interfaces enables polymorphism, one of the core features of object-oriented design.

At this point, we have written a good little set of classes in the classic OO style. We're now going to convert these classes to use modern Perl object orientation.

## Modern OO Style

Classic OO Perl is largely based on convention; everyone who does classic OO Perl adheres to common patterns to write attributes and object methods. Modern OO Perl, in contrast, uses a declarative syntax, which follows more of the spirit of Perl that different things should look different: object attributes are declared using the `has` keyword, and object methods work just like they do now, declared as subroutines in a package.

I'll be using Moo to demonstrate modern Perl OO style, but Moo is almost completely compatible with Moose—these are two OO systems for Perl, so that if you have some Moo-based classes, you could with little effort upgrade them to Moose-based classes. I won't get into why you might want to do this, but there are several good reasons for it and you'll likely hit them if you write enough modern Perl.

## Checkpoint 2.4: Boilerplate and Constructor

We're going to start with our existing Timer class and rewrite it using Moo incrementally. Here is the existing Timer class and we'll compare it with the next checkpoint for this file:

[
  `work/lib/Timer.pm`
  `2.4-moo-boilerplate/lib/Timer.pm`
]

First we'll replace `use strict` and `use warnings` with:

```perl
use strictures 2;
use Moo;
use namespace::clean;
```

This is a bit of boilerplate that you see in nearly all Moo classes. `strictures` is like `use warnings` and `use strict`, but it also makes warnings fatal so that during development you know when you've gotten something wrong.

Moo gives us a constructor for free, but because we're not a full Moo class yet, it doesn't know how to map incoming parameters to object attributes, so we'll to replace `new` with `BUILD`.

`BUILD` is a special method that Moo looks for and runs it if it exists after the constructor is done building the object. There's also `BUILDARGS` which Moo runs just before the constructor, allowing you to modify incoming arguments if you need to.

I'm going to apply this next checkpoint to our code.

```sh # private
cd ../2.4-moo-boilerplate
make next
```

All we've done is gotten rid of the constructor and replaced it with the `BUILD` method, so this should be an easy checkpoint:

```sh
make test
```

## Checkpoint 2.5: Attributes

As I mentioned, one of the hallmarks of modern Perl OO is declarative syntax: attributes look like attributes and look different from methods.

[
  `work/lib/Timer.pm`
  `2.5-moo-start-attribute/lib/Timer.pm`
]

Here on the left is our current Timer class, on the right we've made the following changes:

* Scalar::Util is replaced with Types::Standard
* the `start` invocation is removed from the `BUILD` method
* the `start` method is replaced with `has`

Before you start to wonder if we've accidentally stepped in some Ruby somewhere, let me assure you this is still very much Perl.

In Perl, if you declare a subroutine up front, you can invoke it without parentheses. A lot of Perl's syntax works like this: `print`, `return`, `defined`, `join`, `split`, etc. It allows you to write a subroutine that does something that looks like it's built into the syntax of the language.

That's all that's going on here. `has` is a method that Moo exports. The first argument to `has` is the name of the attribute. It's customary to not quote the attribute name by using a fat-arrow afterward, but you can quote it if it makes you feel better.

We're telling Moo that this object "has" an attribute called 'start' and then we describe the attribute with these additional parameters. The `is` property tells Moo what kinds of accessors to build for this attribute: a reader, maybe a writer, whether the attribute is calculated when it is created or when it is first used (this is 'lazy') and something called read-write-protected, which is a read-only attribute but with a private writer method for using inside your class.

Next we have an `isa` property—this is a type constraint. This tells Moo that when the value for the attribute is set, whether in the constructor or through its writer method, that Moo should make sure the supplied value matches the supplied type constraint. Here we say that `start` parameter is an integer.

Under the hood, Perl just applies a regular expression and maybe some other stuff to test that. That comes from `Types::Standard`:

Moo also allows us to provide a default value for an attribute in the form of a subroutine that it will run when the object is created and no value is supplied.

When we declare an attribute with `has`, the constructor is informed so that it will accept `start` as a parameter when the object is created and use the value of the parameter to set the value of the attribute of the same name.

And now because the `start` attribute has a default value, we no longer need to set it in the `BUILD` method.

```sh # private
cd ../2.5-moo-start-attribute
make next
```

```sh
make test
```

## Checkpoint 2.6: More Attributes

Now that we've got the hang of it, let's replace the `activity` and `duration` methods with attributes:

[
  `work/lib/Timer.pm`
  `2.6-moo-more-attributes/lib/Timer.pm`
]

Here they are on the right:

```perl
has activity => (is => 'rw', isa => Str, default => sub {''});
has duration => (is => 'rwp', isa => Int, default => sub {0});
```

You can see that activity works like `start`, except that it takes a string for a value, so we'll also update our type imports:

```perl
use Types::Standard qw/Int Str/;
```

The `duration` attribute we declare as 'rwp' which stands for "read-write protected". The attribute is read-only, but Moo creates a private setter for us so we can update the value from inside our class.

Now that we have real attributes for `activity` and `duration`, we can remove them from the `BUILD` method, which now only has `stop`:

```perl
sub BUILD {
    my ($self, $args) = @_;
    $self->stop(defined $args->{stop} ? $args->{stop} : time);
}
```

```sh # private
cd ../2.6-moo-more-attributes
make next
```

and test:

```sh
make test
```

> duration is a read-only accessor at 3-moo/lib/Timer.pm line 24

## Checkpoint 2.7: Read-Only Accessors

Oh-ho! What's this? Looks like our little trigger in `stop` is illegal now:

```perl
## trigger
$self->duration($self->{stop} - $self->{start});
```

We forgot that `duration` is read-write protected, which means that there is no public setter method. Instead, we'll have to use the private setter accessor that Moo created for us.

```perl
## trigger
$self->_set_duration($self->{stop} - $self->{start});
```

```sh # private
cd ../2.7-moo-fix-duration
make next
```

and test again:

```sh
make test
```

Isn't that nice? Moo helped us make sure that we're not modifying object attributes that we shouldn't. Because the `duration` attribute is calculated from `stop - start`, we don't want to allow people to bypass our object's business logic. But we have this convenient trigger in the `stop` method that updates `duration` as a convenience for us, so we can use the protected private setter for that.

### Checkpoint 2.8: Last Attribute

We have one final method to convert in the Timer class:

[
  `work/lib/Timer.pm`
]

We saved the `stop` method for last because it has this little tricky trigger in here: it's not just a simple accessor. Well, the nice thing is that Moo attributes also accept a `trigger` parameter that works like this:

[
  `2.8-moo-stop-attribute/lib/Timer.pm`
]

Anytime the `stop` attribute is set, we're also going to update the `duration` attribute. That's nifty. We can also remove this `BUILD` method completely since all of our attributes are properly declared.

```sh # private
cd ../2.8-moo-stop-attribute
```

```sh
make test
```

## Benefits of Modern OO

Our modern Timer class is less than half the size of the classic OO Timer class size—and our class is starting to read like a children's book.

But we've done far more than reducing the number of lines of code. If we were to add into the classic Timer class all of the type constraint checks and other stuff we get from Moo, our original class would be even *larger* and more bulky.

Declarative code means fewer areas for bugs to hide and less complexity you have to load into your head. Your code reads better.

## Checkpoint 2.9: Converting Tracker

We're going to convert the Tracker class too. I'll just show you what that looks like, not much here:

[
  `work/lib/Tracker.pm`
  `2.9-moo-tracker/lib/Tracker.pm`
]

We're going to add the boilerplate. The constructor goes away, and the `ledger` attribute becomes a one-liner. We also get some simple type checking on it.

```sh # private
cd ../2.9-moo-tracker
make next
```

```sh
make test
```

## Checkpoint 3.0: Convert Ledgers

To tidy this up, we'll convert the Ledger classes too:

[
  `work/lib/Ledger/File.pm`,
  `3.0-moo-ledger/lib/Ledger/File.pm`
]

Again, the only thing that's changing here is we're adding the Moo boilerplate, and converting the `ledger_file` accessor to be a Moo attribute.

```sh # private
cd ../3.0-moo-ledger
make next
```

```sh
make test
```

<slide title="ledger-size-comparison">
Just for fun, here is our original Ledger::File implementation on the left and our new one on the right. I've cut off the identical append and scan methods. The Moo version is far less error-prone: the classic version has 10 mentions of the string "ledger_file" and the Moo version just has one.
</slide>

## Roles: Units of Composition

A second principle of object-oriented design is "Favor object composition over class inheritance".

<slide title="favor-composition-over-inheritance">
This is a principle because most programming languages make inheritance easy and composition less easy, so people tend to favor inheritance over composition because the programming languages they use also do this. Inheritance is so easy in Moo that I'm not even going to show it to you. If you want to do vertical inheritance, you're going to have to learn that on your own.

There is a place for inheritance, of course: when one class is really just an enhanced version of its parent class. This is what we call an "IS-A" relationship and that's what inheritance is good at.

But just because a class needs some behavior doesn't mean inheritance the right choice. Roles allow us to selectively compose behavior into a class without requiring the class to change its essential nature, which is what inheritance demands. Roles are typically small packages that implement just one kind of cross-cutting behavior that many classes could use: logging, serialization, storage access, reporting, and so forth.
</slide>

<slide title="roles">
In Perl, composition is done using "roles". Roles in modern Perl OO systems typically have two distinct uses:

1, 2

We're going to look at the first, more common use of a role now in our Timer class.
</slide>

## Checkpoint 3.7: Extracting and Composing Roles

Let's look at the `Timer` class once more: we have this `to_csv` method that we can experiment with. We're going to pull this "csv-able" behavior out of the Timer class and turn it into a role. Here we go:

[
  `work/lib/Timer.pm`
  `3.7-roles-extract/lib/Role/Serializable/CSV.pm`
]

We're just going to move the subroutine out and replace it with a `with` statement.

```sh # private
cd ../3.7-roles-extract
make next
```

(reload `work/lib/Timer.pm`)

The `with` statement is like `use`: it goes and finds the module by that name and then tries to load it. But it carefully checks to make sure it's not overriding any methods your class already has (that would be like inheritance), otherwise, it's like a "#include" statement: the class now has the methods the role implements *as if they were defined in the class to begin with*.

```sh
make test
```

## Checkpoint 4.0: Generic Role Interfaces

(skip 3.8, 3.9)

[
  `lib/Timer.pm`
  `lib/Role/Serializable/CSV.pm`
]

That was easy: we have composed in this role to the Timer class and now any class can consume this role just by adding a `with` statement. Of course, we've made a terrible blunder. Can you tell what we did wrong?

(start, stop, activity fields)

Yes: this is role is not reusable code! We've just moved Timer logic from one place to another. To make this role truly useful, it needs to work for many kinds of objects, not just Timer objects.

How do we do this? We could easily make this `to_csv` method accept a list of fields from the caller. The problem with that is, because this is a serialization method, it has to work the same every time it is called.

The Timer class needs to be authoritative for its own serialization representation because only the Timer class knows about its own inner workings. How do we get these two classes to share that knowledge?

<slide title="roles">
The first use of roles is to allow us to compose behaviors into classes; the second use is to specify an interface that a class must implement. What we want to do with this role is to require any class that consumes the role to specify a method the role code can call and receive a data structure it can serialize.

We're going to use both kinds of roles in the next few minutes. Let me warn you that programming to an interface usually means extra code, but it's often a very little extra code, clean and easy to test. You will have little classes and modules that don't appear to do much, but they're acting like electrical sockets—providing a consistent interface to a variety of consumers.
</slide>

Buckle up, because we've got a bit of ground to cover.

I'm going to gloss over a lot of the code unless someone stops me and asks for a better explanation. This section is probably better enjoyed when you can pause the video and try things with the code yourself.

Our primary goal is to abstract the idea of what it means to serialize and deserialize an object. We observe now that CSV is one of several serialization formats we could use. For example, we might want to use JSON or YAML, so rather than having a `to_csv`, `to_json`, etc. we'll generalize that to just `freeze`, which gives us some nice imagery.

Deserialization is taking a serialized or frozen data structure and creating an object from it again. We call this "thaw" to go with "freeze". So we want to define and implement an interface that does "freeze" and "thaw" in a way that will work for many objects, not just Timers, and many serialization formats, not just CSV.

Here are some illustrations that may or may not help.

<slide title="roles-and-classes">
Here's what's going on. We have the Tracker and Timer classes, and a CSV role.

* **Role::Serializable::CSV implements "freeze" and "thaw" from the Role::Serializable interface.** Role::Serializable is acting as an interface, requiring any role or class that consumes it to implement it. Role::Serializable::CSV is acting as a role that implements the Role::Serializable interface.
* **Timer consumes Role::Serializable::CSV.** The Timer class gets new methods as if they were implemented in the Timer class.
* **Timer implements "pack" and "unpack" from the Role::Packable interface.** Role::Packable is acting as an interface, requiring any class that consumes it to implement it.
* **Serializable consumes Packable.** Any class that consumes Serializable must also implement Packable.
* **"freeze" and "thaw" invoke "pack" and "unpack".** Pack and unpack are implemented inside of Timer, while freeze and thaw are composed into Timer from the Role::Serializable::CSV role.
* **Tracker invokes "freeze" and "thaw" from Timer.** Now that Timer implements "freeze" and "thaw", the Tracker class can use those to get its work done without knowing any details of Timers or serialization.
</slide>

```sh # private
cd ../4.0-roles
make next
```

With those images in our heads, let's look at Role::Serializable::CSV and Role::Serializable:

[
  `4.0-roles-interface/lib/Role/Serializable/CSV.pm`
  `4.0-roles-interface/lib/Role/Serializable.pm`
]

We say that CSV *implements* the Serializable interface. Notice that the Serializable interface also requires the Packable interface because Serializable depends on "pack" and "unpack".

Now we'll look at Timer:

[
  `4.0-roles-interface/lib/Role/Serializable/CSV.pm`
  `4.0-roles-interface/lib/Role/Serializable.pm`
  `4.0-roles-interface/lib/Timer.pm`
  `4.0-roles-interface/lib/Role/Packable.pm`
]

Because Timer consumes a Serializable role, it *must* implement `pack` and `unpack` because Serializable consumes that role.

The `pack` method takes an object, in this case a Timer object, and turns it into a data structure that, if it were passed to the constructor, would create a copy of the object. All we need in this case is the start, stop, and activity attributes. `pack` returns a hash reference of these three fields.

The `unpack` method does the inverse: it takes the packed data structure and returns a new Timer object. If you needed to clone an object, invoking pack and unpack would do it.

If we look at `freeze` in CSV now, we can see that it takes a packed object, that is, a hash reference, and loops over its keys and creates a list of strings of the form "key=value", it then joins these strings with commas. That's poor man's CSV.

The `thaw` method takes that kind of string, splits on commas, which gives us a list of "key=value" strings, then splits those on the equals sign, and creates a hash reference from these fields, effectively reversing `freeze`. We then pass that hash reference to the class's `unpack` method, which we know is a constructor, and we get a new object back.

The CSV role doesn't know what kind of object it's dealing with, but because it implements the Serializable interface, the CSV role *knows* that the consuming class is guaranteed to have implemented `pack` and `unpack`.

[
  `4.0-roles-interface/t/Timer.pm.t`
]

We'll even add a round-trip test in our `Timer` test:

```perl
## round-trip serialization
my $timer2 = Timer->thaw($timer->freeze);
is_deeply $timer, $timer2, 'round-trip serialization';
```

The last thing we need to update is the Tracker class. The Tracker class makes use of both the serializer and the deserializer, freeze and thaw.

[
  `3.7-roles-extract/lib/Tracker.pm`
  `4.0-roles-interface/lib/Tracker.pm`
]

Tracker used to invoke `to_csv` in the `append_event` method, but we replace that with `freeze` because the Tracker class doesn't care about which serialization is used, and the Ledger class only cares that it receives a string to append to the ledger.

This whole chunk of knowledge about thawing a Timer is no longer needed here, which is great because the Tracker has no business knowing that kind of stuff. We can just replace it with:

```perl
my $timer = Timer->thaw($entry);
```

```sh
make test
```

## Checkpoint 4.1: JSON Serialization

Why go through all of this bother of setting up an interface for serialization? Let's illustrate this with a JSON serializer.

[
  `work/lib/Role/Serializable/CSV.pm`
  `4.1-roles-json-serialization/lib/Role/Serializable/JSON.pm`
]

Comparing the CSV to the JSON, the JSON is simpler because JSON was designed to be a serializer.

We'll change the Timer class to consume it instead of CSV:

```sh # private
cd ../4.1-roles-json-serialization
make next
```

```perl
with 'Role::Serializable::JSON';
```

```sh
make test
```

Boom. Once the proper abstractions were in place, one change to the Timer class switches from CSV serialization to JSON serialization.

## Checkpoint 4.2: Attribute Interfaces

Let's look at one last use of a role which is kind of neat.

[
  `work/lib/Tracker.pm`
  `4.2-roles-does/lib/Tracker.pm`
]

In the Tracker class, we declare that the `ledger` attribute must be an object of some kind. With roles, we can make that even stronger by using the `does` property:

```perl
has ledger => (is => 'ro', does => 'Role::Ledger', required => 1);
```

And we can get rid of the `use Types::Standard` statement.

What this says is that whenever this `ledger` attribute is set, it *must* be set with an object that implements the `Role::Ledger` interface, that is, it must implement `append` and `scan`.

[
  `work/lib/Role/Ledger.pm`
]

```perl
package Role::Ledger;
use Moo::Role;
use strictures 2;

requires qw(append scan);

1;
```

This gives us a stronger guarantee of compatibility than simply requiring an object.

```sh # private
cd ../4.2-roles-does
make next
```

```sh
make test
```

## Conclusion

We've taken some classes written in the "classic" Perl OO style and converted them incrementally to take advantage of modern Perl OO techniques. Along the way we've learned about Moo, roles, role interfaces, and type constraints.

There is much more to Moo and Moose, and we barely touched on OO design principles and patterns. I recommend you look at the resource section and review the reading there.

<slide title="resources"/>
