##################################################################################################
# Title: Meta pipelines
# Author: Naren Srinivasan
# Created on: Nov 20, 2018
# Description: Functions/ Methods to define and use meta-pipelines
##################################################################################################

# proto' is an S3 class whic is used as a slot, and hence it is defined in the environment
setOldClass("proto")

#' @name MetaAnalysisPipeline-class
#' @rdname MetaAnalysisPipeline-class
#' @title Class for creating and working with meta-pipelines
#' @details This class works with the \code{AnalysisPipeline} and \code{StreamingAnalysisPipeline} classes, and allows the
#' pipeline to be exported as meta-pipeline. A meta-pipeline is a construct, where the input dataset as well as the arguments
#' to functions in the pipeline are not defined. Only the analysis flow and dependencies are stored.
#' @slot pipeline A tibble which holds functions to be called in the pipeline
#' @slot pipelinePrototype An object of class \code{proto} from the 'proto' package which maintains the prototype of the
#' functions in the pipeline and their respective arguments
#' @slot type A string defining whether it is a batch or streaming pipeline. Acceptable values are 'batch' & 'streaming'
#' @family Package core functions
#' @exportClass MetaAnalysisPipeline
#' @export MetaAnalysisPipeline

MetaAnalysisPipeline <- setClass("MetaAnalysisPipeline",
                                 slots = c(
                                   pipeline = "tbl",
                                   pipelinePrototype = "proto",
                                   type = "character"
                                 ))

#' MetaAnalysisPipeline constructor
#' @docType methods
#' @rdname initialize-methods
#' @title This is the constructor for the \link{MetaAnalysisPipeline} class
#' @family Package core functions
#' @keywords internal

setMethod(
  f = "initialize",
  signature = "MetaAnalysisPipeline",
  definition = function(.Object, type = "batch")
  {
    tryCatch({
      .Object@pipeline <- dplyr::tibble(
        id = character(),
        operation = character(),
        heading = character(),
        parameters = list(),
        outAsIn = logical(),
        storeOutput = F
      )

      .Object@type <- "batch"

      return(.Object)
    }, error = function(e){
      futile.logger::flog.error(e, name = "logger.base")
      stop()
    })
  }
)

#' @name exportAsMetaPipeline
#' @rdname exportAsMetaPipeline
#' @title Method to export a meta-pipeline
#' @details This method exports a Pipeline object i.e. of the classes \code{AnalysisPipeline} or
#' \code{StreamingAnalysisPipeline} as a meta-pipeline
#' @param object A Pipeline object
#' @return an object of class "\code{MetaAnalysisPipeline}"
#' @family Package core functions
#' @examples
#' \dontrun{
#' #' pipelineObj <- AnalysisPipeline(input = iris)
#' pipelineObj %>>% univarCatDistPlots(uniCol = "Species") %>>%
#'  exportAsMetaPipeline -> exportedMetaPipeline
#' }
#' @export
setGeneric(
  name = "exportAsMetaPipeline",
  def = function(object){
    standardGeneric("exportAsMetaPipeline")
  }
)

.exportAsMetaPipeline <- function(object){
  object %>>% setLoggerDetails(target = "none") -> object
  metaPipeline <- MetaAnalysisPipeline()
  pipelineProto <- proto::proto()
  if(class(object) == "AnalysisPipeline"){
    metaPipeline@type <- "batch"
  }else if(class(object) == "StreamingAnalysisPipeline"){
    metaPipeline@type <- "streaming"
  }

  if(nrow(object@pipelineExecutor$topologicalOrdering) == 0){
    object %>>% prepExecution -> object
  }

  object@pipeline -> pipeline
  pipeline %>>% purrr::pmap(function(id, operation, heading,
                                     parameters, outAsIn, storeOutput, dependencies){
    # fnName <- paste0("fn_", operation)
    fnName <- operation
    assign(x = fnName, value = proto::proto(), envir = pipelineProto)

    purrr::imap(parameters, function(p, np){
      # n <- names(p)
      if(class(p) == "formula"){
        if(analysisPipelines::isDependencyParam(p)){
          n <- analysisPipelines::getResponse(p)
          p <- paste0("~", analysisPipelines::getTerm(p)) %>>% as.formula()
        }
      }
      assign(x = paste0(np),
             value = p,
             envir = pipelineProto[[fnName]])
      return(NULL)
    })
    return(NULL)
  })
  metaPipeline@pipeline <- pipeline
  metaPipeline@pipelinePrototype <- pipelineProto
  return(metaPipeline)
}

