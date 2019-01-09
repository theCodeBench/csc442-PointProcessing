--[[

  * * * * main.lua * * * *

Lua image processing test file.

Author: Ryan Hinrichs and Zachery Crandall
Class: CSC442/542 Digital Image Processing
Date: Spring 2017

--]]

require "ip"
local viz = require "visual"
local il = require "il"

-- Our routines
local histogram = require "histogram"
local point = require "point"
local basic = require "basic"
local falsecolor = require "falsecolor"

-- load images listed on command line
local imgs = {...}
for i, fname in ipairs(imgs) do loadImage(fname) end

viz.imageMenu( "Point Processes",
  {
    {"Greyscale", basic.greyscale},
    {"RGB Negate", basic.rgbnegate},
    {"YIQ Negate", basic.intnegate},
    {"Apply Binary Threshold", basic.binarythresh, {{name = "Threshold", type = "number", displaytype = "textbox", default = "126.0"}}},
    {"Posterize Image", il.negate},
    {"My Posterize", basic.posterize, {{name = "Number of Levels", type = "number", displaytype = "spin", default = 4, min = 0, max = 255}}},
    {"My Brightness", basic.brightness, {{name = "Brightness", type = "number", displaytype = "textbox", default = "10.0"}}},
    {"Gamma", point.gamma, {{name = "Gamma", type = "number", displaytype = "textbox", default = "1.0"}}},
    {"Contrast Stretch (linear ramp)", point.contrastLinearRate, 
      { {name = "Minimum", type = "number", displaytype = "spin", default = 64, min = 0, max = 255},
        {name = "Maximum", type = "number", displaytype = "spin", default = 191, min = 0, max = 255}}},
    {"Compress Dynamic Range", point.logCompress},
    {"Pseudocolor (8-level)", falsecolor.pseudoeight},
    {"Pseudocolor (continuous)", falsecolor.pseudocont},
    {"Bit-plane Slicing", falsecolor.bitslice, 
      { {name = "Plane", type = "number", displaytype = "spin", 
          default = 7, min = 0, max = 7}}},
    {"Sepia", falsecolor.sepia}
  }
)

viz.imageMenu( "Histogram Processes",
  {
    {"Adjust Contrast (automatic)", histogram.autoContrastStretch},
    {"Adjust Contrast (% dark/light pixels)", histogram.modifiedContrastStretch,
      { {name = "Minimum", type = "number", displaytype = "spin", 
          default = 0, min = 0, max = 100},
        {name = "Maximum", type = "number", displaytype = "spin",
          default = 100, min = 0, max = 100}}},
    {"Histogram Intensity Display", histogram.displayIntensityHistogram},
    {"Histogram Color Display", histogram.displayColorHistogram},
    {"Histogram Equalization YIQ", histogram.histogramEquilizeYIQ},
    {"Histogram Equalization (with clipping)", histogram.histogramClipYIQ,
      {{name = "clip %", type = "number", displaytype = "textbox", default = "1.0"}}},
  }
)

viz.imageMenu( "Help",
  {
    {"About", viz.imageMessage( "PA1", "Authors: Ryan Hinrichs and Zachery Crandall\nClass: CSC442/542 Digital Image Processing\nDate: February 9, 2017" ) },
  }
)

-- Open window to begin
start()