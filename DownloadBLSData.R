
# Modify these to fit your environment:
DDLRoot = 'Data_Science/DDL Incubator Program'
ProjectDir = paste0(DDLRoot,'/03-the-redline')
DataDir = paste0(DDLRoot,'/Data')
OrigDataDir = paste0(DataDir,'/BLSOrig')
BLSDataURL ='http://download.bls.gov/pub/time.series/cs/cs.industry'

setwd(Data_Science/DDL Incubator Program)

download.file(FileURL, FilePath, mode='wb')


library(rvest) # XML/HTML handling

FileListRaw = html(BLSDataURL)
FileList = (FileListRaw %>% html_nodes('a') %>% html_text())

Notes = c()
for(FileName in FileList[2:length(FileList)]) # [1] is [To Parent Directory]
{
    FilePath = paste(OrigDataDir, FileName, sep='/')
    if (file.exists(FilePath))
    {
        Notes=c(Notes,paste0('Skipping ', FilePath))
        next
    }

    FileURL = paste(BLSDataURL, FileName, sep='/')
    Notes=c(Notes,paste0('Downloading ', FilePath, ' from ', FileURL))
    download.file(FileURL, FilePath, mode='wb')
}

Notes
