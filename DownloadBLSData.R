# Some of the BLS data files are large enough that it is impractical to work with
# them over the net. This R script downloads any that are missing from the target
# directory.

# Modify these to fit your environment:
DDLRoot <- '~/Downloads/bls'
ProjectDir <- paste0(DDLRoot, '/03-the-redline')
DataDir <- paste0(DDLRoot, '/Data')
OrigDataDir <- paste0(DataDir, '/BLSOrig')
BLSDataURL <- 'http://download.bls.gov/pub/time.series/cs'

# setwd(ProjectDir)

library(rvest) # XML/HTML handling

FileListRaw <- html(BLSDataURL)
FileList <- (FileListRaw %>% html_nodes('a') %>% html_text())

Notes <- c()
fileGet <- function() { 
  cat("Starting file downloading...\n")
  count.d <- 0
  count.e <- 0
  # [1] is [To Parent Directory] 
  for(FileName in FileList[2:length(FileList)]) {
    FilePath <- paste(OrigDataDir, FileName, sep='/')
    if (file.exists(FilePath)==T) {
      msg <- paste0(FileName, ' exists')
      print(msg)
      Notes <- c(Notes, msg)
      count.e <- count.e + 1
    } else {
      FileURL <- paste(BLSDataURL, FileName, sep='/')
      msg <- paste0('Downloading: ', FilePath, ' from: ', FileURL)
      print(msg)
      Notes <- c(Notes, msg)
      download.file(FileURL, FilePath, mode='wb')
      count.d <- count.d + 1
    }
  } 
  cat("\nFinished downloading process.\n")
  cat(paste(count.e, "out of 25 files present in directory.\n"))
  cat(paste("(Downloaded", count.d, "files.)", sep=" "))
  Notes <- Notes
}

fileGet()
Notes
