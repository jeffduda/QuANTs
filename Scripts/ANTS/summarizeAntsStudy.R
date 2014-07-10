meanByLabel <- function( img, labelImg, labels ) {
  means <- rep(NA,length(labels))
  for (lab in c(1:length(labels))) {
     
    #means[lab] <- mean(img, mask=(labelImg==labels[lab]))
    means[lab] <- mean(as.array(img)[which(as.array(labelImg)==labels[lab])])
  }
  return(means)
}

labelVolumes <- function( labelImg, labels ) {
  vol <- rep(NA,length(labels))
  voxVol <- prod(antsGetSpacing(labelImg))
  for ( lab in c(1:length(labels))) {
    vol[lab] <- voxVol * length( which(as.array(labelImg)==labels[lab]) )
  }
  return(vol)
}


summarizeAntsStudy <- function( baseDirectory ) {

require(ANTsR)

subjects <- list.files(baseDirectory)

dat = NA
init = FALSE
for (subject in subjects) {
  times <- list.files(paste(sep="/",baseDirectory, subject))
  for ( time in times ) {
    prefix = paste(sep="_", subject, time, "")
    dir = paste(sep="/", baseDirectory, subject, time, "")
    timedat = summarizeAntsProcessing(directory=dir, prefix=prefix)
    timedat = data.frame(ID=prefix, timedat)
      
    if ( init==FALSE ) {
      dat = timedat
      init = TRUE
      }
    else {
      dat = rbind(dat, timedat)
      }
      
  
    }

  
  }

n = length(dat$CerebrumVolume)
volumes = c(dat$CerebrumVolume, dat$CSFVolume, dat$GMVolume, dat$WMVolume, dat$DeepGrayVolume, dat$BrainStemVolume, dat$CerebellumVolume)
volumeNames = c(rep("Cerebrum", n), rep("CSF", n), rep("Gray matter",n), rep("White matter",n), rep("Deep gray",n), rep("Brain stem",n), rep("Cerebellum",n) )
ids = as.factor(dat$ID)
volumeNames = as.factor(volumeNames)

ggplotFrame = data.frame(Volumes=volumes, Names=volumeNames, ID=ids)
#ggplot(a$plotframe, aes(y=Volumes, x=ID, group=Names, colour=Names)) + geom_line() + geom_point() + theme(axis.text.x = element_text(angle = 90, hjust = 1)

return( list(rawframe=dat, plotframe=ggplotFrame) )

}
