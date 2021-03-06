% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/TBSignatureProfiling.R
\name{combine_auc}
\alias{combine_auc}
\title{Combine results from list. Calculate p-value and AUC values}
\usage{
combine_auc(
  SE_scored_list,
  annotationColName,
  signatureColNames,
  num.boot = NULL,
  percent = 0.95,
  AUC.abs = FALSE,
  BPPARAM = BiocParallel::SerialParam(progressbar = TRUE)
)
}
\arguments{
\item{SE_scored_list}{A list of SummarizedExperiment Object from \code{\link[TBSignatureProfiler]{runTBsigProfiler}}.}

\item{annotationColName}{A character string specifying the feature of interest in the object's column data}

\item{signatureColNames}{A character/vector string contains name of gene signature.}

\item{num.boot}{Number of bootstrapping.}

\item{percent}{A number indicates the percentage of confidence interval.}

\item{AUC.abs}{Boolean. If AUC.abs = TRUE, return the AUC values from function \code{\link[ROCit]{rocit}}.
If AUC.abs = FALSE, return the AUC values for max(AUC, 1-AUC).}

\item{An}{instance inherited from \code{bplappy}.
See \code{\link[BiocParallel]{bplapply}} for details.}
}
\value{
A data frame with features including Signatures, P.value, neg10xLog(P.value) and AUC for each signature across datasets.
}
\description{
Combine results from list. Calculate p-value and AUC values
}
