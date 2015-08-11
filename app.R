# Exploratory Data Analysis Shiny App for Redline BLS data.
# The filename app.R is required by Shiny.

library(shiny)
library(datasets)

# Globals

DDLRoot = 'd:/RProjects' # Oops
DDLRoot = 'E:/wat/misc/DDL' # Oops
ProjectDir = paste0(DDLRoot,'/03-the-redline')
DataDir = paste0(DDLRoot,'/Data')
OrigDataDir = paste0(DataDir,'/BLSOrig')
HeadTailN = 10

# Cache the data

StartTime = proc.time()
StartTime
MaxRowToRead = 100000000 # data max is less than 50M
DFs = list()
for(FileName in dir(OrigDataDir))
{
    print(FileName)
    if (FileName %in% c('cs.contacts','cs.txt','cs.data.0.Current')) next # These do not contain tabular data or duplicate other files.

    FilePath = paste(OrigDataDir, FileName, sep='/')
    if (file.size(FilePath) > 999999)
    {
        next
        DF = fread(FilePath,nrow=MaxRowToRead)
    }
    else
    {
        DF = read.table(FilePath,header=T,nrow=MaxRowToRead,sep='\t',row.names=NULL)
    }
    # I am not sure why but even though some files load correctly, some start with
    # a column "row.names" and right shift all the column names, with the last column
    # name being assigned to a made up column of all NAs. I am sure this is related to
    # the trailing tabs on every line except the header. Still, why inconstint loads?
    cn = colnames(DF)
    if (cn[1] == 'row.names')
    {
        DF = DF[,1:ncol(DF)-1]
        colnames(DF) = cn[2:length(cn)]
    }
    DFs[[length(DFs)+1]] = list(FileName, DF)
}
LoadTime = proc.time()
LoadTime = LoadTime - StartTime

# Define UI for dataset viewer application.

ui = fluidPage(
    titlePanel('Codesets'), # Application title
    # Sidebar with controls to provide a caption, select a dataset,
    # and specify the number of observations to view. Note that
    # changes made to the caption in the textInput control are
    # updated in the output area immediately as you type
    sidebarLayout
    (
        sidebarPanel
        (
            textInput("caption", "Caption:", "Data Summary"),
            selectInput("dataset", "Choose a dataset:",
                        choices = c("rock", "pressure", "cars")),
            numericInput("obs", "Number of observations to view:", 10)
        ),
        # Show the caption, a summary of the dataset and an HTML
        # table with the requested number of observations
        mainPanel
        (
            h3(textOutput("caption", container = span)),
            verbatimTextOutput("summary"),
            tableOutput("view")
        )
    )
) # ui

# Define server logic required to summarize and view the selected
# dataset
server = function(input, output)
{
    # By declaring datasetInput as a reactive expression we ensure
    # that:
    #  1) It is only called when the inputs it depends on changes
    #  2) The computation and result are shared by all the callers
    #	  (it only executes a single time)
    datasetInput = reactive({
        switch(input$dataset,
            "rock" = rock,
            "pressure" = pressure,
            "cars" = cars
            )
    })
    # The output$caption is computed based on a reactive expression
    # that returns input$caption. When the user changes the
    # "caption" field:
    #
    #  1) This function is automatically called to recompute the
    #     output
    #  2) The new caption is pushed back to the browser for
    #     re-display
    #
    # Note that because the data-oriented reactive expressions
    # below don't depend on input$caption, those expressions are
    # NOT called when input$caption changes.
    output$caption = renderText({input$caption})
    # The output$summary depends on the datasetInput reactive
    # expression, so will be re-executed whenever datasetInput is
    # invalidated
    # (i.e. whenever the input$dataset changes)
    output$summary <- renderPrint({
        dataset <- datasetInput()
        summary(dataset)
    })
    # The output$view depends on both the databaseInput reactive
    # expression and input$obs, so will be re-executed whenever
    # input$dataset or input$obs is changed.
    output$view <- renderTable({head(datasetInput(), n = input$obs)})
} # server

shinyApp(ui, server)
