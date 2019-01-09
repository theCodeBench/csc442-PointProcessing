--[[

  * * * * point.lua * * * *

General point process manipulation file.

Author: Zachery Crandall
Class:  CSC442/542 Digital Image Processing
Date:   Spring 2017

--]]

require "ip"
local viz = require "visual"
local il = require "il"
local util = require "util"



--[[

  * * * * Linear Ramp Contrast Stretch * * * *

Function to adjust the contrast of a given image by endpoints
provided by the user. The image is first converted to the YIQ
color model, then all pixels are subject to the intensity transform
T(i) = (i - startPt) * ( ( 255 ) / ( endPt - startPt) ). The image
is converted back to the RGB color model and returned for display.

Author:     Zachery Crandall
Class:      CSC442/542 Digital Image Processing
Date:       Spring 2017
Parameters: img - the image to be processed
            startPt - the intensity (0, 255) to start from 
            endPt - the intensity (0, 255) to end at
Returns:    img - the processed image to be displayed

--]]
local function contrastLinearRate( img, startPt, endPt )
  -- Convert to YIQ
  img = il.RGB2YIQ( img )

  -- Calculate the multipler
  local multiplier = 255 / ( endPt - startPt )

  -- Adjust the contrast of all pixels in the image
  for row, col in img:pixels() do
    local pixel = img:at(row, col).yiq[0]

    pixel = ( pixel - startPt ) * multiplier

    --Clip the channel values at 0 and 255
    pixel = util.clip( pixel )

    -- Store value
    img:at(row, col).yiq[0] = pixel
  end

  -- Return the modified RBG image for display
  return il.YIQ2RGB( img )
end



--[[

  * * * * Gamma Adjustment * * * *

Function to adjust the gamma of an image given the
exponential gamma factor and a constant if desired.
The pixels are tranformed according to 
T(i) = 255 * ( i / 255 ) ^ factor

Author:     Zachery Crandall
Class:      CSC442/542 Digital Image Processing
Date:       Spring 2017
Parameters: img - the image to be processed
            factor - the gamma factor to adjust the image by
Returns:    img - the processed image to be displayed

--]]
local function gamma( img, factor )
  local gammas = {}
  
  -- Generate a lookup table
  for i = 0, 255 do
    gammas[i] = ( i / 256 ) ^ factor
  end
  
  -- Convert image to YIQ
  img = il.RGB2YIQ( img )

  -- Adjust every pixel by gamma factor and constant
  for row, col in img:pixels() do
    local pixel = img:at(row, col).yiq[0]

    -- Adjust the intensity by the gamma
    pixel = gammas[pixel]

    -- Store value
    img:at(row, col).yiq[0] = pixel * 256
  end

  return il.YIQ2RGB( img )
end



--[[

  * * * * Dynamic Range Compression * * * *

Function to perform dynamic range compression on the
image using a log transform in form of 
T(i) = log( 1 + i ) / log( 256 )

Author:     Zachery Crandall
Class:      CSC442/542 Digital Image Processing
Date:       Spring 2017
Parameters: img - the image to be processed
Returns:    img - the processed image to be displayed

--]]
local function logCompress( img )
  local logs = {}
  
  -- Generate a lookup table
  for i = 0, 255 do
    logs[i] = math.log10( 1 + i ) / math.log10( 256 )
  end
  
  -- Convert image to YIQ
  img = il.RGB2YIQ( img )

  -- Compress the dynamic range of the image
  for row, col in img:pixels() do
    local pixel = img:at(row, col).yiq[0]

    -- Adjust the value of each pixel for the log transform
    pixel = logs[pixel]

    -- Store value
    img:at(row, col).yiq[0] = pixel * 255
  end

  return il.YIQ2RGB( img )
end



-- Return the functions to be referenced elsewhere
return 
{
  contrastLinearRate = contrastLinearRate,
  gamma = gamma,
  logCompress = logCompress
}