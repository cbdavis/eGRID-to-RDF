#This code reads in eGRID data from the original Excel spreadsheets and then merges them all together into a single CSV file
#The benefit of this is that when using Google Refine and the rdf-extension, mappings only have to be done once.
library(XLConnect) #reads Excel files
library(plyr) #rbind.fill
library(stringr)
library(sqldf)

#don't use postgres with sqldf, just want to use sqlite.  If this package is not removed, it will cause a problem.
if('package:RPostgreSQL' %in% search()){
  detach('package:RPostgreSQL')  
}
sqldf()

#don't use factors
options(stringsAsFactors = FALSE)

#time how long things take 
#http://stackoverflow.com/questions/1716012/stopwatch-function-in-r
tic <- function(gcFirst = TRUE, type=c("elapsed", "user.self", "sys.self"))
{
   type <- match.arg(type)
   assign(".type", type, envir=baseenv())
   if(gcFirst) gc(FALSE)
   tic <- proc.time()[type]         
   assign(".tic", tic, envir=baseenv())
   invisible(tic)
}

toc <- function()
{
   type <- get(".type", envir=baseenv())
   toc <- proc.time()[type]
   tic <- get(".tic", envir=baseenv())
   print(toc - tic)
   invisible(toc)
}

tic()

#only keep text before the first period
cleanHeaders <- function(dataFrame){
  #get rid of extra columns while we're here
  dataFrame = removeExtraColumns(dataFrame)

  colnames(dataFrame) <- str_extract(colnames(dataFrame), "[A-Za-z0-9]+")
  return(dataFrame)
}

removeExtraColumns <- function(dataFrame){
  #get rid of all columns that look like Col34, etc.  These are likely to be empty - not sure why these are extracted
  colsToRemove = grep("^Col[0-9]+", colnames(dataFrame))
  if (length(colsToRemove) > 0) {
    dataFrame = dataFrame[,-colsToRemove]
  }
  return(dataFrame)
}

#Contains data for 2009, 2007, 2005 and 2004.
if (file.exists('eGRID2012_Version1-0.zip') == FALSE) {
  download.file('http://www.epa.gov/cleanenergy/documents/egridzips/eGRID2012_Version1-0.zip', 'eGRID2012_Version1-0.zip')
}
unzip('eGRID2012_Version1-0.zip')


#contains data for 1996, 1997, 1998, 1999, and 2000
if (file.exists('eGRID2002Spreadsheets.zip') == FALSE) {
  download.file('http://www.epa.gov/cleanenergy/documents/egridzips/eGRID2002Spreadsheets.zip', 'eGRID2002Spreadsheets.zip')
}
unzip('eGRID2002Spreadsheets.zip')


#1996 through 2000 need to have their header names fixed
#Also each data frame has the corresponding year connected to it
eGRID_1996_plants <- cleanHeaders(readWorksheetFromFile('eGRID2002yr96_plant.xls', 
                                    sheet = 2, header = TRUE, startCol = 1, startRow = 4, endCol=0, endRow=0))
eGRID_1996_plants$year = 1996
xlcFreeMemory()

eGRID_1997_plants <- cleanHeaders(readWorksheetFromFile('eGRID2002yr97_plant.xls',
                                    sheet = 2, header = TRUE, startCol = 1, startRow = 4, endCol=0, endRow=0))
eGRID_1997_plants$year = 1997
xlcFreeMemory()

eGRID_1998_plants <- cleanHeaders(readWorksheetFromFile('eGRID2002yr98_plant.xls',
                                    sheet = 2, header = TRUE, startCol = 1, startRow = 4, endCol=0, endRow=0))
eGRID_1998_plants$year = 1998
xlcFreeMemory()

eGRID_1999_plants <- cleanHeaders(readWorksheetFromFile('eGRID2002yr99_plant.xls', 
                                    sheet = 2, header = TRUE, startCol = 1, startRow = 4, endCol=0, endRow=0))
eGRID_1999_plants$year = 1999
xlcFreeMemory()

eGRID_2000_plants <- cleanHeaders(readWorksheetFromFile('eGRID2002yr00_plant.xls',
                                    sheet = 2, header = TRUE, startCol = 1, startRow = 4, endCol=0, endRow=0))
