# Yönetim ve Geliştirme

[pathologyatlas.github.io](https://pathologyatlas.github.io/)

[lab.patolojinotlari.com](https://lab.patolojinotlari.com)

[patolojinotlari.com](https://patolojinotlari.com)

[parapathology.com](https://parapathology.com)

[twitter](https://twitter.com/patolojinotlari)

[linkedin](https://www.linkedin.com/company/patoloji-notlari)

https://leanpub.com/patolojiatlasi/

[development & WIP](https://pathologyatlas.github.io/development.md)

contact: info\@patolojinotlari.com

contact: bilgi\@patolojiatlasi.com

<iframe width="160" height="400" src="https://leanpub.com/patolojiatlasi/embed" frameborder="0" allowtransparency="true">

</iframe>

-   https://github.com/marketplace/actions/quarto-render

-   https://github.com/quarto-dev/quarto-actions

------------------------------------------------------------------------

# Examples for future uploads

## Pancreas Ductal Adenocarcinoma

<https://pathologyatlas.github.io/pancreaticadenocarcinoma/>

### Case 1

[histopathology](https://pathologyatlas.github.io/pancreaticadenocarcinoma/case1-histopathology/viewer_z0.html)

## Neoplazinin Klinikopatolojik Özellikleri ve Epidemiyoloji

<https://pathologyatlas.github.io/lecture1/Neoplazinin-Klinikopatolojik-Ozellikleri-ve-Epidemiyoloji.html>

# TODO

-   lab-patolojinotlari adresini patolojiatlasi'na yönlendir.
-   template ve eski repository'lerde openseadragon adresini değiştir
-   pathologyatlas-github-io'daki alt repository'leri kaldır
-   EN için ilk grubu yayınla
-   pathologyatlas-github-io EN'e yönlendir
-   GBDAtlas ilk grubu ekle
-   development ve wsi to html repolarının adreslerini güncelle ve detaylandır
- https://quarto.org/docs/websites/website-navigation.html#pages-404

# adding submodule

https://github.blog/2016-02-01-working-with-submodules/

``` zsh
git submodule add https://github.com/pathologyatlas/pancreaticadenocarcinoma pancreaticadenocarcinoma
```

# removing submodule

``` zsh
git submodule deinit -f --all
rm -rf .git/modules/
git rm -f pancreaticadenocarcinoma
```

# making WSI

see: [Convert .svs to .dzi and publish as or embed in a web page](https://github.com/pathologyatlas/make-html-WSI#convert-svs-to-dzi-and-publish-as-or-embed-in-a-web-page)

# using templates for new repositories

see: [Using templates for new repositories](https://github.com/pathologyatlas/template)


# tweeting with update
- https://github.com/and-computers/HowToTweetEveryCommit
- https://www.daveabrock.com/2020/04/19/posting-to-twitter-from-gh-actions/
- https://gitweet.io/
- https://joshuaiz.com/words/using-github-actions-to-post-to-twitter-on-commit

