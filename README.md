# Turku - Decidim

Turku Decidim instance for the "Asukasbudjetti" service.

The platform is based on [Decidim](https://github.com/decidim/decidim).

For documentation and further guidance about the framework, see
[Decidim Docs](https://docs.decidim.org/).

## Gettings started

Clone this repository and run:

```bash
$ bundle exec db:create db:migrate
$ bundle exec db:seed
```

Make sure to run these two commands separately.

More information available from Decidim's own
[Getting started guide](https://github.com/decidim/decidim/blob/master/docs/getting_started.md).

## Update the git gems

If you want to update the gems loaded from Git, run the following with the
gem's name:

```bash
$ bundle update --source "decidim"
```
