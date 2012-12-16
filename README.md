# loganleger.com

This is the repo for my personal site, loganleger.com. It's powered by Jekyll. This is currently under development. Dependencies are handled by Bundler (Ruby) and Bower (external assets).

## TODO

- Favicon / Apple touch images
- Add title attributes everywhere
- Configure retina.js
- Thor listings: add timestamp column

## Thor: Command Line Hotness

[Thor][wycats/thor] is configured to provide some wonderful tools to make blogging easier. To list the available commands, use `thor list`. To get help on a command, including its usage and parameters, use `thor help <command>`.
  
- `thor jekyll:draft NAME`: creates a new blank post with the name *NAME* in the `./_drafts` folder (and makes that folder if it doesn't exist)
- `thor jekyll:drafts`: lists all draft posts (files in `./drafts`)
- `thor jekyll:posts`: lists all posts (files in `./posts`)
- `thor jekyll:publish [FILE]`: publishes (moves from `./drafts` to `./posts` and renames file with timestamp) a draft with the given file path *FILE*, or publishes the latest draft with the `--latest` or `-l` flag, or gives a list of drafts to chose from

## Custom Front Matter

The `default.html` layout includes the *description* and *keywords* meta tags in the `head`. They contain default values, but each post can manipulate those by adding the following custom front matter. In the absence of these keys in the YAML, the default values are used.

```yaml
---
seo:
  description: A post about kittens, memes, and other things about the internet.
  keywords: kittens, memes, reddit, internet
---
```