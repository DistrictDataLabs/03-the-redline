# The BLS datafiles are too much for shinyapps.io to deal with, even when compressed.
# Also, they have NAs that need to be handled, factors that need to be set, etc. This
# is the R code to create the actual datafiles for TEam RedLine's data product.

library(data.table)

# Globals

hostname = system('hostname', intern=T)

if (hostname == 'AJ')
{
    DDLRoot = 'E:/wat/misc/DDL'
    DataDir = paste0(DDLRoot,'/Data')
} else if (hostname == 'VM-EP-3')
{
    DDLRoot = 'd:/RProjects' # Oops
    DataDir = paste0(DDLRoot,'/RedLineData')
} else
{
    DataDir = 'Data'
}
OrigDataDir = paste0(DataDir,'/BLSOrig')
CompressedRDataDir = paste0(DataDir,'/CompressedRDA')
dir.create(CompressedRDataDir,recursive=T,showWarnings=F)

# This saves obj as an RDA of the same name in CompressedRDataDir then removes it
# from the environment, unless the default is overridden.

SaveObjectToDataFile = function(obj,remove=TRUE)
{
    FileName = as.character(substitute(obj))
    SaveFilePath = paste(CompressedRDataDir,FileName,sep='/')
    SaveFilePath = paste0(SaveFilePath,'.rda')
    if (file.exists(SaveFilePath))
    {
        Note = paste0(FileName,' overwritten.')
    }
    StartTime = proc.time()
    save(obj,file=SaveFilePath)
    if (remove)
    {
        rm(list=FileName,inherits=T)
    }
    SaveTime = proc.time()
    SaveTime = SaveTime - StartTime
    Note = paste0(FileName,' saved in:')
    print(Note)
    print(SaveTime)
} # SaveObjectToDataFile

