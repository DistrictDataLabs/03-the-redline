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
    Note = ''
    FileName = as.character(substitute(obj))
    SaveFilePath = paste(CompressedRDataDir,FileName,sep='/')
    SaveFilePath = paste0(SaveFilePath,'.rda')
    if (file.exists(SaveFilePath))
    {
        Note = paste0(Note,FileName,' overwritten. ')
    }
    StartTime = proc.time()
    save(list=FileName,file=SaveFilePath)
    if (remove)
    {
        rm(list=FileName,inherits=T)
    }
    SaveTime = proc.time()
    SaveTime = SaveTime - StartTime
    Note = paste0(Note,FileName,' saved in:')
    print(Note)
    print(SaveTime)
} # SaveObjectToDataFile

LoadCompressedDataFile = function(FileName)
{
    StartTime = proc.time()
    CompressedRDataPath = paste0(CompressedRDataDir,'/',FileName,'.rda')
    if (file.exists(CompressedRDataPath))
    {
        load(CompressedRDataPath,.GlobalEnv) # Load it in the global environment. The RDA file was created to contain 1 data.table with the name indicated by FileName.
    }
    else
    {
        return(NULL)
    }
    LoadTime = proc.time()
    LoadTime = LoadTime - StartTime
    Note = paste0(FileName, ' loaded in:')
    print(Note)
    print(LoadTime)
} # LoadCompressedDataFile

# For each missing 'rl' codetable, prepend an integer ID variable to
# its 'cs' codetable and save it. To Do
# For each 'cs' codetable, prepend...

# rl.age

LoadCompressedDataFile('cs.age')
rl.age = data.table(age_id=1:nrow(cs.age),cs.age)
rm(cs.age)
SaveObjectToDataFile(rl.age)

# rl.case

LoadCompressedDataFile('cs.case')
rl.case = data.table(case_id=1:nrow(cs.case),cs.case)
rm(cs.case)
SaveObjectToDataFile(rl.case)

# rl.category

LoadCompressedDataFile('cs.category')
rl.category = data.table(category_id=1:nrow(cs.category),cs.category)
rm(cs.category)
SaveObjectToDataFile(rl.category)

# rl.datatype

LoadCompressedDataFile('cs.datatype')
rl.datatype = data.table(datatype_id=1:nrow(cs.datatype),cs.datatype)
rm(cs.datatype)
SaveObjectToDataFile(rl.datatype)

# rl.event

LoadCompressedDataFile('cs.event')
rl.event = data.table(event_id=1:nrow(cs.event),cs.event)
rm(cs.event)
SaveObjectToDataFile(rl.event)

# rl.footnote

LoadCompressedDataFile('cs.footnote')
rl.footnote = data.table(footnote_id=1:nrow(cs.footnote),cs.footnote)
rm(cs.footnote)
SaveObjectToDataFile(rl.footnote)

# rl.gender

LoadCompressedDataFile('cs.gender')
rl.gender = data.table(gender_id=1:nrow(cs.gender),cs.gender)
rm(cs.gender)
SaveObjectToDataFile(rl.gender)

# rl.hour

LoadCompressedDataFile('cs.hour')
rl.hour = data.table(hour_id=1:nrow(cs.hour),cs.hour)
rm(cs.hour)
SaveObjectToDataFile(rl.hour)

# rl.industry

LoadCompressedDataFile('cs.industry')
rl.industry = data.table(industry_id=1:nrow(cs.industry),cs.industry)
rm(cs.industry)
SaveObjectToDataFile(rl.industry)

# rl.los

LoadCompressedDataFile('cs.los')
rl.los = data.table(los_id=1:nrow(cs.los),cs.los)
rm(cs.los)
SaveObjectToDataFile(rl.los)

# rl.nature

LoadCompressedDataFile('cs.nature')
rl.nature = data.table(nature_id=1:nrow(cs.nature),cs.nature)
rm(cs.nature)
SaveObjectToDataFile(rl.nature)

# rl.occupation

LoadCompressedDataFile('cs.occupation')
rl.occupation = data.table(occupation_id=1:nrow(cs.occupation),cs.occupation)
rm(cs.occupation)
SaveObjectToDataFile(rl.occupation)

