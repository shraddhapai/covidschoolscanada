# convert qc update excel file into format compatible
# with covidschoolsCA

source("utils.R")
Sys.setenv(TZ="America/Toronto")

args <- "/Users/shraddhapai/Google_covidschools/daily_data/Canada_COVID_tracker/export" #commandArgs(TRUE)

date2use <- Sys.Date()
dt <- format(date2use,"%y%m%d")
outDir <- sprintf("%s-%s",args[1],dt)

inFile <- sprintf("%s/CEQ_annotated_%s.csv",
	outDir,dt)
outFile <- sprintf("%s/CEQ_annotated_clean_%s.csv",
	outDir,dt)

dat <- read.delim(inFile,sep=",",h=T,as.is=T)
idx <- which(is.na(dat$longitude))
if (any(idx)) dat <- dat[-idx,]
idx <- which(dat[,"École"]=="")
if (any(idx)) dat <- dat[-idx,]

for (k in 1:ncol(dat)) {
	dat[,k] <- stringr::str_trim(dat[,k])
}


map_colname <- list(
	"École"="institute.name",
	"Nombre.cumulatif"="Total.cases.to.date",
	"Ville"="City",
	"Date.la.plus.récente"="Date",
	"Type.d.établissement"="Type_of_school",
	"Centre.de.Service"="School.board",
	"latitude"="Latitude",
	"longitude"="Longitude")
for (nm in names(map_colname)){
	colnames(dat)[which(colnames(dat)==nm)] <- map_colname[[nm]]
}

idx <- which(is.na(dat$Date))
if (any(idx)) dat$Date[idx] <- dat$Date.du.1er.cas.en.2020[idx]

dat$Total.students.to.date <- NA
dat$Total.staff.to.date <- NA

dat$Total.outbreaks.to.date <- NA
dat$Outbreak.dates <- NA
dat$Outbreak.Status <- "Single/unlinked cases"

idx <- which(dat$Total.cases.to.date >=5)
dat$Total.outbreaks.to.date[idx] <- 1L
dat$Outbreak.Status[idx] <- "Declared outbreaks"
dat$Outbreak.dates[idx] <- dat$Date[idx]

dat$Province <- "QC"

finalorder <- c("institute.name","Total.cases.to.date",
	"Total.students.to.date","Total.staff.to.date",
	"Date","Article",
	"Total.outbreaks.to.date","Outbreak.dates","Outbreak.Status",
	"Type_of_school","School.board",
	"City","Province",
	"Latitude","Longitude")

dat$Article <- "https://www.covidecolesquebec.org/nouvelles-closions"
dat  <- dat[,finalorder]

# --------------------------------------------
# Clean school type
# --------------------------------------------
dat$Type_of_school[which(dat$Type_of_school %in% 
	c("Secondaire, CEGEP, Professionnel",
	"Professionnel",
	"professionnel","Université","CEGEP"))] <- "Post-secondary"
dat$Type_of_school <- sub("Primaire et Secondaire","Mixed",dat$Type_of_school)
dat$Type_of_school[grep("et secondaire",dat$Type_of_school)] <- "Mixed"
dat$Type_of_school <- sub("Primaire","Elementary",dat$Type_of_school)
dat$Type_of_school <- sub("Pimaire","Elementary",dat$Type_of_school)
dat$Type_of_school <- sub("","TBA",dat$Type_of_school)
dat$Type_of_school <- sub("Secondaire","Secondary",dat$Type_of_school)
dat$Type_of_school <- sub("Commission scolaire","Field Office",dat$Type_of_school)
dat$Type_of_school[grep("^Secondary s",dat$Type_of_school)] <- "Secondary"
print(table(dat$Type_of_school,useNA="always"))
idx <- which(is.na(dat$Type_of_school))
idx <- c(idx, which(dat$Type_of_school==""))
if (any(idx)) {
	message("Found schools with no type - excluding records")
	message(sprintf("Excluding %i records",length(idx)))
	dat <- dat[-idx,]
}
idx <- which(is.na(dat$Total.cases.to.date))
if (any(idx)) {
	message("Found NA cases")
	message(sprintf("Excluding %i records",length(idx)))
	dat <- dat[-idx,]
}

# --------------------------------------------
# Clean region
# --------------------------------------------
dat$School.board <- sub("Decouvreurs","Découvreurs",dat$School.board)
dat$School.board <- sub("Energie","Énergie",dat$School.board)
dat$School.board <- sub("Jonquiere","Jonquière",dat$School.board)
dat$School.board <- sub("Vallee des Tisserands","Vallée-des-Tisserands",
	dat$School.board)
dat$School.board <- sub("Pays-de-Bluets","Pays-de-Bleuets",
	dat$School.board)
dat$School.board <- sub("Vals-des-Cerfs","Vals-Des-Cerfs",
	dat$School.board)

# add active/resolved column
#dat$ActiveOrResolved <- addActiveResolved(dat,date2use)

write.table(dat,file=outFile,sep=",",col=T,row=F,quote=TRUE)
message("Done QC annotation processing")

