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
#install.packages('data.table')
#install.packages('rvest')
library(rvest)

library(XML)

library(rlist)

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

tst = data.table('id'=1:5,'a_code'=c('a1','a2','a3','a3','a2'),'b_code'=c('b6','b4','b2','b6','b5'))
str(tst)
summary(tst)
FactorCols = grep('_code$',colnames(tst),value=T)
tst[,(FactorCols):=lapply(.SD,as.factor),.SDcols=FactorCols]

FactorCols = grep('_code$',colnames(cs.series),value=T)
cs.series[,(FactorCols):=lapply(.SD,as.factor),.SDcols=FactorCols]
cs.series[,seasonal:=as.factor(seasonal)]
cs.series[,footnote_codes:=as.factor(footnote_codes)]
cs.series[,begin_period:=as.factor(begin_period)]
cs.series[,end_period:=as.factor(end_period)]
cs.series[,begin_year:=as.integer(begin_year)]
cs.series[,end_year:=as.integer(end_year)]

save(cs.series,file='cs.series_wip2.rda')
str(cs.series)
summary(cs.series)
save(cs.series,file='cs.series_wip3.rda')

# Wip on putting the industry (code) data into the indicated tree structure.
setkey(rl.industry,sort_sequence)



# This is phase 2. See below for more info.

PopulateSubTree = function(dt,RowNum) # All children, recursively. Designed for use by MakeCodeTree
{
    CurrentCodeDef = dt[RowNum,]
    ret = list(me=CurrentCodeDef,children=list())
    ChildrenRNs = which(dt$parent_rn == RowNum)
    for(ThisChildRN in ChildrenRNs)
    {
        ThisChildSubTree = PopulateSubTree(dt,ThisChildRN)
        ret[[2]] = list.append(ret[[2]],ThisChildSubTree)
        cl = length(ret[[2]])
        rl = length(ret)
#        fl = length(list.flatten(ret))
#        tl = cl + rl # To hang a breakpoint
    }
    return(ret)
} # PopulateSubTree



# Many of the BLS code tables encode a hierarchy using sort_sequence and display_level.
# This routine builds the tree structure. That will be useful for the GUI. There are
# two phases. First the parent row numbers are computed. Then these drive the actual
# tree building. Conventional (C++, etc.) recursive approaches don't work in R because
# there are no reasonable 'back pointers' into the tree in progress.

MakeCodeTree = function(dt)
{
    setkey(dt,sort_sequence)
    MaxRow = nrow(dt)
    dt[,rn:=1:MaxRow] # Will compute each row's Parent RowNum and put it here.
    dt[,parent_rn:=0] # Will compute each row's Parent RowNum and put it here.
    CurrentDisplayLevel = 0

    for(RowNum in 2:MaxRow)
    {
        dl = dt[RowNum,]$display_level
        if (dl == CurrentDisplayLevel)
        {
            dt[RowNum]$parent_rn = dt[RowNum-1]$parent_rn
        } else if (dl > CurrentDisplayLevel) # Moving down the tree, so this node is a child
        {
            dt[RowNum]$parent_rn = RowNum-1
            CurrentDisplayLevel = dl
        } else # Jumping back up to a different branch
        {
            CondSiblingRowNum = RowNum-1
            while(dl < CurrentDisplayLevel)
            {
                CondSiblingRowNum = dt[CondSiblingRowNum,]$parent_rn
                CurrentDisplayLevel = dt[CondSiblingRowNum,]$display_level
            }
            dt[RowNum]$parent_rn = dt[CondSiblingRowNum]$parent_rn
        }
    } # Parent row number loop

    # dt as computed here when called with rl.industry:
    # Classes ‘data.table’ and 'data.frame':	1281 obs. of  8 variables:
    #  $ industry_id  : int  1 1249 1252 1253 7 2 3 4 5 6 ...
    #  $ industry_code: chr  "000000" "GP1AAA" "GP1NRM" "GP2AFH" ...
    #  $ industry_text: chr  "All workers" "Goods-producing" "Natural resources and mining" "Agriculture, forestry, fishing and hunting" ...
    #  $ display_level: int  0 1 2 3 4 5 5 5 5 5 ...
    #  $ selectable   : logi  TRUE TRUE TRUE TRUE TRUE TRUE ...
    #  $ sort_sequence: int  1 2 3 4 5 6 16 20 31 38 ...
    #  $ rn           : int  1 2 3 4 5 6 7 8 9 10 ...
    #  $ parent_rn    : num  0 1 2 3 4 5 5 5 5 5 ...
    #  - attr(*, ".internal.selfref")=<externalptr>
    #  - attr(*, "sorted")= chr "sort_sequence"

    ret = PopulateSubTree(dt,1)
    return(ret)
} # MakeCodeTree

ct = MakeCodeTree(rl.industry)

# Take 2, cleanup and encapsulation.


# Many of the BLS code tables encode a hierarchy using sort_sequence and
# display_level. This routine builds the corresponding tree structure. This data
# structure will be useful for the GUI. There are two phases. First the parent
# row numbers are computed. Then these drive the actual tree building.
# Conventional (C++, etc.) recursive approaches don't work in R because there
# are no reasonable 'back pointers' into the tree in progress.
# Note: there was some development complexity due to data.table's non standard
# lazy copy functionality.

