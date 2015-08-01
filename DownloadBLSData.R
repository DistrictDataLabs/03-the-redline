# Some of the BLS data files are large enough that it is impractical to work with
# them over the net. This R script downloads any that are missing from the target
# directory.

# Modify these to fit your environment:
DDLRoot = 'e:/wat/misc/ddl'
ProjectDir = paste0(DDLRoot,'/03-the-redline')
DataDir = paste0(DDLRoot,'/Data')
OrigDataDir = paste0(DataDir,'/BLSOrig')
BLSDataURL ='http://download.bls.gov/pub/time.series/cs'

setwd(ProjectDir)

library(rvest) # XML/HTML handling

FileListRaw = html(BLSDataURL)
FileList = (FileListRaw %>% html_nodes('a') %>% html_text())

Notes = c()
for(FileName in FileList[2:length(FileList)])
{
    FilePath = paste(OrigDataDir, FileName, sep='/')
    if (file.exists(FilePath))
    {
        Notes=c(Notes,paste0('Skipping ', FilePath))
        next
    }

    FileURL = paste(BLSDataURL, FileName, sep='/')
    Notes=c(Notes,paste0('Downloading ', FilePath, ' from ', FileURL))
    download.file(FileURL, FilePath)
}

Notes
