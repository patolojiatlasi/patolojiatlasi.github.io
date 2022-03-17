# adding submodule

https://github.blog/2016-02-01-working-with-submodules/

```zsh
git submodule add https://github.com/pathologyatlas/pancreaticadenocarcinoma pancreaticadenocarcinoma
```

# removing submodule

```zsh
git submodule deinit -f --all
rm -rf .git/modules/
git rm -f pancreaticadenocarcinoma
```



# making WSI

see: [Convert .svs to .dzi and publish as or embed in a web page](https://github.com/pathologyatlas/make-html-WSI#convert-svs-to-dzi-and-publish-as-or-embed-in-a-web-page)


# using templates for new repositories

see: [Using templates for new repositories](https://github.com/pathologyatlas/template)

