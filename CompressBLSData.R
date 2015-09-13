# For each relevant BLS datafile in .../BLSOrig, create a saved data.table
# in ../CompressedRDA with the original filename with '.rda' appended.

library(data.table)

# Globals

hostname = system('hostname', intern=T)

# Add support for your system by name by adding another else if...

if (hostname == 'AJ')
{
    DDLRoot = 'E:/wat/misc/DDL'
    DataDir = paste0(DDLRoot,'/Data')
} else if (hostname == 'VM-EP-3')
{
    DDLRoot = 'd:/RProjects' # Oops
    DataDir = paste0(DDLRoot,'/RedLineData')
} else # Wayne's system, name not yet recorded here.
{
    DDLRoot = '~/Downloads/bls'
    DataDir = paste0(DDLRoot,'/Data')
}
OrigDataDir = paste0(DataDir,'/BLSOrig')
CompressedRDataDir = paste0(DataDir,'/CompressedRDA')
dir.create(CompressedRDataDir,recursive=T,showWarnings=F)

MaxRowsToRead = 100000000 # data max is almost 50M; lower this for quick tests, e.g., to 10000.

# Cache the filelist from BLSOrig into FNs

FNs = c()
for(FileName in dir(OrigDataDir)) # [1] is [To Parent Directory]
{
    if (FileName %in% c('cs.contacts','cs.txt','cs.data.0.Current')) next # These do not contain tabular data or duplicate other files.

    FNs[length(FNs)+1] = FileName
} # for

# This creates a data.table named FileName using fread of a BLS format datafile named
# FileName in the OrigDataDir, then saves that object in FileName.rda in CompressedDataDir,
# and then removes the data.table from memory. Load and Save times are reported.

LoadSaveDataFile = function(FileName)
{
    SaveFilePath = paste(CompressedRDataDir,FileName,sep='/')
    SaveFilePath = paste0(SaveFilePath,'.rda')
    if (file.exists(SaveFilePath))
    {
        Note = paste0(FileName,' skipped because it has been compressed before.')
        print(Note)
        return()
    }
    StartTime = proc.time()
    FilePath = paste(OrigDataDir, FileName, sep='/')
    # fread ignores the first line of these codetables because that
    # header doesn't have the trailing tab (blank column) of the data rows.
    # So read.table is used to get the variable names.
    # But read.table is slow and also won't handle the Windows format text lines
    # on the Linux Shiny server at shinyapps.io,
    # so fread is used to actually load the data. Then then variable names are fixed up.
    namesDF = read.table(FilePath,header=F,nrow=1,sep='\t',row.names=NULL,stringsAsFactors=F)
    if (file.size(FilePath) > 999999) # These don't have the spare tab problem
    {
        drop = NULL
        skip = 1 # Skip the header that has already been read.
    }
    else # These do, so drop that empty variable
    {
        drop = ncol(namesDF) + 1
        skip = -1 # fread does the skip because of the spare tab.
    }
    assign(FileName,fread(FilePath,nrow=MaxRowsToRead,header=F,drop=drop,skip=skip))
    setnames(get(FileName), colnames(get(FileName)), as.matrix(namesDF)[1,])

    LoadTime = proc.time()
    LoadTime = LoadTime - StartTime
    Note = paste0(FileName,' loaded in:')
    print(Note)
    print(LoadTime)
    save(list=FileName,file=SaveFilePath)
    rm(list=FileName)
    SaveTime = proc.time()
    SaveTime = SaveTime - LoadTime - StartTime
    Note = paste0(FileName,' saved in:')
    print(Note)
    print(SaveTime)
} # LoadSaveDataFile

for(FileName in FNs)
{
    LoadSaveDataFile(FileName)
}

