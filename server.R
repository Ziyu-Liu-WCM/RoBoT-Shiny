#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(DT)

source("fn_RoBoT.R") # Assuming your main_RoBoT.R contains the RoBoT_MCMC function and necessary setup

check_elements_within_range <- function(input_string) {
  tryCatch(
    {elements <- unlist(strsplit(input_string, ","))
     numeric_elements <- as.numeric(elements)
     return(TRUE)},
    error = function(err){
      message("Please check inputs!")
      return(FALSE)
    },
    warning = function(war){
      message("Please check inputs!")
      return(FALSE)
    })
}


server <- function(input, output) {
  
  results <- eventReactive(input$runMCMC, {
    n <- as.numeric(unlist(strsplit(input$n, ",")))
    r <- as.numeric(unlist(strsplit(input$r, ",")))
    pi0 <- input$pi0
    niter <- input$niter
    burnin <- input$burnin
    thin <- input$thin
    alpha <- input$alpha
    
    comp_time <- system.time({
      result <- RoBoT_MCMC(n, r, pi0, niter, burnin, thin, return_MCMC_spls = TRUE, alpha = alpha)
    })
    
    list(result = result, comp_time = n)
  })
  
  result_df <- reactive({
    MCMC_spls <- results()$result
    
    # pi_spls: J * niter matrix, posterior samples of pi
    pi_spls <- MCMC_spls$pi_spls
    
    pi0 <- rep(input$pi0, dim(pi_spls)[1])
    
    # PP: posterior probability of the J alternatives
    PP <- paste(100 * (apply(pi_spls > pi0, 1, sum) / dim(pi_spls)[2]), "%", sep = "")
    # PM: posterior mean of the response rates in the J baskets
    PM <- 100 * apply(pi_spls, 1, mean)
    # PM_lower and PM_upper: posterior CI bounds
    PM_lower <- 100 * apply(pi_spls, 1, function(x) quantile(x, probs = 0.025))
    PM_upper <- 100 * apply(pi_spls, 1, function(x) quantile(x, probs = 0.975))
    
    data.frame(
      Basket = paste("Basket", 1:dim(pi_spls)[1]),
      PP = PP,
      PM_CI = paste0(round(PM, 3), " (", round(PM_lower, 3), ", ", round(PM_upper, 3), ")")
    )
  })
  
  output$mytable1 <- DT::renderDataTable({
    
    validate(
      need(check_elements_within_range(input$n), "Number of patients must be greater than 0 and comma-separated!"),
      need(check_elements_within_range(input$r), "Number of responses must be greater than 0 and comma-separated!")
    )
    
    validate(
      need(length(as.numeric(unlist(strsplit(input$n, ",")))) == length(as.numeric(unlist(strsplit(input$r, ",")))), "Number of patients must be equal to Number of responses!"),
      need(input$pi0 >= 0 && input$pi0 <= 1, "Null hypothesis response rate must be between 0 and 1!"),
      need(input$niter > 0, "Number of iterations must be greater than 0!"),
      need(input$burnin >= 0, "Number of burn-in iterations must be 0 or greater!"),
      need(input$thin > 0, "Thinning interval must be greater than 0!"),
      need(input$alpha >= 0, "Alpha parameter must be 0 or greater!")
    )
    
    
    result_df <- result_df()

    DT::datatable(result_df)
  })
  
  output$compTime <- renderText({
    comp_time <- results()$comp_time
    paste("Output", comp_time)
    paste("Computation time: User:", round(comp_time[1], 3), "System:", round(comp_time[2], 3), "Elapsed:", round(comp_time[3], 3), "seconds")
  })
  
  # output$get_the_item <- renderUI({
  #   if(exists("results()$result")){
  #   downloadButton('downloadData', label = 'Download Data')} })
  
  output$downloadData <- downloadHandler(
    filename = function() {
      paste("RoBoT_MCMC_results-", Sys.Date(), ".csv", sep="")
    },
    content = function(file) {
      write.csv(result_df(), file, row.names = FALSE)
    }
  )
}

shinyServer(server)
