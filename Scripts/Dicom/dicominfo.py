import os
import gdcm

def get_filepaths(directory):
  """This function will generate the file names in a directory 
  tree by walking the tree either top-down or bottom-up. For each 
  directory in the tree rooted at directory top (including top itself), 
  it yields a 3-tuple (dirpath, dirnames, filenames).
  """

  file_paths = []  # List which will store all of the full filepaths.

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
        print filepath

        # Retrieve data set
        dataSet = file.GetDataSet()
        if ( dataSet.FindDataElement(gdcm.Tag(0x0008, 0x103e)) ):
          print str( dataSet.GetDataElement(gdcm.Tag(0x0008, 0x103e)).GetValue() )
        
        
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


  return file_paths  # Self-explanatory.





