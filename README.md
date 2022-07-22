
# idler

<!-- badges: start -->
[![R-CMD-check](https://github.com/grddavies/idler/workflows/R-CMD-check/badge.svg)](https://github.com/grddavies/idler/actions)
<!-- badges: end -->

Boot idle users off your shiny server :zzz:

## Installation

You can install the development version of idler from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("grddavies/idler")
```

## Example

How to use idler to manage user sessions in your Shiny app:

``` r
library(shiny)
ui <- function(){
  tagList(
    idler::use_idler(),
    tags$h1("idler demo")
  )
}

server <- function(input, output, session) {
  # Boot idle users after 2s
  idler::set(2)
}

shinyApp(ui, server)
```

## Acknowledgements

The JavaScript event listeners at `idler`'s core are lifted straight from [this stack exchange answer](https://stackoverflow.com/a/58006254/12879453). Credit for that (crucial) bit of functionality goes to [Pork Chop](https://stackoverflow.com/users/2753526/pork-chop)
