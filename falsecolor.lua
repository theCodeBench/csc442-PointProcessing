--[[

  * * * * falsecolor.lua * * * *

Lua File Containing:
Discrete 8-Level Pseudocolor
Continuous Pseudocolor
Bit-Plane Slicing
Sepia

Author: Ryan Hinrichs & Zach Crandall
Class: CSC442/542 Digital Image Processing
Date: Spring 2017

--]]

require "ip"
local viz = require "visual"
local il = require "il"
local basic = require "basic"

--[[

  * * * * Eight Value Pseudocolor * * * *

Function to give a greyscale image the simulated example
of color by assigning 8 intervals of gray to 8 specified
color values.

Author:     Ryan Hinrichs
Class:      CSC442/542 Digital Image Processing
Date:       Spring 2017
Parameters: img - the image to be processed
Returns:    img - the processed image to be displayed

--]]
local function pseudoeight( img )
  
  --Arrays of color values
  local pseu_r = {0,255,255,255,  0,  0,255,255}
  local pseu_g = {0,  0,  0,255,255,  0,153,255}
  local pseu_b = {0,  0,255, 51,  0,255, 51,255}
  local pseu = {}
  local pixel = 0
  
  --Convert image to greyscale
  img = basic.greyscale( img )
  
  --Calculating intervals
  for i = 1, 8 do    
    pseu[i] = (255/8)*i
  end

  local row, col = img.height, img.width
  
  --Goes through the image and applies color values to the intervals
  for row, col in img:pixels() do
        pixel = img:at(row,col).r
        for inter = 2, 8 do
          if pixel >= pseu[8] then
            img:at(row,col).r = pseu_r[inter]
            img:at(row,col).g = pseu_g[inter]
            img:at(row,col).b = pseu_b[inter]
            inter = 9
          elseif pixel >= pseu[inter - 1] and pixel < pseu[inter] then
            img:at(row,col).r = pseu_r[inter]
            img:at(row,col).g = pseu_g[inter]
            img:at(row,col).b = pseu_b[inter]
            inter = 9
          end
        end
        --print(pixel)
        
        --if pixel > 7 then pixel = 7 end
        --if pixel < 1 then pixel = 1 end
        
        --yvals[r][c] = pixel
  end

  return img
end

--[[

  * * * * Continuous Pseudocolor * * * *

Function to give a greyscale image the simulated example
of color by assigning 255 intervals of gray to specified
color values based on mathematical trends coded into the
function

Author:     Ryan Hinrichs
Class:      CSC442/542 Digital Image Processing
Date:       Spring 2017
Parameters: img - the image to be processed
Returns:    img - the processed image to be displayed

--]]
local function pseudocont( img )
  local pseu_r = {}
  local pseu_g = {}
  local pseu_b = {}

  for i = 0, 255 do    

    if i <= 122 then pseu_r[i] = 2*i end
    if i > 122 then pseu_r[i] = 255 - (i - 122) end
    if pseu_r[i] > 255 then pseu_r[i] = 255 end
    if pseu_r[i] < 0 then pseu_r[i] = 0 end

    pseu_g[i] = i

    pseu_b[i] = 255 - i

  end



  local row, col = img.height, img.width

  for r = 0, row-1 do
    for c = 0, col-1 do
      img:at(r,c).r = pseu_r[img:at(r,c).r]
      img:at(r,c).g = pseu_g[img:at(r,c).g]
      img:at(r,c).b = pseu_b[img:at(r,c).b]
    end 
  end


  return img
end

--[[

* * * * Bitplane Slicing * * * *

This function checks if the plane (0, 7) provided by the user
is 0 or 1 in the intensity value of the pixel. It then applies
a binary threshold to the RGB channels of the image based on
whether the bit was flipped or not. The image is then returned
for display.

Author:     Zachery Crandall
Class:      CSC442/542 Digital Image Processing
Date:       Spring 2017
Parameters: img - the image to be processed
            plane - the bit to set the binary threshold at
Returns:    img - the processed image to be displayed

  --]]
local function bitslice( img, plane )
  local row, col = img.height, img.width
  local bool switch = 0
  local intensity = 0
  local bitslices = {}

  -- Create lookup table
  for i = 0, 255 do
    -- Check if the bit is flipped
    switch = bit32.extract( i, plane, 1) 

    -- Apply the binary threshold
    if switch == 0 then bitslices[i] = 0 end
    if switch == 1 then bitslices[i] = 255 end
  end

  for row, col in img:pixels() do
    intensity = math.floor((img:at(row,col).r * 0.30) + (img:at(row,col).g * 0.59) + (img:at(row,col).b * 0.11) + 0.5)
    
    -- Binary threshold the RGB channels
    for ch = 0, 2 do
      img:at(row, col).rgb[ch] = bitslices[intensity]
    end
  end

  return img
end

local function sepia( img )
  local row, col = img.height, img.width

  local rvals = {}          -- create the matrix
  for i=0,row-1 do
    rvals[i] = {}
    for j=0,col-1 do
      rvals[i][j] = (img:at(i,j).r * 0.393) + (img:at(i,j).g * 0.769) + (img:at(i,j).b * 0.189)
      if rvals[i][j] < 0 then rvals[i][j] = 0 end
      if rvals[i][j] > 255 then rvals[i][j] = 255 end
    end
  end

  local gvals = {}          -- create the matrix
  for i=0,row-1 do
    gvals[i] = {}
    for j=0,col-1 do
      gvals[i][j] = (img:at(i,j).r * 0.349) + (img:at(i,j).g * 0.686) + (img:at(i,j).b * 0.168)
      if gvals[i][j] < 0 then gvals[i][j] = 0 end
      if gvals[i][j] > 255 then gvals[i][j] = 255 end
    end
  end

  local bvals = {}          -- create the matrix
  for i=0,row-1 do
    bvals[i] = {}
    for j=0,col-1 do
      bvals[i][j] = (img:at(i,j).r * 0.272) + (img:at(i,j).g * 0.534) + (img:at(i,j).b * 0.131)
      if bvals[i][j] < 0 then bvals[i][j] = 0 end
      if bvals[i][j] > 255 then bvals[i][j] = 255 end
    end
  end

  for r = 0, row-1 do
    for c = 0, col-1 do
      img:at(r,c).r = rvals[r][c]
      img:at(r,c).g = gvals[r][c]
      img:at(r,c).b = bvals[r][c]        
    end 
  end

  return img
end


return {
  pseudoeight = pseudoeight,
  pseudocont = pseudocont,
  bitslice = bitslice,
  sepia = sepia
}