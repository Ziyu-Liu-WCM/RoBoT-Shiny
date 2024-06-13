#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(DT)


# Define UI for application
ui <- fluidPage(
  
  # Application title
  titlePanel(
    tags$div(
      style = "text-align: center;",
      tags$h1(style = "color: purple;", "RoBoT: A Robust Bayesian Hypothesis Testing Method for Basket Trials"),
      tags$p(style = "font-size: 16px;", "Last Updated: 06/05/2024"),
      tags$p(style = "font-size: 16px; font-weight: bold;", "Author1, Author2, Author3"),
      tags$p(style = "font-size: 16px;", "Department of Population Health Sciences, Weill Cornell Medicine")
    )
  ),


  
  tabsetPanel(
    #          tabPanel("Main",
    #                   # Sidebar with input controls
    #                   sidebarLayout(
    #                     sidebarPanel(
    #                       textInput("n", "Number of patients in each group(comma-separated):", value = "15, 13, 12 ,28, 29, 29, 26, 5, 2, 20"),
    #                       textInput("r", "Number of responses in each group(comma-separated):", value = "2, 0, 1, 6, 7, 3, 5, 1, 0, 3"),
    #                       numericInput("pi0", "Null hypothesis response rate:", value = 0.3, min = 0, max = 1, step = 0.01),
    #                       numericInput("niter", "Number of iterations:", min = 2, value = 10000),
    #                       numericInput("burnin", "Number of burn-in iterations:", min = 1, value = 5000),
    #                       numericInput("thin", "Thinning interval:", min = 1, value = 5),
    #                       numericInput("alpha", "Alpha parameter:", min = 0, value = 2),
    #                       actionButton("runMCMC", "Run MCMC"),
    #                       downloadButton("downloadData", "Download Data")
    #                     ),
    #                     
    #                     # Show the result table
    #                     mainPanel(
    #                       DT::dataTableOutput("mytable1"),
    #                       textOutput("compTime")
    #                     )
    #                   )
    #          
    # ),
    

    tabPanel("Description", includeHTML('./Description.html')),
  
  
    tabPanel("Main",
           # Sidebar with input controls
           sidebarLayout(
             sidebarPanel(
               textInput("n", "Number of patients in each group(comma-separated):", value = "15, 13, 12 ,28, 29, 29, 26, 5, 2, 20"),
               textInput("r", "Number of responses in each group(comma-separated):", value = "2, 0, 1, 6, 7, 3, 5, 1, 0, 3"),
               numericInput("pi0", "Null hypothesis response rate:", value = 0.3, min = 0, max = 1, step = 0.01),
               numericInput("niter", "Number of iterations:", min = 2, value = 10000),
               numericInput("burnin", "Number of burn-in iterations:", min = 1, value = 5000),
               numericInput("thin", "Thinning interval:", min = 1, value = 5),
               numericInput("alpha", "Alpha parameter:", min = 0, value = 2),
               actionButton("runMCMC", "Run MCMC"),
             ),
             
             # Show the result table
             mainPanel(
               DT::dataTableOutput("mytable1"),
               hr(),
               downloadButton("downloadData", "Download Output"),
               hr(),
               textOutput("compTime")
             )
           )
        )
      )
    )

