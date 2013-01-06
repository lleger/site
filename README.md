# loganleger.com

This is the repo for my personal site, loganleger.com. It's powered by Jekyll. This is currently under development (and probably will always be).

## TODO

- Analytics
- Add some tests for thor functionality
- Revised drafts workflow

## Thor: Command Line Hotness

[Thor](http://github.com/wycats/thor) is configured to provide some wonderful tools to make blogging easier. To list the available commands, use `thor list`. To get help on a command, including its usage and parameters, use `thor help <command>`.

| Command       | Functionality |
| ------------- | ------------- |
| `thor jekyll:draft NAME` | creates a new blank post with the name *NAME* in the `./_drafts` folder (and makes that folder if it doesn't exist) |
| `thor jekyll:drafts` | lists all draft posts (files in `./drafts`) |
| `thor jekyll:posts` | lists all posts (files in `./posts`) |
| `thor jekyll:post [FILE]` | posts (moves from `./drafts` to `./posts` and renames file with timestamp) a draft with the given file path *FILE*, or posts the latest draft with the `--latest` or `-l` flag, or gives a list of drafts to chose from |
| `thor jekyll:publish` | deploys to S3/Cloudfront |
| `thor jekyll:dependencies` | check for dependencies |

## Local Development: Guard + Foreman

Development is made nicer with Guard and Foreman. When a file changes (or a new gem is added), Guard rebuilds the site and loads it up at `http://localhost:4000`. Foreman is used to manage the Guard and Jekyll server processes. To get everything running, type `foreman start`.

## Bootstrap

Before you do anything, you'll need to install the dependencies. System utilities are handled by Homebrew, Ruby Gems by Bundler and JS/CSS by Bower. A Thor command to check dependencies is available: `thor jekyll:dependencies`.

## How To Make A New Post

1. `thor jekyll:draft "My New Post"`
2. Edit `./_drafts/my_new_post.mdown` until draft is finished and ready to post.
3. `thor jekyll:post --latest`
4. `jekyll` (Not necessary with Foreman + Guard set up.)
5. `thor jekyll:publish`

## Custom Front Matter

The `default.html` layout includes the *description* and *keywords* meta tags in the `head`. They contain default values, but each post can manipulate those by adding the following custom front matter. In the absence of these keys in the YAML, the default values are used.

```yaml
---
seo:
  description: A post about kittens, memes, and other things about the internet.
  keywords: kittens, memes, reddit, internet
---
```