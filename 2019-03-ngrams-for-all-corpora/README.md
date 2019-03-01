
# Comparison of ngrams in different corpora

*"Corpora" is the plural of "corpus", like the Russian book corpus or the German book corpus. [Learn more about Google ngrams here](https://books.google.com/ngrams).*

## What does it do?

The code in this repo is great if you want to find out **how often the same words (or numbers) were used in books written in different languages, historically.** It runs [Matt Nicklay](https://github.com/econpy)'s [google-ngrams](https://github.com/econpy/google-ngrams) script for different corpora and joins them all together as one csv.

## How does it work?

1. `git clone` this repo.
2. Open the `makefile` and write down the queries you want to run.
3. Open the `make-ngrams.sh` bash script and specify the corpora, the end year, the start year and everything else the [google-ngrams script](https://github.com/econpy/google-ngrams) lets you specify (Matt wrote a good readme explaining that).
4. Open your terminal, navigate to the folder and type `make` (or `make ngram`).
5. Wait. Then celebrate your final csv.

The following thing will happen once you type `make`:
![](https://i.imgur.com/wQc2Ihf.gif)

## Output
...is a csv that looks like this:
![](https://i.imgur.com/0UDAL0y.png)

## Related links
not yet up!
