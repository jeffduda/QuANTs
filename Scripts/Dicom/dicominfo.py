import os
import gdcm

def get_filepaths(directory):
  """This function will generate the file names in a directory 
  tree by walking the tree either top-down or bottom-up. For each 
  directory in the tree rooted at directory top (including top itself), 
  it yields a 3-tuple (dirpath, dirnames, filenames).
  """

  file_paths = []  # List which will store all of the full filepaths.
  sequences = []

  # Walk the tree.
  for root, directories, files in os.walk(directory):

    for filename in files:

      # Join the two strings in order to form the full filepath.
      filepath = os.path.join(root, filename)

      # Read file
      reader = gdcm.Reader()
      reader.SetFileName(filepath)
      if (reader.Read()):
        file = reader.GetFile()
        #print filepath

        # Retrieve data set
        dataSet = file.GetDataSet()
        if ( dataSet.FindDataElement(gdcm.Tag(0x0008, 0x103e)) ):
          print str( dataSet.GetDataElement(gdcm.Tag(0x0008, 0x103e)).GetValue() )
          sequences.append( str( dataSet.GetDataElement(gdcm.Tag(0x0008, 0x103e)).GetValue() ) )
        
        
        # Iterate through the DICOMDIR data set
        #iterator = dataSet.GetDES().begin()
        #while (not iterator.equal(dataSet.GetDES().end())):
        #  dataElement = iterator.next()

          # Check the element tag
        #  if (dataElement.GetTag() == gdcm.Tag(0x004, 0x1220)):
            # The 'Directory Record Sequence' element
       #     sequence = dataElement.GetValueAsSQ()

            # Loop through the sequence items
       #     itemNr = 1
       #     while (itemNr < sequence.GetNumberOfItems()):
       #       item = sequence.GetItem(itemNr)

              # Print patient name
       #       if (item.FindDataElement(gdcm.Tag(0x0010, 0x0010))):
       #         value = str(item.GetDataElement(gdcm.Tag(0x0010, 0x0010)).GetValue())
       #         print value

        file_paths.append(filepath)
 
  sequences  = sorted(set(sequences))
  return file_paths  # Self-explanatory.



def print_dicom_info(filenames):
  """Print info related to each dicom file
  """
  for filename in filenames:
    
    # Read file
    reader = gdcm.Reader()
    reader.SetFileName(filename)
    if (reader.Read()):
      file = reader.GetFile()
      #print filepath

      # Retrieve data set
      dataSet = file.GetDataSet()
      if ( dataSet.FindDataElement(gdcm.Tag(0x0008, 0x103e)) ):
        filesetid = str( dataSet.GetDataElement(gdcm.Tag(0x0004,0x1130)).GetValue() )
        seq = str( dataSet.GetDataElement(gdcm.Tag(0x0008, 0x103e)).GetValue() )
        studydate = str( dataSet.GetDataElement(gdcm.Tag(0x0008, 0x0020)).GetValue() )
        studytime = str( dataSet.GetDataElement(gdcm.Tag(0x0008, 0x0030)).GetValue() )
        seriestime = str( dataSet.GetDataElement(gdcm.Tag(0x0008, 0x0031)).GetValue() )
        acquisitiontime = str( dataSet.GetDataElement(gdcm.Tag(0x0008, 0x0032)).GetValue() )
        print( seq + " " + studydate + " " + studytime + " " + seriestime + " " + acquisitiontime )

        

def get_sequences(filenames):
  """This function will generate the sequence names of dicom files
  """

  sequences = []
  for filename in filenames:

    # Read file
    reader = gdcm.Reader()
    reader.SetFileName(filename)
    if (reader.Read()):
      file = reader.GetFile()
      #print filepath

      # Retrieve data set
      dataSet = file.GetDataSet()
      if ( dataSet.FindDataElement(gdcm.Tag(0x0008, 0x103e)) ):
        print str( dataSet.GetDataElement(gdcm.Tag(0x0008, 0x103e)).GetValue() )
        sequences.append( str( dataSet.GetDataElement(gdcm.Tag(0x0008, 0x103e)).GetValue() ) )

      
  return sequences

def FindDicomStudies(filenames):

  studies = []
  for filename in filenames:

    # Read file
    reader = gdcm.Reader()
    reader.SetFileName(filename)
    if (reader.Read()):
      file = reader.GetFile()
      #print filepath

      # Retrieve data set
      dataSet = file.GetDataSet()
      if ( dataSet.FindDataElement(gdcm.Tag(0x0008, 0x103e)) ):
        studydate = str( dataSet.GetDataElement(gdcm.Tag(0x0008, 0x0020)).GetValue() )
        studytime = str( dataSet.GetDataElement(gdcm.Tag(0x0008, 0x0030)).GetValue() )
        simpletime = studytime[:studytime.find( "." )]
        studies.append( studydate + "_" + simpletime )

      
  return studies


def FindSeriesByStudy(filenames, study):

  studies = []
  for filename in filenames:

    # Read file
    reader = gdcm.Reader()
    reader.SetFileName(filename)
    if (reader.Read()):
      file = reader.GetFile()
      #print filepath

      # Retrieve data set
      dataSet = file.GetDataSet()
      if ( dataSet.FindDataElement(gdcm.Tag(0x0008, 0x103e)) ):
        studydate = str( dataSet.GetDataElement(gdcm.Tag(0x0008, 0x0020)).GetValue() )
        studytime = str( dataSet.GetDataElement(gdcm.Tag(0x0008, 0x0030)).GetValue() )
        seq = str( dataSet.GetDataElement(gdcm.Tag(0x0008, 0x103e)).GetValue() )
        simpletime = studytime[:studytime.find( "." )]
        studyid = studydate + "_" + simpletime 
        if ( studyid == study ):
          studies.append(seq)

      
  return studies