eGRID_2000_plants$year = 2000
xlcFreeMemory()

eGRID_2004_plants <- cleanHeaders(readWorksheetFromFile('eGRID2006V2_1_year04_plant.xls', 
                                    sheet = 4, header = TRUE, startCol = 1, startRow = 5, endCol=0, endRow=0))
eGRID_2004_plants$year = 2004
xlcFreeMemory()

eGRID_2005_plants <- cleanHeaders(readWorksheetFromFile('eGRID2007V1_1year05_plant.xls',
                                    sheet = 4, header = TRUE, startCol = 1, startRow = 5, endCol=0, endRow=0))
eGRID_2005_plants$year = 2005
xlcFreeMemory()

eGRID_2007_plants <- cleanHeaders(readWorksheetFromFile('eGRID2010V1_1_year07_PLANT.xls',
                                    sheet = 4, header = TRUE, startCol = 1, startRow = 5, endCol=0, endRow=0))
eGRID_2007_plants$year = 2007
xlcFreeMemory()

eGRID_2009_plants <- cleanHeaders(readWorksheetFromFile('eGRID2012V1_0_year09_DATA.xls',
                                                        sheet = 4, header = TRUE, startCol = 1, startRow = 5, endCol=0, endRow=0))
eGRID_2009_plants$year = 2009
xlcFreeMemory()


#bind everything together
#rind.fill is needed to fill in missing columns

eGRID_all_years_plants <- rbind.fill(eGRID_1996_plants, 
                                      eGRID_1997_plants, 
                                      eGRID_1998_plants, 
                                      eGRID_1999_plants, 
                                      eGRID_2000_plants, 
                                      eGRID_2004_plants, 
                                      eGRID_2005_plants, 
                                      eGRID_2007_plants,
                                      eGRID_2009_plants)

#clean up after ourselves - these are not needed anymore
rm(list=c('eGRID_1996_plants', 
             'eGRID_1997_plants', 
             'eGRID_1998_plants', 
             'eGRID_1999_plants', 
             'eGRID_2000_plants', 
             'eGRID_2004_plants', 
             'eGRID_2005_plants', 
             'eGRID_2007_plants', 
             'eGRID_2009_plants'))

#need to make sure that the year is in the first column - this keeps Google Refine from breaking
currentColumnNameOrder = colnames(eGRID_all_years_plants)
desiredColumnNameOrder = c('year', currentColumnNameOrder[-which(currentColumnNameOrder == 'year')])
eGRID_all_years_plants = eGRID_all_years_plants[,desiredColumnNameOrder]

#replace all "N/A" with NA
eGRID_all_years_plants[eGRID_all_years_plants=="N/A"] <- NA

#The names and coordinates change over time, want to only use the latest value for these
#Often, the names are first in all caps, then in later versions use title case
#For coordinates, it's common to see the point shift slightly.

#get the values for the latest year for each entry - ORISPL is the unique identifier
preferredValues = sqldf('select ORISPL, PNAME, MAX(year) AS LATEST_YEAR, LAT, LON from eGRID_all_years_plants group by ORISPL')

preferredValues$LATEST_YEAR = NULL
colnames(preferredValues) = c('ORISPL', 'preferredName', 'preferredLat', 'preferredLon')
eGRID_all_years_plants = merge(eGRID_all_years_plants, preferredValues, by='ORISPL')

#replace values with the latest
eGRID_all_years_plants$LAT = eGRID_all_years_plants$preferredLat
eGRID_all_years_plants$LON = eGRID_all_years_plants$preferredLon
eGRID_all_years_plants$PNAME = eGRID_all_years_plants$preferredName

#remove extra columns
eGRID_all_years_plants$preferredLat = NULL
eGRID_all_years_plants$preferredLon = NULL
eGRID_all_years_plants$preferredName = NULL

#write table, NA will be just ""
write.table(eGRID_all_years_plants, file="eGRID_all_years_plants.csv", sep="\t", row.names=FALSE, na="")



