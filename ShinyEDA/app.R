# Exploratory Data Analysis Shiny App for Redline BLS data.
# The filename app.R is required by Shiny.

library(utils)
library(data.table)
library(rvest) # XML/HTML handling
library(rdrop2)
library(shiny)

# Globals are first computed or just plain set to parameterize behavior.

HeadTailN = 10 # Initial value to seed the GUI.

hostname = system('hostname', intern=T)

if (hostname == 'AJ')
{
    MaxRowsToRead = 10000 # data max is less than 50M
    DDLRoot = 'E:/wat/misc/DDL'
    DataDir = paste0(DDLRoot,'/Data')
} else
{
    MaxRowsToRead = 100000000 # data max is less than 50M
}
if (hostname == 'VM-EP-3')
{
    DDLRoot = 'd:/RProjects' # Oops
    DataDir = paste0(DDLRoot,'/RedLineData')
}
if (hostname == 'VM-EP-3' | hostname == 'AJ')
{
    QuietDownload = FALSE
} else
{
    DataDir = 'Data'
    QuietDownload = TRUE
}
OrigDataDir = paste0(DataDir,'/BLSOrig')
CompressedRDataDir = paste0(DataDir,'/CompressedRDA')
dir.create(OrigDataDir,recursive=T,showWarnings=F)
dir.create(CompressedRDataDir,recursive=T,showWarnings=F)

# If we don't have the data locally, check DropBox using these globals.

DropBoxDataDir = '/Data'
DropBoxCompressedRDataDir = paste0(DropBoxDataDir,'/CompressedRDA')
# This works around an apparent limitation of publishing to shinyapps.io:
if (!file.exists('.httr-oauth') & file.exists('httr-oauth')) {file.rename('httr-oauth','.httr-oauth')}

# Cache the filelist from BLS into FNs

BLSDataURL ='http://download.bls.gov/pub/time.series/cs'

FileListRaw = html(BLSDataURL)
FileList = (FileListRaw %>% html_nodes('a') %>% html_text())

FNs = c()
for(FileName in FileList[2:length(FileList)]) # [1] is [To Parent Directory]
{
    if (FileName %in% c('cs.contacts','cs.txt','cs.data.0.Current')) next # These do not contain tabular data or duplicate other files.

    FNs[length(FNs)+1] = FileName
} # for

LoadDataFile = function(FileName) # First downloads the file unless it is already local
{
    Note=''
    StartTime = proc.time()
    CompressedRDataPath = paste0(CompressedRDataDir,'/',FileName,'.rda')
    DropBoxCompressedRDataPath = paste0(DropBoxCompressedRDataDir,'/',FileName,'.rda')
    if (!file.exists(CompressedRDataPath) & drop_exists(DropBoxCompressedRDataPath))
    {
        # This is the case where we don't have the file locally as required by load()
        # but it is on DropBox. Download the file so we can use it locally.
        drop_get(DropBoxCompressedRDataPath, CompressedRDataPath)
        Note=paste0(Note,'Dowloaded RDA from DropBox. ')
    }
    if (file.exists(CompressedRDataPath))
    {
        load(CompressedRDataPath,.GlobalEnv) # Load it in the global environment. The RDA file was created to contain 1 data.table with the name indicated by FileName.
        Note = paste0(Note,'Loaded compressed data.table ',FileName,'.')
    }
    else
    {
        FilePath = paste(OrigDataDir, FileName, sep='/')
        # The file must be local for file.size. Plus, we use both read.table and fread so may
        # as well download it.
        if (file.exists(FilePath))
        {
            Note = paste0(FileName, ' already local.')
        }
        else
        {
            Note = paste0(FileName, ' downloaded from BLS.')
            FileURL = paste(BLSDataURL, FileName, sep='/')
            download.file(FileURL, FilePath, mode='wb',quiet=QuietDownload)
        }
        # fread ignores the first line of these codetables because that
        # header doesn't have the trailing tab (blank column) of the data rows.
        # So read.table is used to get the variable names.
        # But read.table is slow and also won't handle the Windows format text lines
        # on the Linux Shiny server at shinyapps.io,
        # so fread is used to actually load the data. Then then variable names are fixed up.
        namesDF = read.table(FilePath,header=F,nrows=1,sep='\t',row.names=NULL,stringsAsFactors=F)
        if (file.size(FilePath) > 999999)
        {
            drop = NULL
        }
        else
        {
            drop = ncol(namesDF) + 1
        }
        assign(FileName,fread(FilePath,nrows=MaxRowsToRead,header=F,drop=drop),envir=.GlobalEnv)
        setnames(get(FileName), colnames(get(FileName)), as.matrix(namesDF)[1,])
    }

    LoadTime = proc.time()
    LoadTime = LoadTime - StartTime
    print(Note)
    print('Data loaded in:')
    print(LoadTime)
    get(FileName)
} # LoadDataFile

# If a variable exists with the name in FileName, return it. Otherwise,
# load it using LoadDataFile.

CondLoadDataTable = function(FileName)
{
    mget(FileName,ifnotfound=list(LoadDataFile),inherits=T)[[1]]
    # <sigh> get0 was running LoadDataFile even when FileName was found!
} # CondLoadDataTable

# Define UI for dataset viewer application.

ui = fluidPage(
    titlePanel('BLS Datafiles'), # Application title
    # Sidebar with controls to provide a caption, select a dataset,
    # and specify the number of observations to view. Note that
    # changes made to the caption in the textInput control are
    # updated in the output area immediately as you type
    sidebarLayout
    (
        sidebarPanel
        (
            textInput('caption', 'Caption:', 'Data Structure'),
            selectInput('dataset', 'Choose a datafile:',
                        choices = FNs),
            numericInput('obs','Number of observations to view:',10,min=1)
        ),
        # Show the caption, a summary of the dataset and an HTML
        # table with the requested number of observations
        mainPanel
        (
            h3(textOutput('caption',container=span)),
            verbatimTextOutput('summary'),
            h3('Head'),
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
        CondLoadDataTable(input$dataset)
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
