#!/usr/bin/env Rscript

library(tidyverse)
library(seqinr)
library(stringr)

is_unique <- function(x) {
  length(unique(x)) == length(x) 
}

is_proper_sub <- function(x, y) {
  ixy <- intersect(x, y)
  fst <- all(x %in% ixy)
  scd <- !all(y %in% ixy)
  fst && scd
}

IN <- "hmmer_raw.tsv"
FAA <- "pids.faa"
CUT <- 24

x <- read_tsv(IN)

x <- x |>
  filter(score >= CUT)

x |>
  arrange(score) |>
  ggplot(aes(y = score)) +
  geom_point(alpha = 1/3, shape = 1, aes(x = 1:length(score))) +
  facet_grid(. ~ query_description)

endo <- x |> 
  filter(query_description ==
           "Endonuclease_5") |>
  pull(pid)

deam <- x |> 
  filter(query_description ==
           "YwqJ-deaminase") |>
  pull(pid)


faa <- read.fasta(FAA, seqtype = "AA")

# Emotional Talking
# Attributes vs. Looks

pids <- map_chr(faa, \(x) attr(x, "name"))

stopifnot("pids is not unique" =
            is_unique(pids))
stopifnot("endo is not proper subset of pids" =
            is_proper_sub(endo, pids))
stopifnot("deam is not proper subset of pids" =
            is_proper_sub(deam, pids))

endo_faa <- faa[pids %in% unique(endo)]
endo_headers <- map_chr(endo_faa, \(x) attr(x, "Annot")) |>
    str_replace_all(">", "")

deam_faa <- faa[pids %in% unique(deam)]
deam_headers <- map_chr(deam_faa, \(x) attr(x, "Annot")) |>
    str_replace_all(">", "")

write.fasta(endo_faa, endo_headers,
            "endo.24.faa",
            nbchar = 80)

write.fasta(deam_faa, deam_headers,
            "deam.24.faa",
            nbchar = 80)
