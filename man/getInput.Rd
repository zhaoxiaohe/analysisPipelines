% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/core-functions.R
\docType{methods}
\name{getInput}
\alias{getInput}
\alias{getInput,BaseAnalysisPipeline-method}
\title{Obtains the initializedInput}
\usage{
getInput(object)

\S4method{getInput}{BaseAnalysisPipeline}(object)
}
\arguments{
\item{object}{The \code{AnalysisPipeline} or \code{StreamingAnalysisPipeline} object}
}
\value{
Dataframe for an \code{AnalysisPipeline} & SparkDataFrame for a \code{StreamingAnalysisPipeline}
}
\description{
Obtains the initializedInput
}
\details{
Obtains the input from the \code{AnalysisPipeline} or \code{StreamingAnalysisPipeline} object

This method is implemented on the base class as it is a shared functionality types of Analysis Pipelines
which extend this class
}
\examples{
library(analysisPipelines)
pipelineObj <- AnalysisPipeline(input = iris)
pipelineObj \%>>\% getInput
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
  \code{\link{getLoggerDetails}},
  \code{\link{getOutputById}},
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