#' @rdname exportAsMetaPipeline
setMethod(
  f = "exportAsMetaPipeline",
  signature = "BaseAnalysisPipeline",
  definition = .exportAsMetaPipeline
)


#' @name getPipelinePrototype
#' @rdname getPipelinePrototype
#' @title Obtain the prototype of the functions in the pipeline
#' @param metaPipelineObj  A \code{MetaAnalysisPipeline} object
#' @details This method returns the prototype of functions in the pipeline and their respective arguments as \code{proto} object.
#' Functions in the pipeline can be accessed easily by using the '$' operator, and within the functions the arguments can
#' be accessed the same way. These can be accessed and set to new values. This pipeline prototype can then be passed to the
#' \code{createPipelineInstance} method which will instantiate an executable pipeline with the inputs set in the prototype
#' @return An object og class \code{proto} from the 'proto' package
#' @family Package core functions
#' @examples
#' \dontrun{
#' pipelineObj <- AnalysisPipeline(input = iris)
#' pipelineObj %>>% univarCatDistPlots(uniCol = "Species") %>>%
#'  exportAsMetaPipeline %>>% getPipelinePrototype
#' }
#' @export
setGeneric(
  name = "getPipelinePrototype",
  def = function(metaPipelineObj){
    standardGeneric("getPipelinePrototype")
  }
)

.getPipelinePrototype <- function(metaPipelineObj){
  return(metaPipelineObj@pipelinePrototype)
}

#' @rdname getPipelinePrototype
setMethod(
  f = "getPipelinePrototype",
  signature = "MetaAnalysisPipeline",
  definition = .getPipelinePrototype
)


#' @name createPipelineInstance
#' @rdname createPipelineInstance
#' @title Create a Pipeline object from a meta-pipeline
#' @param metaPipelineObj  A \code{MetaAnalysisPipeline} object
#' @param newParams Either a nested named list containing all the functions in the pipeline, their arguments and
#' corresponding values (OR) an object of class \code{proto} which is a pipeline prototype, with the new values of the arguments
#' set. Refer the \code{getPipelinePrototype} method.
#' @details This method instantiates a Pipeline object (both \code{AnalysisPipeline} and \code{StreamingAnalysisPipeline}) from
#' a meta-pipeline as well as an object containing the new set of values for the arguments of all the functions in the pipeline.
#' @return A Pipeline object
#' @family Package core functions
#' @examples
#' \dontrun{
#' pipelineObj <- AnalysisPipeline(input = iris)
#' pipelineObj %>>% univarCatDistPlots(uniCol = "Species") -> pipelineObj
#' pipelineObj %>>% exportAsMetaPipeline -> exportedMetaPipeline
#' exportedMetaPipeline %>>%
#' createPipelineInstance(newParams = exportedMetaPipeline %>>%
#'  getPipelinePrototype)
#' }
#' @export
setGeneric(
  name = "createPipelineInstance",
  def = function(metaPipelineObj, newParams){
    standardGeneric("createPipelineInstance")
  }
)