MakeCodeTree = function(CodeData) # data.table version of an appropriate BLS code table.
{
    # This will be sorted by sort_sequence then 2 variables will be added, rn and parent_rn.
    AugmentedCodeData = CodeData
    CachedCodeTree = NULL

    GetAugmentedCodeData = function()
    {
        CondCacheCodeTree() # If needed calls CacheParentRNs() which adds variables rn and parent_rn
        return(AugmentedCodeData)
    } # GetAugmentedCodeData

    GetCodeTree = function()
    {
        CondCacheCodeTree()
        return(CachedCodeTree)
    } # GetCodeTree

    CondCacheCodeTree = function() # And also AugmentedCodeData
    {
        if (is.null(CachedCodeTree))
        {
            MyAugmentedCodeData = ComputeParentRNs()
            AugmentedCodeData <<- MyAugmentedCodeData
            MyCodeTree = PopulateSubTree(1)
            CachedCodeTree <<- MyCodeTree
        }
    } # CondCacheCodeTree

    ComputeParentRNs = function() # Phase 1
    {
        acd = copy(AugmentedCodeData) # So as to not change the original code table in the parent environment
        setkey(acd,sort_sequence) # This needs to be executed after we force a local copy of the dt
        MaxRow = nrow(acd)
        acd[,rn:=1:MaxRow] # Will compute each row's Parent RowNum and put it here
        acd[,parent_rn:=0] # Will compute each row's Parent RowNum and put it here

        CurrentDisplayLevel = 0

        for(RowNum in 2:MaxRow)
        {
            dl = acd[RowNum,]$display_level
            if (dl == CurrentDisplayLevel)
            {
                acd[RowNum]$parent_rn = acd[RowNum-1]$parent_rn
            } else if (dl > CurrentDisplayLevel) # Moving down the tree, so this node is a child
            {
                acd[RowNum]$parent_rn = RowNum-1
                CurrentDisplayLevel = dl
            } else # Jumping back up to a different branch
            {
                CondSiblingRowNum = RowNum-1
                while(dl < CurrentDisplayLevel)
                {
                    CondSiblingRowNum = acd[CondSiblingRowNum,]$parent_rn
                    CurrentDisplayLevel = acd[CondSiblingRowNum,]$display_level
                }
                acd[RowNum]$parent_rn = acd[CondSiblingRowNum]$parent_rn
            }
        } # Parent row number loop

        # acd as computed here when called with rl.industry as the input:
        # Classes ‘data.table’ and 'data.frame':	1281 obs. of  8 variables:
        #  $ industry_id  : int  1 1249 1252 1253 7 2 3 4 5 6 ...
        #  $ industry_code: chr  "000000" "GP1AAA" "GP1NRM" "GP2AFH" ...
        #  $ industry_text: chr  "All workers" "Goods-producing" "Natural resources and mining" "Agriculture, forestry, fishing and hunting" ...
        #  $ display_level: int  0 1 2 3 4 5 5 5 5 5 ...
        #  $ selectable   : logi  TRUE TRUE TRUE TRUE TRUE TRUE ...
        #  $ sort_sequence: int  1 2 3 4 5 6 16 20 31 38 ...
        #  $ rn           : int  1 2 3 4 5 6 7 8 9 10 ...
        #  $ parent_rn    : num  0 1 2 3 4 5 5 5 5 5 ...
        #  - attr(*, ".internal.selfref")=<externalptr>
        #  - attr(*, "sorted")= chr "sort_sequence"
        return(acd)
    } # ComputeParentRNs

    PopulateSubTree = function(RowNum) # And all children, recursively. Phase 2
    {
        CurrentCodeDef = AugmentedCodeData[RowNum,]
        ret = list(me=CurrentCodeDef,children=list())
        ChildrenRNs = which(AugmentedCodeData$parent_rn == RowNum)
        for(ThisChildRN in ChildrenRNs)
        {
            ThisChildSubTree = PopulateSubTree(ThisChildRN)
            ret[[2]] = list.append(ret[[2]],ThisChildSubTree)
            cl = length(ret[[2]])
            rl = length(ret)
        }
        return(ret)
    } # PopulateSubTree

    # These are the only public methods for a CodeTree

    list(GetAugmentedCodeData = GetAugmentedCodeData, # This method is intended for troubleshooting or EDA
         GetCodeTree = GetCodeTree # This returns the code tree as a nested list, building it and caching it if needed
    )
} # MakeCodeTree

ct = MakeCodeTree(rl.industry)
tct = ct$GetCodeTree()

CondLoadDataTable('rl.series.series_id')
CondLoadDataTable('rl.series.industry_code')
CondLoadDataTable('rl.data.series_id')
CondLoadDataTable('rl.data.year')
rl.data.series_id$year = rl.data.year
rm(rl.data.year)
setkey(rl.data.series_id,series_id)
rl.series.series_id$industry_code = rl.series.industry_code
rm(rl.series.industry_code)
setkey(rl.series.series_id,series_id)
rl.data.series_id = rl.data.series_id[rl.series.series_id]
rm(rl.series.series_id)
SeriesYearIndustryCounts = rl.data.series_id[,.N,by='year,industry_code']
SeriesYearIndustryCounts = SeriesYearIndustryCounts[industry_code != '']
SaveFilePath = paste(CompressedRDataDir,'SeriesYearIndustryCounts',sep='/')
SaveFilePath = paste0(SaveFilePath,'.rda')
save(SeriesYearIndustryCounts,file=SaveFilePath)

plot(N~.,data=SeriesYearIndustryCounts) # Yuck

junkFit = lm(N~.,data=SeriesYearIndustryCounts)
summary(junkFit)

CondLoadDataTable('SeriesYearIndustryCounts')
SeriesYearIndustryCounts[4]$industry_code == ''
SeriesYearIndustryCounts[industry_code != '']
