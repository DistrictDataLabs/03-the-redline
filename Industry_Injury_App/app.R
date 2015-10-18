# Wat: I combined Ian's files into a new file that Shiny and RStudio will automatically
# recognize.

# This generic App displays injury rates for each industry category. The
# main visualization launches when a user navigates to the page.
# Input = submitButton ()
# Output = Dotplot of Non-Fatal Injury/Illness Rate/Industry.

ui = fluidPage(

  # Application title
  titlePanel("Industry v Injury"),

  # Input function
      submitButton("Get Industry Data", icon="BLS"),

    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("Inj_Rates")
    )
)

# This generic App displays injury rates for each industry category.
# The main visualization launches when a user navigates to the page.
# Input = submitButton ()
# Output = Dotplot of Non-Fatal Injury/Illness Rate/Industry.
# Rates = numeric vector of injury/illness Rates.
# Industries = vector of industry names corresponding to injury/illness
# rates.

library(shiny)

server = function(input, output) {

  output$Inj-Rates <- renderPlot({

    dotchart(Rates, labels="Industry")

  })

}

shinyApp(ui, server)