#1996 through 2000 need to have their header names fixed
#Also each data frame has the corresponding year connected to it
eGRID_1996_boilers <- cleanHeaders(readWorksheetFromFile('eGRID2002yr96_plant.xls', 
                                    sheet = 3, header = TRUE, startCol = 1, startRow = 4, endCol=0, endRow=0))
eGRID_1996_boilers$year = 1996
xlcFreeMemory()

eGRID_1997_boilers <- cleanHeaders(readWorksheetFromFile('eGRID2002yr97_plant.xls',
                                    sheet = 3, header = TRUE, startCol = 1, startRow = 4, endCol=0, endRow=0))
eGRID_1997_boilers$year = 1997
xlcFreeMemory()

eGRID_1998_boilers <- cleanHeaders(readWorksheetFromFile('eGRID2002yr98_plant.xls',
                                    sheet = 3, header = TRUE, startCol = 1, startRow = 4, endCol=0, endRow=0))
eGRID_1998_boilers$year = 1998
xlcFreeMemory()

eGRID_1999_boilers <- cleanHeaders(readWorksheetFromFile('eGRID2002yr99_plant.xls', 
                                    sheet = 3, header = TRUE, startCol = 1, startRow = 4, endCol=0, endRow=0))
eGRID_1999_boilers$year = 1999
xlcFreeMemory()

eGRID_2000_boilers <- cleanHeaders(readWorksheetFromFile('eGRID2002yr00_plant.xls',
                                    sheet = 3, header = TRUE, startCol = 1, startRow = 4, endCol=0, endRow=0))
eGRID_2000_boilers$year = 2000
xlcFreeMemory()

eGRID_2004_boilers <- cleanHeaders(readWorksheetFromFile('eGRID2006V2_1_year04_plant.xls', 
                                    sheet = 2, header = TRUE, startCol = 1, startRow = 6, endCol=0, endRow=0))
eGRID_2004_boilers$year = 2004
xlcFreeMemory()

eGRID_2005_boilers <- cleanHeaders(readWorksheetFromFile('eGRID2007V1_1year05_plant.xls',
                                    sheet = 2, header = TRUE, startCol = 1, startRow = 6, endCol=0, endRow=0))
eGRID_2005_boilers$year = 2005
xlcFreeMemory()

eGRID_2007_boilers <- cleanHeaders(readWorksheetFromFile('eGRID2010V1_1_year07_PLANT.xls',
                                    sheet = 2, header = TRUE, startCol = 1, startRow = 6, endCol=0, endRow=0))
eGRID_2007_boilers$year = 2007
xlcFreeMemory()

eGRID_2009_boilers <- cleanHeaders(readWorksheetFromFile('eGRID2012V1_0_year09_DATA.xls',
                                                         sheet = 2, header = TRUE, startCol = 1, startRow = 6, endCol=0, endRow=0))
eGRID_2009_boilers$year = 2009
xlcFreeMemory()


eGRID_all_years_boilers <- rbind.fill(eGRID_1996_boilers, 
                                      eGRID_1997_boilers, 
                                      eGRID_1998_boilers, 
                                      eGRID_1999_boilers, 
                                      eGRID_2000_boilers, 
                                      eGRID_2004_boilers, 
                                      eGRID_2005_boilers, 
                                      eGRID_2007_boilers, 
                                      eGRID_2009_boilers)

#clean up after ourselves - these are not needed anymore
rm(list=c('eGRID_1996_boilers', 
          'eGRID_1997_boilers', 
          'eGRID_1998_boilers', 
          'eGRID_1999_boilers', 
          'eGRID_2000_boilers', 
          'eGRID_2004_boilers', 
          'eGRID_2005_boilers', 
          'eGRID_2007_boilers', 
          'eGRID_2009_boilers'))

#replace all "N/A" with NA
eGRID_all_years_boilers[eGRID_all_years_boilers=="N/A"] <- NA

#need to make sure that the year is in the first column - this keeps Google Refine from breaking
currentColumnNameOrder = colnames(eGRID_all_years_boilers)
desiredColumnNameOrder = c('year', currentColumnNameOrder[-which(currentColumnNameOrder == 'year')])
eGRID_all_years_boilers = eGRID_all_years_boilers[,desiredColumnNameOrder]

