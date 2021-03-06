#' Calculate F-statistics at base pair resolution from a loaded BAM files
#'
#' After defining the models of interest (see \link{makeModels}) and 
#' pre-processing the data (see \link{preprocessCoverage}), use 
#' \link{calculateStats} to calculate the F-statistics at base-pair resolution.
#' 
#' @param coveragePrep A list with \code{$coverageProcessed}, 
#' \code{$mclapplyIndex}, and \code{$position} normally generated using 
#' \link{preprocessCoverage}.
#' @param models A list with \code{$mod} and \code{$mod0} normally generated 
#' using \link{makeModels}.
#' @param lowMemDir The directory where the processed chunks are saved when 
#' using \link{preprocessCoverage} with a specified \code{lowMemDir}.
#' @param ... Arguments passed to other methods and/or advanced arguments.
#'
#' @return A numeric Rle with the F-statistics per base pair that passed the 
#' cutoff.
#'
#' @author Leonardo Collado-Torres
#' @export
#' @aliases calculate_stats
#' @seealso \link{makeModels}, \link{preprocessCoverage}
#' @importFrom BiocParallel bplapply bpworkers
#' @importMethodsFrom IRanges ncol '[[' length unlist
#' @importFrom IRanges RleList
#' @importFrom derfinderHelper fstats.apply
#'
#' @examples
#' ## Collapse the coverage information
#' collapsedFull <- collapseFullCoverage(list(genomeData$coverage), 
#'     verbose = TRUE)
#' 
#' ## Calculate library size adjustments
#' sampleDepths <- sampleDepth(collapsedFull, probs=c(0.5), verbose = TRUE)
#' 
#' ## Build the models
#' group <- genomeInfo$pop
#' adjustvars <- data.frame(genomeInfo$gender)
#' models <- makeModels(sampleDepths, testvars = group, adjustvars = adjustvars)
#'
#' ## Preprocess the data
#' prep <- preprocessCoverage(genomeData, cutoff = 0, scalefac = 32,
#'     chunksize=1e3, colsubset=NULL)
#' 
#' ## Run the function
#' fstats <- calculateStats(prep, models, verbose=TRUE, method='regular')
#' fstats
#'
#' \dontrun{
#' ## Compare vs pre-packaged F-statistics
#' library('testthat')
#' expect_that(fstats, is_equivalent_to(genomeFstats))
#' }

calculateStats <- function(coveragePrep, models, lowMemDir = NULL, ...) {
    
    stopifnot(length(intersect(names(coveragePrep), c('coverageProcessed', 
        'mclapplyIndex', 'position'))) == 3)
    stopifnot(length(intersect(names(models), c('mod', 'mod0'))) == 
        2)
    
    ## Advanged arguments
#' @param verbose If \code{TRUE} basic status updates will be printed along the 
#' way.
    verbose <- .advanced_argument('verbose', TRUE, ...)


#' @param scalefac This argument is passed to 
#' \link[derfinderHelper]{fstats.apply} and should be the same as the one used 
#' in \link{preprocessCoverage}.
    scalefac <- .advanced_argument('scalefac', 32, ...)    


#' @param method Has to be either 'Matrix' (default), 'Rle' or 'regular'. See 
#' details in derfinderHelper::fstats.apply().
    method <- .advanced_argument('method', 'Matrix', ...)


#' @param adjustF A single value to adjust that is added in the denominator of 
#' the F-stat calculation. Useful when the Residual Sum of Squares of the 
#' alternative model is very small.
    adjustF <- .advanced_argument('adjustF', 0, ...)

    if (is.null(lowMemDir) & is.null(coveragePrep$coverageProcessed)) 
        stop("preprocessCoverage() was used with a non-null 'lowMemDir', so please specify 'lowMemDir'.")
    
    ## Define cluster
    BPPARAM <- .define_cluster(...)
    
    if (is.null(lowMemDir)) {
        ## Check that the columns match
        numcol <- ncol(coveragePrep$coverageProcessed)
        if (numcol != dim(models$mod)[1]) {
            stop("The alternative model 'models$mod' is not compatible with the number of samples in 'coveragePrep$coverageProcessed'. Check the dimensions of the alternative model.")
        }
        
        if (length(coveragePrep$coverageProcessed) < bpworkers(BPPARAM)) {
            warning("The number of chunks in coveragePrep$coverageProcessed is smaller than the number of cores selected. For using all the cores specified consider splitting the data into more chunks.")
        }
    }
        
    ## Fit a model to each row (chunk) of database:
    if (verbose) 
        message(paste(Sys.time(), 'calculateStats: calculating the F-statistics'))
    fstats.output <- bplapply(coveragePrep$mclapplyIndex, fstats.apply, 
        data = coveragePrep$coverageProcessed, mod = models$mod, 
        mod0 = models$mod0, lowMemDir = lowMemDir, scalefac = scalefac,
        method = method, adjustF = adjustF, BPPARAM = BPPARAM)
    result <- unlist(RleList(fstats.output), use.names = FALSE)
    
    ## Done =)
    return(result)    
} 

#' @export
calculate_stats <- calculateStats
