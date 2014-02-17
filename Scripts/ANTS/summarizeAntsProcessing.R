summarizeAntsProcessing <- function( directory, prefix, dim=3, grayLabelID=NA, grayLabelNames=NA ) {

require(ANTsR)

directory <- paste(sep='',directory,"/")

# Check for required files

# Brain Extraction Mask
brainMaskName <- list.files(path=directory, pattern=glob2rx(paste(sep='',prefix,"BrainExtractionMask.nii.gz")), full.names=TRUE)
if ( length(brainMaskName) == 0 ) {
  warning( paste("No brainmask file found in", directory) )
}

# Brain Segmentation
brainSegName <- list.files(path=directory, pattern=glob2rx(paste(sep='',prefix,"BrainSegmentation.nii.gz")), full.names=TRUE)
if ( length(brainSegName) == 0 ) {
  warning( paste("No brain segmentation file found in", directory) )
}

# Thickness
thicknessName <- list.files(path=directory, pattern=glob2rx(paste(sep='',prefix,"CorticalThickness.nii.gz")), full.names=TRUE)
if ( length(thicknessName) == 0 ) {
  warning( paste("No thickness file found in", directory) )
}


brainMask <- antsImageRead(brainMaskName[1],dim)
voxVol <- prod(antsGetSpacing(brainMask))
brainvol <- voxVol * length(which(as.array(brainMask)>0))
print( paste("Cerebrum volume =", brainvol ) )

brainSeg <- antsImageRead(brainSegName[1],dim)
voxVol <- prod(antsGetSpacing(brainSeg))
csfVol <- voxVol * length(which(as.array(brainSeg)==1))
gmVol <- voxVol * length(which(as.array(brainSeg)==2))
wmVol <- voxVol * length(which(as.array(brainSeg)==3))
deepVol <- voxVol * length(which(as.array(brainSeg)==4))
stemVol <- voxVol * length(which(as.array(brainSeg)==5))
cerbVol <- voxVol * length(which(as.array(brainSeg)==6))

print( paste("CSF volume =", csfVol))
print( paste("GM volume =", gmVol))
print( paste("WM volume =", wmVol))
print( paste("DeepGray volume =", deepVol))
print( paste("BrainStem volume = ", stemVol))
print( paste("Cerebellum volume = ", cerbVol))

thickness <- antsImageRead(thicknessName,dim)
voxVol <- prod(antsGetSpacing(thickness))
thickMean <- mean(thickness, mask=(brainSeg==2))
print( paste("GM mean thickness", thickMean))


if ( grayLabelID != NA ) {

  grayLabels <- list.files(path=directory, pattern=glob2rx(paste(sep='',prefix,grayLabelID)), full.names=TRUE)
  if ( length(grayLabels) > 0 ) {
    gLabels <- antsImageRead(grayLabels,dim)
    gLabelList <- unique(as.vector(as.array(gLabels)))
    gLabelList <- gLabelList[ gLabelList != 0 ]
    gLabelNames <- gLabelList

    if ( grayLabelNames != NA ) {
      grayNames <- read.csv(grayLabelNames)
      grayLabelList <- grayNames[,1]
      grayLabelNames <- grayNames[,2]
      }
    
    # Mean value per label
    thicknessValues <- c()
    for ( lab in grayLabelList ) {
      thVal <- mean(thickness,mask=(gLabels==lab))
      thicknessValues <- c(thicknessValues, thVal)
     }

}


}