#write table, NA will be just ""
write.table(eGRID_all_years_boilers, file="eGRID_all_years_boilers.csv", sep="\t", row.names=FALSE, na="")

#Now get all the generators
#1996 through 2000 need to have their header names fixed
#Also each data frame has the corresponding year connected to it
eGRID_1996_generators <- cleanHeaders(readWorksheetFromFile('eGRID2002yr96_plant.xls', 
                                    sheet = 4, header = TRUE, startCol = 1, startRow = 4, endCol=0, endRow=0))
eGRID_1996_generators$year = 1996
xlcFreeMemory()

eGRID_1997_generators <- cleanHeaders(readWorksheetFromFile('eGRID2002yr97_plant.xls',
                                    sheet = 4, header = TRUE, startCol = 1, startRow = 4, endCol=0, endRow=0))
eGRID_1997_generators$year = 1997
xlcFreeMemory()

eGRID_1998_generators <- cleanHeaders(readWorksheetFromFile('eGRID2002yr98_plant.xls',
                                    sheet = 4, header = TRUE, startCol = 1, startRow = 4, endCol=0, endRow=0))
eGRID_1998_generators$year = 1998
xlcFreeMemory()

eGRID_1999_generators <- cleanHeaders(readWorksheetFromFile('eGRID2002yr99_plant.xls', 
                                    sheet = 4, header = TRUE, startCol = 1, startRow = 4, endCol=0, endRow=0))
eGRID_1999_generators$year = 1999
xlcFreeMemory()

eGRID_2000_generators <- cleanHeaders(readWorksheetFromFile('eGRID2002yr00_plant.xls',
                                    sheet = 4, header = TRUE, startCol = 1, startRow = 4, endCol=0, endRow=0))
eGRID_2000_generators$year = 2000
xlcFreeMemory()

eGRID_2004_generators <- cleanHeaders(readWorksheetFromFile('eGRID2006V2_1_year04_plant.xls', 
                                    sheet = 3, header = TRUE, startCol = 1, startRow = 6, endCol=0, endRow=0))
eGRID_2004_generators$year = 2004
xlcFreeMemory()

eGRID_2005_generators <- cleanHeaders(readWorksheetFromFile('eGRID2007V1_1year05_plant.xls',
                                    sheet = 3, header = TRUE, startCol = 1, startRow = 6, endCol=0, endRow=0))
eGRID_2005_generators$year = 2005
xlcFreeMemory()

eGRID_2007_generators <- cleanHeaders(readWorksheetFromFile('eGRID2010V1_1_year07_PLANT.xls',
                                    sheet = 3, header = TRUE, startCol = 1, startRow = 6, endCol=0, endRow=0))
eGRID_2007_generators$year = 2007
xlcFreeMemory()

eGRID_2009_generators <- cleanHeaders(readWorksheetFromFile('eGRID2012V1_0_year09_DATA.xls',
                                                            sheet = 3, header = TRUE, startCol = 1, startRow = 6, endCol=0, endRow=0))
eGRID_2009_generators$year = 2009
xlcFreeMemory()

eGRID_all_years_generators <- rbind.fill(eGRID_1996_generators, 
                                         eGRID_1997_generators, 
                                         eGRID_1998_generators, 
                                         eGRID_1999_generators, 
                                         eGRID_2000_generators, 
                                         eGRID_2004_generators, 
                                         eGRID_2005_generators, 
                                         eGRID_2007_generators, 
                                         eGRID_2009_generators)

#replace all "N/A" with NA
eGRID_all_years_generators[eGRID_all_years_generators=="N/A"] <- NA

#need to make sure that the year is in the first column - this keeps Google Refine from breaking
currentColumnNameOrder = colnames(eGRID_all_years_generators)
desiredColumnNameOrder = c('year', currentColumnNameOrder[-which(currentColumnNameOrder == 'year')])
eGRID_all_years_generators = eGRID_all_years_generators[,desiredColumnNameOrder]


#write table, NA will be just ""
write.table(eGRID_all_years_generators, file="eGRID_all_years_generators.csv", sep="\t", row.names=FALSE, na="")

toc()
