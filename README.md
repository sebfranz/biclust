# biclust
Cell clustering wrapper for [scregclust](https://github.com/sven-nelander/scregclust)

## Installation

You can install the development version of biclust from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("sebfranz/biclust")
```

## Example

Run demo/lm_example.R.

## Development

Load package

``` r
library(devtools)
load_all(".")
```

To generate documentation

``` r
library(roxygen2) #  Read in the roxygen2 R package
roxygenise() #  Builds the help files
```