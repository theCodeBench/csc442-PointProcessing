--[[

  * * * * histogram.lua * * * *

File containing routinfes for image histogram manipulation.

Author: Zachery Crandall
Class:  CSC442/542 Digital Image Processing
Date:   Spring 2017

--]]

require "ip"
local viz = require "visual"
local il = require "il"
local util = require "util"



--[[

  * * * * Automatic Contrast Stretch * * * *

Function to adjust the contrast of a given image by the minimum and maximum
intensities detected in the image. The image is first converted to the YIQ
color model. The histogram is searched from 0 to 255 for the first nonzero
intensity value, the minimum intensity, then from 255 to 0 for the first
nonzero intensity value, the maximum intensity. All pixels are then 
subject to the intensity transform:
T(i) = (i - imin) * ( ( 255 ) / ( imax - imin) ). The image
is converted back to the RGB color model and returned for display.

Author:     Zachery Crandall
Class:      CSC442/542 Digital Image Processing
Date:       Spring 2017
Parameters: img - the image to be processed
Returns:    img - the processed image to be displayed

--]]
local function autoContrastStretch( img )
  img = il.RGB2YIQ( img )
  
  local histo = util.histogramYIQ( img )
  local imin, imax = 0, 0

  imin, imax = util.findMinMax( histo )

  -- Calculate the multipler
  local multiplier = 255 / ( imax - imin )

  -- Adjust the contrast of all pixels in the image
  for row, col in img:pixels() do
    local pixel = img:at(row, col).yiq[0]

    pixel = ( pixel - imin ) * multiplier

    --Clip the channel values at 0 and 255
    pixel = util.clip( pixel )

    -- Store value
    img:at(row, col).yiq[0] = pixel
  end

  -- Return the modified RBG image for display
  return il.YIQ2RGB( img )
end



--[[

* * * * Modified Contrast Stretch * * * *

Function to adjust the contrast of a given image by percentages of 
light and dark pixels to ignore. The image is first converted to the YIQ
color model. The number of light and dark pixels to ignore are calculated 
next from the provided percentages and the minimum and maximum intensities
are found by summing portions of the intensity histogram of the image.
Then all pixels are subject to the intensity transform
T(i) = (i - imin) * ( ( 255 ) / ( imax - imin) ). The image
is converted back to the RGB color model and returned for display.

Author:     Zachery Crandall
Class:      CSC442/542 Digital Image Processing
Date:       Spring 2017
Parameters: img - the image to be processed
            minPercent - the bottom percent of total pixels to be ignored
            maxPercent - the top percent of total pixels to be ignored
Returns:    img - the processed image to be displayed

--]]
local function modifiedContrastStretch( img, minPercent, maxPercent )
  img = il.RGB2YIQ( img )
  
  local histo = util.histogramYIQ( img )
  local totalPixels = img.height * img.width
  local ignoredLightPixels = totalPixels * minPercent / 100
  local ignoredDarkPixels = totalPixels * ( 100 - maxPercent ) / 100
  local sum = 0
  local i, imin, imax = 0, 0, 0

  -- Find imin by summing from intensity 0 to 255 until the specified percentage 
  -- of pixels are ignored
  while sum < ignoredLightPixels do
    sum = sum + histo[i]

    i = i + 1
  end

  -- Set min intensity and reinitialize the counter and sum
  imin = i
  i = 255
  sum = 0

  -- Find imax by summing from intensity 255 to 0 until the specified percentage 
  -- of pixels are ignored
  while sum < ignoredDarkPixels do
    sum = sum + histo[i]

    i = i - 1
  end

  -- Set max intensity
  imax = i

  -- Calculate the multipler
  local multiplier = 255 / ( imax - imin )

  -- Adjust the contrast of all pixels in the image
  for row, col in img:pixels() do
    local pixel = img:at(row, col).yiq[0]

    pixel = ( pixel - imin ) * multiplier

    --Clip the channel values at 0 and 255
    pixel = util.clip( pixel )

    -- Store value
    img:at(row, col).yiq[0] = pixel
  end

  -- Return the modified RBG image for display
  return il.YIQ2RGB( img )
end



