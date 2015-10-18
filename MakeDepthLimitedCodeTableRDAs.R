# Subsetted from ShinyEDA/app.R, then enhanced to build and cache the depth limited
# code table to speed up the GUI.

library(utils)
library(data.table)
library(rvest) # XML/HTML handling
library(rdrop2) # Dropbox wrapper

source('ShinyEDA/MakeCodeTree.R')
source('ShinyEDA/CondLoadDataTable.R')

# Globals are first computed or just plain set to parameterize behavior.

MaxDepth = 4 # e.g., rl.industry4 will have no tree branches deeper than 4 levels.

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
ForceListRLFilesFromDropBox = F # T to locally test DropBox connectivity
if (!ForceListRLFilesFromDropBox & (hostname == 'VM-EP-3' | hostname == 'AJ'))
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

InputCodeTableNames = c(
#         rl.category='', # Doesn't work yet; don't know why
        'rl.industry',
        'rl.event', # Want industry to be the default so show selected works for it
        'rl.nature',
#        rl.occupation='', # Doesn't work yet; 17 'roots' but so far only 1 is supported
        'rl.pob',
        'rl.source'
            )

for(FN in InputCodeTableNames)
{
    NewFN = paste0(FN,as.character(MaxDepth))
    SaveFilePath = paste(CompressedRDataDir,NewFN,sep='/')
    SaveFilePath = paste0(SaveFilePath,'.rda')
    if (file.exists(SaveFilePath))
    {
        Note = paste0(NewFN,' skipped because it has been limited before.')
        print(Note)
        next
    }
    dt = CondLoadDataTable(FN)
    dt = dt[display_level < MaxDepth]
    str(dt)
    assign(NewFN,dt)
    save(list=NewFN,file=SaveFilePath)
}
