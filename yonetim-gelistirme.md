# Yönetim ve Geliştirme

[Patoloji Atlası](https://www.patolojiatlasi.com/)

[![Quarto Render Bilingual Book Push Other Repos GitLab](https://github.com/patolojiatlasi/patolojiatlasi.github.io/actions/workflows/Quarto-Render-Bilingual-Book-Push-Other-Repos-GitLab.yml/badge.svg)](https://github.com/patolojiatlasi/patolojiatlasi.github.io/actions/workflows/Quarto-Render-Bilingual-Book-Push-Other-Repos-GitLab.yml)

[![Lecture Notes Quarto Render Bilingual Book Push Other Repos and GitLab](https://github.com/patolojiatlasi/patolojiatlasi.github.io/actions/workflows/lecture-notes.yml/badge.svg)](https://github.com/patolojiatlasi/patolojiatlasi.github.io/actions/workflows/lecture-notes.yml)

[![pages-build-deployment](https://github.com/patolojiatlasi/patolojiatlasi.github.io/actions/workflows/pages/pages-build-deployment/badge.svg)](https://github.com/patolojiatlasi/patolojiatlasi.github.io/actions/workflows/pages/pages-build-deployment)

[![Post Wordpress Random Cases](https://github.com/patolojiatlasi/patolojiatlasi.github.io/actions/workflows/post-wordpress-random-cases.yml/badge.svg)](https://github.com/patolojiatlasi/patolojiatlasi.github.io/actions/workflows/post-wordpress-random-cases.yml)

------------------------------------------------------------------------

[pathologyatlas.github.io](https://images.patolojiatlasi.com/)

[lab.patolojinotlari.com](https://lab.patolojinotlari.com)

[patolojinotlari.com](https://patolojinotlari.com)

[parapathology.com](https://parapathology.com)

[twitter](https://twitter.com/patolojinotlari)

[linkedin](https://www.linkedin.com/company/patoloji-notlari)

<https://leanpub.com/patolojiatlasi/>

[development & WIP](https://images.patolojiatlasi.com/development.md)

-   <https://github.com/pathologyatlas>

-   <https://github.com/pathologyatlas/TODO>

-   <https://github.com/pathologyatlas/pathologyatlas.github.io>

-   <https://github.com/pathologyatlas/template>

-   <https://github.com/pathologyatlas/make-html-WSI>

contact: info\@patolojinotlari.com

contact: bilgi\@patolojiatlasi.com

<iframe width="160" height="400" src="https://leanpub.com/patolojiatlasi/embed" frameborder="0" allowtransparency="true">

</iframe>

-   https://github.com/marketplace/actions/quarto-render

-   https://github.com/quarto-dev/quarto-actions


------------------------------------------------------------------------


[![](./images/patoloji-atlasi-openseadragon-example)](https://openseadragon.github.io/examples/in-the-wild/#science)


[![](./images/patoloji-atlasi-quarto-example)](https://github.com/quarto-dev/quarto-actions/tree/main/examples)









---


## Examples for future uploads

### Pancreas Ductal Adenocarcinoma

<https://images.patolojiatlasi.com/pancreaticadenocarcinoma/>

#### Case 1

[histopathology](https://images.patolojiatlasi.com/pancreaticadenocarcinoma/case1-histopathology/viewer_z0.html)

### Neoplazinin Klinikopatolojik Özellikleri ve Epidemiyoloji

<https://images.patolojiatlasi.com/lecture1/Neoplazinin-Klinikopatolojik-Ozellikleri-ve-Epidemiyoloji.html>

------------------------------------------------------------------------

## adding submodule

https://github.blog/2016-02-01-working-with-submodules/

``` zsh
git submodule add https://github.com/pathologyatlas/pancreaticadenocarcinoma pancreaticadenocarcinoma
```

## removing submodule

``` zsh
git submodule deinit -f --all
rm -rf .git/modules/
git rm -f pancreaticadenocarcinoma
```

## making WSI

see: [Convert .svs to .dzi and publish as or embed in a web page](https://github.com/pathologyatlas/make-html-WSI#convert-svs-to-dzi-and-publish-as-or-embed-in-a-web-page)

## using templates for new repositories

see: [Using templates for new repositories](https://github.com/pathologyatlas/template)


## TODO

### Yönlendirme

-   development ve wsi to html repolarının adreslerini güncelle ve detaylandır
-   https://quarto.org/docs/websites/website-navigation.html#pages-404
-   Yönlendirme örneği: https://github.com/patolojiatlasi/GBD

### GBDAtlas

-   GBDAtlas ilk grubu ekle

### Language

-   https://statnmap.com/2017-04-04-format-text-conditionally-with-rmarkdown-chunks-complete-iframed-article/
-   https://statnmap.com/2017-10-06-translation-rmarkdown-documents-using-data-frame/
-   https://statnmap.com/2017-03-11-rmarkdown-conditional-chunks-to-create-multilingual-pdf-and-html-with-images/
-   https://bookdown.org/yihui/rmarkdown-cookbook/eng-asis.html
-   https://quarto.org/docs/authoring/create-citeable-articles.html
-   https://github.com/maelle/multilingual-book
-   https://github.com/patolojiatlasi/multilingual-book

### GitHub Actions

-   https://github.com/quarto-dev/quarto-actions
-   https://github.com/pommevilla/quarto-render
-   https://github.com/pommevilla/friendly-dollop
-   https://pommevilla.github.io/friendly-dollop/
-   https://github.com/dicook/github-action-push-to-another-repository
-   https://github.com/marketplace?page=1&q=another+repo&query=another+repo+&type=actions
-   https://github.com/marketplace/actions/file-changes-action

### tweeting with update

-   https://github.com/and-computers/HowToTweetEveryCommit
-   https://www.daveabrock.com/2020/04/19/posting-to-twitter-from-gh-actions/
-   https://gitweet.io/
-   https://joshuaiz.com/words/using-github-actions-to-post-to-twitter-on-commit

### Ders Notlarını ve PPT ekle

```         
<iframe src="https://www.serdarbalci.com/makalesaati/ISO-accreditation-digital-pathology.html" width="100%" height="475px"></iframe>
```

```         
{=html}
<iframe class="slide-deck" src="/dokuman/ISO-accreditation-digital-pathology.html" width="100%" height="475px"></iframe>
```

```         
{{< include ./dokuman/_ISO-accreditation-digital-pathology.qmd >}}
```

------------------------------------------------------------------------

``` zsh
git commit --allow-empty -m "Empty-Commit"
git push origin main
```

------------------------------------------------------------------------

-   https://www.w3schools.com/howto/howto_css_responsive_iframes.asp

------------------------------------------------------------------------

::: callout-note
Note that there are five types of callouts, including: `note`, `tip`, `warning`, `caution`, and `important`.
:::

::: callout-tip
### Tip With Caption

This is an example of a callout with a caption.
:::

::: {.callout-caution collapse="true"}
### Expand To Learn About Collapse

This is an example of a 'folded' caution callout that can be expanded by the user. You can use `collapse="true"` to collapse it by default or `collapse="false"` to make a collapsible callout that is expanded by default.
:::

::: aside
Some additional commentary of more peripheral interest.
:::

::: {.callout-note collapse="false" appearance="default" icon="true"}
### Optional caption (note)

-   Make expandable with 'collapse=true'
-   Remove 'collapse' to prevent expandability
-   Set appearance to 'default', 'simple' or 'minimal'
-   Remove icon with 'icon=false'
:::

::: {.callout-warning collapse="false" appearance="default" icon="true"}
### Optional caption (warning)

-   Make expandable with 'collapse=true'
-   Remove 'collapse' to prevent expandability
-   Set appearance to 'default', 'simple' or 'minimal'
-   Remove icon with 'icon=false'
:::

::: {.callout-important collapse="false" appearance="default" icon="true"}
### Optional caption (important)

-   Make expandable with 'collapse=true'
-   Remove 'collapse' to prevent expandability
-   Set appearance to 'default', 'simple' or 'minimal'
-   Remove icon with 'icon=false'
:::

::: {.callout-tip collapse="false" appearance="default" icon="true"}
### Optional caption (tip)

-   Make expandable with 'collapse=true'
-   Remove 'collapse' to prevent expandability
-   Set appearance to 'default', 'simple' or 'minimal'
-   Remove icon with 'icon=false'
:::

::: {.callout-caution collapse="false" appearance="default" icon="true"}
### Optional caption (caution)

-   Make expandable with 'collapse=true'
-   Remove 'collapse' to prevent expandability
-   Set appearance to 'default', 'simple' or 'minimal'
-   Remove icon with 'icon=false'
:::

::: columns
::: {.column width="40%"}
Left column
:::

::: {.column width="60%"}
Right column
:::
:::

------------------------------------------------------------------------

::: footer
Custom footer text
:::

footnote[^yonetim-gelistirme-1]

[^yonetim-gelistirme-1]: A footnote

::: incremental
-   Eat spaghetti
-   Drink wine
:::

::: nonincremental
-   Eat spaghetti
-   Drink wine
:::

. . .

::: notes
Speaker notes go here.
:::

deneme smaller {.smaller} deneme smaller

scroll till end {.scrollable} scroll till end

::: panel-tabset
#### Tab A

Content for `Tab A`

#### Tab B

Content for `Tab B`
:::


### get whole repos


https://chat.openai.com/share/09291b04-532c-4c5c-adae-017538f447b6


```powershell
Invoke-RestMethod -Uri "https://api.github.com/users/pathologyatlas/repos?per_page=100" | ForEach-Object { $_.clone_url } > repositories.txt

```

```powershell
$apiUrl = "https://api.github.com/users/pathologyatlas/repos?per_page=100"
$repositories = Invoke-RestMethod -Uri $apiUrl | Select-Object -ExpandProperty clone_url

foreach ($repository in $repositories) {
    git clone $repository
}
```


## alternative embedding


```html
=html
<iframe src="https://images.patolojiatlasi.com/ectopic-adrenal/HE.html" style="height:600px;width:100%;" data-external="1"></iframe>
```

knitr::include_url

```r
r
knitr::include_url(url = "https://images.patolojiatlasi.com/ectopic-adrenal/HE.html")
```



This is how you can show verbatim code chunks in the output. This is using
a `{verbatim}` chunk (check the source `index.qmd`):

````{verbatim}
```{r}
a very long line of R code that wraps in html, epub and PDF! In a pdf especially this is needed
```
````

If you want to show the triple backticks inline, you can also do so, like this:
```` ```{r} ```` to start an R chunk and ```` ``` ```` to end it. Check the source.

## Figures

Use `knitr::include_graphics()` to include images. Check the source for how to add
labels and captions:

```{r}
#| label: fig-gosling
#| fig-cap: "Ryan Gosling looking angry."
knitr::include_graphics("images/gosling.jpg")
```

See @fig-gosling for a meme.

## Conditional content

The block below does not appear in the PDF, only on the website and Epub:

::: {.content-hidden when-format="pdf"}
Hello, I won't appear in the PDF!
:::

::: {.content-visible when-format="pdf"}
But this text here, will only appear in the PDF!
:::
