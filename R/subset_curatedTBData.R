#' @title Subsetting curatedTBData based on single/multiple conditions
#' @description \code{subset_curatedTBData} selects desired samples from curatedTBData
#' database according to pre-specified conditions.
#' @name subset_curatedTBData
#' @param theObject A SummarizedExperiment/MultiAssayExperiment object.
#' @param annotationColName A character indicates feature of interest in the object's column data.
#' @param annotationCondition A vector indicates conditions want to be subsetted.
#' @param useAssay A character indicates the name of the assay (expression matrix) within the object.
#' Need this argument when the input is a SummarizedExperiment object.
#' @param experiment_name A character indicates the name of the experiment within MultiAssayExperiment object.
#' Expect \code{theObject[[experiment_name]]} to be a matrix. Two special cases are:
#' When experiment_name is "all". Perform whole MultiAssayExperiment subsetting, output is in the form of MultiAsaayExperiment object.
#' When experiment_name is "assay_raw". Perform subsetting on the SummarizedExperiment Object.
#' @param ... Extra named arguments passed to function.
#' @rdname subset_curatedTBData-methods
#' @exportMethod subset_curatedTBData

setGeneric(name="subset_curatedTBData", function(theObject,...){
  standardGeneric("subset_curatedTBData")
})

#' @rdname subset_curatedTBData-methods
setMethod("subset_curatedTBData",
          signature="SummarizedExperiment",
          function(theObject, annotationColName, annotationCondition,
                   useAssay="counts",...){

            # Check whether assay exists in the object
            assay_names <- SummarizedExperiment::assayNames(theObject)
            assay_name_index <- which(assay_names %in% useAssay)
            assay_name_exclude <- which(assay_names != useAssay)

            if(length(assay_name_index)==0){
              stop(paste(useAssay,"is/are not found within the object"))
            }

            n <- length(annotationCondition)

            theObject_filter <- theObject[,SummarizedExperiment::colData(theObject)
                                          [,annotationColName] %in% annotationCondition]

            # Omit Assays that are not selected in the object
            SummarizedExperiment::assays(theObject_filter)[assay_name_exclude] <- NULL

            annotation <- SummarizedExperiment::colData(theObject_filter)[,annotationColName]
            if(length(unique(annotation)) == n){
              return(theObject_filter)
            }

          }
)

#' @rdname subset_curatedTBData-methods
setMethod("subset_curatedTBData",
          signature="MultiAssayExperiment",
          function(theObject, annotationColName, annotationCondition, useAssay=NULL,
                   experiment_name,...){
            # Check whether experiment exists in the object
            if(experiment_name != "All"){
              experiment_name_index <- which(names(theObject) %in% experiment_name)
              if(length(experiment_name_index) == 0){
                stop(paste(experiment_name,"is not found within the object"))
              }
            }

            # For experiment_name == "all".
            # Perform whole MultiAssayExperiment selection, output is MultiAsaayExperiment
            if(experiment_name == "All"){

              n <- length(annotationCondition)
              theObject_filter <- theObject[,SummarizedExperiment::colData(theObject)
                                            [,annotationColName] %in% annotationCondition]
              result <- SummarizedExperiment::colData(theObject_filter)[,annotationColName]
              if(length(unique(result)) == n){
                return(theObject_filter)

              }
            }
              # Perform individual selection, assay_raw is SummarizedExperiment
              # output is reduced SummarizedExperiment
            else if (experiment_name == "assay_raw"){

                theObject_sub <- theObject[[experiment_name]]
                n <- length(annotationCondition)
                col_data <-  SummarizedExperiment::colData(theObject)

                # For those datasets that do not include all samples from the study
                if (ncol(theObject[[experiment_name]]) != nrow(col_data)){
                  index <- stats::na.omit(match(colnames(theObject[[experiment_name]]),
                                         row.names(col_data)))
                  col_data <- col_data[index,]
                }

                SummarizedExperiment::colData(theObject_sub) <- col_data
                # subsetting annotationCondition
                sobject_TBSig_filter <- theObject_sub[,SummarizedExperiment::colData(theObject_sub)
                                                      [,annotationColName] %in% annotationCondition]
                result <- SummarizedExperiment::colData(sobject_TBSig_filter)[,annotationColName]
                # check if both status are in the column data
                if(length(unique(result)) == n){
                  return(sobject_TBSig_filter)
                }

              }
            # Perform individual selection, output is SummarizedExperiment
            # Potentially for TBSignatureProfiler
            # assay_reduce matrix
            else{

              n <- length(annotationCondition)
              col_data <-  SummarizedExperiment::colData(theObject)

              # when not all samples are included in the expression matrix
              # This is the cases with some RNA-seq studies
              if (ncol(theObject[[experiment_name]]) != nrow(col_data)){
                index <- stats::na.omit(match(colnames(theObject[[experiment_name]]),
                                       row.names(col_data)))
                col_data <- col_data[index,]
              }

              # Set atrribute to be NULL, ensure that row/column names have NULL attributes
              colnames(theObject[[experiment_name]]) <- as.character(
                                         colnames(theObject[[experiment_name]]))

              row.names(theObject[[experiment_name]]) <- as.character(
                                         row.names(theObject[[experiment_name]]))

              sobject_TBSig <- SummarizedExperiment::SummarizedExperiment(
                                  assays=list(counts = as.matrix(theObject[[experiment_name]])),
                                              colData = col_data)

              # subsetting annotationCondition
              sobject_TBSig_filter <- sobject_TBSig[,SummarizedExperiment::colData(sobject_TBSig)
                                                    [,annotationColName] %in% annotationCondition]
              result <- SummarizedExperiment::colData(sobject_TBSig_filter)[,annotationColName]
              # check if both conditions are in the column data
              if(length(unique(result)) == n){
                return(sobject_TBSig_filter)
              }

            }

        }
)


