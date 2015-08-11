# Modify these to fit your environment:
DDLRoot = 'd:/RProjects' # Oops
ProjectDir = paste0(DDLRoot,'/03-the-redline')
DataDir = paste0(DDLRoot,'/Data')
OrigDataDir = paste0(DataDir,'/BLSOrig')
FilesListURL ='http://download.bls.gov/pub/time.series/cs'
HeadTailN = 10

setwd(ProjectDir)
dir()

library(data.table)
install.packages('data.table')
install.packages('rvest')
library(rvest)

library(XML)

seriesFN='cs.series'
series='http://download.bls.gov/pub/time.series/cs/cs.series'
currentFN='cs.data.0.current'
current='http://download.bls.gov/pub/time.series/cs/cs.data.0.Current'

currentDS=read.table(current,header=T,nrow=5,sep='\t')
seriesDF=read.table(series,header=T,nrow=5,sep='\t')

currentDS
seriesDF

currentAll

FilesRaw = htmlTreeParse(FilesListURL)
FilesRaw = htmlParse(FilesListURL)
FilesRaw = html(FilesListURL)

counter = function() {
    counts = integer(0)
    list(startElement = function(node) {
        name = xmlName(node)
        if(name %in% names(counts))
            counts[name] <<- counts[name] + 1
        else
            counts[name] <<- 1
    },
    counts = function() counts)
}

h = counter()
htmlParse(FilesListURL,handlers = h)
h$counts()


x=(FilesRaw %>% html_nodes('a') %>% html_text())

E:\wat\misc\DDL\Data\BLSOrig>wc *
    90     202    1264    cs.age
15     137    1008    cs.case
2357   22934  112687    cs.category
60     399    2987    cs.contacts
45,179,788 181259160 2344488905    cs.data.0.Current
45,179,788 181259160 2344488905    cs.data.1.AllData
4      20     140    cs.datatype
475    4840   29865    cs.event
2       6      51    cs.footnote
5      13     110    cs.gender
13      58     317    cs.hour
1282   11287   74118    cs.industry
7      29     170    cs.los
399    3398   21952    cs.nature
1294   10726   70419    cs.occupation
6      20     159    cs.ownership
182    1235    7277    cs.pob
11      41     314    cs.race
21,103,308 253505196 1751574784    cs.series
1431   10490   68013    cs.source
3       8      86    cs.special
48     251    1111    cs.state
9      33     234    cs.time
615    2117   17813    cs.txt
9      19     177    cs.weekday
111,471,201 616091779 2145995570    total

str(dir(OrigDataDir))

StartTime = proc.time()
StartTime
MaxRowToRead = 100000000 # data max is less than 50M
DFs = list()
for(FileName in dir(OrigDataDir))
{
    print(FileName)
    if (FileName %in% c('cs.contacts','cs.txt','cs.data.0.Current')) next # These do not contain tabular data or duplicate other files.

    FilePath = paste(OrigDataDir, FileName, sep='/')
    if (file.size(FilePath) > 999999)
    {
        DF = fread(FilePath,nrow=MaxRowToRead)
    }
    else
    {
        DF = read.table(FilePath,header=T,nrow=MaxRowToRead,sep='\t',row.names=NULL)
    }
    # I am not sure why but even though some files load correctly, some start with
    # a column "row.names" and right shift all the column names, with the last column
    # name being assigned to a made up column of all NAs. I am sure this is related to
    # the trailing tabs on every line except the header. Still, why inconstint loads?
    cn = colnames(DF)
    if (cn[1] == 'row.names')
    {
        DF = DF[,1:ncol(DF)-1]
        colnames(DF) = cn[2:length(cn)]
    }
    DFs[[length(DFs)+1]] = list(FileName, DF)
}
LoadTime = proc.time()
LoadTime
LoadTime - StartTime

# This is used for the print side effect of cat. Junk is ignored.
junk = sapply(DFs, function(lDF) {(cat('\n',lDF[[1]],' ')); str(lDF[[2]])})

junk = sapply(DFs, function(lDF) {cat('\n',lDF[[1]],'\n'); print(summary(lDF[[2]]))})
junk
junk = sapply(DFs, function(lDF) {cat('\n',lDF[[1]],'\n'); print(head(lDF[[2]],n=HeadTailN))})

junk = sapply(DFs, function(lDF) if (nrow(lDF[[2]]) > HeadTailN) {cat('\n',lDF[[1]],'\n'); print(tail(lDF[[2]],n=HeadTailN))})


str(DFs)
head(DF)

sapply(DFs, function(lDF) lDF[[1]])
junk = sapply(DFs, function(lDF) {(cat('\n',lDF[[1]],' ')); str(lDF[[2]])})

DFs[[17]][[1]]
str(DFs[[17]][[2]])
table(DFs[[17]][[2]]$seasonal)
var='seasonal'
table(DFs[[17]][[2]][,.N,by=var])
colnames(DFs[[17]][[2]])

for(colNum in 2:ncol(DFs[[17]][[2]]))
{
  colName = colnames(DFs[[17]][[2]])[colNum]
  print(DFs[[17]][[2]][,.N,by=colName])
}

DFs[[4]][[1]]
str(DFs[[4]][[2]])

for(colNum in 2:ncol(DFs[[4]][[2]]))
{
  colName = colnames(DFs[[4]][[2]])[colNum]
  print(DFs[[4]][[2]][,.N,by=colName])
}

str(DFs[[3]])
FilePath


DF

DF
cn=colnames(DF)
DF=DF[,1:ncol(DF)-1]
colnames(DF) = cn[2:length(cn)]

DT = fread(FilePath,nrow=10)
DF=NULL
DFs=NULL

DTs = list()
for(FileName in dir(OrigDataDir))
{
    print(FileName)
    if (FileName %in% c('cs.contacts','cs.txt','cs.data.0.Current')) next # These do not contain tabular data or duplicate other files.

    FilePath = paste(OrigDataDir, FileName, sep='/')
    DT = fread(FilePath,nrow=0,sep='\t')

    DTs[[length(DTs)+1]] = list(FileName, DT)
}
# This is used for the print side effect of cat. Junk is ignored.
junk = sapply(DTs, function(lDT) {(cat('\n',lDT[[1]],' ')); str(lDT[[2]])})

junk = sapply(DFs, function(lDF) {cat('\n',lDF[[1]],'\n'); print(summary(lDF[[2]]))})

# Gratuitous Change