.createPipelineInstance <- function(metaPipelineObj, newParams){

  if(metaPipelineObj@type == "batch"){
    pipelineObj <- AnalysisPipeline()
  }else if(metaPipelineObj@type == "streaming"){
    pipelineObj <- StreamingAnalysisPipeline()
  }

  pipelineObj@pipeline <- metaPipelineObj@pipeline

  newParamList <- newParams
  if(any(class(newParams) == "proto")){
    names(newParams) %>>% grep(pattern = "^[.]", value = T, invert = T ) -> fnNames

    newParamList <- purrr::imap(fnNames, function(fn, nfn){
      fnEnvir <- get(fn, envir = newParams)
      fnEnvir %>>% names %>>% grep(pattern = "^[.]", invert = T, value = T ) -> argNames
      params <- mget(x = argNames, envir = newParams[[fn]])
      params <- purrr::imap(params, function(p, np){
        if(class(p) == "formula"){
          if(analysisPipelines::isDependencyParam(p)){
            p <- paste(np, "~", analysisPipelines::getTerm(p)) %>>% as.formula
          }
          #TODO: Deal with normal formula parameters
        }
        return(p)
      })
      return(params)
    })
    names(newParamList) <- fnNames
  }

  # Match pipeline table order
  tblOrder <- match(pipelineObj@pipeline$operation, names(newParamList))
  newParamList <- newParamList[tblOrder]

  #Match argument list orders
  newParamList <- purrr::imap(newParamList, function(params, fnName){
    pipelineParams <- pipelineObj@pipeline %>>% dplyr::filter(.data$operation == fnName)
    pipelineParams <- unlist(pipelineParams$parameters, recursive = F)
    argOrder <- match(names(pipelineParams), names(params))
    params <- params[argOrder]
    return(params)
  })

  names(newParamList) <- NULL
  pipelineObj@pipeline %>>% dplyr::mutate(parameters = newParamList) -> pipelineObj@pipeline

  return(pipelineObj)
}

#' @rdname createPipelineInstance
setMethod(
  f = "createPipelineInstance",
  signature = "MetaAnalysisPipeline",
  definition = .createPipelineInstance
)

#' A method definition for visualizing meta-pipelines, called when the 'visualizePipeline' method is called against the
#' \code{MetaAnalysisPipeline} signature
#' @name .visualizeMetaPipeline
#' @keywords internal
.visualizeMetaPipeline <- function(object){
  object %>>% createPipelineInstance(object@pipelinePrototype) -> sampleObj
  vis <- NULL
  sampleObj %>>% setLoggerDetails(target = "none") -> sampleObj
  sampleObj %>>% prepExecution -> sampleObj
  sampleObj %>>% visualizePipeline -> vis
  return(vis)
}

#' @rdname visualizePipeline
setMethod(
  f = "visualizePipeline",
  signature = "MetaAnalysisPipeline",
  definition = .visualizeMetaPipeline
)


#' A method definition for saving meta-pipelines, called when the 'savePipeline' method is called against the
#' \code{MetaAnalysisPipeline} signature
#' @name .saveMetaPipeline
#' @keywords internal
.saveMetaPipeline <- function(object, path){
  tryCatch({
    .registry <- getRegistry()
    listToBeSaved <- c("object", ".registry", getRegistry()$functionName, getRegistry()$exceptionHandlingFunction)
    save(list = listToBeSaved,file = path)
    futile.logger::flog.info("|| Registry saved successfully at path '%s'  ||", path,
                             name = "logger.base")
  },error = function(e){
    futile.logger::flog.error(e, name = "logger.base")
    stop()
  }, warning = function(w){
    futile.logger::flog.warn(w, name = "logger.base")
  })
}

#' @rdname savePipeline
setMethod(
  f = "savePipeline",
  signature = "MetaAnalysisPipeline",
  definition = .saveMetaPipeline
)

#' @name loadMetaPipeline
#' @title Load a meta-pipeline
#' @param path the path at which the .Rds file containing the pipeline is located
#' @details This function loads a meta-pipeline from a file system, and returns the meta-pipeline object, which can be assigned
#' to an object in the environment.
#' @details Note - When a meta-pipeline is loaded, the existing registry is overwritten with the registry saved with the
#' meta-pipeline
#' @return An \code{MetaAnalysisPipeline} object
#' @family Package core functions
#' @examples
#' \dontrun{
#'  loadMetaPipeline(path = "./metaPipeline.RDS")
#' }
#' @export
loadMetaPipeline <- function(path){
  tryCatch({
    object <- NULL
    futile.logger::flog.warn("||  The existing registry will be overwritten with the registry from the RDS file  ||",
                               name = "logger.base")
    load(path, envir = environment())
    functionNames = setdiff(ls(envir = environment()), c("path", "object", ".registry"))
    eval(parse(text = paste0(".setRegistry(.registry)")))
    lapply(functionNames, function(x){
      assign(x, get(x, environment()), globEnv)
    })

    return(object)
  },error = function(e){
    futile.logger::flog.error(e, name = "logger.base")
    stop()
  })
}


