# BARUG November 2016: Integrating Shiny into RStudio and Your Daily Workflow: A Hands-on Tutorial

## Introduction
As part of your standard data/analytics/software development process, you may write a utility function or package to automate or simplify your repeatable tasks. But what if the reproducible task is best solved visually?

For this tutorial, I'll walk through building an example Shiny gadget, a SQL database workbench in Shiny that is integrated into your RStudio session to pull data, save queries, and plot results to streamline your ad-hoc querying process.

Each of the commits in the repository is a step in the process. You can get everything by cloning the repository:

`git clone https://github.com/ayayron/sql_workbench_addin.git`

## Requirements
1. You'll need to have RStudio at least v0.99.878
2. Packages: shiny(>= 0.13), devtools, miniUI, rstudioapi, ggplot, RMySQL

## Recommended Reading
* [RStudio Addins](https://rstudio.github.io/rstudioaddins/)
* [Shiny Gadget UI](http://shiny.rstudio.com/articles/gadget-ui.html)
* [Rstudio Addin List](https://github.com/daattali/addinslist)
* [Creating a minimal package](http://kbroman.org/pkg_primer/pages/minimal.html)