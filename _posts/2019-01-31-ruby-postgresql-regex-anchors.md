---
layout: post
title:  "Regex anchors in Ruby and PostgreSQL"
date:   2019-01-31 14:24:37 -0800
---
Regular expressions (regex) in Ruby and PostgreSQL differ in a slightly confusing way when it comes to the meaning of `/Z`.

## Ruby

A [common pitfall](https://batsov.com/articles/2013/12/04/regexp-anchors-in-ruby/) for people learning Ruby is using `^` and `$` in regular expressions thinking that they apply to the entire string when they actually apply to the beginning and end of a *line*:

```
irb(main):001:0> "hello\nworld".match?(/^hello$/)
=> true
```

To match the beginning and end of the entire string in Ruby you should instead use `\A` and `\z`:

```
irb(main):002:0> "hello\nworld".match?(/\Ahello\z/)
=> false
irb(main):003:0> "hello".match?(/\Ahello\z/)
=> true
```

## PostgreSQL

Postgres also has a [pattern matching](https://www.postgresql.org/docs/current/functions-matching.html) feature but it works in "non-newline-sensitive" mode by default:

```
postgres=# select e'hello\nworld' ~ '^hello$';
 ?column?
----------
 f
(1 row)
```

**Sidenote:** Postgres will not interpret `\n` inside a string as a newline by default. To use C-style escapes, you have to [prefix the string with an E](https://www.postgresql.org/docs/current/sql-syntax-lexical.html#SQL-SYNTAX-STRINGS-ESCAPE): `e'hello\nworld'`


To change to "newline-sensitive" mode, you have to add a [special prefix](https://www.postgresql.org/docs/current/functions-matching.html#POSIX-METASYNTAX) `(?n)`:

```
postgres=# select e'hello\nworld' ~ '(?n)^hello$';
 ?column?
----------
 t
(1 row)
````

In this mode, you can use `\A` and `\Z` (note: uppercase, unlike Ruby) to match the beginning and end of the string:

```
postgres=# select e'hello\nworld' ~ '(?n)\Ahello\Z';
 ?column?
----------
 f
(1 row)

postgres=# select e'hello\nworld' ~ '(?n)\Ahello\nworld\Z';
 ?column?
----------
 t
(1 row)
```

## The confusing bit

Confusingly, Ruby also has a `\Z` but it means "match end of string, ignoring a single newline at the end":
```
irb(main):001:0> "hello\nworld".match?(/\Ahello\nworld\Z/)
=> true
irb(main):002:0> "hello\nworld\n".match?(/\Ahello\nworld\Z/)
=> true
irb(main):003:0> "hello\nworld\n\n".match?(/\Ahello\nworld\Z/)
=> false
irb(main):004:0> "hello\nworld\n\n".match?(/\Ahello\nworld\n\Z/)
=> true
```

My guess is that this was provided to match the behavior in Perl as described [here](https://www.regular-expressions.info/anchors.html):
>Because Perl returns a string with a newline at the end when reading a line from a file, Perl's regex engine matches $ at the position before the line break at the end of the string even when multi-line mode is turned off. Perl also matches $ at the very end of the string, regardless of whether that character is a line break. So `^\d+$` matches `123` whether the subject string is `123` or `123\n`.

Personally, I would probably avoid using this at all since it's likely to be confused for `\z`.

## In summary

To match the beginning and end of an entire *string*:

- Ruby: use `\A` and `\z` (probably best to avoid `\Z`)
- Postgres: use `^` and `$`

To match the beginning and end of a *line*:

- Ruby: use `^` and `$`
- Postgres: use `^` and `$` but change to "newline-sensitive" mode
