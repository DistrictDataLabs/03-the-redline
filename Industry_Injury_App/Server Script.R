
# This generic App displays injury rates for each industry category.  
# The main visualization launches when a user navigates to the page. 
# Input = submitButton () 
# Output = Dotplot of Non-Fatal Injury/Illness Rate/Industry. 
# Rates = numeric vector of injury/illness Rates.
# Industries = vector of industry names corresponding to injury/illness 
# rates.

library(shiny)

shinyServer(function(input, output) {

  output$Inj-Rates <- renderPlot({

    dotchart(Rates, labels="Industry")

  })

})
