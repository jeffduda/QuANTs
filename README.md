# QuANTs

The purpose of QuANTs is to provide quality assurance and assessment for [Advanced Normalization Tools (ANTs)](https://github.com/stnava/ANTs). Specifically, routines will be provided to evaluate the output of scripts inlcluded with ANTs such as antsCorticalThickness and antsNeuroimagingBattery. A layered approach will be taken:

* Cluster based generatation of csv files and images for individual data sets
* Generation of summary csv files, graph and images for large sets of data (studies, etc)

In addition, by providing an example of how to use these routines, we inherently provide an example of how to use ANTs for an "off the shelf" analysis.

## The Layers

We generally have 3 forms of the data that we are interested in examining:

* Raw input (e.g. dicom)
* Minimally preprocessed input (e.g. nifti)
* Processed (e.g. masked, registered, segmented)

### Raw 
In most cases, you want to receive the data in dicom format as this removes an problems that may result from unknown or inconsistent methods for converting from dicom to nifti. In some cases, such as many publicly available data sets, this conversion has already occured in order to provide a more convenient data set to the research community. From the dicom data we want to gather the following information to guide the rest of the study

* Number of unique acquisitions
* Number of unique subjects
* Number and timing of acquisitions per subject
* Image types (e.g. MR sequences) for each acquisition
* Repeat images within an acquisition (intentional or due to bad data?)
* Subject demographic info that can be pulled from the header

Conversion to anonymized data

### Preprocessed


### Processed

