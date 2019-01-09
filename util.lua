--[[

  * * * * util.lua * * * *

File for general utility functions used in the image processing code of this
project. Examples are creating a histogram and clipping values.

Author: Zachery Crandall
Class:  CSC442/542 Digital Image Processing
Date:   Spring 2017

--]]
require "ip"
local viz = require "visual"
local il = require "il"



--[[

  * * * * Clip Intensity Values * * * *

Function to clip intensity values to the range (0,255).

Author:     Zachery Crandall
Class:      CSC442/542 Digital Image Processing
Date:       Spring 2017
Parameters: pixel - the pixel to be clipped
Returns:    pixel - the clipped pixel

--]]
local function clip( pixel )
  if pixel < 0 then pixel = 0 end
  if pixel > 255 then pixel = 255 end

  return pixel
end



--[[

  * * * * Create Histogram YIQ * * * *

Function to create the histogram of an image. The image
is first converted to YIQ. The intensity (0, 255) of each pixel is
then counted and the resulting table of counts is returned.

Author:     Zachery Crandall
Class:      CSC442/542 Digital Image Processing
Date:       Spring 2017
Parameters: img - the image to be processed
Returns:    img - the processed image to be displayed

--]]
local function histogramYIQ( img )
  local histogram = {}

  -- Initialize the histogram
  for i = 0, 255 do
    histogram[i] = 0
  end

  -- Count the various intensities of the image
  for row, col in img:pixels() do
    i = img:at(row, col).yiq[0]
    histogram[i] = histogram[i] + 1
  end

  return histogram
end



--[[

  * * * * Find Min and Max of a Histogram * * * *

This function checks from intensity 0 to 255 for the first nonzero intensity
value. This is the minimum intensity of the histogram. It then checks from 
255 to 0 for the first nonzero intensity. This is the maximum intensity.
These values are returned for use.

Author:     Zachery Crandall
Class:      CSC442/542 Digital Image Processing
Date:       Spring 2017
Parameters: histogram - the histogram table to be processed
Returns:    imin - the minimum nonzero intensity
            imax - the maximum nonzero intensity

--]]
local function findMinMax( histogram )
  i, imin, imax = 0, 0, 0

  -- Find imin by summing from intensity 0 to 255 until the specified percentage 
  -- of pixels are ignored
  while histogram[i] == 0 do
    i = i + 1
  end

  -- Set min intensity and reinitialize the counter and sum
  imin = i
  i = 255
  sum = 0

  -- Find imax by summing from intensity 255 to 0 until the specified percentage 
  -- of pixels are ignored
  while histogram[i] == 0 do
    i = i - 1
  end

  -- Set max intensity
  imax = i

  return imin, imax
end



return {
  clip = clip,
  histogramYIQ = histogramYIQ,
  findMinMax = findMinMax,
  about = about,
}