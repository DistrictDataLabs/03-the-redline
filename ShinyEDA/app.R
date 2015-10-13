# Exploratory Data Analysis Shiny App for Redline BLS data.
# The filename app.R is required by Shiny.

library(utils)
library(data.table)
library(rvest) # XML/HTML handling
library(rdrop2) # Dropbox wrapper
library(shiny)

library('shinyTree')

source('MakeCodeTree.R')

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
    MaxRowsToRead = 100000000 # data max is less than 50M so this gets all
}
if (hostname == 'VM-EP-3')
{
    DDLRoot = 'd:/RProjects' # Oops
    DataDir = paste0(DDLRoot,'/RedLineData')
}
if (hostname == 'VM-EP-3' | hostname == 'AJ')
{
    ListRLFilesFromDropBox = FALSE # Local only
    QuietDownload = FALSE
} else
{
    DataDir = 'Data'
    ListRLFilesFromDropBox = TRUE # Any local cache is still used for the actual data
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

# Cache the filelist from BLS into FNsB

BLSDataURL ='http://download.bls.gov/pub/time.series/cs'

FileListRaw = read_html(BLSDataURL)
FileList = (FileListRaw %>% html_nodes('a') %>% html_text())

FNsB = c()
for(FileName in FileList[2:length(FileList)]) # [1] is [To Parent Directory]
{
    if (FileName %in% c('cs.contacts','cs.txt','cs.data.0.Current')) next # These do not contain tabular data or duplicate other files.

    FNsB[length(FNsB)+1] = FileName
} # for

# Cache the RedLine data filelist into FNsR

if (ListRLFilesFromDropBox)
{
    # List the directory, stipping off the pathname from each filename
    FNsR = sub(paste0(DropBoxCompressedRDataDir,'/'),'',drop_dir(DropBoxCompressedRDataDir)$path)
    FNsR = grep('^rl[.].*rda',FNsR,value=T,ignore.case=T) # Filter, keeping just the rl datafiles
    FNsR = sub('[.]rda','',FNsR) # Remove .rda to make the name look better in the GUI.
} else
{
    FNsR = dir(CompressedRDataDir,'^rl[.].*rda')
    FNsR = sub('[.]rda','',FNsR) # Remove .rda to make the name look better in the GUI.
}

FNsT = list(
        rl.event='',
#         rl.category='', # Doesn't work yet; don't know why
        rl.industry='',
        rl.nature='',
#        rl.occupation='', # Doesn't work yet; 17 'roots' but so far only 1 is supported
        rl.pob='',
        rl.source=''
            )

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
    tabsetPanel
    (
        type = "tabs",
        tabPanel
        (
            'BLS Datafiles',
            sidebarLayout
            (
                sidebarPanel
                (
                    selectInput('datasetB', 'Choose a datafile:',
                                choices = FNsB),
                    numericInput('obsB','Number of observations to view:',10,min=1)
                ),
                mainPanel
                (
                    h3('Data Structure'),
                    verbatimTextOutput('strB'),
                    h3('Head'),
                    tableOutput('viewB')
                )
            )
        ),
        tabPanel
        (
            'RedLine Datafiles',
            sidebarLayout
            (
                sidebarPanel
                (
                    selectInput('datasetR', 'Choose a datafile:',
                                choices = FNsR),
                    numericInput('obsR','Number of observations to view:',10,min=1)
                ),
                mainPanel
                (
                    h3('Data Structure'),
                    verbatimTextOutput('strR'),
                    h3('Summary'),
                    verbatimTextOutput('summaryR'),
                    h3('Head'),
                    tableOutput('viewR')
                )
            )
        ),
        tabPanel
        (
            'Sample Tree Control for a BLS Code Table Hierarchy',
            sidebarLayout
            (
                sidebarPanel
                (
                    selectInput('datasetT', 'Choose a data.table:',
                                choices = names(FNsT))
                ),
                mainPanel
                (
                    h3('Data Structure'),
                    verbatimTextOutput('strT'),
                    h3('Currently Selected:'),
                    verbatimTextOutput('selTxtT'),
                    hr(),
                    shinyTree('treeT')
                )
            )
        )
    ) # tabsetPanel
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
    datasetInputB = reactive({
        CondLoadDataTable(input$datasetB)
    })
    # The output$str depends on the datasetInput reactive
    # expression, so will be re-executed whenever datasetInput is
    # invalidated
    # (i.e. whenever the input$dataset changes)
    output$strB = renderPrint({
        dataset = datasetInputB()
        str(dataset)
    })
    # The output$view depends on both the databaseInput reactive
    # expression and input$obs, so will be re-executed whenever
    # input$dataset or input$obs is changed.
    output$viewB = renderTable({head(datasetInputB(), n = input$obsB)})
    # RedLine Data
    datasetInputR = reactive({
        CondLoadDataTable(input$datasetR)
    })
    output$strR = renderPrint({
        dataset = datasetInputR()
        str(dataset)
    })
    output$summaryR = renderPrint({
        dataset = datasetInputR()
        summary(dataset)
    })
    output$viewR = renderTable({head(datasetInputR(), n = input$obsR)},include.rownames=F)
    # Code Hierarchy
    datasetInputT = reactive({
        CondLoadDataTable(input$datasetT)
    })
    output$strT = renderPrint({
        dataset = datasetInputT()
        str(dataset)
    })

    output$treeT <- renderTree({
        datasetname = input$datasetT
        ct = FNsT[[datasetname]]
        if (!is.list(ct))
        {
            ct = MakeCodeTree(get(datasetname))
            FNsT[[datasetname]] = ct
        }
        DisplayTree = ct$GetDisplayTree()
        # browser() # Breakpoints seem flaky in Shiny
        DisplayTree
    })
    output$selTxtT <- renderText({
        datasetname = input$datasetT # Reactive dependency -- doesn't work.
        tree = input$treeT
        if (is.null(tree))
        {
            'None'
        } else
        {
            sel = get_selected(tree)
            ss = unlist(sel)
#            browser() # sel is a list of 1, the name of selected node, with the path to the root available as the ancestry attribute.
            if (is.null(ss))
            {
                selTxtT = 'Nothing selected.'
            }
            else if(T)
            {
                selTxtT = ss
            } # Below here is WIP
            else if(is.na(as.integer(ss)))
            {
                selTxtT = paste0('Cannot find sort_sequence ',ss)
            }
            else
            {
                adt = FNsT[[1]]$GetAugmentedCodeData()
                selTxtT = adt[as.integer(ss)]$industry_text
            }
            selTxtT
        }
    })
} # server

shinyApp(ui, server)
