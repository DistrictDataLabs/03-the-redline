# Some of the BLS data files are large enough that it is impractical to work with
# them over the net. This R script downloads any that are missing from the target
# directory.
#
# Note, git auto merge failed on 9/12/2015 so Wat hand merged changes from Wayne.

# Globals

BLSDataURL ='http://download.bls.gov/pub/time.series/cs'

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
    DDLRoot = 'Data_Science/DDL Incubator Program' # Ian
    DDLRoot = '~/Downloads/bls'
    DataDir = paste0(DDLRoot,'/Data')
}
OrigDataDir = paste0(DataDir,'/BLSOrig')
dir.create(OrigDataDir,recursive=T,showWarnings=F)

library(rvest) # XML/HTML handling

FileListRaw = html(BLSDataURL)
FileList = (FileListRaw %>% html_nodes('a') %>% html_text())

FileGet = function()
{
    Notes = c()
    cat("Starting file downloading...\n")
    count.d <- 0
    count.e <- 0
    for(FileName in FileList[2:length(FileList)]) # [1] is [To Parent Directory]
    {
        FilePath = paste(OrigDataDir, FileName, sep='/')
        if (file.exists(FilePath))
        {
            Notes=c(Notes,paste0('Skipping ', FilePath))
            msg <- paste0(FileName, ' exists')
            print(msg)
            count.e <- count.e + 1
            next
        }
        FileURL = paste(BLSDataURL, FileName, sep='/')
        Notes=c(Notes,paste0('Downloading ', FilePath, ' from ', FileURL))
        msg <- paste0('Downloading: ', FilePath, ' from: ', FileURL)
        print(msg)
        download.file(FileURL, FilePath, mode='wb')
        count.d <- count.d + 1
    } # for each file
    cat("\nFinished downloading process.\n")
    cat(paste(count.e, "out of 25 files present in directory.\n"))
    cat(paste("(Downloaded", count.d, "files.)", sep=" "))
    print(Notes)
} # FileGet

FileGet()