--[[

* * * * Intensity Histogram Display * * * *

Displays a histogram of the intensity (YIQ) of an image
in the image tab. This uses the showHistogram function
created by Dr. John Weiss and Alex Iverson.

Author:     Zachery Crandall
Class:      CSC442/542 Digital Image Processing
Date:       Spring 2017
Parameters: img - the image to be processed
Returns:    An image of the intensity histogram for img

--]]
local function displayIntensityHistogram( img )
  return il.showHistogram( img )
end



--[[

* * * * Color Histogram Display * * * *

Displays color histograms of an image in the image tab.
This uses the showHistogramRGB function created by 
Dr. John Weiss and Alex Iverson.

Author:     Zachery Crandall
Class:      CSC442/542 Digital Image Processing
Date:       Spring 2017
Parameters: img - the image to be processed
Returns:    An image of the color histograms for img

--]]
local function displayColorHistogram( img )
  return il.showHistogramRGB( img )
end



--[[

* * * * Histogram Equilization YIQ * * * *

This function equalizes the histogram of a given image using 
the YIQ color model. An image is provided and converted to YIQ.
Using the histogram of the image, the cumulative distribution 
function (CDF) of the image is generated and used to generate a lookup
table for the intensities 0 to 255. This lookup table is used to
apply the CDF to all pixels in the image. The image is then
converted back to RGB and returned for display.

Author:     Zachery Crandall
Class:      CSC442/542 Digital Image Processing
Date:       Spring 2017
Parameters: img - the image to be processed
Returns:    img - the processed image to be displayed

  --]]
local function histogramEquilizeYIQ( img )
  img = il.RGB2YIQ( img )

  local histogram = util.histogramYIQ( img )
  local nrows, ncols = img.height, img.width
  local eqHisto = {}
  local multiplier = 255 / (nrows * ncols)
  local sum = 0

  -- Generate a look up table
  for i = 0, 255 do
    sum = sum + histogram[i]

    eqHisto[i] = math.floor(multiplier * sum + 0.5)
  end


  for row, col in img:pixels() do
    local pixel = img:at(row,col).yiq[0]

    -- Apply histogram equilization to the pixel
    pixel = eqHisto[pixel]

    -- Store value
    img:at(row,col).yiq[0] = pixel
  end

  return il.YIQ2RGB( img )
end



--[[

* * * * Histogram Equilization with Clipping YIQ * * * *

This function equalizes the histogram of a given image using 
the YIQ color model. An image is provided and converted to YIQ.
Using the histogram of the image, the cumulative distribution 
function (CDF) of the image is generated and used to generate a lookup
table for the intensities 0 to 255. This lookup table is clipped
at a percentage of the total pixels specified by the user. The lookup
table is then used to apply the clipped CDF to all pixels in the image. 
The image is then converted back to RGB and returned for display.

Author:     Zachery Crandall
Class:      CSC442/542 Digital Image Processing
Date:       Spring 2017
Parameters: img - the image to be processed
            percent - the percent of total pixels to be clipped at
Returns:    img - the processed image to be displayed

  --]]
local function histogramClipYIQ( img, percent )
  img = il.RGB2YIQ( img )

  local histo = util.histogramYIQ( img )
  local nrows, ncols = img.height, img.width
  local eqHisto = {}
  local percentElements = nrows * ncols * percent / 100
  local multiplier = 0 -- 255 / (nrows * ncols)
  local sum = 0

  -- Clip the pixels at each intensity if needed
  for i = 0, 255 do
    if( percentElements < histo[i]) then
      sum = sum + percentElements
      histo[i] = percentElements
    else
      sum = sum + histo[i]
    end
  end

  multiplier = 255 / sum

  sum = 0

  -- Generate a look up table
  for i = 0, 255 do
    sum = sum + histo[i]

    eqHisto[i] = math.floor(multiplier * sum + 0.5)
  end


  for row, col in img:pixels() do
    local pixel = img:at(row,col).yiq[0]

    -- Apply histogram equilization to the pixel
    pixel = eqHisto[pixel]

    -- Store value
    img:at(row,col).yiq[0] = pixel
  end

  return il.YIQ2RGB( img )
end



-- Return the functions to be referenced elsewhere
return {
  autoContrastStretch = autoContrastStretch,
  modifiedContrastStretch = modifiedContrastStretch,
  displayIntensityHistogram = displayIntensityHistogram,
  displayColorHistogram = displayColorHistogram,
  histogramEquilizeYIQ = histogramEquilizeYIQ,
  histogramClipYIQ = histogramClipYIQ
}