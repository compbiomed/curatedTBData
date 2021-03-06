% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/TBSignatureProfiling.R
\name{heatmap_auc}
\alias{heatmap_auc}
\title{Obtain ridge plots for emprirical AUC distribution for signature scores.}
\usage{
heatmap_auc(
  combine_dat,
  GSE_sig = NULL,
  signatureColNames,
  facet = TRUE,
  clustering = TRUE,
  order_increase_avg = FALSE,
  x_axis_name = NULL
)
}
\arguments{
\item{combine_dat}{A dataframe contains signatures, datsets name, and AUC.
Such dataset can be obtained from \code{\link[curatedTBData]{combine_auc}}.}

\item{GSE_sig}{A dataframe contains information about each signature and its traning dataset name.
Defult is NULL.}

\item{signatureColNames}{A character vector. Expect in the format "Name_SignatureType_Number". e.g. "Anderson_OD_51"}

\item{facet}{Boolean. TRUE if the users want to group signatures into groups.
Default is TRUE.}

\item{clustering}{Boolena. TRUE if the users want to perform clustering of the heatmap using hierarchical clustering.
Default is TRUE.}
}
\value{
Heatmap with AUC values. x axis is the expression data, y axis represents signatures.
}
\description{
Obtain ridge plots for emprirical AUC distribution for signature scores.
}
\examples{
combine_dat_exp <- data.frame(Signature=rep(c("Anderson_42", "Anderson_OD_51",
                              "Berry_393","Berry_OD_86","Blankley_5"),2),
               AUC = stats::runif(10,0.5,1), GSE=rep(c("GSE39939","GSE19442"), each=5))
GSE_sig_exp <- data.frame(Signature=c("Anderson","Anderson","Berry","Berry"),
                   GSE=c("GSE39939","GSE39940","GSE19442","GSE19443"))
TBsignatures_exp <- c("Anderson_42", "Anderson_OD_51", "Berry_393","Berry_OD_86",
                      "Blankley_5")
heatmap_auc(combine_dat_exp,GSE_sig_exp, TBsignatures_exp, facet = FALSE)
heatmap_auc(combine_dat_exp,GSE_sig_exp, TBsignatures_exp, facet = TRUE)
}