# rl.ownership

LoadCompressedDataFile('cs.ownership')
rl.ownership = data.table(ownership_id=1:nrow(cs.ownership),cs.ownership)
rm(cs.ownership)
SaveObjectToDataFile(rl.ownership)

# rl.pob

LoadCompressedDataFile('cs.pob')
rl.pob = data.table(pob_id=1:nrow(cs.pob),cs.pob)
rm(cs.pob)
SaveObjectToDataFile(rl.pob)

# rl.race

LoadCompressedDataFile('cs.race')
rl.race = data.table(race_id=1:nrow(cs.race),cs.race)
rm(cs.race)
SaveObjectToDataFile(rl.race)

# rl.source

LoadCompressedDataFile('cs.source')
rl.source = data.table(source_id=1:nrow(cs.source),cs.source)
rm(cs.source)
SaveObjectToDataFile(rl.source)

# rl.special

LoadCompressedDataFile('cs.special')
rl.special = data.table(special_id=1:nrow(cs.special),cs.special)
rm(cs.special)
SaveObjectToDataFile(rl.special)

# rl.state

LoadCompressedDataFile('cs.state')
rl.state = data.table(state_id=1:nrow(cs.state),cs.state)
rm(cs.state)
SaveObjectToDataFile(rl.state)

# rl.time

LoadCompressedDataFile('cs.time')
rl.time = data.table(time_id=1:nrow(cs.time),cs.time)
rm(cs.time)
SaveObjectToDataFile(rl.time)

# rl.weekday

LoadCompressedDataFile('cs.weekday')
rl.weekday = data.table(weekday_id=1:nrow(cs.weekday),cs.weekday)
rm(cs.weekday)
SaveObjectToDataFile(rl.weekday)

# Datafiles

# rl.data (from cs.data.1.AllData)

LoadCompressedDataFile('cs.data.1.AllData')
FactorCols = c('year','period','footnote_codes')
cs.data.1.AllData[,(FactorCols):=lapply(.SD,as.factor),.SDcols=FactorCols]
rl.data = data.table(datum_id=1:nrow(cs.data.1.AllData),cs.data.1.AllData)
rm(cs.data.1.AllData)
SaveObjectToDataFile(rl.data)

# rl.data.series_id

rl.data.series_id = data.table(series_id=rl.data$series_id)
SaveObjectToDataFile(rl.data.series_id)

# rl.data.year

rl.data.year = data.table(year=rl.data$year)
SaveObjectToDataFile(rl.data.year)

# rl.data.value

rl.data.value = data.table(value=rl.data$value)
SaveObjectToDataFile(rl.data.value)

# rl.series

LoadCompressedDataFile('cs.series')
FactorCols = grep('_code$',colnames(cs.series),value=T)
FactorCols = c(FactorCols,'seasonal','footnote_codes','begin_period','end_period','begin_year','end_year')
cs.series[,(FactorCols):=lapply(.SD,as.factor),.SDcols=FactorCols]
# Note that series has a variable series_id that is in fact unique, but is char not int.
rl.series = data.table(s_id=1:nrow(cs.series),cs.series)
rm(cs.series)
SaveObjectToDataFile(rl.series)

# rl.series.series_id

rl.series.series_id = data.table(series_id=rl.series$series_id)
SaveObjectToDataFile(rl.series.series_id)

# rl.series.age_code

rl.series.age_code = data.table(age_code=rl.series$age_code)
SaveObjectToDataFile(rl.series.age_code)

# rl.series.pob_code

rl.series.pob_code = data.table(pob_code=rl.series$pob_code)
SaveObjectToDataFile(rl.series.pob_code)

# rl.series.nature_code

rl.series.nature_code = data.table(nature_code=rl.series$nature_code)
SaveObjectToDataFile(rl.series.nature_code)

# rl.series.industry_code

rl.series.industry_code = data.table(industry_code=rl.series$industry_code)
SaveObjectToDataFile(rl.series.industry_code)

# rl.series.source_code

rl.series.source_code = data.table(source_code=rl.series$source_code)
SaveObjectToDataFile(rl.series.source_code)