#' Check the annotation column name in the colData function
#' @param theObject A SummarizedExperiment/MultiAssayExperiment object.
#' @param annotationColName A character indicates feature of interest in the object's column data.
#' @param annotationCondition A vector indicates conditions want to be subsetted.
#'
#' @export
check_annotation <- function(theObject, annotationColName, annotationCondition){

  col_names <- colnames(SummarizedExperiment::colData(theObject))
  n <- length(annotationCondition)
  if(!is.na(match(annotationColName, col_names))){

    theObject_sub <- theObject[, SummarizedExperiment::colData(theObject)
                               [,annotationColName] %in% annotationCondition]
    result <- SummarizedExperiment::colData(theObject_sub)[,annotationColName]
    if(length(unique(result)) == n){
      return(theObject_sub)
    }

  }

}

#' Combine samples with common genes from selected studies,
#' usually run after matching prob sets to gene symbol. See \code{\link{MatchProbe}}
#' @name CombineObjects
#' @param object_list A list contains expression data with probes mapped to gene symbol.
#' @param list_name A character/vector contains object name to be selected to merge.
#' @param experiment_name A character/vector to choose the name of the experiment from MultiAssayExperiment Object.
#' @return A SummarizedExperiment Object contains combined data from several studies.
#' @examples
#' list_name <-  c("GSE101705","GSE54992","GSE19444")
#' data_list <-  get_curatedTBData(list_name)
#' sobject <- CombineObjects(data_list, list_name,
#'                           experiment_name = "assay_curated")
#' @export
CombineObjects <- function(object_list, list_name=NULL,
                           experiment_name=NULL, useAssay=NULL){
  # Check the element witin list
  if(is.null(experiment_name) && is.null(useAssay)){
    stop(paste("Please specify experiment name of the MultiAssayExperiment Object or
               assay name of the SummarizedExperiment Object."))
  }
  if(is.null(list_name)){
    list_name <- names(objects_list)
    object_list <- object_list[list_name]
  }
  else{
    object_list <- object_list[list_name]
  }
  if(class(object_list[[1]]) == "MultiAssayExperiment"){

    dat_exprs_match <- lapply(object_list, function(x)
      MultiAssayExperiment::experiments(x)[[experiment_name]] %>% data.frame)

  }

  if(class(object_list[[1]]) == "SummarizedExperiment"){

    dat_exprs_match <- lapply(object_list, function(x)
      SummarizedExperiment::assays(x)[[useAssay]] %>% data.frame)

  }

  # Combine sample with common genes from a list of objects.
  # Input data type should be data.frame
  dat_exprs_combine <- Reduce(
    function(x, y) merge(x, y, by = "id", all = FALSE),
    lapply(dat_exprs_match, function(x) { x$id <- rownames(x); x }))
  row_names <- dat_exprs_combine$id
  dat_exprs_count <- dat_exprs_combine %>% dplyr::select(-.data$id) %>% data.frame()
  row.names(dat_exprs_count) <- row_names

  # Create combined column data information
  Sample1 <- lapply(object_list[list_name], function(x)
    SummarizedExperiment::colData(x) %>% row.names())

  Sample <- unlist(Sample1, use.names=FALSE)
  col_data <- lapply(seq_len(length(object_list[list_name])), function(x) {
    col_data <- SummarizedExperiment::colData(object_list[list_name][[x]])
    col_data$GSE <-names(object_list[list_name][x])
    col_data
  })

  # Combine list into dataframe with unequal columns
  col_info <- plyr::rbind.fill(lapply(col_data, function(x){ as.data.frame(x) }))
  row.names(col_info) <- Sample

  # Remove samples that does not exist in the count
  index <- stats::na.omit(match(colnames(dat_exprs_count), Sample))
  col_info <- col_info[index,]

  # Create output in the format of SummarizedExperiment
  result <- SummarizedExperiment::SummarizedExperiment(assays = list(counts = as.matrix(dat_exprs_count)),
                                                       colData = col_info)
  return(result)
}
