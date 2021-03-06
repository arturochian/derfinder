% Generated by roxygen2 (4.0.2): do not edit by hand
\name{findRegions}
\alias{findRegions}
\alias{find_regions}
\title{Find non-zero regions in a Rle}
\usage{
findRegions(position = NULL, fstats, chr, oneTable = TRUE,
  maxClusterGap = 300L, cutoff = quantile(fstats, 0.99), segmentIR = NULL,
  ...)
}
\arguments{
\item{position}{A logical Rle of genomic positions. This is generated in
\link{loadCoverage}. Note that it gets updated in \link{preprocessCoverage}
if \code{colsubset} is not \code{NULL}.}

\item{fstats}{A numeric Rle with the F-statistics. Usually obtained using
\link{calculateStats}.}

\item{chr}{A single element character vector specifying the chromosome name.}

\item{oneTable}{If \code{TRUE} only one GRanges is returned.
Otherwise, a GRangesList with two components is returned: one for the
regions with positive values and one for the negative values.}

\item{maxClusterGap}{This determines the maximum gap between candidate DERs.
It should be greater than \code{maxRegionGap} (0 by default).}

\item{cutoff}{Threshold applied to the \code{fstats} used to determine the #' regions.}

\item{segmentIR}{An IRanges object with the genomic positions that are
potentials DERs. This is used in \link{calculatePvalues} to speed up
permutation calculations.}

\item{...}{Arguments passed to other methods and/or advanced arguments.}
}
\value{
Either a GRanges or a GRangesList as determined by \code{oneTable}.
Each of them has the following metadata variables.
\describe{
\item{value }{ The mean of the values of \code{y} for the given region.}
\item{area }{  The absolute value of the sum of the values of \code{y} for
the given region.}
\item{indexStart }{ The start position of the region in terms of the index
for \code{y}.}
\item{indexEnd }{ The end position of the region in terms of the index for
\code{y}.}
\item{cluster }{ The cluser ID.}
\item{clusterL }{ The total length of the cluster.}
}
}
\description{
Find genomic regions for which a numeric vector is above (or below)
predefined thresholds. In other words, this function finds the candidate
Differentially Expressed Regions (candidate DERs). This is similar to
\link[bumphunter]{regionFinder} and is a helper function for
\link{calculatePvalues}.
}
\details{
\link[bumphunter]{regionFinder} adapted to Rle world.
}
\examples{
## Preprocess the data
prep <- preprocessCoverage(genomeData, cutoff=0, scalefac=32, chunksize=1e3,
    colsubset=NULL)

## Get the F statistics
fstats <- genomeFstats

## Find the regions
regs <- findRegions(prep$position, fstats, 'chr21', verbose=TRUE)
regs

\dontrun{
## Once you have the regions you can proceed to annotate them
annotation <- bumphunter::annotateNearest(regs, 'hg19')
annotation
}
}
\author{
Leonardo Collado-Torres
}
\references{
Rafael A. Irizarry, Martin Aryee, Hector Corrada Bravo, Kasper
D. Hansen and Harris A. Jaffee. bumphunter: Bump Hunter. R package version
1.1.10.
}
\seealso{
\link{calculatePvalues}
}

