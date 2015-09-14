
# This generic App displays injury rates for each industry category. The 
# main visualization launches when a user navigates to the page. 
# Input = submitButton () 
# Output = Dotplot of Non-Fatal Injury/Illness Rate/Industry.

library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("Industry v Injury"),

  # Input function
      submitButton("Get Industry Data", icon="BLS")
    ),

    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("Inj_Rates")
    )
  )
))
