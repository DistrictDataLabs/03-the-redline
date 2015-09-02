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
if (hostname == 'VM-EP-3' | hostname == 'AJ')
{
    DataDir = paste0(DDLRoot,'/Data')
    QuietDownload = FALSE
} else
{
    DataDir = 'Data'
    QuietDownload = TRUE
}
OrigDataDir = paste0(DataDir,'/BLSOrig')
CompressedRDataDir = paste0(DataDir,'/CompressedRDA')
dir.create(CompressedRDataDir,recursive=T,showWarnings=F)

MaxRowsToRead = 100000000 # data max is less than 50M

# Cache the filelist from BLSOrig into FNs

FNs = c()
for(FileName in dir(OrigDataDir)) # [1] is [To Parent Directory]
{
    if (FileName %in% c('cs.contacts','cs.txt','cs.data.0.Current')) next # These do not contain tabular data or duplicate other files.

    FNs[length(FNs)+1] = FileName
} # for

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
    if (file.size(FilePath) > 999999)
    {
        drop = NULL
    }
    else
    {
        drop = ncol(namesDF) + 1
    }
    DF = fread(FilePath,nrow=MaxRowsToRead,header=F,drop=drop)
    setnames(DF, colnames(DF), as.matrix(namesDF)[1,])

    LoadTime = proc.time()
    LoadTime = LoadTime - StartTime
    Note = paste0(FileName,' loaded in:')
    print(Note)
    print(LoadTime)
    save(DF,file=SaveFilePath)
    rm(DF)
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

