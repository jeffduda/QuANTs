meanByLabel <- function( img, labelImg, labels ) {
  means <- rep(NA,length(labels))
  for (lab in c(1:length(labels))) {
    means[lab] <- mean(img, mask=(labelImg==labels[lab]))
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


summarizeAntsProcessing <- function( directory, prefix, dim=3, grayLabelID=NA, grayLabelNames=NA, whiteLabelID=NA, whiteLabelNames=NA, DTI=NA, PASL=NA, PCASL=NA, BOLD=NA, MT=NA, verbose=FALSE )
{

  require(ANTsR)
  basicACTsummary<-data.frame( BrainVolume=0, CSFVolume=0,  GMVolume=0,  WMVolume=0, DeepGrayVolume=0, BrainStemVolume=0, CerebellumVolume=0, MeanThickness=0 )
#directory <- paste(sep='',directory,"/")

# Check for required files

# Brain Extraction Mask
  brainMaskName <- list.files(path=directory, pattern=glob2rx(paste(sep='',prefix,"BrainExtractionMask.nii.gz")), full.names=TRUE)
  if ( length(brainMaskName) == 0 ) {
    warning( paste("No brainmask file found in", directory) )
  } else if (verbose) print(brainMaskName)

# Brain Segmentation
  brainSegName <- list.files(path=directory, pattern=glob2rx(paste(sep='',prefix,"BrainSegmentation.nii.gz")), full.names=TRUE)
  if ( length(brainSegName) == 0 ) {
    warning( paste("No brain segmentation file found in", directory) )
  } else if (verbose) print(brainSegName)

# Thickness
  thicknessName <- list.files(path=directory, pattern=glob2rx(paste(sep='',prefix,"CorticalThickness.nii.gz")), full.names=TRUE)
  if ( length(thicknessName) == 0 ) {
      warning( paste("No thickness file found in", directory) )
  }


  brainMask <- antsImageRead(brainMaskName[1],dim)
  voxVol <- prod(antsGetSpacing(brainMask))
  brainvol <- voxVol * length(which(as.array(brainMask)>0))
  if ( verbose ) {
      print( paste("Cerebrum volume =", brainvol ) )
  }
  
  brainSeg <- antsImageRead(brainSegName[1],dim)
  tissueVols <- labelVolumes(brainSeg, c(1:6) )
  
  csfVol <- tissueVols[1]
  gmVol <- tissueVols[2]
  wmVol <- tissueVols[3]
  deepVol <-tissueVols[4]
  stemVol <- tissueVols[5]
  cerbVol <- tissueVols[6]
  
  if ( verbose ) {
      print( paste("CSF volume =", csfVol))
      print( paste("GM volume =", gmVol))
      print( paste("WM volume =", wmVol))
      print( paste("DeepGray volume =", deepVol))
      print( paste("BrainStem volume = ", stemVol))
      print( paste("Cerebellum volume = ", cerbVol))
  }
  
  thickness <- antsImageRead(thicknessName,dim)
  voxVol <- prod(antsGetSpacing(thickness))
  thickMean <- mean(thickness, mask=(brainSeg==2))
  if (verbose) {
      print( paste("GM mean thickness", thickMean))
  }
  
  basicACTsummary$BrainVolume<-brainvol
  basicACTsummary$CSFVolume<-csfVol
  basicACTsummary$GMVolume<-gmVol
  basicACTsummary$WMVolume<-wmVol
  basicACTsummary$DeepGrayVolume<-deepVol
  basicACTsummary$BrainStemVolume<-stemVol
  basicACTsummary$CerebellumVolume<-cerbVol
  basicACTsummary$MeanThickness<-thickMean
  
  thickMeanRegions <- NA
  gVolumeRegions <- NA
  gLabels <- NA
  gLabelList <- NA

  corticalLabelSummary<-NA
  if ( !is.na(grayLabelID) ) {
      grayLabels <- list.files(path=directory, pattern=glob2rx(paste(sep='',prefix,grayLabelID)), full.names=TRUE)
      
      if ( length(grayLabels) > 0 ) {
          gLabels <- antsImageRead(grayLabels,dim)
          gLabels[ brainSeg != 2 ]<-0 
          gLabelList <- sort(unique(as.vector(as.array(gLabels))))
          gLabelList <- gLabelList[ gLabelList != 0 ]
          gLabelNames <- gLabelList
          
          if ( !is.na(grayLabelNames) ) {
              grayNames <- read.csv(grayLabelNames)
              grayLabelList <- grayNames[,1]
              grayLabelNames <- grayNames[,2]
              grayThickNames<-paste("MeanCorticalThickness",grayLabelNames,sep='')
          } else {
              grayLabelNames<-paste("CorticalVolume",c(1:length(gLabelList)),sep='')
              grayThickNames<-paste("MeanCorticalThickness",c(1:length(gLabelList)),sep='')
          }
    
    # Mean value per label
          thickMeanRegions <- meanByLabel(thickness, gLabels, gLabelList)
      }

      gVolumeRegions <- labelVolumes(gLabels, gLabelList)
      
      if ( verbose ) {
          print( "Gray ROI Volumes" )
          print(gVolumeRegions)
          print( "Thickness ROI Values" )
          print( thickMeanRegions )
      }
      corticalLabelSummary<-data.frame( c(thickMeanRegions  , gVolumeRegions ) )
      concatnames<-c(grayThickNames,grayLabelNames)
      rownames(corticalLabelSummary)<-concatnames 
  }
  

# White matter labels
  wLabels <- NA
  wLabelList <- NA
  wVolumeRegions <- NA
  if ( !is.na(whiteLabelID) ) {
      whiteLabels <- list.files(path=directory, pattern=glob2rx(paste(sep='',prefix,whiteLabelID)), full.names=TRUE)
      if ( length(whiteLabels) > 0 ) {
          wLabels <- antsImageRead(whiteLabels,dim)
          wLabelList <- sort(unique(as.vector(as.array(wLabels))))
          wLabelList <- wLabelList[ wLabelList != 0 ]
          wLabelNames <- wLabelList
          
          if ( !is.na(whiteLabelNames) ) {
              WhiteNames <- read.csv(whiteLabelNames)
              whiteLabelList <- whiteNames[,1]
              whiteLabelNames <- whiteNames[,2]
          }
      }
      wVolumeRegions <- labelVolumes(wLabels, wLabelList)
  }

# Examine DTI data
  if ( !is.na(DTI) ) {

      dtdir <- paste(sep='',directory,"DTI/")
      faName <- list.files(path=dtdir, pattern=glob2rx(paste(sep='',prefix,"Anatomical_FA.nii.gz")), full.names=TRUE)
      mdName <- list.files(path=dtdir, pattern=glob2rx(paste(sep='',prefix,"Anatomical_MD.nii.gz")), full.names=TRUE)
      rdName <- list.files(path=dtdir, pattern=glob2rx(paste(sep='',prefix,"Anatomical_RD.nii.gz")), full.names=TRUE)

      if ( length(faName) > 0 ) {
          fa <- antsImageRead(faName[1], dim)
          meanFA <- mean(fa, mask=(brainSeg==3))
          if ( verbose ) {
              print( paste("Mean FA in white matter", meanFA))
          }

      }
      
      if ( length(rdName) > 0 ) {
          rd <- antsImageRead(rdName[1], dim)
          meanRD <- mean(rd, mask=(brainSeg==3))
          
          if ( verbose ) {
              print( paste("Mean RD in white matter", meanRD))
          }

      }

      if ( length(mdName) > 0 ) {
          md <- antsImageRead(mdName[1], dim)
          meanMDW <- mean(md, mask=(brainSeg==3))
          meanMDG <- mean(md, mask=(brainSeg==2))
          
          if ( verbose ) {
              print( paste("Mean MD in white matter", meanMDW))
              print( paste("Mean MD in gray matter", meanMDG))
          }
          
          if ( !is.na(gLabels) ) {
              mdGrayRegions <- meanByLabel(md, gLabels, gLabelList)
          }

      }

  }

# Examine BOLD data
# cat("should see:  http://www.ancienteco.com/2012/05/quickly-visualize-your-whole-dataset.html \n")

  return( list( basicACTsummary=basicACTsummary, corticalLabelSummary=t(corticalLabelSummary ) ))
}
