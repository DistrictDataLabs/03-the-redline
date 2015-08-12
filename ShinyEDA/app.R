# Exploratory Data Analysis Shiny App for Redline BLS data.
# The filename app.R is required by Shiny.

library(shiny)
require(utils)
library(data.table)

# Globals

hostname = system('hostname', intern=T)
if (hostname == 'VM-EP-3')
{
    DDLRoot = 'd:/RProjects' # Oops
} else
{
    DDLRoot = 'E:/wat/misc/DDL'
}
ProjectDir = paste0(DDLRoot,'/03-the-redline')
if (hostname == 'VM-EP-3' | hostname == 'AJ')
{
    DataDir = paste0(DDLRoot,'/Data')
} else
{
    DataDir = 'Data'
}
OrigDataDir = paste0(DataDir,'/BLSOrig')
HeadTailN = 10
MaxRowToRead = 100000000 # data max is less than 50M

# Cache the filelist

FNs = c()
for(FileName in dir(OrigDataDir))
{
#    print(FileName)
    if (FileName %in% c('cs.contacts','cs.txt','cs.data.0.Current')) next # These do not contain tabular data or duplicate other files.

    FilePath = paste(OrigDataDir, FileName, sep='/')
    if (file.size(FilePath) > 999999)
    {
        next
    }
    else
    {
    }
    FNs[length(FNs)+1] = FileName
}

LoadDataFile = function(FileName)
{
    StartTime = proc.time()
    FilePath = paste(OrigDataDir, FileName, sep='/')
    # fread ignores the first line of these codetables because that
    # header doesn't have the trailing tab (blank column) of the data rows.
    # So read.table is used to get the variable names.
    # But read.table is slow and also won't handle the Windows format text lines
    # on the Linux Shiny server at shinyapps.io,
    # so fread is used to actually load the data. Then then variable names are fixed up.
    namesDF = read.table(FilePath,header=F,nrow=1,sep='\t',row.names=NULL,stringsAsFactors=F)
    if (file.size(FilePath) > 999999)
    {
        drop = NULL
    }
    else
    {
        drop = ncol(namesDF) + 1
    }
    DF = fread(FilePath,nrow=MaxRowToRead,header=F,drop=drop)
    setnames(DF, colnames(DF), as.matrix(namesDF)[1,])

    LoadTime = proc.time()
    LoadTime = LoadTime - StartTime
    print('Codetable loaded in:')
    print(LoadTime)
    DF
} # LoadDataFile

# Define UI for dataset viewer application.

ui = fluidPage(
    titlePanel('Codetables'), # Application title
    # Sidebar with controls to provide a caption, select a dataset,
    # and specify the number of observations to view. Note that
    # changes made to the caption in the textInput control are
    # updated in the output area immediately as you type
    sidebarLayout
    (
        sidebarPanel
        (
            textInput('caption', 'Caption:', 'Data Structure'),
            selectInput('dataset', 'Choose a codetable:',
                        choices = FNs),
            numericInput('obs', 'Number of observations to view:', 10)
        ),
        # Show the caption, a summary of the dataset and an HTML
        # table with the requested number of observations
        mainPanel
        (
            h3(textOutput('caption', container = span)),
            verbatimTextOutput('summary'),
            tableOutput('view')
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
        LoadDataFile(input$dataset)
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
        str(dataset)
    })
    # The output$view depends on both the databaseInput reactive
    # expression and input$obs, so will be re-executed whenever
    # input$dataset or input$obs is changed.
    output$view <- renderTable({head(datasetInput(), n = input$obs)})
} # server

shinyApp(ui, server)
