--[[

  * * * * basic.lua * * * *

Lua File Containing:
Grayscale
Binary Threshold
Brightness
Negate
Posterize

Author: Ryan Hinrichs
Class: CSC442/542 Digital Image Processing
Date: Spring 2017

--]]

require "ip"
local viz = require "visual"
local il = require "il"


--[[

  * * * * Posterize * * * *

Function to limit the number of colors available to the image
and then lock each pixel within those color bands.  It takes 
the intensity values and sets which intensity value the pixel is
at based on where it is within the interval specified through the
levels given by the user.

Author:     Ryan Hinrichs
Class:      CSC442/542 Digital Image Processing
Date:       Spring 2017
Parameters: img - the image to be processed
            levelnum - the number of levels to separate the colors
Returns:    img - the processed image to be displayed

--]]
local function posterize( img , levelnum)
  levels = {}
  local pixel = 0
  --Create the intervals
  for i = 0, levelnum do 
    levels[i] = (255.0/(levelnum))*i
    print(levels[i])
  end
  
  local row, col = img.height, img.width
  
  img = il.RGB2YIQ( img )
  
  --Process the image through the intervals
  for r = 0, row-1 do
    for c = 0, col-1 do
      pixel = img:at(r,c).y
      for lev = 1, levelnum do
        if pixel >= levels[lev - 1] and pixel <= levels[lev] then
          pixel = (levels[lev] + levels[lev - 1]) / 2
          lev = levelnum
        elseif pixel >= levels[levelnum - 1] then
          pixel = 255
          lev = levelnum
        end
      end
      img:at(r,c).y = pixel
    end 
  end
  
  --Returns the altered image
  return il.YIQ2RGB( img )
end

--[[

  * * * * Binary Thresholding * * * *

Function which takes the image and a threshold value given
by the user, analyzes the intensity values to find if each
value is above or below, and sets the pixels to white if
above and black if below

Author:     Ryan Hinrichs
Class:      CSC442/542 Digital Image Processing
Date:       Spring 2017
Parameters: img - the image to be processed
            thresh - the threshold image
Returns:    img - the processed image to be displayed

--]]
local function binarythresh( img , thresh)
  
  local row, col = img.height, img.width
  
  img = il.RGB2YIQ( img )

  --Create a 2d array to mimic the pixel values of
  --the image to reference in RGB
  local yvals = {}    
  for i=0,row-1 do
    yvals[i] = {}
    for j=0,col-1 do
        pixel = img:at(i,j).y
        if pixel > thresh then pixel = 255 end
        if pixel < thresh then pixel = 0 end
        yvals[i][j] = pixel
    end
  end
  
  img = il.YIQ2RGB( img )
  
  --Sets the pixel values based on the analysis of the 
  --intensities
  for r = 0, row-1 do
    for c = 0, col-1 do
      for ch = 0, 2 do
        img:at(r,c).rgb[ch] = yvals[r][c]
      end
    end
  end

  return img
end

--[[

  * * * * Brightness * * * *

Function to increase the brightness of the image by a set
value given by the user.  It takes a value and adds it to 
the RGB values of each of the pixel intensities.

Author:     Ryan Hinrichs
Class:      CSC442/542 Digital Image Processing
Date:       Spring 2017
Parameters: img - the image to be processed
            brightval - brightness value
Returns:    img - the processed image to be displayed

--]]
local function brightness( img , brightval)
  
  local row, col = img.height, img.width
  
  img = il.RGB2YIQ( img )

  
  for r = 0, row-1 do
    for c = 0, col-1 do
      pixel = img:at(r,c).y
      --Add the brightness value to the intensity
      pixel = pixel + brightval
      
      if pixel < 0 then pixel = 0 end
      if pixel > 255 then pixel = 255 end
      img:at(r,c).y = pixel
    end
  end

  return il.YIQ2RGB( img )
end

--[[

  * * * * Intensity Negate * * * *

Function to negate the image, setting every pixel value
to it's opposite by taking 255 minus the value of the 
pixel intensity.

Author:     Ryan Hinrichs
Class:      CSC442/542 Digital Image Processing
Date:       Spring 2017
Parameters: img - the image to be processed
Parameters: img - the image to be processed
Returns:    img - the processed image to be displayed

--]]
local function intnegate( img )
  img = il.RGB2YIQ( img )
  
  local row, col = img.height, img.width

  -- Invert the colors for the whole image
  for r = 0, row-1 do
    for c = 0, col-1 do
      img:at(r,c).y = 255 - img:at(r,c).y
    end
  end
  
  return il.YIQ2RGB( img )
end

--[[

  * * * * RGB Negate * * * *

Function to negate the image, setting every pixel value
to it's opposite by taking 255 minus the value of the 
pixel red, green, and blue channels.

Author:     Ryan Hinrichs
Class:      CSC442/542 Digital Image Processing
Date:       Spring 2017
Parameters: img - the image to be processed
Returns:    img - the processed image to be displayed

--]]
local function rgbnegate( img )
  local row, col = img.height, img.width
  
  -- Invert the colors for the whole image
  for r = 0, row-1 do
    for c = 0, col-1 do
      for ch = 0, 2 do
        img:at(r,c).rgb[ch] = 255 - img:at(r,c).rgb[ch]
      end
    end
  end
  
  return img
end

--[[

  * * * * Grayscale * * * *

Function that takes the image values and calculates
an appropriate grayscale image with the visual 
proportions of the human eye

Author:     Ryan Hinrichs
Class:      CSC442/542 Digital Image Processing
Date:       Spring 2017
Parameters: img - the image to be processed
Returns:    img - the processed image to be displayed

--]]
local function greyscale( img )
  
  local row, col = img.height, img.width

  --Create a matrix of grayscale values based on intensities
  yvals = {}  
  for i=0,row-1 do
    yvals[i] = {}
    for j=0,col-1 do
        yvals[i][j] = (img:at(i,j).r * 0.30) + (img:at(i,j).g * 0.59) + (img:at(i,j).b * 0.1)
        if yvals[i][j] < 0 then yvals[i][j] = 0 end
        if yvals[i][j] > 255 then yvals[i][j] = 255 end
    end
  end

  --Set the values based on the intensities to the rgb 
  --channels
  for r = 0, row-1 do
    for c = 0, col-1 do
      img:at(r,c).r = yvals[r][c]
      img:at(r,c).g = yvals[r][c]
      img:at(r,c).b = yvals[r][c]
    end
  end


  return img
end

return {
  rgbnegate = rgbnegate,
  intnegate = intnegate,
  greyscale = greyscale,
  brightness = brightness,
  binarythresh = binarythresh,
  posterize = posterize
}