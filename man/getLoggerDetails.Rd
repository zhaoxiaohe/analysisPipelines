% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/core-functions.R
\docType{methods}
\name{getLoggerDetails}
\alias{getLoggerDetails}
\alias{getLoggerDetails,BaseAnalysisPipeline-method}
\title{Obtains the logger configuration for the pipeline}
\usage{
getLoggerDetails(object)

\S4method{getLoggerDetails}{BaseAnalysisPipeline}(object)
}
\arguments{
\item{object}{A Pipeline object}
}
\value{
Logger configuration as a list
}
\description{
Obtains the logger configuration for the pipeline
}
\details{
This function obtains the logger configuration for the pipeline.
}
\examples{
library(analysisPipelines)
pipelineObj <- AnalysisPipeline(input = iris)
pipelineObj \%>>\% getLoggerDetails
}
\seealso{
Other Package core functions: \code{\link{BaseAnalysisPipeline-class}},
  \code{\link{MetaAnalysisPipeline-class}},
  \code{\link{assessEngineSetUp}},
  \code{\link{checkSchemaMatch}},
  \code{\link{createPipelineInstance}},
  \code{\link{exportAsMetaPipeline}},
  \code{\link{generateOutput}},
  \code{\link{genericPipelineException}},
  \code{\link{getInput}}, \code{\link{getOutputById}},
  \code{\link{getPipelinePrototype}},
  \code{\link{getPipeline}}, \code{\link{getRegistry}},
  \code{\link{initDfBasedOnType}},
  \code{\link{initialize,BaseAnalysisPipeline-method}},
  \code{\link{loadMetaPipeline}},
  \code{\link{loadPipeline}},
  \code{\link{loadPredefinedFunctionRegistry}},
  \code{\link{loadRegistry}}, \code{\link{prepExecution}},
  \code{\link{registerFunction}},
  \code{\link{savePipeline}}, \code{\link{saveRegistry}},
  \code{\link{setInput}}, \code{\link{setLoggerDetails}},
  \code{\link{updateObject}},
  \code{\link{visualizePipeline}}
}
\concept{Package core functions}
