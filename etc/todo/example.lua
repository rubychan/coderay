
-------------------------------------------------------------------------------
-- Creates a new function, with the name suffixed by "New". This new function
-- creates a new image, based on a source image, and calls the previous function
-- with this new image.

local function OneSourceOneDest (funcname, width, height, color_space, data_type)
  local func = im[funcname]
  assert(func) -- see if function is really defined

  -- define function with "New" suffix
  im[funcname.."New"] = function (src_image, ...)
    -- create destination image
    local dst_image = im.ImageCreateBased(src_image, width, height, color_space, data_type)

    -- call previous method, repassing all parameters
    func(src_image, dst_image, unpack(arg))
    return dst_image
  end
end

-------------------------------------------------------------------------------
-- This function is similar to OneSourceOneDest, but it receives two source
-- images.

local function TwoSourcesOneDest (funcname, width, height, color_space, data_type)
  local func = im[funcname]
  
  -- see if function is really defined
  assert(func, string.format("undefined function `%s'", funcname))

  -- define function with "New" suffix
  im[funcname.."New"] = function (src_image1, src_image2, ...)
    -- create destination image
    local dst_image = im.ImageCreateBased(src_image1, width, height, color_space, data_type)

    -- call previous method, repassing all parameters
    func(src_image1, src_image2, dst_image, unpack(arg))
    return dst_image
  end
end

-------------------------------------------------------------------------------

TwoSourcesOneDest("ProcessCrossCorrelation")
OneSourceOneDest("ProcessAutoCorrelation", nil, nil, nil, im.CFLOAT)
OneSourceOneDest("ProcessFFT")
OneSourceOneDest("ProcessIFFT")

-------------------------------------------------------------------------------
-- Creates a new function, with the name suffixed by "New". This new function
-- creates a new image, based on a source image, and calls the previous function
-- with this new image.
-- We assume here that the functions returns only one parameter or none.

local function OneSourceOneDest (funcname, width, height, color_space, data_type)
  local func = im[funcname]
  assert(func) -- see if function is really defined

  -- define function with "New" suffix
  im[funcname.."New"] = function (src_image, ...)
    -- create destination image
    local dst_image = im.ImageCreateBased(src_image, width, height, color_space, data_type)

    -- call previous method, repassing all parameters
    local ret = func(src_image, dst_image, unpack(arg))
    if (ret) then
      return ret, dst_image
    else
      return dst_image
    end
  end
end

-------------------------------------------------------------------------------
-- This function is similar to OneSourceOneDest, but it receives two source
-- images.

local function TwoSourcesOneDest (funcname, width, height, color_space, data_type)
  local func = im[funcname]
  
  -- see if function is really defined
  assert(func, string.format("undefined function `%s'", funcname))

  -- define function with "New" suffix
  im[funcname.."New"] = function (src_image1, src_image2, ...)
    -- create destination image
    local dst_image = im.ImageCreateBased(src_image1, width, height, color_space, data_type)

    -- call previous method, repassing all parameters
    local ret = func(src_image1, src_image2, dst_image, unpack(arg))
    if (ret) then
      return ret, dst_image
    else
      return dst_image
    end
  end
end

-------------------------------------------------------------------------------
-- This function is similar to OneSourceOneDest, but it receives three source
-- images.

local function ThreeSourcesOneDest (funcname, width, height, color_space, data_type)
  local func = im[funcname]
  assert(func) -- see if function is really defined

  -- define function with "New" suffix
  im[funcname.."New"] = function (src_image1, src_image2, src_image3, ...)
    -- create destination image
    local dst_image = im.ImageCreateBased(src_image1, width, height, color_space, data_type)

    -- call previous method, repassing all parameters
    local ret = func(src_image1, src_image2, src_image3, dst_image, unpack(arg))
    if (ret) then
      return ret, dst_image
    else
      return dst_image
    end
  end
end

-------------------------------------------------------------------------------
-- This function is similar to OneSourceOneDest, but it creates two destiny
-- images.

local function OneSourceTwoDests (funcname, width, height, color_space, data_type)
  local func = im[funcname]
  assert(func) -- see if function is really defined

  -- define function with "New" suffix
  im[funcname.."New"] = function (src_image, ...)
    -- create destination image
    local dst_image1 = im.ImageCreateBased(src_image, width, height, color_space, data_type)
    local dst_image2 = im.ImageCreateBased(src_image, width, height, color_space, data_type)

    -- call previous method, repassing all parameters
    local ret = func(src_image, dst_image1, dst_image2, unpack(arg))
    if (ret) then
      return ret, dst_image1, dst_image2
    else
      return dst_image1, dst_image2
    end
  end
end

-------------------------------------------------------------------------------
-- This function is similar to OneSourceOneDest, but it creates three destiny
-- images.

local function OneSourceThreeDests (funcname, width, height, color_space, data_type)
  local func = im[funcname]
  assert(func) -- see if function is really defined

  -- define function with "New" suffix
  im[funcname.."New"] = function (src_image, ...)
    -- create destination image
    local dst_image1 = im.ImageCreateBased(src_image, width, height, color_space, data_type)
    local dst_image2 = im.ImageCreateBased(src_image, width, height, color_space, data_type)
    local dst_image3 = im.ImageCreateBased(src_image, width, height, color_space, data_type)

    -- call previous method, repassing all parameters
    local ret = func(src_image, dst_image1, dst_image2, dst_image3, unpack(arg))
    if (ret) then
      return ret, dst_image1, dst_image2, dst_image3
    else
      return dst_image1, dst_image2, dst_image3
    end
  end
end

-------------------------------------------------------------------------------

local function hough_height(image)
  local function sqr(x) return x*x end
  local rmax = math.sqrt(sqr(image:Width()) + sqr(image:Height())) / 2
  return 2*rmax+1
end

OneSourceOneDest("AnalyzeFindRegions", nil, nil, nil, im.USHORT)
OneSourceOneDest("ProcessPerimeterLine")
OneSourceOneDest("ProcessPrune")
OneSourceOneDest("ProcessFillHoles")
OneSourceOneDest("ProcessHoughLines", 180, hough_height, im.GRAY, im.INT)
OneSourceOneDest("ProcessHoughLinesDraw")
OneSourceOneDest("ProcessDistanceTransform", nil, nil, nil, im.FLOAT)
OneSourceOneDest("ProcessRegionalMaximum", nil, nil, im.BINARY, nil)

function im.ProcessReduceNew (src_image, width, height)
  local dst_image = im.ImageCreateBased(src_image, width, height)
  return im.ProcessReduce(src_image, dst_image), dst_image
end

function im.ProcessResizeNew (src_image, width, height)
  local dst_image = im.ImageCreateBased(src_image, width, height)
  return im.ProcessResize(src_image, dst_image), dst_image
end

OneSourceOneDest("ProcessReduceBy4", function (image) return image:Width() / 2 end, 
                                     function (image) return image:Height() / 2 end)

function im.ProcessCropNew (src_image, xmin, xmax, ymin, ymax)
  local width = xmax - xmin + 1
  local height = xmax - ymin + 1
  local dst_image = im.ImageCreateBased(src_image, width, height)
  im.ProcessCrop(src_image, dst_image, xmin, ymin)
  return dst_image
end

TwoSourcesOneDest("ProcessInsert")

function im.ProcessAddMarginsNew (src_image, xmin, xmax, ymin, ymax)
  local width = xmax - xmin + 1
  local height = xmax - ymin + 1
  local dst_image = im.ImageCreateBased(src_image, width, height)
  im.ProcessAddMargins(src_image, dst_image, xmin, ymin)
  return dst_image
end

function im.ProcessRotateNew (src_image, cos0, sin0, order)
  local width, height = im.ProcessCalcRotateSize(src_image:Width(), src_image:Height(), cos0, sin0)
  local dst_image = im.ImageCreateBased(src_image, width, height)
  return im.ProcessRotate(src_image, dst_image, cos0, sin0, order), dst_image
end

OneSourceOneDest("ProcessRotateRef")
OneSourceOneDest("ProcessRotate90", function (image) return image:Height() end, function (image) return image:Width() end)
OneSourceOneDest("ProcessRotate180")
OneSourceOneDest("ProcessMirror")
OneSourceOneDest("ProcessFlip")
OneSourceOneDest("ProcessRadial")
OneSourceOneDest("ProcessGrayMorphConvolve")
OneSourceOneDest("ProcessGrayMorphErode")
OneSourceOneDest("ProcessGrayMorphDilate")
OneSourceOneDest("ProcessGrayMorphOpen")
OneSourceOneDest("ProcessGrayMorphClose")
OneSourceOneDest("ProcessGrayMorphTopHat")
OneSourceOneDest("ProcessGrayMorphWell")
OneSourceOneDest("ProcessGrayMorphGradient")
OneSourceOneDest("ProcessBinMorphConvolve")
OneSourceOneDest("ProcessBinMorphErode")
OneSourceOneDest("ProcessBinMorphDilate")
OneSourceOneDest("ProcessBinMorphOpen")
OneSourceOneDest("ProcessBinMorphClose")
OneSourceOneDest("ProcessBinMorphOutline")
OneSourceOneDest("ProcessBinMorphThin")
OneSourceOneDest("ProcessMedianConvolve")
OneSourceOneDest("ProcessRangeConvolve")
OneSourceOneDest("ProcessRankClosestConvolve")
OneSourceOneDest("ProcessRankMaxConvolve")
OneSourceOneDest("ProcessRankMinConvolve")
OneSourceOneDest("ProcessConvolve")
OneSourceOneDest("ProcessConvolveSep")
OneSourceOneDest("ProcessConvolveRep")
OneSourceOneDest("ProcessConvolveDual")
OneSourceOneDest("ProcessCompassConvolve")
OneSourceOneDest("ProcessMeanConvolve")
OneSourceOneDest("ProcessGaussianConvolve")
OneSourceOneDest("ProcessBarlettConvolve")
OneSourceTwoDests("ProcessInterlaceSplit", nil, function (image) if (image:Height()) then return image:Height() else return image:Height()/2 end end)

function im.ProcessInterlaceSplitNew(src_image)
  -- create destination image
  local dst_height1 = src_image:Height()/2
  if math.mod(src_image:Height(), 2) then
    dst_height1 = dst_height1 + 1
  end
  
  local dst_image1 = im.ImageCreateBased(src_image, nil, dst_height1)
  local dst_image2 = im.ImageCreateBased(src_image, nil, src_image:Height()/2)

  -- call method, repassing all parameters
  im.ProcessInterlaceSplit(src_image, dst_image1, dst_image2)
  return dst_image1, dst_image2
end

local function int_datatype (image)
  local data_type = image:DataType()
  if data_type == im.BYTE or data_type == im.USHORT then
    data_type = im.INT
  end
  return data_type
end

OneSourceOneDest("ProcessDiffOfGaussianConvolve", nil, nil, nil, int_datatype)
OneSourceOneDest("ProcessLapOfGaussianConvolve", nil, nil, nil, int_datatype)
OneSourceOneDest("ProcessSobelConvolve")
OneSourceOneDest("ProcessSplineEdgeConvolve")
OneSourceOneDest("ProcessPrewittConvolve")
OneSourceOneDest("ProcessZeroCrossing")
OneSourceOneDest("ProcessCanny")
OneSourceOneDest("ProcessUnArithmeticOp")
TwoSourcesOneDest("ProcessArithmeticOp")

function im.ProcessArithmeticConstOpNew (src_image, src_const, op)
  local dst_image = im.ImageCreateBased(src_image)
  im.ProcessArithmeticConstOp(src_image, src_const, dst_image, op)
  return dst_image
end

TwoSourcesOneDest("ProcessBlendConst")
ThreeSourcesOneDest("ProcessBlend")
OneSourceTwoDests("ProcessSplitComplex")
TwoSourcesOneDest("ProcessMergeComplex", nil, nil, nil, im.CFLOAT)

function im.ProcessMultipleMeanNew (src_image_list, dst_image)
  local dst_image = im.ImageCreateBased(src_image_list[1])
  im.ProcessMultipleMean(src_image_list, dst_image)
  return dst_image
end

function im.ProcessMultipleStdDevNew (src_image_list, mean_image)
  local dst_image = im.ImageCreateBased(src_image_list[1])
  im.ProcessMultipleStdDev(src_image_list, mean_image, dst_image)
  return dst_image
end

TwoSourcesOneDest("ProcessAutoCovariance")
OneSourceOneDest("ProcessMultiplyConj")
OneSourceOneDest("ProcessQuantizeRGBUniform", nil, nil, im.MAP, nil)
OneSourceOneDest("ProcessQuantizeGrayUniform")
OneSourceOneDest("ProcessExpandHistogram")
OneSourceOneDest("ProcessEqualizeHistogram")

function im.ProcessSplitYChromaNew (src_image)
  local y_image = im.ImageCreateBased(src_image, nil, nil, im.GRAY, im.BYTE)
  local chroma_image = im.ImageCreateBased(src_image, nil, nil, im.RGB, im.BYTE)
  im.ProcessSplitYChroma(src_image, y_image, chroma_image)
  return y_image, chroma_image
end

OneSourceThreeDests("ProcessSplitHSI", nil, nil, im.GRAY, im.FLOAT)
ThreeSourcesOneDest("ProcessMergeHSI", nil, nil, im.RGB, im.BYTE)

function im.ProcessSplitComponentsNew (src_image)
  local depth = src_image:Depth()
  local dst_images = {}
  for i = 1, depth do
    table.insert(dst_images, im.ImageCreateBased(src_image, nil, nil, im.GRAY))
  end
  im.ProcessSplitComponents(src_image, dst_images)
  return unpack(dst_images)
end

function im.ProcessMergeComponentsNew (src_image_list)
  local dst_image = im.ImageCreateBased(src_image_list[1], nil, nil, im.RGB)
  im.ProcessMergeComponents(src_image_list, dst_image)
  return dst_image
end

OneSourceOneDest("ProcessNormalizeComponents", nil, nil, nil, im.FLOAT)
OneSourceOneDest("ProcessReplaceColor")
TwoSourcesOneDest("ProcessBitwiseOp")
OneSourceOneDest("ProcessBitwiseNot")
OneSourceOneDest("ProcessBitMask")
OneSourceOneDest("ProcessBitPlane")
OneSourceOneDest("ProcessToneGamut")
OneSourceOneDest("ProcessUnNormalize", nil, nil, nil, im.BYTE)
OneSourceOneDest("ProcessDirectConv", nil, nil, nil, im.BYTE)
OneSourceOneDest("ProcessNegative")
OneSourceOneDest("ProcessRangeContrastThreshold", nil, nil, im.BINARY, nil)
OneSourceOneDest("ProcessLocalMaxThreshold", nil, nil, im.BINARY, nil)
OneSourceOneDest("ProcessThreshold", nil, nil, im.BINARY, nil)
TwoSourcesOneDest("ProcessThresholdByDiff")
OneSourceOneDest("ProcessHysteresisThreshold", nil, nil, im.BINARY, nil)
OneSourceOneDest("ProcessUniformErrThreshold", nil, nil, im.BINARY, nil)
OneSourceOneDest("ProcessDifusionErrThreshold")
OneSourceOneDest("ProcessPercentThreshold")
OneSourceOneDest("ProcessOtsuThreshold")
OneSourceOneDest("ProcessMinMaxThreshold", nil, nil, im.BINARY, nil)
OneSourceOneDest("ProcessSliceThreshold", nil, nil, im.BINARY, nil)
OneSourceOneDest("ProcessPixelate")
OneSourceOneDest("ProcessPosterize")

----------------------------------------------------
-- The main porpouse of this file is to build linux gcc makefiles.
-- Must have Premake version 3 installed.
-- Original Premake was changed to remove some parameters and add others.
-- Default parameters:
--   premake3s --target gnu --os linux
-- But it can build windows gcc makefiles, and visual studio projects.
--   premake3s --target gnu --os windows
--   premake3s --target gnu --os macosx
--   premake3s --target vs6
--   premake3s --target vs2002
--   premake3s --target vs2003
--   premake3s --target vs2005
-- In Linux the generated makefiles will not correctly build libraries in 64-bits.
--              must add "-m64 -fPIC" flags
----------------------------------------------------

if (not options.target) then 
  options.target = "gnu"
end

if (not options.os) then
  if (options.target ~= "gnu") then
    options.os = "windows"
  else
    options.os = "linux"
  end
end

function fixPackagePath(package_files)
  if (options.os ~= "linux") then
    for i, file in package_files do 
      package_files[i] = "../src/"..file 
    end
  end
end

----------------------------------------------------

project.name = "im"
project.bindir = "../bin"
project.libdir = "../lib"

if (options.os ~= "linux") then
  if (options.os == "macosx") then
	project.path = "../mak.macosx"
  else
	project.path = "../mak."..options.target
  end
end

----------------------------------------------------

package = newpackage()
package.name = "im"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "lib"
package.buildflags = { "static-runtime" }

package.files =
{
  matchfiles("libtiff/*.c"),
  matchfiles("libjpeg/*.c"),
  matchfiles("liblzf/*.c"),
  matchfiles("zlib/*.c"),
  "libpng/png.c",      "libpng/pngget.c",   "libpng/pngread.c",  "libpng/pngrutil.c", "libpng/pngwtran.c",  
  "libpng/pngerror.c", "libpng/pngmem.c",   "libpng/pngrio.c",   "libpng/pngset.c",   "libpng/pngwio.c",    
  "libpng/pngpread.c", "libpng/pngrtran.c", "libpng/pngtrans.c", "libpng/pngwrite.c", "libpng/pngwutil.c",  
  matchfiles("libexif/canon/*.c"),
  matchfiles("libexif/olympus/*.c"),
  matchfiles("libexif/pentax/*.c"),
  matchfiles("libexif/*.c"),
  "old_imcolor.c",         "old_imresize.c",      "tiff_binfile.c",       "im_converttype.cpp",
  "im_attrib.cpp",         "im_format.cpp",       "im_format_tga.cpp",    "im_filebuffer.cpp", 
  "im_bin.cpp",            "im_format_all.cpp",   "im_format_tiff.cpp",   "im_format_raw.cpp", 
  "im_binfile.cpp",        "im_format_sgi.cpp",   "im_datatype.cpp",      "im_format_pcx.cpp", 
  "im_colorhsi.cpp",       "im_format_bmp.cpp",   "im_image.cpp",         "im_rgb2map.cpp",    
  "im_colormode.cpp",      "im_format_gif.cpp",   "im_lib.cpp",           "im_format_pnm.cpp", 
  "im_colorutil.cpp",      "im_format_ico.cpp",   "im_palette.cpp",       "im_format_png.cpp", 
  "im_convertbitmap.cpp",  "im_format_led.cpp",   "im_counter.cpp",       "im_str.cpp",        
  "im_convertcolor.cpp",   "im_format_jpeg.cpp",  "im_fileraw.cpp",       "im_format_krn.cpp", 
  "im_file.cpp",           "im_format_ras.cpp",   "old_im.cpp",           "im_compress.cpp",   
}

package.includepaths = { ".", "../include", "libtiff", "libjpeg", "libexif", "libpng", "zlib" }
package.defines = { "JPEG_SUPPORT", "ZIP_SUPPORT", "OJPEG_SUPPORT", "PIXARLOG_SUPPORT", "PNG_NO_STDIO", "PNG_TIME_RFC1123_SUPPORTED" }

if (options.os == "windows") then
  tinsert(package.files, {"im_sysfile_win32.cpp", "im_dib.cpp", "im_dibxbitmap.cpp"})
  
  if (options.target ~= "gnu") then
    -- optimize PNG lib for VC
    tinsert(package.files, "libpng/pngvcrd.c")
    tinsert(package.defines, "PNG_USE_PNGVCRD")
  end
else
  tinsert(package.files, "im_sysfile_unix.cpp")
  
  if (options.os == "linux") then
    --package.buildoptions = { "-W -Wall -ansi -pedantic" }
    
    -- optimize PNG lib for Linux in x86
    tinsert(package.files, "libpng/pnggccrd.c")
    tinsert(package.defines, "PNG_USE_PNGGCCRD")
  end
end      

fixPackagePath(package.files)

---------------------------------------------------------------------

package = newpackage()
package.name = "im_process"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "lib"
package.buildflags = { "static-runtime" }

package.files =
{
  "process/im_arithmetic_bin.cpp",  "process/im_morphology_gray.cpp",  "process/im_quantize.cpp", 
  "process/im_arithmetic_un.cpp",  "process/im_geometric.cpp",  "process/im_render.cpp",
  "process/im_color.cpp",  "process/im_histogram.cpp",  "process/im_resize.cpp",
  "process/im_convolve.cpp",  "process/im_houghline.cpp",  "process/im_statistics.cpp",
  "process/im_convolve_rank.cpp",  "process/im_logic.cpp",  "process/im_threshold.cpp",
  "process/im_effects.cpp",  "process/im_morphology_bin.cpp",  "process/im_tonegamut.cpp",
  "process/im_canny.cpp",  "process/im_distance.cpp",  "process/im_analyze.cpp"
}
fixPackagePath(package.files)

package.includepaths = { "../include" }

---------------------------------------------------------------------

package = newpackage()
package.name = "im_jp2"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "lib"
package.buildflags = { "static-runtime" }

package.files =
{
  matchfiles("libjasper/base/*.c", "libjasper/jp2/*.c", "libjasper/jpc/*.c"),
  "jas_binfile.c", "im_format_jp2.cpp"
}
fixPackagePath(package.files)

package.includepaths = { "../include", "libjasper" }
package.defines = { "EXCLUDE_JPG_SUPPORT", "EXCLUDE_MIF_SUPPORT", "EXCLUDE_PNM_SUPPORT",  
                    "EXCLUDE_BMP_SUPPORT", "EXCLUDE_PGX_SUPPORT", "EXCLUDE_RAS_SUPPORT",
                    "EXCLUDE_TIFF_SUPPORT", "JAS_GEO_OMIT_PRINTING_CODE" }
         
tinsert(package.defines, "JAS_TYPES")

if (options.os == "linux") then
  tinsert(package.defines, "HAVE_UNISTD_H")
end
           
---------------------------------------------------------------------

package = newpackage()
package.name = "imlua3"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "lib"
package.buildflags = { "static-runtime" }

package.files =
{
  "im_lua3.c"
}
fixPackagePath(package.files)

package.includepaths = { "../include", "$(LUA3)/include", "$(CD)/include" }

---------------------------------------------------------------------

package = newpackage()
package.name = "im_fftw"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "lib"
package.buildflags = { "static-runtime" }

package.files =
{
  matchfiles("fftw/*.c"),
  "process/im_fft.cpp"
}
fixPackagePath(package.files)

package.includepaths = { "../include", "fftw" }
package.defines = { "FFTW_ENABLE_FLOAT" }

---------------------------------------------------------------------

package = newpackage()
package.name = "im_fftw3"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "lib"
package.buildflags = { "static-runtime" }

package.files =
{
  matchfiles("fftw3/api/*.c"),
  matchfiles("fftw3/reodft/*.c"),
  matchfiles("fftw3/kernel/*.c"),
  matchfiles("fftw3/dft/*.c", "fftw3/dft/codelets/*.c", "fftw3/dft/codelets/inplace/*.c", "fftw3/dft/codelets/standard/*.c"),
  matchfiles("fftw3/rdft/*.c", "fftw3/rdft/codelets/*.c", "fftw3/rdft/codelets/hc2r/*.c", "fftw3/rdft/codelets/r2hc/*.c", "fftw3/rdft/codelets/r2r/*.c"),
  "process/im_fft.cpp"
}
fixPackagePath(package.files)

package.includepaths = { "../include", "fftw3/kernel", "fftw3/dft", "fftw3/rdft", "fftw3/api", 
                         "fftw3/reodft", "fftw3/rdft/codelets", "fftw3/dft/codelets" }
package.defines = { "USE_FFTW3" }

if (options.os == "windows") then
  if (options.target == "gnu") then
    tinsert(package.defines, "HAVE_UINTPTR_T")
  end
end

---------------------------------------------------------------------

package = newpackage()
package.name = "imlua51"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "lib"
package.buildflags = { "static-runtime" }

package.files =
{
  "lua5/imlua.c", "lua5/imlua_aux.c", "lua5/imlua_convert.c", "lua5/imlua_file.c", 
  "lua5/imlua_image.c", "lua5/imlua_palette.c", "lua5/imlua_util.c"
}
fixPackagePath(package.files)

package.includepaths = { "../include", "lua5", "$(LUA51)/include" }

---------------------------------------------------------------------

package = newpackage()
package.name = "imlua_cd51"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "lib"
package.buildflags = { "static-runtime" }

package.files =
{
  "lua5/imlua_cd.c"
}
fixPackagePath(package.files)

package.includepaths = { "../include", "lua5", "$(LUA51)/include", "$(CD)/include" }

---------------------------------------------------------------------

package = newpackage()
package.name = "imlua_process51"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "lib"
package.buildflags = { "static-runtime" }

package.files =
{
  "lua5/imlua_process.c"
}
fixPackagePath(package.files)

package.includepaths = { "../include", "lua5", "$(LUA51)/include" }

---------------------------------------------------------------------

package = newpackage()
package.name = "imlua_capture51"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "lib"
package.buildflags = { "static-runtime" }

package.files =
{
  "lua5/imlua_capture.c"
}
fixPackagePath(package.files)

package.includepaths = { "../include", "lua5", "$(LUA51)/include" }

---------------------------------------------------------------------

package = newpackage()
package.name = "imlua_fftw51"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "lib"
package.buildflags = { "static-runtime" }

package.files =
{
  "lua5/imlua_fftw.c"
}
fixPackagePath(package.files)

package.includepaths = { "../include", "lua5", "$(LUA51)/include" }

---------------------------------------------------------------------
----------------------------------------------------
-- The main porpouse of this file is to build linux gcc makefiles.
-- Must have Premake version 3 installed.
-- Original Premake was changed to remove some parameters and add others.
-- Default parameters:
--   premake3s --target gnu --os linux
-- But it can build windows gcc makefiles, and visual studio projects.
--   premake3s --target gnu --os windows
--   premake3s --target gnu --os macosx
--   premake3s --target vs6
--   premake3s --target vs2002
--   premake3s --target vs2003
--   premake3s --target vs2005
-- In Linux the generated makefiles will not correctly build libraries in 64-bits.
--              must add "-m64 -fPIC" flags
----------------------------------------------------

if (not options.target) then 
  options.target = "gnu"
end

if (not options.os) then
  if (options.target ~= "gnu") then
    options.os = "windows"
  else
    options.os = "linux"
  end
end

function fixPackagePath(package_files)
  if (options.os ~= "linux") then
    for i, file in package_files do 
      package_files[i] = "../src/"..file 
    end
  end
end

function tremove(t, value)
  local index = -1
  function f(i, v)
    if (v == value) then
      index = i
    end
  end
  table.foreachi(t, f)
  if (index ~= -1) then
    table.remove(t, index)
  end
end

----------------------------------------------------

project.name = "iup"
project.bindir = "../bin"
project.libdir = "../lib"

if (options.os ~= "linux") then
  if (options.os == "macosx") then
	project.path = "../mak.macosx"
  else
	project.path = "../mak."..options.target
  end
end

----------------------------------------------------

package = newpackage()
package.name = "iup"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "lib"
package.buildflags = { "static-runtime" }

package.files =
{
  matchfiles("*.c")
}

package.includepaths = { ".", "../include" }

if (options.os == "windows") then
  tinsert(package.files, matchfiles("win/*.c"))
  tinsert(package.includepaths, {"win"})
  package.defines = {"_WIN32_WINNT=0x0400"}
else
  tinsert(package.files, matchfiles("mot/*.c"))
  tremove(package.files[2], "mot/ComboBox1.c")
  tinsert(package.includepaths, {"mot", "/usr/X11R6/include"})
  package.defines = {"LINUX"}
end

fixPackagePath(package.files)

----------------------------------------------------
----------------------------------------------------
-- The main porpouse of this file is to build linux gcc makefiles.
-- Must have Premake version 3 installed.
-- Original Premake was changed to remove some parameters and add others.
-- Default parameters:
--   premake3s --target gnu --os linux
-- But it can build windows gcc makefiles, and visual studio projects.
--   premake3s --target gnu --os windows
--   premake3s --target gnu --os macosx
--   premake3s --target vs6
--   premake3s --target vs2002
--   premake3s --target vs2003
--   premake3s --target vs2005
-- In Linux the generated makefiles will not correctly build libraries in 64-bits.
--              must add "-m64 -fPIC" flags
----------------------------------------------------

if (not options.target) then 
  options.target = "gnu"
end

if (not options.os) then
  if (options.target ~= "gnu") then
    options.os = "windows"
  else
    options.os = "linux"
  end
end

function fixPackagePath(package_files)
  if (options.os ~= "linux") then
    for i, file in package_files do 
      package_files[i] = "../src/"..file 
    end
  end
end

----------------------------------------------------

project.name = "iup"
project.bindir = "../bin"
project.libdir = "../lib"

if (options.os ~= "linux") then
  if (options.os == "macosx") then
	project.path = "../mak.macosx"
  else
	project.path = "../mak."..options.target
  end
end

----------------------------------------------------

package = newpackage()
package.name = "iupcontrols"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "lib"
package.buildflags = { "static-runtime" }

package.files =
{
  matchfiles("*.c"),
  matchfiles("mask/*.c"),
  matchfiles("matrix/*.c"),
  matchfiles("tree/*.c"),
  matchfiles("color/*.c")
}

package.includepaths = { ".", "../include", "../src", "$(CD)/include" }

if (options.os == "linux") then
  package.defines = { "_MOTIF_" }
  tinsert(package.includepaths, {"/usr/X11R6/include"})
end

fixPackagePath(package.files)

----------------------------------------------------
----------------------------------------------------
-- The main porpouse of this file is to build linux gcc makefiles.
-- Must have Premake version 3 installed.
-- Original Premake was changed to remove some parameters and add others.
-- Default parameters:
--   premake3s --target gnu --os linux
-- But it can build windows gcc makefiles, and visual studio projects.
--   premake3s --target gnu --os windows
--   premake3s --target gnu --os macosx
--   premake3s --target vs6
--   premake3s --target vs2002
--   premake3s --target vs2003
--   premake3s --target vs2005
-- In Linux the generated makefiles will not correctly build libraries in 64-bits.
--              must add "-m64 -fPIC" flags
----------------------------------------------------

if (not options.target) then 
  options.target = "gnu"
end

if (not options.os) then
  if (options.target ~= "gnu") then
    options.os = "windows"
  else
    options.os = "linux"
  end
end

function fixPackagePath(package_files)
  if (options.os ~= "linux") then
    for i, file in package_files do 
      package_files[i] = "../src/"..file 
    end
  end
end

----------------------------------------------------

project.name = "iup"
project.bindir = "../bin"
project.libdir = "../lib"

if (options.os ~= "linux") then
  if (options.os == "macosx") then
	project.path = "../mak.macosx"
  else
	project.path = "../mak."..options.target
  end
end

----------------------------------------------------

package = newpackage()
package.name = "iupgl"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "lib"
package.buildflags = { "static-runtime" }

package.includepaths = { ".", "../include" }

if (options.os == "windows") then
  package.files = { "iupglw.c" }
else
  package.files = { "iupglx.c", "GL/GLwMDrawA.c" }
  tinsert(package.includepaths, {"/usr/X11R6/include"})
end

fixPackagePath(package.files)

----------------------------------------------------
----------------------------------------------------
-- The main porpouse of this file is to build linux gcc makefiles.
-- Must have Premake version 3 installed.
-- Original Premake was changed to remove some parameters and add others.
-- Default parameters:
--   premake3s --target gnu --os linux
-- But it can build windows gcc makefiles, and visual studio projects.
--   premake3s --target gnu --os windows
--   premake3s --target gnu --os macosx
--   premake3s --target vs6
--   premake3s --target vs2002
--   premake3s --target vs2003
--   premake3s --target vs2005
-- In Linux the generated makefiles will not correctly build libraries in 64-bits.
--              must add "-m64 -fPIC" flags
----------------------------------------------------

if (not options.target) then 
  options.target = "gnu"
end

if (not options.os) then
  if (options.target ~= "gnu") then
    options.os = "windows"
  else
    options.os = "linux"
  end
end

function fixPackagePath(package_files)
  if (options.os ~= "linux") then
    for i, file in package_files do 
      package_files[i] = "../src/"..file 
    end
  end
end

----------------------------------------------------

project.name = "iup"
project.bindir = "../bin"
project.libdir = "../lib"

if (options.os ~= "linux") then
  if (options.os == "macosx") then
	project.path = "../mak.macosx"
  else
	project.path = "../mak."..options.target
  end
end

----------------------------------------------------

package = newpackage()
package.name = "iupim"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "lib"
package.buildflags = { "static-runtime" }

package.includepaths = { ".", "../include", "$(IM)/include" }

package.files = { "iupim.c" }

fixPackagePath(package.files)

----------------------------------------------------
----------------------------------------------------
-- The main porpouse of this file is to build linux gcc makefiles.
-- Must have Premake version 3 installed.
-- Original Premake was changed to remove some parameters and add others.
-- Default parameters:
--   premake3s --target gnu --os linux
-- But it can build windows gcc makefiles, and visual studio projects.
--   premake3s --target gnu --os windows
--   premake3s --target gnu --os macosx
--   premake3s --target vs6
--   premake3s --target vs2002
--   premake3s --target vs2003
--   premake3s --target vs2005
-- In Linux the generated makefiles will not correctly build libraries in 64-bits.
--              must add "-m64 -fPIC" flags
----------------------------------------------------

if (not options.target) then 
  options.target = "gnu"
end

if (not options.os) then
  if (options.target ~= "gnu") then
    options.os = "windows"
  else
    options.os = "linux"
  end
end

function fixPackagePath(package_files)
  if (options.os ~= "linux") then
    for i, file in package_files do 
      package_files[i] = "../src/"..file 
    end
  end
end

----------------------------------------------------

project.name = "iup"
project.bindir = "../bin"
project.libdir = "../lib"

if (options.os ~= "linux") then
  if (options.os == "macosx") then
	project.path = "../mak.macosx"
  else
	project.path = "../mak."..options.target
  end
end

----------------------------------------------------

package = newpackage()
package.name = "ledc"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "exe"

package.files =
{
  "lex.yy.c", "y.tab.c", "main.c"
}

package.includepaths = { "." }

fixPackagePath(package.files)

----------------------------------------------------
-- Utilities

function printvars()
  local n,v = nextvar(nil)
  print("--printvars Start--")
  while n ~= nil do
    print(tostring(n).."="..tostring(v))
    n,v = nextvar(n)
  end
  print("--printvars End--")
end

function printtable(t)
  local n,v = next(t, nil)
  print("--printtable Start--")
  while n ~= nil do
    print(tostring(n).."="..tostring(v))
    n,v = next(t, n)
  end
  print("--printtable End--")
end

function print_version_info()
  print(_VERSION .. " " .. iup._LUA_COPYRIGHT)
  if (im) then print(im._VERSION .. " " .. im._COPYRIGHT) end
  if (cd and cd._VERSION) then print(cd._VERSION .. " " .. cd._COPYRIGHT) end
  print(iup._VERSION .. " " .. iup._COPYRIGHT)
  print("")
  print("IUP Info")
  print("  System: " .. iup.GetGlobal("SYSTEM"))
  print("  System Version: " .. iup.GetGlobal("SYSTEMVERSION"))
  local mot = iup.GetGlobal("MOTIFVERSION")
  if (mot) then print("  Motif Version: ", mot) end
  print("  Screen Size: " .. iup.GetGlobal("SCREENSIZE"))
  print("  Screen Depth: " .. iup.GetGlobal("SCREENDEPTH"))
  if (iup.GL_VENDOR) then print("  OpenGL Vendor: " .. iup.GL_VENDOR) end
  if (iup.GL_RENDERER) then print("  OpenGL Renderer: " .. iup.GL_RENDERER) end
  if (iup.GL_VERSION) then print("  OpenGL Version: " .. iup.GL_VERSION) end
end

-- IUPLUA Full Application  

lastfile = nil -- Last file open

mulCommands = iupmultiline{expand=IUP_YES, size="200x120", font="COURIER_NORMAL_10"}   
poslabel    = iuplabel{title="0:0", size="50x"} 
filelabel   = iuplabel{title="", size="50x", expand="HORIZONTAL"} 

mulCommands.caretcb = function(self, lin, col)
   poslabel.title = lin..":"..col
end

butExecute = iupbutton{size="50x15", title = "Execute", action="dostring(mulCommands.value)"}
butClearCommands = iupbutton{size="50x15", title = "Clear", action = "mulCommands.value = ''  filelabel.title = ''  lastfile = nil"}
butLoadFile = iupbutton{size="50x15", title = "Load..."}
butSaveasFile = iupbutton{size="50x15", title = "Save As..."}
butSaveFile = iupbutton{size="50x15", title = "Save"}

function butSaveFile:action()
  if (lastfile == nil) then
    butSaveasFile:action() 
  else
    novoarq = openfile (lastfile, "w+")
    if (novoarq ~= nil) then
      write (novoarq,mulCommands.value)
      closefile (novoarq) 
    else
      error ("Cannot Save file "..filename)
    end
  end
end

function butSaveasFile:action()
  local filedlg = iupfiledlg{dialogtype = "SAVE", title = "Save File", filter = "*.lua", filterinfo = "Lua files",allownew=yes}
  IupPopup(filedlg,IUP_LEFT, IUP_LEFT)
  local status = filedlg.status
  lastfile = filedlg.value
  filelabel.title = lastfile
  IupDestroy(filedlg)
  if status ~= "-1" then 
    if (lastfile == nil) then
      error ("Cannot Save file "..lastfile)
    end
    local novoarq = openfile (lastfile, "w+")
    if (novoarq ~= nil) then
      write (novoarq,mulCommands.value)
      closefile (novoarq)
    else
      error ("Cannot Save file")
    end
  end
end

function butLoadFile:action()
  local filedlg = iupfiledlg{dialogtype="OPEN", title="Load File", filter="*.lua", filterinfo="Lua Files", allownew="NO"}
  filedlg:popup(IUP_CENTER, IUP_CENTER)
  local status = filedlg.status
  local newfile = filedlg.value
  IupDestroy(filedlg)
  if (status == "-1") or (status == "1") then 
    if (status == "1") then
      error ("Cannot load file "..newfile)
    end
  else
    local fp = openfile (newfile, "r")
    if (fp == nil) then
      error ("Cannot load file "..newfile)
    else
      mulCommands.value = read (fp,"*a") 
      closefile (fp) 
      lastfile = newfile
      filelabel.title = lastfile
    end
  end
end

vbxConsole = iupvbox 
{
  iupframe{iuphbox{iupvbox{butLoadFile, butSaveFile, butSaveasFile, butClearCommands, butExecute; margin="0x0", gap="10"}, iupvbox{filelabel, mulCommands, poslabel; alignment="ARIGHT"}; alignment="ATOP"}; title="Commands"}
  ;alignment="ACENTER", margin="5x5", gap="5" 
}

-- Main Menu Definition.

mnuMain = iupmenu
{
  iupsubmenu
  {
    iupmenu
    {
      iupitem{title="Exit", action="return IUP_CLOSE"}
    }; title="File"
  },
  iupsubmenu{iupmenu
  {
    iup.item{title="Print Version Info...", action=print_version_info},
    iupitem{title="About...", action="dlgAbout:popup(IUP_CENTER, IUP_CENTER)"}
  };title="Help"}
}

-- Main Dialog Definition.

dlgMain = iupdialog{vbxConsole; title="Complete IupLua3 Interpreter", menu=mnuMain, close_cb = "return IUP_CLOSE"}

-- About Dialog Definition.

dlgAbout = iupdialog 
{
  iupvbox
  {
    iuplabel{title="Complete IupLua3 Interpreter"}, 
    iupfill{size="5"},
    iupfill{size="5"},
    iupframe
    {
       iupvbox
       {
          iuplabel{title="Tecgraf/PUC-Rio"},
          iuplabel{title="Mark/Ovídio/Scuri"},
          iuplabel{title="iup@tecgraf.puc-rio.br"} 
       }
    },
    iupfill{size="5"},
    iupbutton{title="OK", action="return IUP_CLOSE", size="50X20"} 
    ;margin="10x10", alignment="ACENTER" 
  }
  ;maxbox=IUP_NO, minbox=IUP_NO, resize=IUP_NO, title="About"
}

-- Displays the Main Dialog 

dlgMain:show()

IupMainLoop()

IupDestroy(dlgMain)
IupDestroy(dlgAbout)

-- #################################################################################
--                                     Constants
-- #################################################################################


IUP_ERROR     = 1           iup.ERROR     = IUP_ERROR     
IUP_NOERROR   = 0           iup.NOERROR   = IUP_NOERROR   
IUP_OPENED    = -1          iup.OPENED    = IUP_OPENED    
IUP_INVALID   = -1          iup.INVALID   = IUP_INVALID
                  
IUP_CENTER   = 65535        iup.CENTER    = IUP_CENTER 
IUP_LEFT     = 65534		iup.LEFT      = IUP_LEFT   
IUP_RIGHT    = 65533		iup.RIGHT     = IUP_RIGHT  
IUP_MOUSEPOS = 65532        iup.MOUSEPOS  = IUP_MOUSEPOS
IUP_CURRENT  = 65531		iup.CURRENT   = IUP_CURRENT 
IUP_CENTERPARENT = 65530    iup.CENTERPARENT = IUP_CENTERPARENT
IUP_TOP      = IUP_LEFT     iup.TOP       = IUP_TOP   
IUP_BOTTOM   = IUP_RIGHT	iup.BOTTOM    = IUP_BOTTOM
IUP_ANYWHERE = IUP_CURRENT  iup.ANYWHERE  = IUP_ANYWHERE

IUP_BUTTON1   =   49        iup.BUTTON1   = IUP_BUTTON1     -- '1'  
IUP_BUTTON2   =   50        iup.BUTTON2   = IUP_BUTTON2     -- '2'  
IUP_BUTTON3   =   51        iup.BUTTON3   = IUP_BUTTON3     -- '3'  
IUP_BUTTON4   =   52        iup.BUTTON4   = IUP_BUTTON4     -- '4'  
IUP_BUTTON5   =   53        iup.BUTTON5   = IUP_BUTTON5     -- '5'  
                  
IUP_IGNORE    = -1          iup.IGNORE    = IUP_IGNORE    
IUP_DEFAULT   = -2          iup.DEFAULT   = IUP_DEFAULT   
IUP_CLOSE     = -3          iup.CLOSE     = IUP_CLOSE     
IUP_CONTINUE  = -4          iup.CONTINUE  = IUP_CONTINUE  
                  
IUP_SBUP      = 0           iup.SBUP      = IUP_SBUP      
IUP_SBDN      = 1           iup.SBDN      = IUP_SBDN      
IUP_SBPGUP    = 2           iup.SBPGUP    = IUP_SBPGUP    
IUP_SBPGDN    = 3           iup.SBPGDN    = IUP_SBPGDN    
IUP_SBPOSV    = 4           iup.SBPOSV    = IUP_SBPOSV    
IUP_SBDRAGV   = 5           iup.SBDRAGV   = IUP_SBDRAGV   
IUP_SBLEFT    = 6           iup.SBLEFT    = IUP_SBLEFT    
IUP_SBRIGHT   = 7           iup.SBRIGHT   = IUP_SBRIGHT   
IUP_SBPGLEFT  = 8           iup.SBPGLEFT  = IUP_SBPGLEFT  
IUP_SBPGRIGHT = 9           iup.SBPGRIGHT = IUP_SBPGRIGHT 
IUP_SBPOSH    = 10          iup.SBPOSH    = IUP_SBPOSH    
IUP_SBDRAGH   = 11          iup.SBDRAGH   = IUP_SBDRAGH   
                  
IUP_SHOW      = 0           iup.SHOW      = IUP_SHOW      
IUP_RESTORE   = 1           iup.RESTORE   = IUP_RESTORE   
IUP_MINIMIZE  = 2           iup.MINIMIZE  = IUP_MINIMIZE  
IUP_MAXIMIZE  = 3           iup.MAXIMIZE  = IUP_MAXIMIZE
IUP_HIDE      = 4           iup.HIDE      = IUP_HIDE

RED    = IupRGB(1, 0, 0)    iup.RED    = RED    
GREEN  = IupRGB(0, 1, 0)    iup.GREEN  = GREEN  
BLUE   = IupRGB(0, 0, 1)    iup.BLUE   = BLUE   
BLACK  = IupRGB(0, 0, 0)    iup.BLACK  = BLACK  
WHITE  = IupRGB(1, 1, 1)    iup.WHITE  = WHITE  
YELLOW = IupRGB(1, 1, 0)    iup.YELLOW = YELLOW 

IUP_ON =        "ON"           iup.ON =        IUP_ON
IUP_OFF =       "OFF"          iup.OFF =       IUP_OFF
IUP_YES =       "YES"          iup.YES =       IUP_YES
IUP_NO =        "NO"           iup.NO =        IUP_NO
IUP_APPEND =    "APPEND"       iup.APPEND =    IUP_APPEND
IUP_VERTICAL =  "VERTICAL"     iup.VERTICAL =  IUP_VERTICAL
IUP_HORIZONTAL ="HORIZONTAL"   iup.HORIZONTAL =IUP_HORIZONTAL
                    
IUP_ACENTER =   "ACENTER"      iup.ACENTER =   IUP_ACENTER
IUP_ALEFT =     "ALEFT"        iup.ALEFT =     IUP_ALEFT
IUP_ARIGHT =    "ARIGHT"       iup.ARIGHT =    IUP_ARIGHT
IUP_ATOP =      "ATOP"         iup.ATOP =      IUP_ATOP
IUP_ABOTTOM =   "ABOTTOM"      iup.ABOTTOM =   IUP_ABOTTOM
                    
IUP_NORTH =     "NORTH"        iup.NORTH =     IUP_NORTH
IUP_SOUTH =     "SOUTH"        iup.SOUTH =     IUP_SOUTH
IUP_WEST =      "WEST"         iup.WEST =      IUP_WEST
IUP_EAST =      "EAST"         iup.EAST =      IUP_EAST
IUP_NE =        "NE"           iup.NE =        IUP_NE
IUP_SE =        "SE"           iup.SE =        IUP_SE
IUP_NW =        "NW"           iup.NW =        IUP_NW
IUP_SW =        "SW"           iup.SW =        IUP_SW
                    
IUP_FULL =      "FULL"         iup.FULL =      IUP_FULL
IUP_HALF =      "HALF"         iup.HALF =      IUP_HALF
IUP_THIRD =     "THIRD"        iup.THIRD =     IUP_THIRD
IUP_QUARTER =   "QUARTER"      iup.QUARTER =   IUP_QUARTER
IUP_EIGHTH =    "EIGHTH"       iup.EIGHTH =    IUP_EIGHTH
                    
IUP_ARROW =     "ARROW"        iup.ARROW =     IUP_ARROW
IUP_BUSY =      "BUSY"         iup.BUSY =      IUP_BUSY
IUP_RESIZE_N =  "RESIZE_N"     iup.RESIZE_N =  IUP_RESIZE_N
IUP_RESIZE_S =  "RESIZE_S"     iup.RESIZE_S =  IUP_RESIZE_S
IUP_RESIZE_E =  "RESIZE_E"     iup.RESIZE_E =  IUP_RESIZE_E
IUP_RESIZE_W =  "RESIZE_W"     iup.RESIZE_W =  IUP_RESIZE_W
IUP_RESIZE_NE = "RESIZE_NE"    iup.RESIZE_NE = IUP_RESIZE_NE
IUP_RESIZE_NW = "RESIZE_NW"    iup.RESIZE_NW = IUP_RESIZE_NW
IUP_RESIZE_SE = "RESIZE_SE"    iup.RESIZE_SE = IUP_RESIZE_SE
IUP_RESIZE_SW = "RESIZE_SW"    iup.RESIZE_SW = IUP_RESIZE_SW
IUP_MOVE =      "MOVE"         iup.MOVE =      IUP_MOVE
IUP_HAND =      "HAND"         iup.HAND =      IUP_HAND
IUP_NONE =      "NONE"         iup.NONE =      IUP_NONE
IUP_IUP =       "IUP"          iup.IUP =       IUP_IUP
IUP_CROSS =     "CROSS"        iup.CROSS =     IUP_CROSS
IUP_PEN =       "PEN"          iup.PEN =       IUP_PEN
IUP_TEXT =      "TEXT"         iup.TEXT =      IUP_TEXT
IUP_RESIZE_C =  "RESIZE_C"     iup.RESIZE_C =  IUP_RESIZE_C
IUP_OPENHAND =  "OPENHAND"     iup.OPENHAND =  IUP_OPENHAND

IUP_HELVETICA_NORMAL_8 =   "HELVETICA_NORMAL_8"       iup.HELVETICA_NORMAL_8 =   IUP_HELVETICA_NORMAL_8
IUP_HELVETICA_ITALIC_8 =   "HELVETICA_ITALIC_8"       iup.HELVETICA_ITALIC_8 =   IUP_HELVETICA_ITALIC_8
IUP_HELVETICA_BOLD_8 =     "HELVETICA_BOLD_8"         iup.HELVETICA_BOLD_8 =     IUP_HELVETICA_BOLD_8
IUP_HELVETICA_NORMAL_10 =  "HELVETICA_NORMAL_10"      iup.HELVETICA_NORMAL_10 =  IUP_HELVETICA_NORMAL_10
IUP_HELVETICA_ITALIC_10 =  "HELVETICA_ITALIC_10"      iup.HELVETICA_ITALIC_10 =  IUP_HELVETICA_ITALIC_10
IUP_HELVETICA_BOLD_10 =    "HELVETICA_BOLD_10"        iup.HELVETICA_BOLD_10 =    IUP_HELVETICA_BOLD_10
IUP_HELVETICA_NORMAL_12 =  "HELVETICA_NORMAL_12"      iup.HELVETICA_NORMAL_12 =  IUP_HELVETICA_NORMAL_12
IUP_HELVETICA_ITALIC_12 =  "HELVETICA_ITALIC_12"      iup.HELVETICA_ITALIC_12 =  IUP_HELVETICA_ITALIC_12
IUP_HELVETICA_BOLD_12 =    "HELVETICA_BOLD_12"        iup.HELVETICA_BOLD_12 =    IUP_HELVETICA_BOLD_12
IUP_HELVETICA_NORMAL_14 =  "HELVETICA_NORMAL_14"      iup.HELVETICA_NORMAL_14 =  IUP_HELVETICA_NORMAL_14
IUP_HELVETICA_ITALIC_14 =  "HELVETICA_ITALIC_14"      iup.HELVETICA_ITALIC_14 =  IUP_HELVETICA_ITALIC_14
IUP_HELVETICA_BOLD_14 =    "HELVETICA_BOLD_14"        iup.HELVETICA_BOLD_14 =    IUP_HELVETICA_BOLD_14
IUP_COURIER_NORMAL_8 =     "COURIER_NORMAL_8"         iup.COURIER_NORMAL_8 =     IUP_COURIER_NORMAL_8
IUP_COURIER_ITALIC_8 =     "COURIER_ITALIC_8"         iup.COURIER_ITALIC_8 =     IUP_COURIER_ITALIC_8
IUP_COURIER_BOLD_8 =       "COURIER_BOLD_8"           iup.COURIER_BOLD_8 =       IUP_COURIER_BOLD_8
IUP_COURIER_NORMAL_10 =    "COURIER_NORMAL_10"        iup.COURIER_NORMAL_10 =    IUP_COURIER_NORMAL_10
IUP_COURIER_ITALIC_10 =    "COURIER_ITALIC_10"        iup.COURIER_ITALIC_10 =    IUP_COURIER_ITALIC_10
IUP_COURIER_BOLD_10 =      "COURIER_BOLD_10"          iup.COURIER_BOLD_10 =      IUP_COURIER_BOLD_10
IUP_COURIER_NORMAL_12 =    "COURIER_NORMAL_12"        iup.COURIER_NORMAL_12 =    IUP_COURIER_NORMAL_12
IUP_COURIER_ITALIC_12 =    "COURIER_ITALIC_12"        iup.COURIER_ITALIC_12 =    IUP_COURIER_ITALIC_12
IUP_COURIER_BOLD_12 =      "COURIER_BOLD_12"          iup.COURIER_BOLD_12 =      IUP_COURIER_BOLD_12
IUP_COURIER_NORMAL_14 =    "COURIER_NORMAL_14"        iup.COURIER_NORMAL_14 =    IUP_COURIER_NORMAL_14
IUP_COURIER_ITALIC_14 =    "COURIER_ITALIC_14"        iup.COURIER_ITALIC_14 =    IUP_COURIER_ITALIC_14
IUP_COURIER_BOLD_14 =      "COURIER_BOLD_14"          iup.COURIER_BOLD_14 =      IUP_COURIER_BOLD_14
IUP_TIMES_NORMAL_8 =       "TIMES_NORMAL_8"           iup.TIMES_NORMAL_8 =       IUP_TIMES_NORMAL_8
IUP_TIMES_ITALIC_8 =       "TIMES_ITALIC_8"           iup.TIMES_ITALIC_8 =       IUP_TIMES_ITALIC_8
IUP_TIMES_BOLD_8 =         "TIMES_BOLD_8"             iup.TIMES_BOLD_8 =         IUP_TIMES_BOLD_8
IUP_TIMES_NORMAL_10 =      "TIMES_NORMAL_10"          iup.TIMES_NORMAL_10 =      IUP_TIMES_NORMAL_10
IUP_TIMES_ITALIC_10 =      "TIMES_ITALIC_10"          iup.TIMES_ITALIC_10 =      IUP_TIMES_ITALIC_10
IUP_TIMES_BOLD_10 =        "TIMES_BOLD_10"            iup.TIMES_BOLD_10 =        IUP_TIMES_BOLD_10
IUP_TIMES_NORMAL_12 =      "TIMES_NORMAL_12"          iup.TIMES_NORMAL_12 =      IUP_TIMES_NORMAL_12
IUP_TIMES_ITALIC_12 =      "TIMES_ITALIC_12"          iup.TIMES_ITALIC_12 =      IUP_TIMES_ITALIC_12
IUP_TIMES_BOLD_12 =        "TIMES_BOLD_12"            iup.TIMES_BOLD_12 =        IUP_TIMES_BOLD_12
IUP_TIMES_NORMAL_14 =      "TIMES_NORMAL_14"          iup.TIMES_NORMAL_14 =      IUP_TIMES_NORMAL_14
IUP_TIMES_ITALIC_14 =      "TIMES_ITALIC_14"          iup.TIMES_ITALIC_14 =      IUP_TIMES_ITALIC_14
IUP_TIMES_BOLD_14 =        "TIMES_BOLD_14"            iup.TIMES_BOLD_14 =        IUP_TIMES_BOLD_14



-- #################################################################################
--                                 Private functions
-- #################################################################################

-- maps Ihandles into Lua objects
iup_handles = {}

settagmethod(iuplua_tag, "gettable", iup_gettable) 
settagmethod(iuplua_tag, "settable", iup_settable)
settagmethod (tag({}), "index", iup_index)

function _ALERT(s)
  local bt = iupbutton{title="Ok", size="60", action="return IUP_CLOSE"}
  local ml = iupmultiline{expand="YES", readonly="YES", value=s, size="300x150"}
  local vb = iupvbox{ml, bt; alignment="ACENTER", margin="10x10", gap="10"}
  local dg = iupdialog{vb; title="Lua Error",defaultesc=bt,defaultenter=bt,startfocus=bt}
  dg:popup(IUP_CENTER, IUP_CENTER)
  dg:destroy()
end

function type_string (o) 
  return type(o) == "string" 
end

function type_number (o) 
  return type(o) == "number" 
end

function type_nil (o)    
  return type(o) == "nil" 
end

function type_function (o)
  return type(o) == "function" 
end

function type_widget(w)
  if w then
    return iup_handles[w]
  else
    return nil
  end
end

function type_menu (o) 
  return type_widget(o) and (o.parent==IUPMENU) 
end

function type_item (o)
  return type_widget(o) and (o.parent==IUPITEM or o.parent==IUPSUBMENU or o.parent==IUPSEPARATOR)
end

function iupCallMethod(name, ...)
  local handle = arg[1] -- always the handle
 
  local func = handle[name] -- this is the old name
  if (not func) then
    local full_name = strlower(iup_callbacks[name][1])
    func = handle[full_name]  -- check also for the full name
    
    if (not func) then
      return
    end
  end
    
  if type_function (func) then
    return call(func, arg)
  elseif type_string(func) then
    local temp = self
    self = handle
    local result = dostring(func)
    self = temp
    return result
  else
    return IUP_ERROR
  end
end

function iupSetName (handle)
  if not type_string(iup_handles[handle].IUP_name) then
    iup_handles[handle].IUP_name = format("_IUPLUA_NAME(%s)", tostring(handle))
    IupSetHandle(handle.IUP_name, handle)
  end
end

function iupCreateChildrenNames (obj)
  if obj.parent.parent == COMPOSITION then
    local i = 1
    while obj[i] do
      iupCreateChildrenNames (obj[i])
      i = i+1
    end
  elseif obj.parent == IUPFRAME then
    iupCreateChildrenNames (obj[1])
  else
    iupSetName (obj)
  end
end


-- #################################################################################
--                              Public Functions
-- #################################################################################


function IupRGB (red, green, blue)
  return floor(red*255).." "..floor(green*255).." "..floor(blue*255)
end
iup.RGB = IupRGB

function IupRegisterHandle(handle, typename)
  if not iup_handles[handle] then
    local obj = getglobal("IUP"..strupper(typename))
    if not obj then
      obj = WIDGET
    end
    iup_handles[handle] = { parent=obj, handle=handle }
  end
  return handle
end
iup.RegisterHandle = IupRegisterHandle

function IupGetFromC(obj)
  local handle = IupGetHandle(obj[1])
  return IupRegisterHandle(handle, IupGetType(handle))
end

iup.GetFromC = function (name)
  local handle = IupGetHandle(name)
  return IupRegisterHandle(handle, IupGetType(handle))
end


-- #################################################################################
--                               Widgets
-- #################################################################################


-- "type" is used to check the type of each parameter in the creation table
WIDGET = {type = {}}

-- called by the iupxxx functions
-- obj is a lua table
function WIDGET:Constructor(obj)
  -- the parent of the table is the widget class used to create the control
  obj.parent = self
  
  -- check the table parameters
  self:checkParams(obj)

  -- create the IUP control, calling iupCreateXXX
  obj.handle = self:CreateIUPelement(obj)

  -- set the parameters that are attributes
  self:setAttributes(obj)

  -- save the table indexed by the handle
  iup_handles[obj.handle] = obj

  -- the returned value is the handle, not the table
  return obj.handle
end

function WIDGET:checkParams (obj)
  local type = self.type
  local param, func = next(type, nil)
  while param do
    if not func(obj[param]) then
      error("parameter " .. param .. " has wrong value or is not initialized")
    end
    param, func = next(type, param)
  end
end

function WIDGET:setAttributes (obj)
  local temp = {}
  local f = next(obj, nil)
  while f do
    temp[f] = 1
    f = next(obj, f)
  end
  f = next(temp, nil)
  while f do
    obj:set (f, obj[f])
    f = next(temp, f)
  end
end

function WIDGET:get(index)
  if type_string (index) then
    if (iup_callbacks[index]) then
      return self[index]
    else  
      local INDEX = strupper (index)
      local value = IupGetAttribute (self.handle, INDEX)
      if value then
        local handle = IupGetHandle (value)
        if handle then
          return handle
        else
          return value
        end
      end
    end  
  end
  return self[index]
end

function WIDGET:set(index, value)
  if type_string (index) then
    local INDEX = strupper (index)
    local cb = iup_callbacks[index]
    
    -- workaround for resize attribute in dialog  
    if (index == "resize" and IupGetType(self.handle) == "dialog") then
      cb = nil
    end
   
    if (cb) then
      local func = cb[2]
      if (not func) then
        func = cb[IupGetType(self.handle)]
      end
      iupSetCallback(self.handle, cb[1], func, value)
      self[index] = value
      return
    elseif type_string(value) or type_number(value) then
      IupSetAttribute(self.handle, INDEX, value)
      return
    elseif type_nil(value) then
       local old_value = IupGetAttribute(self.handle, INDEX)
       if old_value then
          IupSetAttribute(self.handle, INDEX, value)
          return
       end
    elseif type_widget(value) then
      iupSetName(value)
      IupSetAttribute(self.handle, INDEX, value.IUP_name)
      return
    end
  end
  self[index] = value
end

function WIDGET:r_destroy()
  local i = 1
  local elem = self[i]
  while elem do
    if type_widget (elem) and elem.IUP_parent then
      if elem.IUP_parent == self then
        elem.IUP_parent = nil
        elem:r_destroy ()
      else    -- wrong parent
        error ("Internal table inconsistency")
        exit()
      end
    end

    i = i + 1
    elem = self[i]
  end
  iup_handles[self] = nil
end

function WIDGET:destroy()
  self:r_destroy ()
  IupDestroy (self)
end

function WIDGET:detach()
  IupDetach (self)
  local parent = self.IUP_parent
  if parent then
    self.IUP_parent = nil
    local i = 1
    while parent[i] do
      if parent[i] == self then
        while parent[i+1] do
        parent[i] = parent[i+1]
        i = i+1
        end
        parent[i] = nil
        return
      end
      i = i+1
    end
  end
end

function WIDGET:append(o)
  if IupAppend (self, o) then
    o.IUP_parent = self
    local i = 1
    while self[i] do
      if self[i] == o then
        return i
      end
      i = i+1
    end
    iup_handles[self][i] = o
    return i
  else
    return nil
  end
end

function WIDGET:map()
  return IupMap(self)
end

function WIDGET:hide()
  return IupHide(self)
end


-- ###############
IUPTIMER = {parent = WIDGET}

function IUPTIMER:CreateIUPelement (obj)
  return iupCreateTimer()
end

function iuptimer(o)
  return IUPTIMER:Constructor(o)
end
iup.timer = iuptimer


-- ###############
IUPDIALOG = {parent = WIDGET, type = {type_widget}}

function IUPDIALOG:CreateIUPelement (obj)
  local handle = iupCreateDialog(obj[1])
  obj[1].IUP_parent = handle
  return handle
end

function IUPDIALOG:show ()
  return IupShow(self)
end

function IUPDIALOG:showxy (x,y)
  return IupShowXY(self, x, y)
end

function IUPDIALOG:popup (x, y)
  return IupPopup (self, x, y)
end

function iupdialog (o)
  return IUPDIALOG:Constructor (o)
end
iup.dialog = iupdialog


-- ###############
IUPRADIO = {parent = WIDGET, type = {type_widget}}

function IUPRADIO:CreateIUPelement (obj)
  local handle = iupCreateRadio (obj[1])
  obj[1].IUP_parent = handle
  return handle
end

function iupradio (o)
  local handle = IUPRADIO:Constructor (o)
  iupCreateChildrenNames (handle[1])
  return handle
end
iup.radio = iupradio

-- OLD STUFF
function edntoggles (h)
  local tmp = {}
  local i = 1
  while h[i] do
    if type_string (h[i]) then
      tmp[i] = iuptoggle{title = h[i], action = h.action}
    else
      error ("option "..i.." must be a string")
    end
    i = i + 1
  end

  if h.value then
    local j = 1
    while h[j] and (h[j] ~= h.value) do
      j = j + 1
    end
    if h[j] then
      tmp.value = tmp[j]
    end
  elseif h.nvalue then
    tmp.value = tmp[h.nvalue]
  end

  return tmp
end

-- OLD STUFF
function edhradio (o)
  local toggles = edntoggles (o)
  return iupradio{edhbox (toggles); value = toggles.value}
end

-- OLD STUFF
function edvradio (o)
  local toggles = edntoggles (o)
  return iupradio{edvbox (toggles); value = toggles.value}
end


-- ###############
IUPMENU = {parent = WIDGET}

function IUPMENU:checkParams (obj)
  local i = 1
  while obj[i] do
    local o = obj[i]
    if not type_item (o) then   -- not a menu item
      if type (o) ~= 'table' then
        error("parameter " .. i .. " is not a table nor a menu item")
      elseif (o[1] and not type_string (o[1])) then
        error("parameter " .. i .. " does not have a string title")
      elseif (o[2] and not type_string (o[2]) and not type_function (o[2])
              and not type_widget (o[2])) then
        error("parameter " .. i .. " does not have an action nor a menu")
      end
    end
    i = i + 1
  end
end

function IUPMENU:CreateIUPelement (obj)
  local handle = iupCreateMenu ()
  local i = 1
  while obj[i] do
    local o = obj[i]
    local elem
    if type_widget (o) then  -- predefined
      elem = o
    elseif not o[1] then     -- Separator
      elem = iupseparator {}
    elseif type_widget (o[2]) then    -- SubMenu
      o.title = o[1]
      o[1] = o[2]
      o[2] = nil
      elem = iupsubmenu(o)
    else          -- Item
      o.title = o[1]
      o.action = o[2]
      o[1] = nil
      o[2] = nil
      elem = iupitem(o)
    end
    IupAppend (handle, elem)
    elem.IUP_parent = handle
    obj[i] = elem
    i = i + 1
  end
  return handle
end

function iupmenu (o)
  return IUPMENU:Constructor (o)
end
iup.menu = iupmenu

function IUPMENU:popup (x, y)
  return IupPopup (self, x, y)
end


-- ###############
COMPOSITION = {parent = WIDGET}

function COMPOSITION:checkParams (obj)
  local i = 1
  while obj[i] do
    if not type_widget (obj[i]) then
      error("parameter " .. i .. " has wrong value or is not initialized")
    end
    i = i + 1
  end
end

function COMPOSITION:CreateIUPelement (obj)
  local handle = self:CreateBoxElement ()
  local filled = obj.filled
  local i = 1
  local n = 0
  while obj[i] do
    n = n + 1
    i = i + 1
  end
  i = 1

  if filled == IUP_YES then 
    obj[i+n] = iupfill{}
    IupAppend (handle, obj[i+n])
    obj[i+n].IUP_parent = handle
  end

  while i <= n do
    IupAppend (handle, obj[i])
    obj[i].IUP_parent = handle
    i = i + 1
    if filled == IUP_YES then 
      obj[i+n] = iupfill{}
      IupAppend (handle, obj[i+n])
      obj[i+n].IUP_parent = handle
    end
  end
  return handle
end


-- ###############
IUPHBOX = {parent = COMPOSITION}

function IUPHBOX:CreateBoxElement ()
  return iupCreateHbox ()
end

function iuphbox (o)
  return IUPHBOX:Constructor (o)
end
iup.hbox = iuphbox

-- OLD STUFF
function edhbox (o)
  o.filled = IUP_YES
  return IUPHBOX:Constructor (o)
end

-- OLD STUFF
function edfield (f)
  local l, t
  if (type_string (f.prompt) or type_number (f.prompt)) then
    l = iuplabel {title = f.prompt}
  else
    error ("parameter prompt has wrong value or is not initialized")
  end
  if f.value then
    t = iuptext {value = f.value}
  else
    t = iuptext {value = f.nvalue}
  end
  if t and l then
    return edhbox {l, t}
  else
    return nil
  end
end


-- ###############
IUPVBOX = {parent = COMPOSITION}

function IUPVBOX:CreateBoxElement ()
  return iupCreateVbox ()
end

function iupvbox (o)
  return IUPVBOX:Constructor (o)
end
iup.vbox = iupvbox

-- OLD STUFF
function edvbox (o)
  o.filled = IUP_YES
  return IUPVBOX:Constructor (o)
end


-- ###############
IUPZBOX = {parent = COMPOSITION}

function IUPZBOX:CreateBoxElement ()
  return iupCreateZbox ()
end

function iupzbox (obj)
  local handle = IUPZBOX:Constructor (obj)
  local i = 1
  while obj[i] do
    iupSetName(handle[i])
    i = i+1
  end
  return handle
end
iup.zbox = iupzbox


-- ###############
IUPFILL = {parent = WIDGET}

function IUPFILL:CreateIUPelement (obj)
  return iupCreateFill ()
end

function iupfill (o)
  return IUPFILL:Constructor (o)
end
iup.fill = iupfill


-- ###############
IUPBUTTON = {parent = WIDGET, type = {title = type_string}}

function IUPBUTTON:CreateIUPelement (obj)
  if not obj.title and obj.image then
    obj.title=''
  end
  return iupCreateButton(obj.title)
end

function iupbutton (o)
  return IUPBUTTON:Constructor (o)
end
iup.button = iupbutton


-- ###############
IUPTEXT = {parent = WIDGET}

function IUPTEXT:CreateIUPelement (obj)
  return iupCreateText()
end

function iuptext (o)
  return IUPTEXT:Constructor (o)
end
iup.text = iuptext


-- ###############
IUPMULTILINE = {parent = IUPTEXT}

function IUPMULTILINE:CreateIUPelement (obj)
  return iupCreateMultiLine()
end

function iupmultiline (o)
  return IUPMULTILINE:Constructor (o)
end
iup.multiline = iupmultiline


-- ###############
IUPLABEL = {parent = WIDGET, type = {title = type_string}}

function IUPLABEL:CreateIUPelement (obj)
  if not obj.title and obj.image then
    obj.title=''
  end
  return iupCreateLabel (obj.title)
end

function iuplabel (o)
  return IUPLABEL:Constructor (o)
end
iup.label = iuplabel


-- ###############
IUPTOGGLE = {parent = IUPBUTTON}

function IUPTOGGLE:CreateIUPelement (obj)
  return iupCreateToggle (obj.title)
end

function iuptoggle (o)
  return IUPTOGGLE:Constructor (o)
end
iup.toggle = iuptoggle


-- ###############
IUPITEM = {parent = IUPBUTTON}

function IUPITEM:CreateIUPelement (obj)
  return iupCreateItem (obj.title)
end

function iupitem (o)
  return IUPITEM:Constructor (o)
end
iup.item = iupitem


-- ###############
IUPSUBMENU = {parent = WIDGET, type = {type_menu; title = type_string}}

function IUPSUBMENU:CreateIUPelement (obj)
  local h = iupCreateSubmenu (obj.title, obj[1])
  obj[1].IUP_parent = h
  return h
end

function iupsubmenu (o)
  return IUPSUBMENU:Constructor (o)
end
iup.submenu = iupsubmenu


-- ###############
IUPSEPARATOR = {parent = WIDGET}

function IUPSEPARATOR:CreateIUPelement (obj)
  return iupCreateSeparator ()
end

function iupseparator (o)
  return IUPSEPARATOR:Constructor (o)
end
iup.separator = iupseparator


-- ###############
IUPFILEDLG = {parent = WIDGET}

function IUPFILEDLG:popup (x, y)
  return IupPopup (self, x, y)
end

function IUPFILEDLG:CreateIUPelement ()
  return iupCreateFileDlg ()
end

function iupfiledlg (o)
  return IUPFILEDLG:Constructor (o)
end
iup.filedlg = iupfiledlg


-- ###############
IUPMESSAGEDLG = {parent = WIDGET}

function IUPMESSAGEDLG:popup (x, y)
  return IupPopup (self, x, y)
end

function IUPMESSAGEDLG:CreateIUPelement ()
  return iupCreateMessageDlg ()
end

function iupmessagedlg (o)
  return IUPMESSAGEDLG:Constructor (o)
end
iup.messagedlg = iupmessagedlg


-- ###############
IUPCOLORDLG = {parent = WIDGET}

function IUPCOLORDLG:popup (x, y)
  return IupPopup (self, x, y)
end

function IUPCOLORDLG:CreateIUPelement ()
  return iupCreateColorDlg ()
end

function iupcolordlg (o)
  return IUPCOLORDLG:Constructor (o)
end
iup.colordlg = iupcolordlg


-- ###############
IUPFONTDLG = {parent = WIDGET}

function IUPFONTDLG:popup (x, y)
  return IupPopup (self, x, y)
end

function IUPFONTDLG:CreateIUPelement ()
  return iupCreateFontDlg ()
end

function iupfontdlg (o)
  return IUPFONTDLG:Constructor (o)
end
iup.fontdlg = iupfontdlg


-- ###############
IUPUSER = {parent = WIDGET}

function IUPUSER:CreateIUPelement ()
  return iupCreateUser ()
end

function iupuser ()
  return IUPUSER:Constructor ()
end
iup.user = iupuser


-- ###############
IUPFRAME = {parent = WIDGET, type = {type_widget}}

function IUPFRAME:CreateIUPelement (obj)
  local h = iupCreateFrame (obj[1])
  obj[1].IUP_parent = h
  return h
end

function iupframe (o)
  return IUPFRAME:Constructor (o)
end
iup.frame = iupframe


-- ###############
IUPCANVAS = {parent = WIDGET}

function IUPCANVAS:CreateIUPelement (obj)
  return iupCreateCanvas ()
end

function iupcanvas (o)
  return IUPCANVAS:Constructor (o)
end
iup.canvas = iupcanvas


-- ###############
IUPLIST = {parent = WIDGET}

function IUPLIST:CreateIUPelement (obj)
  return iupCreateList ()
end

function IUPLIST:get(index)
  if type (index) == 'number' then
    return IupGetAttribute (self.handle, ""..index)
  else
    return WIDGET.get(self, index)
  end
end

function IUPLIST:set (index, value)
  if type (index) == 'number' then
    if (type_string (value) or type_number (value)) then
      return IupSetAttribute (self.handle, ""..index, ""..value)
    elseif value == nil then
      return IupSetAttribute (self.handle, ""..index, value)
    end
  end
  return WIDGET.set(self, index, value)
end

function iuplist (o)
  return IUPLIST:Constructor (o)
end
iup.list = iuplist


-- ###############
IUPIMAGE = {parent = WIDGET}

function IUPIMAGE:checkParams (obj)
  local i = 1
  while obj[i] do
    local j = 1
    while obj[i][j] do
      if type (obj[i][j]) ~= 'number' then
        error ("non-numeric value in image definition")
      end
      j = j + 1
    end

    if obj.width and (j - 1) ~= obj.width then
      error ("inconsistent image lenght")
    else
      obj.width = j - 1
    end

    i = i + 1
  end
  
  obj.height = i - 1
end

function IUPIMAGE:CreateIUPelement (obj)
  local handle = iupCreateImage (obj.width, obj.height, obj)
  if type (obj.colors) == 'table' then
    local i = 1
    while obj.colors[i] do
      IupSetAttribute (handle, i, obj.colors[i])
      i = i + 1
    end
  end
  return handle
end

function iupimage (o)
  return IUPIMAGE:Constructor (o)
end
iup.image = iupimage


IUPIMAGERGB = {parent = WIDGET}

function IUPIMAGERGB:CreateIUPelement (obj)
  return iupCreateImageRGB(obj.width, obj.height, obj.pixels)
end

function iupimagergb (o)
  return IUPIMAGERGB:Constructor (o)
end
iup.imagergb = iupimagergb


IUPIMAGERGBA = {parent = WIDGET}

function IUPIMAGERGBA:CreateIUPelement (obj)
  return iupCreateImageRGBA(obj.width, obj.height, obj.pixels)
end

function iupimagergba (o)
  return IUPIMAGERGBA:Constructor (o)
end
iup.imagergba = iupimagergba


-- #################################################################################
--                                     Callbacks
-- #################################################################################


-- global list of callbacks
-- index is the Lua callback name
-- each callback contains the full name, and the C callback
iup_callbacks = 
{
  action      = {"ACTION", nil},
  actioncb    = {"ACTION_CB", nil},
  getfocus    = {"GETFOCUS_CB", iup_getfocus_cb},
  killfocus   = {"KILLFOCUS_CB", iup_killfocus_cb},
  focus       = {"FOCUS_CB", iup_focus_cb},
  k_any       = {"K_ANY", iup_k_any},
  help        = {"HELP_CB", iup_help_cb},
  caretcb     = {"CARET_CB", iup_caret_cb},
  keypress    = {"KEYPRESS_CB", iup_keypress_cb},
  scroll      = {"SCROLL_CB", iup_scroll_cb},
  trayclick   = {"TRAYCLICK_CB", iup_trayclick_cb},
  close       = {"CLOSE_CB", iup_close_cb},
  open        = {"OPEN_CB", iup_open_cb},
  showcb      = {"SHOW_CB", iup_show_cb},
  mapcb       = {"MAP_CB", iup_map_cb},
  dropfiles   = {"DROPFILES_CB", iup_dropfiles_cb},
  menuclose   = {"MENUCLOSE_CB", iup_menuclose_cb},
  highlight   = {"HIGHLIGHT_CB", iup_highlight_cb},
  wom         = {"WOM_CB", iup_wom_cb},
  wheel       = {"WHEEL_CB", iup_wheel_cb},
  button      = {"BUTTON_CB", iup_button_cb},
  resize      = {"RESIZE_CB", iup_resize_cb},
  motion      = {"MOTION_CB", iup_motion_cb},
  enterwindow = {"ENTERWINDOW_CB", iup_enterwindow_cb},
  leavewindow = {"LEAVEWINDOW_CB", iup_leavewindow_cb},
  edit        = {"EDIT_CB", iup_edit_cb},
  multiselect = {"MULTISELECT_CB", iup_multiselect_cb},
  filecb      = {"FILE_CB", iup_file_cb},
  mdiactivatecb = {"MDIACTIVATE_CB", iup_mdiactivate_cb},
}

iup_callbacks.action.toggle = iup_action_toggle
iup_callbacks.action.multiline = iup_action_text
iup_callbacks.action.text = iup_action_text
iup_callbacks.action.button = iup_action_button
iup_callbacks.action.list = iup_action_list
iup_callbacks.action.item = iup_action_button
iup_callbacks.action.canvas = iup_action_canvas

-- must set here because it is also used elsewhere with a different signature
iup_callbacks.actioncb.timer = iup_action_timer

-- aliases for the full names
iup_callbacks.action_cb      = iup_callbacks.actioncb    
iup_callbacks.getfocus_cb    = iup_callbacks.getfocus    
iup_callbacks.killfocus_cb   = iup_callbacks.killfocus   
iup_callbacks.focus_cb       = iup_callbacks.focus       
iup_callbacks.k_any          = iup_callbacks.k_any       
iup_callbacks.help_cb        = iup_callbacks.help        
iup_callbacks.caret_cb       = iup_callbacks.caretcb     
iup_callbacks.keypress_cb    = iup_callbacks.keypress    
iup_callbacks.scroll_cb      = iup_callbacks.scroll      
iup_callbacks.trayclick_cb   = iup_callbacks.trayclick   
iup_callbacks.close_cb       = iup_callbacks.close       
iup_callbacks.open_cb        = iup_callbacks.open        
iup_callbacks.show_cb        = iup_callbacks.showcb      
iup_callbacks.map_cb         = iup_callbacks.mapcb       
iup_callbacks.dropfiles_cb   = iup_callbacks.dropfiles   
iup_callbacks.menuclose_cb   = iup_callbacks.menuclose   
iup_callbacks.highlight_cb   = iup_callbacks.highlight   
iup_callbacks.wom_cb         = iup_callbacks.wom         
iup_callbacks.wheel_cb       = iup_callbacks.wheel       
iup_callbacks.button_cb      = iup_callbacks.button      
iup_callbacks.resize_cb      = iup_callbacks.resize      
iup_callbacks.motion_cb      = iup_callbacks.motion      
iup_callbacks.enterwindow_cb = iup_callbacks.enterwindow 
iup_callbacks.leavewindow_cb = iup_callbacks.leavewindow 
iup_callbacks.edit_cb        = iup_callbacks.edit        
iup_callbacks.multiselect_cb = iup_callbacks.multiselect 
iup_callbacks.mdiactivate_cb = iup_callbacks.mdiactivatecb
iup_callbacks.file_cb        = iup_callbacks.filecb 
IUPCOLORBROWSER = {parent = WIDGET}

function IUPCOLORBROWSER:CreateIUPelement(obj)
  return iupCreateColorBrowser(obj)
end

function iupcolorbrowser (o)
  return IUPCOLORBROWSER:Constructor (o)
end
iup.colorbrowser = iupcolorbrowser


iup_callbacks.drag   = {"DRAG_CB", iup_colorbrowser_drag_cb}
iup_callbacks.change = {"CHANGE_CB", iup_colorbrowser_change_cb}

iup_callbacks.drag_cb   = iup_callbacks.drag  
iup_callbacks.change_cb = iup_callbacks.change
IUPCELLS = {parent = WIDGET}

function IUPCELLS:CreateIUPelement( obj )
  return iupCreateCells()
end

function IUPCELLS:redraw()
   self.repaint = IUP_YES 
end

function iupcells(o)
  return IUPCELLS:Constructor(o)
end
iup.cells = iupcells


-- iup_callbacks.draw_cb      = iup_callbacks.draw         = {"DRAW_CB", iup_mat_draw_cb} -- same callback at IupMatrix

iup_callbacks.mouseclick   = {"MOUSECLICK_CB", iup_cells_mouseclick_cb}
iup_callbacks.mousemotion  = {"MOUSEMOTION_CB", iup_cells_mousemotion_cb}
iup_callbacks.scrolling    = {"SCROLLING_CB", iup_cells_scrolling_cb}
iup_callbacks.width        = {"WIDTH_CB", iup_cells_width_cb}
iup_callbacks.height       = {"HEIGHT_CB", iup_cells_height_cb}
iup_callbacks.nlines       = {"NLINES_CB", iup_cells_nlines_cb}
iup_callbacks.ncols        = {"NCOLS_CB", iup_cells_ncols_cb}
iup_callbacks.hspan        = {"HSPAN_CB", iup_cells_hspan_cb}
iup_callbacks.vspan        = {"VSPAN_CB", iup_cells_vspan_cb}

iup_callbacks.mouseclick_cb   = iup_callbacks.mouseclick  
iup_callbacks.mousemotion_cb  = iup_callbacks.mousemotion 
iup_callbacks.scrolling_cb    = iup_callbacks.scrolling   
iup_callbacks.width_cb        = iup_callbacks.width       
iup_callbacks.height_cb       = iup_callbacks.height      
iup_callbacks.nlines_cb       = iup_callbacks.nlines      
iup_callbacks.ncols_cb        = iup_callbacks.ncols       
iup_callbacks.hspan_cb        = iup_callbacks.hspan       
iup_callbacks.vspan_cb        = iup_callbacks.vspan       
IUPCOLORBAR = {parent = WIDGET}

function IUPCOLORBAR:CreateIUPelement(obj)
  return iupCreateColorbar(obj)
end

function iupcolorbar (o)
  return IUPCOLORBAR:Constructor (o)
end
iup.colorbar = iupcolorbar


iup_callbacks.cellcb      = {"CELL_CB", iup_colorbar_cell_cb}
iup_callbacks.selectcb    = {"SELECT_CB", iup_colorbar_select_cb}
iup_callbacks.switchcb    = {"SWITCH_CB", iup_colorbar_switch_cb}
iup_callbacks.extendedcb  = {"EXTENDED_CB", iup_colorbar_extended_cb}

iup_callbacks.cell_cb      = iup_callbacks.cellcb      
iup_callbacks.select_cb    = iup_callbacks.selectcb    
iup_callbacks.switch_cb    = iup_callbacks.switchcb    
iup_callbacks.extended_cb  = iup_callbacks.extendedcb  
IUPDIAL = {parent = WIDGET}

function IUPDIAL:CreateIUPelement (obj)
  return iupCreateDial (obj[1])
end

function iupdial (o)
  return IUPDIAL:Constructor (o)
end
iup.dial = iupdial

iup_callbacks.mousemove.dial = iup_val_mousemove_cb  -- same callback at IupVal

-- iup_callbacks.buttonpress  = {"BUTTON_PRESS_CB", iup_val_button_press_cb}  -- same callback at IupVal
-- iup_callbacks.buttonrelease  = {"BUTTON_RELEASE_CB", iup_val_button_release_cb} -- same callback at IupVal
IUPGAUGE = {parent = WIDGET}

function IUPGAUGE:CreateIUPelement (obj)
  return iupCreateGauge ()
end

function iupgauge (o)
  return IUPGAUGE:Constructor (o)
end
iup.gauge = iupgauge
IUPMATRIX = {parent = WIDGET}

function IUPMATRIX:CreateIUPelement (obj)
  return iupCreateMatrix ()
end

function IUPMATRIX:setcell(l,c,val)
   IupSetAttribute(self,l..":"..c,val)
end

function IUPMATRIX:getcell(l,c,val)
   return IupGetAttribute(self,l..":"..c)
end

function iupmatrix (o)
  return IUPMATRIX:Constructor (o)
end
iup.matrix = iupmatrix


iup_callbacks.actioncb.matrix = iup_mat_action_cb
iup_callbacks.mousemove.matrix = iup_mat_mousemove_cb

iup_callbacks.edition     = {"EDITION_CB", iup_mat_edition_cb}
iup_callbacks.drop        = {"DROP_CB", iup_mat_drop_cb}
iup_callbacks.dropselect  = {"DROPSELECT_CB", iup_mat_dropselect_cb}
iup_callbacks.enteritem   = {"ENTERITEM_CB", iup_mat_enteritem_cb}
iup_callbacks.leaveitem   = {"LEAVEITEM_CB", iup_mat_leaveitem_cb}
iup_callbacks.click       = {"CLICK_CB", iup_mat_click_cb}
iup_callbacks.scrolltop   = {"SCROLLTOP_CB", iup_mat_scrolltop_cb}
iup_callbacks.valuecb     = {"VALUE_CB", iup_mat_value_cb}
iup_callbacks.draw        = {"DRAW_CB", iup_mat_draw_cb}
iup_callbacks.dropcheck   = {"DROPCHECK_CB", iup_mat_dropcheck_cb}
iup_callbacks.fgcolorcb   = {"FGCOLOR_CB", iup_mat_fgcolor_cb}
iup_callbacks.bgcolorcb   = {"BGCOLOR_CB", iup_mat_bgcolor_cb}
iup_callbacks.value_edit  = {"VALUE_EDIT_CB", iup_mat_value_edit_cb}
iup_callbacks.markedit_cb = {"MARKEDIT_CB", iup_mat_markedit_cb}
iup_callbacks.mark_cb     = {"MARK_CB", iup_mat_mark_cb}
iup_callbacks.mouse_cb    = {"MOUSE_CB", iup_mat_mouse_cb}

iup_callbacks.edition_cb    = iup_callbacks.edition    
iup_callbacks.drop_cb       = iup_callbacks.drop       
iup_callbacks.dropselect_cb = iup_callbacks.dropselect 
iup_callbacks.enteritem_cb  = iup_callbacks.enteritem  
iup_callbacks.leaveitem_cb  = iup_callbacks.leaveitem  
iup_callbacks.click_cb      = iup_callbacks.click      
iup_callbacks.scrolltop_cb  = iup_callbacks.scrolltop  
iup_callbacks.value_cb      = iup_callbacks.valuecb    
iup_callbacks.draw_cb       = iup_callbacks.draw       
iup_callbacks.dropcheck_cb  = iup_callbacks.dropcheck  
iup_callbacks.fgcolor_cb    = iup_callbacks.fgcolorcb  
iup_callbacks.bgcolor_cb    = iup_callbacks.bgcolorcb  
iup_callbacks.value_edit_cb = iup_callbacks.value_edit 
IUPPPLOT = {parent = WIDGET}

function IUPPPLOT:CreateIUPelement (obj)
  return iupCreatePPlot ()
end

function iuppplot (o)
  return IUPPPLOT:Constructor (o)
end
iup.pplot = iuppplot

iup_callbacks.edit_cb.pplot  = iup_pplot_edit_cb

iup_callbacks.editbegin_cb   = {"EDITBEGIN_CB", iup_pplot_editbegin_cb}
iup_callbacks.editend_cb     = {"EDITEND_CB", iup_pplot_editend_cb}
iup_callbacks.select_cb      = {"SELECT_CB", iup_pplot_select_cb}
iup_callbacks.selectbegin_cb = {"SELECTBEGIN_CB", iup_pplot_selectbegin_cb}
iup_callbacks.selectend_cb   = {"SELECTEND_CB", iup_pplot_selectend_cb}
iup_callbacks.delete_cb      = {"DELETE_CB", iup_pplot_delete_cb}
iup_callbacks.deletebegin_cb = {"DELETEBEGIN_CB", iup_pplot_deletebegin_cb}
iup_callbacks.deleteend_cb   = {"DELETEEND_CB", iup_pplot_deleteend_cb}
iup_callbacks.predraw_cb     = {"PREDRAW_CB", iup_pplot_predraw_cb}
iup_callbacks.postdraw_cb    = {"POSTDRAW_CB", iup_pplot_postdraw_cb}
IUPSBOX = {parent = WIDGET}

function IUPSBOX:CreateIUPelement (obj)
  return iupCreateSbox(obj[1])
end

function iupsbox (o)
  return IUPSBOX:Constructor (o)
end
iup.sbox = iupsbox
IUPSPIN = {parent = WIDGET}

function IUPSPIN:CreateIUPelement (obj)
  return iupCreateSpin ()
end

function iupspin (o)
  return IUPSPIN:Constructor (o)
end
iup.spin = iupspin

IUPSPINBOX = {parent = WIDGET}

function IUPSPINBOX:CreateIUPelement (obj)
  return iupCreateSpinbox (obj[1])
end

function iupspinbox (o)
  return IUPSPINBOX:Constructor (o)
end
iup.spinbox = iupspinbox

iup_callbacks.spincb = {"SPIN_CB", iup_spin_cb}
iup_callbacks.spin_cb = iup_callbacks.spincb
IUPTABS = {parent = WIDGET}

function IUPTABS:CreateIUPelement (obj)
  return iupCreateTabs (obj, getn(obj))
end

function iuptabs (o)
  return IUPTABS:Constructor (o)
end
iup.tabs = iuptabs

iup_callbacks.tabchange = {"TABCHANGE_CB", iup_tabchange_cb}
iup_callbacks.tabchange_cb = iup_callbacks.tabchangeIUPTREE = {parent = WIDGET}
IUPTREEREFERENCETABLE = {} -- Used in C, see luatree.c

function IUPTREE:CreateIUPelement (obj)
  return iupCreateTree ()
end

function iuptree (o)
  return IUPTREE:Constructor (o)
end
iup.tree = iuptree

function TreeSetValueRec(handle, t, id)

  if t == nil then return end

  local cont = getn(t)

  while cont >= 0 do
    if type (t[cont]) == "table" then  
      if t[cont].branchname ~= nil then
        IupSetAttribute(handle, "ADDBRANCH"..id, t[cont].branchname)
      else
        IupSetAttribute(handle, "ADDBRANCH"..id, "")
      end
      TreeSetValueRec(handle, t[cont], id+1)
    else
      if t[cont] then
        IupSetAttribute(handle, "ADDLEAF"..id, t[cont])
      end
    end
    cont = cont - 1
   end 
end

function TreeSetValue(handle, t)
  if type(t) ~= "table" then
    IupMessage("TreeLua Error", "Incorrect arguments to function TreeSetValue")
    return
  end
  if t.branchname ~= nil then
    IupSetAttribute(handle, "NAME", t.branchname)
  end
  TreeSetValueRec(handle, t, 0)
end
iup.TreeSetValue = TreeSetValue

iup_callbacks.selection      = {"SELECTION_CB", iup_tree_selection_cb}
iup_callbacks.multiselection = {"MULTISELECTION_CB", iup_tree_multiselection_cb}
iup_callbacks.branchopen     = {"BRANCHOPEN_CB", iup_tree_branchopen_cb}
iup_callbacks.branchclose    = {"BRANCHCLOSE_CB", iup_tree_branchclose_cb}
iup_callbacks.executeleaf    = {"EXECUTELEAF_CB", iup_tree_executeleaf_cb}
iup_callbacks.renamenode     = {"RENAMENODE_CB", iup_tree_renamenode_cb}
iup_callbacks.renamecb       = {"RENAME_CB", iup_tree_renamecb_cb}
iup_callbacks.showrenamecb   = {"SHOWRENAME_CB", iup_tree_showrenamecb_cb}
iup_callbacks.rightclick     = {"RIGHTCLICK_CB", iup_tree_rightclick_cb}
iup_callbacks.dragdrop       = {"DRAGDROP_CB", iup_tree_dragdrop_cb}

iup_callbacks.selection_cb      = iup_callbacks.selection      
iup_callbacks.multiselection_cb = iup_callbacks.multiselection 
iup_callbacks.branchopen_cb     = iup_callbacks.branchopen     
iup_callbacks.branchclose_cb    = iup_callbacks.branchclose    
iup_callbacks.executeleaf_cb    = iup_callbacks.executeleaf    
iup_callbacks.renamenode_cb     = iup_callbacks.renamenode     
iup_callbacks.rename_cb         = iup_callbacks.renamecb       
iup_callbacks.showrename_cb     = iup_callbacks.showrenamecb   
iup_callbacks.rightclick_cb     = iup_callbacks.rightclick     
iup_callbacks.dragdrop_cb       = iup_callbacks.dragdrop       
IUPVAL = {parent = WIDGET}

function IUPVAL:CreateIUPelement (obj)
  return iupCreateVal (obj[1])
end

function iupval (o)
  return IUPVAL:Constructor (o)
end
iup.val = iupval


-- must set here because it is also used elsewhere with a different signature
iup_callbacks.mousemove = {"MOUSEMOVE_CB", nil}
iup_callbacks.mousemove_cb = iup_callbacks.mousemove
iup_callbacks.mousemove.val  = iup_val_mousemove_cb

iup_callbacks.buttonpress    = {"BUTTON_PRESS_CB", iup_val_button_press_cb}
iup_callbacks.buttonrelease  = {"BUTTON_RELEASE_CB", iup_val_button_release_cb}

iup_callbacks.button_press_cb    = iup_callbacks.buttonpress   
iup_callbacks.button_release_cb  = iup_callbacks.buttonrelease 
----------------------------------------------------
-- The main porpouse of this file is to build linux gcc makefiles.
-- Must have Premake version 3 installed.
-- Original Premake was changed to remove some parameters and add others.
-- Default parameters:
--   premake3s --target gnu --os linux
-- But it can build windows gcc makefiles, and visual studio projects.
--   premake3s --target gnu --os windows
--   premake3s --target gnu --os macosx
--   premake3s --target vs6
--   premake3s --target vs2002
--   premake3s --target vs2003
--   premake3s --target vs2005
-- In Linux the generated makefiles will not correctly build libraries in 64-bits.
--              must add "-m64 -fPIC" flags
----------------------------------------------------

if (not options.target) then 
  options.target = "gnu"
end

if (not options.os) then
  if (options.target ~= "gnu") then
    options.os = "windows"
  else
    options.os = "linux"
  end
end

function fixPackagePath(package_files)
  if (options.os ~= "linux") then
    for i, file in package_files do 
      package_files[i] = "../src/"..file 
    end
  end
end

----------------------------------------------------

project.name = "iup"
project.bindir = "../bin"
project.libdir = "../lib"

if (options.os ~= "linux") then
  if (options.os == "macosx") then
	project.path = "../mak.macosx"
  else
	project.path = "../mak."..options.target
  end
end

----------------------------------------------------

package = newpackage()
package.name = "iuplua3"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "lib"
package.buildflags = { "static-runtime" }

package.files =
{
  "iuplua.c",  "iuplua_api.c",  "iuplua_widgets.c"
}
fixPackagePath(package.files)

package.includepaths = { "../include", "../src", "$(LUA3)/include" }
package.defines = {"IUPLUA_USELOH"}

-- SRCLUA = iuplua.lua

---------------------------------------------------------------------

package = newpackage()
package.name = "iupluacontrols3"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "lib"
package.buildflags = { "static-runtime" }

package.files =
{
  "luaval.c", "luadial.c", "luagauge.c", "luagc.c", "luacbox.c", "luacells.c",
  "luacb.c", "luatabs.c", "luamask.c", "luacontrols.c", "luagetparam.c", 
  "luamatrix.c", "luatree.c", "luasbox.c", "luaspin.c", "luacolorbar.c"
}
fixPackagePath(package.files)

-- SRCLUA =  luaval.lua luadial.lua luagauge.lua luacb.lua luatabs.lua luamatrix.lua luatree.lua luasbox.lua luaspin.lua luacells.lua

package.includepaths = { "../include", "$(CD)/include", "$(LUA3)/include" }
package.defines = {"IUPLUA_USELOH"}

---------------------------------------------------------------------

package = newpackage()
package.name = "iuplua_pplot3"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "lib"
package.buildflags = { "static-runtime" }

package.files =
{
  "luapplot.c"
}
fixPackagePath(package.files)

-- SRCLUA =  luapplot.lua

package.includepaths = { "../include", "$(CD)/include", "$(LUA3)/include" }
package.defines = {"IUPLUA_USELOH"}

---------------------------------------------------------------------

package = newpackage()
package.name = "iupluagl3"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "lib"
package.buildflags = { "static-runtime" }

package.files =
{
  "luaglcanvas.c"
}
fixPackagePath(package.files)

package.includepaths = { "../include", "$(LUA3)/include" }
           
---------------------------------------------------------------------

package = newpackage()
package.name = "iupluaim3"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "lib"
package.buildflags = { "static-runtime" }

package.files =
{
  "luaim.c"
}
fixPackagePath(package.files)

package.includepaths = { "../include", "$(LUA3)/include" }
           
---------------------------------------------------------------------

package = newpackage()
package.name = "iuplua3exe"
package.target = "iuplua3"
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "exe"
package.linkflags = { "static-runtime" }

package.files =
{
  "iupluaexe.c"
}
fixPackagePath(package.files)

-- SRCLUA = console.lua

package.includepaths = { "../include", "$(LUA3)/include", "$(CD)/include", "$(IM)/include" }
package.defines = {"IUPLUA_USELOH"}
package.links = { "imlua3", "cdluaiup3", "cdlua3", 
                  "iupluagl3", "iupluaim3", "iupluacontrols3", "iuplua3", 
                  "lualib", "lua", 
                  "iupgl", "iupim", "iupcontrols", 
                  "cdiup", "cd", "iup", "im" }
package.libpaths = { "../lib", "$(IM)/lib", "$(CD)/lib", "$(LUA3)/lib" }

if (options.os == "windows") then
  tinsert(package.links, { "comctl32", "ole32", "opengl32", "glu32", "glaux" })
else
  tinsert(package.links, { "GLU", "GL", "Xm", "Xpm", "Xmu", "Xt", "Xext", "X11", "m" })
  tinsert(package.libpaths, { "/usr/X11R6/lib" })
end

---------------------------------------------------------------------
------------------------------------------------------------------------------
-- Button class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "button",
  parent = WIDGET,
  creation = "S-",
  callback = {
    action = "", 
  }
} 

function ctrl.createElement(class, arg)
  return Button(arg.title)
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- Canvas class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "canvas",
  parent = WIDGET,
  creation = "-",
  callback = {
    action = "ff",
    button_cb = "nnnns",
    enterwindow_cb = "",
    leavewindow_cb = "",
    motion_cb = "nns",
    resize_cb = "nn",
    scroll_cb = "nff",
    keypress_cb = "nn",
    wom_cb = "n",
    wheel_cb = "fnns",
    mdiactivate_cb = "",
    focus_cb = "n",
  }
}

function ctrl.createElement(class, arg)
   return Canvas()
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- Cbox class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "cbox",
  parent = WIDGET,
  creation = "v",
  callback = {},
  include = "iupcbox.h",
  funcname = "Cboxv",
  createfunc = [[
static int Cboxv(lua_State *L)
{
  Ihandle **hlist = iuplua_checkihandle_array(L, 1);
  Ihandle *h = IupCboxv(hlist);
  iuplua_plugstate(L, h);
  iuplua_pushihandle_raw(L, h);
  free(hlist);
  return 1;
}
  ]],
}

function ctrl.createElement(class, arg)
  return Cboxv(arg)
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- Cells class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "cells",
  parent = WIDGET,
  creation = "",
  callback = {
    mouseclick_cb = "nnnnnns",
    mousemotion_cb = "nnnns",
    scrolling_cb = "nn",
--    draw_cb = "nnnnnnn",   -- already registered by the matrix
    width_cb = "n",
    height_cb = "n",
    nlines_cb = "",
    ncols_cb = "",
    hspan_cb = "nn",
    vspan_cb = "nn",
   },
  include = "iupcells.h"
}

function ctrl.redraw(handle)
   handle.repaint = "YES"
end

function ctrl.createElement(class, arg)
   return Cells()
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- Colorbar class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "colorbar",
  parent = WIDGET,
  creation = "",
  callback = {
    select_cb = "nn",
    cell_cb = {"n", ret = "s"},
    switch_cb = "nn",
    extended_cb = "n",
   },
  funcname = "Colorbar",
  include = "iupcolorbar.h",
}

function ctrl.createElement(class, arg)
   return Colorbar(arg.action)
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- ColorBrowser class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "colorbrowser",
  parent = WIDGET,
  creation = "",
  callback = {
    drag_cb = "ccc",
    change_cb = "ccc",
  },
  funcname = "ColorBrowser",
  include = "iupcb.h",
}

function ctrl.createElement(class, arg)
   return ColorBrowser(arg.action)
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- ColorDlg class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "colordlg",
  parent = WIDGET,
  creation = "",
  funcname = "ColorDlg",
  callback = {}
} 

function ctrl.popup(handle, x, y)
  Popup(handle,x,y)
end

function ctrl.destroy(handle)
  return Destroy(handle)
end

function ctrl.createElement(class, arg)
   return ColorDlg()
end
   
iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")

-- Utilities
iupluacmd = {}

function iupluacmd.printtable(t)
  local n,v = next(t, nil)
  print("--printtable Start--")
  while n ~= nil do
    print(tostring(n).."="..tostring(v))
    n,v = next(t, n)
  end
  print("--printtable End--")
end

function iupluacmd.print_version_info()
  print(_VERSION .. " " .. _COPYRIGHT)
  if (im) then print("IM " .. im._VERSION .. " " .. im._COPYRIGHT) end
  if (cd) then print("CD " .. cd._VERSION .. " " .. cd._COPYRIGHT) end
  print("IUP " .. iup._VERSION .. " " .. iup._COPYRIGHT)
  print("")
  print("IUP Info")
  print("  System: " .. iup.GetGlobal("SYSTEM"))
  print("  System Version: " .. iup.GetGlobal("SYSTEMVERSION"))
  local mot = iup.GetGlobal("MOTIFVERSION")
  if (mot) then print("  Motif Version: ", mot) end
  print("  Screen Size: " .. iup.GetGlobal("SCREENSIZE"))
  print("  Screen Depth: " .. iup.GetGlobal("SCREENDEPTH"))
  if (iup.GL_VENDOR) then print("  OpenGL Vendor: " .. iup.GL_VENDOR) end
  if (iup.GL_RENDERER) then print("  OpenGL Renderer: " .. iup.GL_RENDERER) end
  if (iup.GL_VERSION) then print("  OpenGL Version: " .. iup.GL_VERSION) end
end

-- IUPLUA Full Application  

iupluacmd.lastfilename = nil -- Last file open
iupluacmd.mlCode = iup.multiline{expand="YES", size="200x120", font="COURIER_NORMAL_10"}   
iupluacmd.lblPosition = iup.label{title="0:0", size="50x"} 
iupluacmd.lblFileName = iup.label{title="", size="50x", expand="HORIZONTAL"} 

function iupluacmd.mlCode:caret_cb(lin, col)
   iupluacmd.lblPosition.title = lin..":"..col
end

iupluacmd.butExecute = iup.button{size="50x15", title="Execute", 
                                  action="iup.dostring(iupluacmd.mlCode.value)"}
iupluacmd.butClearCommands = iup.button{size="50x15", title="Clear", 
                                        action="iupluacmd.mlCode.value=''  iupluacmd.lblFileName.title = ''  iupluacmd.lastfilename = nil"}
iupluacmd.butLoadFile = iup.button{size="50x15", title="Load..."}
iupluacmd.butSaveasFile = iup.button{size="50x15", title="Save As..."}
iupluacmd.butSaveFile = iup.button{size="50x15", title="Save"}

iupluacmd.butSaveFile.action = function()
   if (iupluacmd.lastfilename == nil) then
      iupluacmd.butSaveasFile:action() 
   else
      newfile = io.open(iupluacmd.lastfilename, "w+")
      if (newfile ~= nil) then
         newfile:write(iupluacmd.mlCode.value)
         newfile:close() 
      else
         error ("Cannot Save file "..filename)
      end
   end
end

iupluacmd.butSaveasFile.action = function()
   local fd = iup.filedlg{dialogtype="SAVE", title="Save File", 
                          filter="*.lua", filterinfo="Lua files",allownew=yes}
   fd:popup(iup.LEFT, iup.LEFT)
   local status = fd.status
   iupluacmd.lastfilename = fd.value
   iupluacmd.lblFileName.title = iupluacmd.lastfilename
   fd:destroy()
   if status ~= "-1" then 
      if (iupluacmd.lastfilename == nil) then
         error ("Cannot Save file "..filename)
      end
      local newfile=io.open(iupluacmd.lastfilename, "w+")
      if (newfile ~= nil) then
         newfile:write(iupluacmd.mlCode.value)
         newfile:close(newfile)
      else
         error ("Cannot Save file")
      end
   end
end

iupluacmd.butLoadFile.action = function ()
   local fd=iup.filedlg{dialogtype="OPEN", title="Load File", 
                        filter="*.lua", filterinfo="Lua Files", allownew="NO"}
   fd:popup(iup.CENTER, iup.CENTER)
   local status = fd.status
   local filename = fd.value
   fd:destroy()
   if (status == "-1") or (status == "1") then 
      if (status == "1") then
         error ("Cannot load file "..filename)
      end
   else
      local newfile = io.open (filename, "r")
      if (newfile == nil) then
         error ("Cannot load file "..filename)
      else
         iupluacmd.mlCode.value=newfile:read("*a") 
         newfile:close (newfile) 
         iupluacmd.lastfilename = filename
         iupluacmd.lblFileName.title = iupluacmd.lastfilename
      end
   end
end

iupluacmd.vbxConsole = iup.vbox 
{
   iup.frame{iup.hbox{iup.vbox{iupluacmd.butLoadFile, 
                               iupluacmd.butSaveFile, 
                               iupluacmd.butSaveasFile, 
                               iupluacmd.butClearCommands, 
                               iupluacmd.butExecute; 
                               margin="0x0", gap="10"}, 
                      iup.vbox{iupluacmd.lblFileName, 
                               iupluacmd.mlCode, 
                               iupluacmd.lblPosition; 
                               alignment = "ARIGHT"}; 
                      alignment="ATOP"}; title="Commands"}
   ;alignment="ACENTER", margin="5x5", gap="5" 
}

-- Main Menu Definition.

iupluacmd.mnuMain = iup.menu
{
   iup.submenu
   {
      iup.menu
      {
          iup.item{title="Exit", action="return iup.CLOSE"}
      }; title="File"
   },
   iup.submenu{iup.menu
   {
      iup.item{title="Print Version Info...", action=iupluacmd.print_version_info},
      iup.item{title="About...", action="iupluacmd.dlgAbout:popup(iup.CENTER, iup.CENTER)"}
   };title="Help"}
}

-- Main Dialog Definition.

iupluacmd.dlgMain = iup.dialog{iupluacmd.vbxConsole; 
                               title="IupLua Console", 
                               menu=iupluacmd.mnuMain, 
                               defaultenter=iupluacmd.butExecute,
                               close_cb = "return iup.CLOSE"}

-- About Dialog Definition.

iupluacmd.dlgAbout = iup.dialog 
{
   iup.vbox
   {
      iup.label{title="IupLua5 Console"}, 
      iup.fill{size="5"},
      iup.fill{size="5"},
      iup.frame
      {
          iup.vbox
          {
              iup.label{title="Tecgraf/PUC-Rio"},
              iup.label{title="iup@tecgraf.puc-rio.br"} 
          }
      },
      iup.fill{size="5"},
      iup.button{title="OK", action="return iup.CLOSE", size="50X20"} 
      ;margin="10x10", alignment="ACENTER" 
   }
   ;maxbox="NO", minbox="NO", resize="NO", title="About"
}

-- Displays the Main Dialog 

iupluacmd.dlgMain:show()
iup.SetFocus(iupluacmd.mlCode)

iup.MainLoop()

iupluacmd.dlgMain:destroy()
iupluacmd.dlgAbout:destroy()
----------------------------------------------------------------------------
--  Callback return values              
----------------------------------------------------------------------------
IGNORE = -1
DEFAULT = -2
CLOSE = -3
CONTINUE = -4

----------------------------------------------------------------------------
--  IupPopup e IupShowXY        
----------------------------------------------------------------------------
CENTER = 65535
LEFT = 65534
RIGHT = 65533
MOUSEPOS = 65532
CURRENT = 65531
CENTERPARENT = 65530
TOP = LEFT
BOTTOM = RIGHT
ANYWHERE = CURRENT

----------------------------------------------------------------------------
--  Scrollbar
----------------------------------------------------------------------------
SBUP      = 0  
SBDN      = 1  
SBPGUP    = 2  
SBPGDN    = 3  
SBPOSV    = 4  
SBDRAGV   = 5  
SBLEFT    = 6  
SBRIGHT   = 7  
SBPGLEFT  = 8  
SBPGRIGHT = 9  
SBPOSH    = 10 
SBDRAGH   = 11 

----------------------------------------------------------------------------
--  SHOW_CB                      
----------------------------------------------------------------------------
SHOW = 0
RESTORE = 1
MINIMIZE = 2
MAXIMIZE = 3
HIDE = 4

----------------------------------------------------------------------------
--  BUTTON_CB        
----------------------------------------------------------------------------
BUTTON1 = string.byte('1')
BUTTON2 = string.byte('2')
BUTTON3 = string.byte('3')
BUTTON4 = string.byte('4')
BUTTON5 = string.byte('5')

----------------------------------------------------------------------------
--  IupOpen
----------------------------------------------------------------------------
ERROR = 1
NOERROR = 0
OPENED = -1
INVALID = -1
------------------------------------------------------------------------------
-- Template to create control classes for IupLua5
-- The Lua module is used by the "generator.lua" to build a C module,
-- and loaded during iuplua_open to initialize the control.
------------------------------------------------------------------------------
local ctrl = {
  nick = "mycontrol", -- name of the control, used in the control creation: iup.mycontrol{}
                      -- also used for the generated C module
  parent = WIDGET, -- used to define a few methods used fro creation and set attribute
  creation = "nn", -- the creation parameters in Lua
      -- "n"  = int
      -- "d" = double
      -- "s" = char*
      -- "S" = optional char*, can be nil
      -- "i" = Ihandle*
      -- "-" = NULL, no parameters in Lua, but a NULL parameter in C
      -- "a" = char* array in a table
      -- "t" = int array in a table
      -- "v" = Ihandle* array in a table
      
  funcname = "myControl", -- [optional] name of the function used in C  
                          -- default is ctrl.nick with first letter uppercase
                          
  callback = {            -- partial list of callbacks
                          -- only the callbacks that are not already defined by other controls needs to be defined
    action = "ff",
    button_cb = "nnnns",
    enterwindow_cb = "",
    leavewindow_cb = "",
    motion_cb = "nns",
    resize_cb = "nn",
    scroll_cb = "nff",
    keypress_cb = "nn",
    wom_cb = "n",
    wheel_cb = "fnns",
    mdiactivate_cb = "",
    focus_cb = "n",
    value_cb = {"nn", ret = "s"}, -- ret is return type, default is n ("int")

 -- the following types can be used for callback parameters:    
 -- n = "int",
 -- s = "char *",
 -- i = "Ihandle *",
 -- c = "unsigned char ",
 -- d = "double",
 -- f = "float",
 -- v = "Ihandle **",
 --
 -- Other parameters must be implemented in C using the extrafuncs module
 
 -- IMPORTANT: callbacks with the same name in different controls
 -- are assumed to have the same parameters, that's why they are defined only once
 -- When callbacks conflict using the same name, but different parameters
 -- generator.lua must be edited to include the callback in the list of conflicting callbacks
 -- "action" is a common callback that conflicts
 -- In the callback list, just declare the callback with the parameters used in that control.
  }
  
  include = "iupmycontrol.h", -- [optional] header to be included, it is where the creation function is declared.
  extrafuncs = 1, -- [optional] additional module in C called by the initialization function
  
  createfunc = [[         -- [optional] creation function in C, 
                          -- used if creation parameters needs some interpretation in C
                          -- not to be used together with funcname
#include<stdlib.h>
static int myControl (lua_State * L)
{
  xxxx;
  yyyy;
  return 1;
} 
]]

  extracode = [[        -- [optional] extra fucntions to be defined in C.
int luaopen_iupluamycontrol51(lua_State* L)
{
  return iupmycontrollua_open(L);
}
]]

}

-- must be defined so the WIDGET constructor can call it
function ctrl.createElement(class, arg)  
   return myControl()
end

-- here you can add some custom methods to the class
function ctrl.popup(handle, x, y)
  Popup(handle,x,y)
end

iupRegisterWidget(ctrl) -- will make iup.mycontrol available
iupSetClass(ctrl, "iup widget") -- register the class in the registry
------------------------------------------------------------------------------
-- Dial class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "dial",
  parent = WIDGET,
  creation = "s",
  callback = {
     mousemove_cb = "d",       -- already registered by the val, but has a name conflict
--     button_press_cb = "d",    -- already registered by the val
--     button_release_cb = "d",  -- already registered by the val
  },
  include = "iupdial.h",
}

function ctrl.createElement(class, arg)
   return Dial(arg[1])
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- Dialog class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "dialog",
  parent = WIDGET,
  creation = "i",
  callback = {
    map_cb = "",
    close_cb = "",
    show_cb = "n",
    trayclick_cb = "nnn",
    dropfiles_cb = "snnn",
  }
}

function ctrl.createElement(class, arg)
   return Dialog(arg[1])
end

function ctrl.popup(handle, x, y)
  Popup(handle,x,y)
end

function ctrl.showxy(handle, x, y)
  return ShowXY(handle, x, y)
end

function ctrl.destroy(handle)
  return Destroy(handle)
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- FileDlg class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "filedlg",
  parent = WIDGET,
  creation = "",
  callback = {
    file_cb = "ss",
  },
  funcname = "FileDlg"
} 

function ctrl.popup(handle, x, y)
  Popup(handle,x,y)
end

function ctrl.destroy(handle)
  return Destroy(handle)
end

function ctrl.createElement(class, arg)
   return FileDlg()
end
   
iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")

------------------------------------------------------------------------------
-- Fill class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "fill",
  parent = WIDGET,
  creation = "",
  callback = {}
}

function ctrl.createElement(class, arg)
   return Fill()
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- FontDlg class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "fontdlg",
  parent = WIDGET,
  creation = "",
  funcname = "FontDlg",
  callback = {}
} 

function ctrl.popup(handle, x, y)
  Popup(handle,x,y)
end

function ctrl.destroy(handle)
  return Destroy(handle)
end

function ctrl.createElement(class, arg)
   return FontDlg()
end
   
iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")

------------------------------------------------------------------------------
-- Frame class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "frame",
  parent = WIDGET,
  creation = "i",
  callback = {}
}

function ctrl.createElement(class, arg)
   return Frame(arg[1])
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- Gauge class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "gauge",
  parent = WIDGET,
  creation = "",
  callback = {},
  include = "iupgauge.h",
}

function ctrl.createElement(class, arg)
   return Gauge(arg.action)
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")

function dofile(f)
    pcall(loadfile(f))
end

-- compatibility functions (with iuplua.lua)
function iupSetClass(ctrl, name)
  element = ctrl
end

-- dummy functions
iupluaNewClass = function() end
iupSetMethod = iupluaNewClass
iupRegisterWidget = iupluaNewClass

c_types = {
  n = "int",
  s = "char *",
  i = "Ihandle *",
  c = "unsigned char ",
  d = "double",
  f = "float",
  v = "Ihandle **",
}

-- Adjust the callbacks table
function adjustcallbacktable(c)
   d = {}
   for i,j in pairs(c) do
      if type(j) == "string" then
         d[i] = { j, "IUP_".. string.upper(i)}
      elseif type(j) == "table" then
         d[i] = j
      else
         print("ERROR IN CALLBACK TABLE FORMAT")
      end
   end
   return d
end


function header(o,i)
   io.write [[
/******************************************************************************
 * Automatically generated file (iuplua5). Please don't change anything.                *
 *****************************************************************************/

#include <stdlib.h>

#include <lua.h>
#include <lauxlib.h>

#include <iup.h>
#include <iuplua.h>
]]
  if i then io.write("#include <",i,">\n") end
  io.write('#include "il.h"\n\n\n')
end

function firstupper(name)
   return string.upper(string.sub(name,1,1)) .. string.sub(name,2,-1)
end

function write_creation(o, t)
   local aux = {n = 1}
   local u = firstupper(o)
   local v = t.creation
   local c = t.callback
   if t.funcname then
      u = t.funcname
   end
   io.write ("static int ",u,"(lua_State *L)\n")
   io.write ("{\n") 
   if t.rettype == nil then io.write("  Ihandle *ih = Iup",u,"(")
   elseif t.rettype == "n" then io.write("  int n = (Iup",u,"(")
   elseif t.rettype == "s" then io.write("  char *s = (Iup",u,"(")
   end
   local max = string.len(v)
   string.gsub(v, "(.)", function(p)
      if p == "n" then io.write("luaL_checkint(L, ",aux.n,")")
      elseif p == "d" then io.write("luaL_number(L, ",aux.n,")")
      elseif p == "s" then io.write("(char *) luaL_checkstring(L, ",aux.n,")")
      elseif p == "S" then io.write("(char *) luaL_optstring(L, ",aux.n,', NULL)')
      elseif p == "i" then io.write("iuplua_checkihandle(L, ",aux.n,")")
      elseif p == "-" then io.write("NULL")
      elseif p == "a" then io.write("iuplua_checkstring_array(L, ",aux.n,")")
      elseif p == "t" then io.write("iuplua_checkint_array(L, ",aux.n,")")
      elseif p == "v" then io.write("iuplua_checkihandle_array(L, ",aux.n,")")
      else io.write("FORMAT '", p, "' NOT SUPPORTED\n")
      end
      if aux.n < max then io.write(", ") end
      aux.n = aux.n + 1
   end)
   io.write(");\n")
   
   io.write("  iuplua_plugstate(L, ih);\n")
   io.write("  iuplua_pushihandle_raw(L, ih);\n")
   io.write("  return 1;\n")
   io.write("}\n\n")
end

function write_callbacks(o, c)
   local aux = { }
   for i,v in pairs(c) do
      local s = v[1]
      local max = string.len(s)
      aux.n = 0
      io.write("static ")
      if v.ret ~= nil then
         if v.ret == "s" then
            io.write("char * ")
         end
      else
         io.write("int ")
      end
      io.write(o, "_", i, "(Ihandle *self")
      if max > 0 then io.write(", ") end
      string.gsub(s, "(.)", function(p)
         io.write(c_types[p], " p", aux.n)
         aux.n = aux.n + 1
         if aux.n < max then io.write(", ") end
      end)
      io.write(")\n{\n")
      io.write('  lua_State *L = iuplua_call_start(self, "', i, '");')
      aux.n = 0
      string.gsub(s, "(.)", function(p)
         if p == "n" or p == "f" or p == "d" or p == "c" then
            io.write("\n  lua_pushnumber(L, p"..aux.n..");")
         elseif p == "s" then
            io.write("\n  lua_pushstring(L, p"..aux.n..");")
         elseif p == "i" then
            io.write("\n  iuplua_pushihandle(L, p"..aux.n..");")
         else
            io.write("\n ERROR !! ")
         end
         aux.n = aux.n + 1
      end)
      if v.ret ~= nil and v.ret == "s" then
        io.write("\n  return iuplua_call_rs(L, " .. max .. ");")
      else   
        io.write("\n  return iuplua_call(L, " .. max .. ");")
      end
      io.write("\n}\n\n")
   end
end

function write_initialization(o,t)
   local aux= {n=1}
   local c = t.callback
   local u = firstupper(o)
   if t.extrafuncs then
      io.write('void iuplua_', o,'funcs_open(lua_State *L);\n\n')
   end
   if t.openfuncname then
      io.write("void ", t.openfuncname, "(lua_State * L)\n")
   else
      io.write("int iup", o,"lua_open(lua_State * L)\n")
   end
   io.write("{\n")
   io.write("  iuplua_register(L, ")
   if t.funcname then
      u = t.funcname
   end
   io.write(u, ', "', u,'");\n\n')
   
   for i,v in pairs(c) do
      local type = "NULL"
      if i == "action" or 
         i == "action_cb" or 
         i == "edit_cb" or 
         i == "mousemove_cb" then
        type = '"'..string.lower(o)..'"'
      end
      io.write('  iuplua_register_cb(L, "',string.upper(i),'", (lua_CFunction)',o,'_',i,', ',type,');\n')
      first = 0
   end
   io.write('\n')
   
   if t.extrafuncs then
      io.write('  iuplua_', o,'funcs_open(L);\n\n')
   end
   io.write('#ifdef IUPLUA_USELOH\n')
   io.write('#ifdef TEC_BIGENDIAN\n')
   io.write('#ifdef TEC_64\n')
   io.write('#include "', o,'_be64.loh"\n')
   io.write('#else\n')
   io.write('#include "', o,'_be32.loh"\n')
   io.write('#endif\n')
   io.write('#else\n')
   io.write('#ifdef TEC_64\n')
   io.write('#ifdef WIN64\n')
   io.write('#include "', o,'_le64w.loh"\n')
   io.write('#else\n')
   io.write('#include "', o,'_le64.loh"\n')
   io.write('#endif\n')
   io.write('#else\n')
   io.write('#include "', o,'.loh"\n')
   io.write('#endif\n')
   io.write('#endif\n')
   io.write('#else\n')
   io.write('  iuplua_dofile(L, "', o,'.lua");\n')
   io.write('#endif\n\n')  
   io.write('  return 0;\n')
   io.write("}\n\n")
end

dofile(arg[1])
element.callback = adjustcallbacktable(element.callback)

io.output(element.nick..".c")
header(element.nick, element.include)
write_callbacks(element.nick, element.callback)
if element.createfunc == nil then 
   write_creation(element.nick, element)
else 
   io.write(element.createfunc) 
end
write_initialization(element.nick, element)
if element.extracode then 
   io.write(element.extracode) 
end
------------------------------------------------------------------------------
-- GLCanvas class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "glcanvas",
  parent = WIDGET,
  creation = "-",
  funcname = "GLCanvas",
  include = "iupgl.h",
  callback = {
    action = "nn",
  },
  extrafuncs = 1,
  extracode = [[ 
int iupgllua_open(lua_State * L)
{
  if (iuplua_opencall_internal(L))
    IupGLCanvasOpen();

  iuplua_changeEnv(L);
  iupglcanvaslua_open(L);
  iuplua_returnEnv(L);
  return 0;
}

/* obligatory to use require"iupluagl" */
int luaopen_iupluagl(lua_State* L)
{
  return iupgllua_open(L);
}

/* obligatory to use require"iupluagl51" */
int luaopen_iupluagl51(lua_State* L)
{
  return iupgllua_open(L);
}

]]
}

function ctrl.createElement(class, arg)
   return GLCanvas()
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- HBox class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "hbox",
  parent = BOX,
  creation = "-",
  callback = {}
}

function ctrl.append(handle, elem)
  Append(handle, elem)
end

function ctrl.createElement(class, arg)
   return Hbox()
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- Image class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "image",
  parent = WIDGET,
  creation = "nns", -- fake definition
  callback = {},
  createfunc = [[ 
#include<stdlib.h>
static int Image (lua_State * L)
{
  int w, h, i, j;
  char *img;
  Ihandle *image;
  
  h = luaL_getn(L, 1);
  lua_pushnumber(L, 1);
  lua_gettable(L, 1);
  w = luaL_getn(L, -1);
  lua_pop(L, 1);
  
  img = (char *) malloc (h*w);

  for (i=1; i<=h; i++)
  {
    lua_pushnumber(L, i);
    lua_gettable(L, 1);
    for (j=1; j<=w; j++)
    {
      int idx = (i-1)*w+(j-1);
      lua_pushnumber(L, j);
      lua_gettable(L, -2);
      img[idx] = (char)lua_tonumber(L, -1);
      lua_pop(L, 1);
    }
    lua_pop(L, 1);
  }
  
  image = IupImage(w,h,img);  
  free(img);

  w = luaL_getn(L, 2);

  for(i=1; i<=w; i++)
  {
    lua_pushnumber(L,i);
    lua_pushnumber(L,i);
    lua_gettable(L, 2);
    IupStoreAttribute(image, (char *) lua_tostring(L,-2), (char *) lua_tostring(L,-1));
    lua_pop(L, 2);
  }
  
  iuplua_plugstate(L, image);
  iuplua_pushihandle_raw(L, image);
  return 1;
} 
 
]]
}

function ctrl.createElement(class, arg)
   return Image(arg, arg.colors)
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- ImageRGB class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "imagergb",
  parent = WIDGET,
  creation = "nns", -- fake definition
  funcname = "ImageRGB", 
  callback = {},
  createfunc = [[ 
static int ImageRGB(lua_State *L)
{
  int w = luaL_checkint(L, 1);
  int h = luaL_checkint(L, 2);
  unsigned char *pixels = iuplua_checkuchar_array(L, 3, w*h*3);
  Ihandle *ih = IupImageRGB(w, h, pixels);
  iuplua_plugstate(L, ih);
  iuplua_pushihandle_raw(L, ih);
  free(pixels);
  return 1;
}
 
]]
}

function ctrl.createElement(class, arg)
   return ImageRGB(arg.width, arg.height, arg.pixels)
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- ImageRGBA class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "imagergba",
  parent = WIDGET,
  creation = "nns", -- fake definition
  funcname = "ImageRGBA", 
  callback = {},
  createfunc = [[ 
static int ImageRGBA(lua_State *L)
{
  int w = luaL_checkint(L, 1);
  int h = luaL_checkint(L, 2);
  unsigned char *pixels = iuplua_checkuchar_array(L, 3, w*h*4);
  Ihandle *ih = IupImageRGBA(w, h, pixels);
  iuplua_plugstate(L, ih);
  iuplua_pushihandle_raw(L, ih);
  free(pixels);
  return 1;
}
 
]]
}

function ctrl.createElement(class, arg)
   return ImageRGBA(arg.width, arg.height, arg.pixels)
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- Item class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "item",
  parent = WIDGET,
  creation = "S-",
  callback = {
    action = "", 
    highlight_cb = "",
  }
} 

function ctrl.createElement(class, arg)
   return Item(arg.title)
end
   
iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
-- This file is executed with the "iup" table already as the globalindex

------------------------------------------------------------------------------
-- Callback handler  
------------------------------------------------------------------------------

callbacks = {}

function iupCallMethod(name, ...)
  local handle = arg[1] -- always the handle
  local func = handle[name]
  if (not func) then
    return
  end
  
  if type(func) == "function" then
    return func(unpack(arg))
  elseif type(func) == "string" then  
    local temp = self
    self = handle
    local result = iup.dostring(func)
    self = temp
    return result
  else
    return iup.ERROR
  end
end

function RegisterCallback(name, func, type)
  if not callbacks[name] then callbacks[name] = {} end
  local cb = callbacks[name]
  if type then
    cb[type] = func
  else
    cb[1] = func
  end
end

------------------------------------------------------------------------------
-- Meta Methods 
------------------------------------------------------------------------------


local widget_gettable = function(object, index)
  local p = object
  local v
  while 1 do
    v = rawget(p, index)
    if v then return v end
    p = rawget(p, "parent")
      if not p then return nil end
  end
end

iupNewClass("iup widget")
iupSetMethod("iup widget", "__index", widget_gettable)


local ihandle_gettable = function(handle, index)
  local INDEX = string.upper(index)
  if (callbacks[INDEX]) then 
   local object = iupGetWidget(handle)
   if (not object or type(object)~="table") then error("invalid iup handle") end
   return object[index]
  else
    local value = GetAttribute(handle, INDEX)
    if (not value) then
      local object = iupGetWidget(handle)
      if (not object or type(object)~="table") then error("invalid iup handle") end
      return object[index]
    elseif type(value)== "number" or type(value) == "string"  then
      local ih = GetHandle(value)
      if ih then return ih
      else return value end
    else
      return value 
    end
  end
end

local ihandle_settable = function(handle, index, value)
  local ti = type(index)
  local tv = type(value)
  local object = iupGetWidget(handle)
  if (not object or type(object)~="table") then error("invalid iup handle") end
  if ti == "number" or ti == "string" then -- check if a valid C name
    local INDEX = string.upper(index)
    local cb = callbacks[INDEX]
    if (cb) then -- if a callback name
      local func = cb[1]
      if (not func) then
        func = cb[GetType(handle)]
      end
      iupSetCallback(handle, INDEX, func, value) -- register the pre-defined C callback
      object[index] = value -- store also in Lua
    elseif iupGetClass(value) == "iup handle" then -- if a iup handle
      local name = ihandle_setname(value)
      StoreAttribute(handle, INDEX, name)
      object[index] = nil -- if there was something in Lua remove it
    elseif tv == "string" or tv == "number" or tv == "nil" then -- if a common value
      StoreAttribute(handle, INDEX, value)
      object[index] = nil -- if there was somthing in Lua remove it
    else
      object[index] = value -- store also in Lua
    end
  else
    object[index] = value -- store also in Lua
  end
end

iupNewClass("iup handle")
iupSetMethod("iup handle", "__index", ihandle_gettable)
iupSetMethod("iup handle", "__newindex", ihandle_settable)
iupSetMethod("iup handle", "__tostring", ihandle_tostring)
iupSetMethod("iup handle", "__eq", ihandle_compare) -- implemented in C


------------------------------------------------------------------------------
-- Utilities 
------------------------------------------------------------------------------

function ihandle_setname(v)  -- used also by radio and zbox
  local name = GetName(v)
  if not name then
    local autoname = string.format("_IUPLUA_NAME(%s)", tostring(v))
    SetHandle(autoname, v)
    return autoname
  end
  return name
end

function iupRegisterWidget(ctrl) -- called by all the controls initialization functions
  iup[ctrl.nick] = function(arg)
    return ctrl:constructor(arg)
  end
end

function RegisterHandle(handle, typename)

  iupSetClass(handle, "iup handle")
  
  local object = iupGetWidget(handle)
  if not object then

    local class = iup[string.upper(typename)]
    if not class then
      class = WIDGET
    end

    local object = { parent=class, handle=handle }
    iupSetClass(object, "iup widget")
    iupSetWidget(handle, object)
  end
  
  return handle
end

------------------------------------------------------------------------------
-- Widget class (top class) 
------------------------------------------------------------------------------

WIDGET = {
  callback = {}
}

function WIDGET.show(object)
  Show(object.handle)
end

function WIDGET.hide(object)
  Hide(object.handle)
end

function WIDGET.map(object)
  Map(object.handle)
end

function WIDGET.constructor(class, arg)
  local handle = class:createElement(arg)
  local object = { 
    parent = class,
    handle = handle
  }
  iupSetClass(handle, "iup handle")
  iupSetClass(object, "iup widget")
  iupSetWidget(handle, object)
  object:setAttributes(arg)
  return handle
end

function WIDGET.setAttributes(object, arg)
  local handle = object.handle
  for i,v in pairs(arg) do 
    if type(i) == "number" and iupGetClass(v) == "iup handle" then
      -- We should not set this or other elements (such as iuptext)
      -- will erroneosly inherit it
      rawset(object, i, v)
    else
      -- this will call settable metamethod
      handle[i] = v
    end
  end
end

-- all the objects in the hierarchy must be "iup widget"
-- Must repeat this call for every new widget
iupSetClass(WIDGET, "iup widget")


------------------------------------------------------------------------------
-- Box class (inherits from WIDGET) 
------------------------------------------------------------------------------

BOX = {
  parent = WIDGET
}

function BOX.setAttributes(object, arg)
  local handle = rawget(object, "handle")
  local n = table.getn(arg)
  for i = 1, n do
    if iupGetClass(arg[i]) == "iup handle" then 
      Append(handle, arg[i]) 
    end
  end
  WIDGET.setAttributes(object, arg)
end

iupSetClass(BOX, "iup widget")


------------------------------------------------------------------------------
-- Compatibility functions.
------------------------------------------------------------------------------

error_message_popup = nil

function _ERRORMESSAGE(err)
  if (error_message_popup) then
    error_message_popup.value = err
  else  
    local bt = button{title="Ok", size="60", action="error_message_popup = nil; return iup.CLOSE"}
    local ml = multiline{expand="YES", readonly="YES", value=err, size="300x150"}
    local vb = vbox{ml, bt; alignment="ACENTER", margin="10x10", gap="10"}
    local dg = dialog{vb; title="Error Message",defaultesc=bt,defaultenter=bt,startfocus=bt}
    error_message_popup = ml
    dg:popup(CENTER, CENTER)
    dg:destroy()
    error_message_popup = nil
  end
end

pack = function (...) return arg end

function protectedcall_(f, err)
  if not f then 
    _ERRORMESSAGE(err)
    return 
  end
  local ret = pack(pcall(f))
  if not ret[1] then 
    _ERRORMESSAGE(ret[2])
    return
  else  
    table.remove(ret, 1)
    return unpack(ret)
  end
end

function dostring(s) return protectedcall_(loadstring(s)) end
function dofile(f) return protectedcall_(loadfile(f)) end

function RGB(r, g, b)
  return string.format("%d %d %d", 255*r, 255*g, 255*b)
end
------------------------------------------------------------------------------
-- Label class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "label",
  parent = WIDGET,
  creation = "S",
  callback = {}
}

function ctrl.createElement(class, arg)
   return Label(arg.title)
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- List class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "list",
  parent = WIDGET,
  creation = "-",
  callback = {
     action = "snn", 
     multiselect_cb = "s",
     edit_cb = "ns",
   }
} 

function ctrl.createElement(class, arg)
   return List()
end
   
iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- Matrix class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "matrix",
  parent = WIDGET,
  creation = "-",
  callback = {
    action_cb = "nnnns",
    click_cb = "nns",
    release_cb = "nns",
    drop_cb = "inn",
    dropcheck_cb = "nn",
    draw_cb = "nnnnnnn",  -- fake definitions to be replaced by matrixfuncs module
    dropselect_cb = "nnisnn",
    edition_cb = "nnn",
    enteritem_cb = "nn",
    leaveitem_cb = "nn",
    mousemove_cb = "nn",
    scrolltop_cb = "nn",
    fgcolor_cb = "nn",  -- fake definitions to be replaced by matrixfuncs module
    bgcolor_cb = "nn",
    value_cb = {"nn", ret = "s"}, -- ret is return type
    value_edit_cb = "nns",
    mark_cb = "nn",
    markedit_cb = "nnn",
  },
  include = "iupmatrix.h",
  extrafuncs = 1,
}

function ctrl.createElement(class, arg)
   return Matrix(arg.action)
end

function ctrl.setcell(handle, l, c, val)
  SetAttribute(handle,l..":"..c,val)
end

function ctrl.getcell(handle, l, c)
  return GetAttribute(handle,l..":"..c)
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- Menu class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "menu",
  parent = BOX,
  creation = "-",
  callback = {
    open_cb = "",
    menuclose_cb = "",
  }
}

function ctrl.popup(handle, x, y)
  Popup(handle, x, y)
end

function ctrl.append(handle, elem)
  Append(handle, elem)
end

function ctrl.createElement(class, arg)
  local n = table.getn(arg)
  for i=1,n do
    if type(arg[i]) == "table" then 
      itemarg = {}
      for u,v in pairs(arg[i]) do
        if type(u) ~= "number" then
          itemarg[u] = v
        end
      end
      if type(arg[i][1]) == "string" and (type(arg[i][2]) == "function" or type(arg[i][2]) == "string") then
        itemarg.title = arg[i][1]
        itemarg.action = arg[i][2]
        arg[i] = item(itemarg)
      elseif type(arg[i][1]) == "string" and type(arg[i][2]) == "userdata" then
        itemarg[1] = arg[i][2]
        itemarg.title = arg[i][1]
        arg[i] = submenu(itemarg)
      end
    end
  end
   return Menu()
end

function ctrl.showxy(handle, x, y)
  return ShowXY(handle, x, y)
end

function ctrl.destroy(handle)
  return Destroy(handle)
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- MessageDlg class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "messagedlg",
  parent = WIDGET,
  creation = "",
  funcname = "MessageDlg",
  callback = {}
} 

function ctrl.popup(handle, x, y)
  Popup(handle,x,y)
end

function ctrl.destroy(handle)
  return Destroy(handle)
end

function ctrl.createElement(class, arg)
   return MessageDlg()
end
   
iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")

------------------------------------------------------------------------------
-- Multiline class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "multiline",
  parent = WIDGET,
  creation = "-",
  callback = {
    action = "ns", 
  },
  funcname = "MultiLine",
} 

function ctrl.createElement(class, arg)
   return MultiLine()
end
   
iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- OleControl class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "olecontrol",
  parent = WIDGET,
  creation = "s",
  funcname = "OleControl",
  callback = {},
  include = "iupole.h",
  extracode = [[ 
int iupolelua_open(lua_State* L)
{
  if (iuplua_opencall_internal(L))
    IupOleControlOpen();
    
  iuplua_changeEnv(L);
  iupolecontrollua_open(L);
  iuplua_returnEnv(L);
  return 0;
}

/* obligatory to use require"iupluaole" */
int luaopen_iupluaole(lua_State* L)
{
  return iupolelua_open(L);
}

/* obligatory to use require"iupluaole51" */
int luaopen_iupluaole51(lua_State* L)
{
  return iupolelua_open(L);
}

]]
}

function ctrl.createElement(class, arg)
  local ctl = OleControl(arg[1])
   
  -- if luacom is loaded, use it to access methods and properties
  -- of the control
  if luacom then
    local punk = ctl.iunknown
    if punk then
      ctl.com = luacom.MakeLuaCOM(luacom.MakeIUnknown(punk))
    end     
  end
   
  return ctl
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- PPlot class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "pplot",
  parent = WIDGET,
  creation = "",
  funcname = "PPlot",
  callback = {
    select_cb = "nnffn",
    selectbegin_cb = "",
    selectend_cb = "",
    predraw_cb = "n",   -- fake definitions to be replaced by pplotfuncs module
    postdraw_cb = "n",  -- fake definitions to be replaced by pplotfuncs module
    edit_cb = "nnffff",  -- fake definitions to be replaced by pplotfuncs module
    editbegin_cb = "",
    editend_cb = "",
    delete_cb = "nnff",
    deletebegin_cb = "",
    deleteend_cb = "",
  },
  include = "iup_pplot.h",
  extrafuncs = 1,
}

function ctrl.createElement(class, arg)
   return PPlot(arg.action)
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
----------------------------------------------------
-- The main porpouse of this file is to build linux gcc makefiles.
-- Must have Premake version 3 installed.
-- Original Premake was changed to remove some parameters and add others.
-- Default parameters:
--   premake3s --target gnu --os linux
-- But it can build windows gcc makefiles, and visual studio projects.
--   premake3s --target gnu --os windows
--   premake3s --target gnu --os macosx
--   premake3s --target vs6
--   premake3s --target vs2002
--   premake3s --target vs2003
--   premake3s --target vs2005
-- In Linux the generated makefiles will not correctly build libraries in 64-bits.
--              must add "-m64 -fPIC" flags
----------------------------------------------------

if (not options.target) then 
  options.target = "gnu"
end

if (not options.os) then
  if (options.target ~= "gnu") then
    options.os = "windows"
  else
    options.os = "linux"
  end
end

function fixPackagePath(package_files)
  if (options.os ~= "linux") then
    for i, file in package_files do 
      package_files[i] = "../src/"..file 
    end
  end
end

if (options.os ~= "linux") then
  if (options.os == "macosx") then
	project.path = "../mak.macosx"
  else
	project.path = "../mak."..options.target
  end
end

----------------------------------------------------

project.name = "iup"
project.bindir = "../bin"
project.libdir = "../lib"

----------------------------------------------------

package = newpackage()
package.name = "iuplua51"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "lib"
package.buildflags = { "static-runtime" }

package.files =
{
  "iuplua.c", "scanf.c", "iuplua_api.c", "fontdlg.c", 
  "button.c", "canvas.c", "dialog.c", "messagedlg.c", 
  "filedlg.c", "fill.c", "frame.c", "hbox.c",
  "item.c", "image.c", "label.c", "menu.c", "multiline.c",
  "list.c", "separator.c", "radio.c", "colordlg.c", 
  "submenu.c", "text.c", "toggle.c", "vbox.c", "zbox.c", "timer.c"
}
fixPackagePath(package.files)

package.includepaths = { "../include", "../src", "$(LUA51)/include" }
package.defines = {"IUPLUA_USELOH"}

--SRCLUA = iuplua.lua constants.lua $(CTRLUA)
--GC = $(addsuffix .c, $(basename $(CTRLUA)))
--$(GC) : %.c : %.lua %.loh generator.lua
--	lua5 generator.lua $<

---------------------------------------------------------------------

package = newpackage()
package.name = "iupluacontrols51"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "lib"
package.buildflags = { "static-runtime" }

package.files =
{
  "val.c", "dial.c", "gauge.c", "gc.c", "cbox.c", "cells.c", "getparam.c",
  "colorbrowser.c", "tabs.c", "mask.c", "colorbar.c",
  "matrix.c", "tree.c", "sbox.c", "spin.c", "spinbox.c",
  "controls.c", "mask.c", "treefuncs.c", "matrixfuncs.c"
}
fixPackagePath(package.files)

package.includepaths = { "../include", "$(CD)/include", "$(LUA51)/include" }
package.defines = {"IUPLUA_USELOH"}

--SRCLUA = val.lua dial.lua gauge.lua colorbrowser.lua tabs.lua sbox.lua matrix.lua tree.lua spin.lua spinbox.lua

---------------------------------------------------------------------

package = newpackage()
package.name = "iuplua_pplot51"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "lib"
package.buildflags = { "static-runtime" }

package.files =
{
  "pplot.c", "pplotfuncs.c"
}
fixPackagePath(package.files)

package.includepaths = { "../include", "$(CD)/include", "$(LUA51)/include" }
package.defines = {"IUPLUA_USELOH"}

--SRCLUA = pplot.lua

---------------------------------------------------------------------

package = newpackage()
package.name = "iupluagl51"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "lib"
package.buildflags = { "static-runtime" }

package.files =
{
  "glcanvas.c", "glcanvasfuncs.c"
}
fixPackagePath(package.files)

-- SRCLUA = glcanvas.lua

package.includepaths = { "../include", "$(LUA51)/include" }
package.defines = {"IUPLUA_USELOH"}
           
---------------------------------------------------------------------

package = newpackage()
package.name = "iupluaim51"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "lib"
package.buildflags = { "static-runtime" }

package.files =
{
  "iupluaim.c"
}
fixPackagePath(package.files)

package.includepaths = { "../include", "$(LUA51)/include" }

---------------------------------------------------------------------

package = newpackage()
package.name = "iuplua51exe"
package.target = "iuplua51"
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "exe"
package.linkflags = { "static-runtime" }

package.files =
{
  "iupluaexe51.c"
}
fixPackagePath(package.files)

-- SRCLUA = console.lua

package.includepaths = { "../include", "$(LUA51)/include", "$(CD)/include", "$(IM)/include" }

package.links = { "imlua_process51", "im_process", "imlua_cd51", "imlua51", 
                  "cdluaiup51", "cdlua51", 
                  "iupluagl51", "iupluaim51", "iuplua_pplot51.lib", "iupluacontrols51", "iuplua51", 
                  "lua5.1", 
                  "iupgl", "iupim", "iup_pplot.lib", "iupcontrols", 
                  "cdiup", "cd", "iup", "im" }
package.libpaths = { "../lib", "$(IM)/lib", "$(CD)/lib", "$(LUA51)/lib", }
                  
if (options.os == "windows") then
  tinsert(package.links, { "cdgdiplus", "gdiplus", "comctl32", "opengl32", "glu32", "glaux" })
else
  tinsert(package.links, { "GLU", "GL", "Xm", "Xpm", "Xmu", "Xt", "Xext", "X11", "m" })
  tinsert(package.libpaths, { "/usr/X11R6/lib" })
end

---------------------------------------------------------------------
------------------------------------------------------------------------------
-- Radio class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "radio",
  parent = WIDGET,
  creation = "i",
  callback = {}
} 

function ctrl.CreateChildrenNames(obj)
  if obj then
    if obj.parent.parent == BOX then
      local i = 1
      while obj[i] do
        ctrl.CreateChildrenNames (obj[i])
        i = i+1
      end
    elseif obj.parent == IUPFRAME then
      ctrl.CreateChildrenNames (obj[1])
    else
      ihandle_setname(obj)
    end
  end
end

function ctrl.createElement(class, arg)
   ctrl.CreateChildrenNames(arg[1])
   return Radio(arg[1])
end
   
iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- Sbox class 
------------------------------------------------------------------------------
local ctrl = {
	nick = "sbox",
  parent = WIDGET,
	creation = "i",
  callback = {},
  include="iupsbox.h"
}

function ctrl.createElement(class, arg)
   return Sbox(arg[1])
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- Separator class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "separator",
  parent = WIDGET,
  creation = "",
  callback = {}
}

function ctrl.createElement(class, arg)
   return Separator()
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- Spin class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "spin",
  parent = WIDGET,
  creation = "",
  callback = {
    spin_cb = "n",
  },
  include = "iupspin.h",
}

function ctrl.createElement(class, arg)
   return Spin(arg.action)
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- SpinBox class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "spinbox",
  parent = WIDGET,
  creation = "i",
  callback = {
    spin_cb = "n",
  },
  include = "iupspin.h",
}

function ctrl.createElement(class, arg)
   return Spinbox(arg[1])
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- Submenu class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "submenu",
  parent = WIDGET,
  creation = "Si",
  callback = {
--    open_cb = "",       -- already registered by the menu
--    menuclose_cb = "",  -- already registered by the menu
  }
} 

function ctrl.createElement(class, arg)
  return Submenu(arg.title, arg[1])
end
   
iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- Tabs class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "tabs",
  parent = WIDGET,
  creation = "v",
  callback = {
    tabchange_cb = "ii",
  },
  include = "iuptabs.h",
  funcname = "Tabsv",
  createfunc = [[
static int Tabsv(lua_State *L)
{
  Ihandle **hlist = iuplua_checkihandle_array(L, 1);
  Ihandle *h = IupTabsv(hlist);
  iuplua_plugstate(L, h);
  iuplua_pushihandle_raw(L, h);
  free(hlist);
  return 1;
}

]],
}

function ctrl.createElement(class, arg)
  return Tabsv(arg)
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- Text class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "text",
  parent = WIDGET,
  creation = "-", 
  callback = {
    action = "ns",
    caret_cb = "nn", 
  }
}

function ctrl.createElement(class, arg)
   return Text()
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- Timer class 
------------------------------------------------------------------------------
local ctrl = {
  nick     = "timer",
  parent   = WIDGET,
  creation = "",
  callback = {
    action_cb = "", 
  },
} 

function ctrl.createElement(class, arg)
  return Timer()
end
   
iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- Toggle class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "toggle",
  parent = WIDGET,
  creation = "S-",
  callback = {
    action = "n",
  }
} 

function ctrl.createElement(class, arg)
  return Toggle(arg.title)
end
   
iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- Tree class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "tree",
  parent = WIDGET,
  creation = "",
  callback = {
    selection_cb = "nn",
    multiselection_cb = "nn",  -- fake definition to be replaced by treefuncs module
    branchopen_cb = "n",
    branchclose_cb = "n",
    executeleaf_cb = "n",
    renamenode_cb = "ns",
    rename_cb = "ns",
    showrename_cb = "n",
    rightclick_cb = "n",
    dragdrop_cb = "nnnn",
  },
  include = "iuptree.h",
  extrafuncs = 1,
}

function TreeSetValueRec(handle, t, id)
  if t == nil then return end
  local cont = table.getn(t)
  while cont >= 0 do
    if type (t[cont]) == "table" then
      if t[cont].branchname ~= nil then
        SetAttribute(handle, "ADDBRANCH"..id, t[cont].branchname)
        TreeSetValueRec(handle, t[cont], id+1)
      end
    else
      if t[cont] then
        SetAttribute(handle, "ADDLEAF"..id, t[cont])
      end
    end
    cont = cont - 1
   end
end

function TreeSetValue(handle, t)
  if t.branchname ~= nil then
    SetAttribute(handle, "NAME", t.branchname)
  end
  TreeSetValueRec(handle, t, 0)
end

function ctrl.createElement(class, arg)
  return Tree()
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- Val class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "val",
  parent = WIDGET,
  creation = "s",
  callback = {
    mousemove_cb = "d",
    button_press_cb = "d",
    button_release_cb = "d",
  },
  include = "iupval.h",
}

function ctrl.createElement(class, arg)
   return Val(arg[1])
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- VBox class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "vbox",
  parent = BOX,
  creation = "-",
  callback = {}
}

function ctrl.append (handle, elem)
  Append(handle, elem)
end

function ctrl.createElement(class, arg)
   return Vbox()
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
------------------------------------------------------------------------------
-- ZBox class 
------------------------------------------------------------------------------
local ctrl = {
  nick = "zbox",
  parent = BOX,
  creation = "-",
  callback = {}
}

function ctrl.append (handle, elem)
  ihandle_setname(elem)
  Append(handle, elem)
end

function ctrl.SetChildrenNames(obj)
  if obj then
    local i = 1
    while obj[i] do
      ihandle_setname(obj[i])
      i = i+1
    end
  end
end

function ctrl.createElement(class, arg)
   ctrl.SetChildrenNames(arg)
   return Zbox()
end

iupRegisterWidget(ctrl)
iupSetClass(ctrl, "iup widget")
----------------------------------------------------
-- The main porpouse of this file is to build linux gcc makefiles.
-- Must have Premake version 3 installed.
-- Original Premake was changed to remove some parameters and add others.
-- Default parameters:
--   premake3s --target gnu --os linux
-- But it can build windows gcc makefiles, and visual studio projects.
--   premake3s --target gnu --os windows
--   premake3s --target gnu --os macosx
--   premake3s --target vs6
--   premake3s --target vs2002
--   premake3s --target vs2003
--   premake3s --target vs2005
-- In Linux the generated makefiles will not correctly build libraries in 64-bits.
--              must add "-m64 -fPIC" flags
----------------------------------------------------

if (not options.target) then 
  options.target = "gnu"
end

if (not options.os) then
  if (options.target ~= "gnu") then
    options.os = "windows"
  else
    options.os = "linux"
  end
end

function fixPackagePath(package_files)
  if (options.os ~= "linux") then
    for i, file in package_files do 
      package_files[i] = "../src/"..file 
    end
  end
end

----------------------------------------------------

project.name = "iup"
project.bindir = "../bin"
project.libdir = "../lib"

if (options.os ~= "linux") then
  if (options.os == "macosx") then
	project.path = "../mak.macosx"
  else
	project.path = "../mak."..options.target
  end
end

----------------------------------------------------

package = newpackage()
package.name = "iup_pplot"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "lib"
package.buildflags = { "static-runtime" }

package.includepaths = { ".", "../include" }

package.files = { "iup_pplot.cpp", "PPlot.cpp", "PPlotInteraction.cpp" }
fixPackagePath(package.files)

----------------------------------------------------
----------------------------------------------------
-- The main porpouse of this file is to build linux gcc makefiles.
-- Must have Premake version 3 installed.
-- Original Premake was changed to remove some parameters and add others.
-- Default parameters:
--   premake3s --target gnu --os linux
-- But it can build windows gcc makefiles, and visual studio projects.
--   premake3s --target gnu --os windows
--   premake3s --target gnu --os macosx
--   premake3s --target vs6
--   premake3s --target vs2002
--   premake3s --target vs2003
--   premake3s --target vs2005
-- In Linux the generated makefiles will not correctly build libraries in 64-bits.
--              must add "-m64 -fPIC" flags
----------------------------------------------------

if (not options.target) then 
  options.target = "gnu"
end

if (not options.os) then
  if (options.target ~= "gnu") then
    options.os = "windows"
  else
    options.os = "linux"
  end
end

function fixPackagePath(package_files)
  if (options.os ~= "linux") then
    for i, file in package_files do 
      package_files[i] = "../src/"..file 
    end
  end
end

----------------------------------------------------

project.name = "iup"
project.bindir = "../bin"
project.libdir = "../lib"

if (options.os ~= "linux") then
  if (options.os == "macosx") then
	project.path = "../mak.macosx"
  else
	project.path = "../mak."..options.target
  end
end

----------------------------------------------------

package = newpackage()
package.name = "iupview"
package.target = package.name
package.objdir = "../obj/"..package.name
package.language = "c++"
package.kind = "winexe"
package.linkflags = { "static-runtime" }

package.files =
{
  "iupview.c"
}
fixPackagePath(package.files)

package.includepaths = { ".", "../include", "$(CD)/include" }
package.links = { "iupgl", "iupim", "iupimglib", "iupcontrols", "cdiup", "cd", "iup", "im" }
package.libpaths = { "../lib", "$(IM)/lib", "$(CD)/lib" }

if (options.os == "windows") then
  tinsert(package.links, { "comctl32", "opengl32", "glu32", "glaux" })
else
  tinsert(package.links, { "GLU", "GL", "Xm", "Xpm", "Xmu", "Xt", "Xext", "X11", "m" })
  tinsert(package.libpaths, { "/usr/X11R6/lib" })
end

----------------------------------------------------

l = iup.label{title="1", size="200x"}

function idle_cb()
  local v = tonumber(l.title) + 1
  l.title = v
  if v == 10000 then
    iup.SetIdle(nil)
  end
  return iup.DEFAULT
end

dlg = iup.dialog{l; title = "Idle Test"}

dlg:showxy(iup.CENTER, iup.CENTER)

-- Registers idle callback
iup.SetIdle(idle_cb)

-- Creates a IupColorBrowser control and updates, through 
-- callbacks, the values of texts representing the R, G and B 
-- components of the selected color.

text_red = iup.text{}
text_green = iup.text{}
text_blue = iup.text{}

cb = iup.colorbrowser{}

function update(r, g, b)
  text_red.value = r
  text_green.value = g
  text_blue.value = b
end

function cb:drag_cb(r, g ,b)
  update(r,g,b)
end

function cb:change_cb(r, g ,b)
  update(r,g,b)
end

vbox = iup.vbox {
                 iup.fill {}, 
                 text_red, 
                 iup.fill {}, 
                 text_green, 
                 iup.fill {}, 
                 text_blue, 
                 iup.fill {}
               }

dlg = iup.dialog{iup.hbox {cb, iup.fill{}, vbox}; title = "ColorBrowser"}
dlg:showxy(iup.CENTER, iup.CENTER)
--IupDial Example in IupLua 

lbl_h = iup.label{title = "0", alignment = "ACENTER", size = "100x10"}
lbl_v = iup.label{title = "0", alignment = "ACENTER", size = "100x10"}
lbl_c = iup.label{title = "0", alignment = "ACENTER", size = "100x10"}

dial_v = iup.dial{"VERTICAL"; size="100x100"}
dial_h = iup.dial{"HORIZONTAL"; density=0.3}

function dial_v:mousemove_cb(a)
   lbl_v.title = a
   return iup.DEFAULT
end

function dial_v:button_press_cb(a)
   lbl_v.bgcolor = "255 0 0"
   return iup.DEFAULT
end

function dial_v:button_release_cb(a)
   lbl_v.bgcolor = nil
   return iup.DEFAULT
end

function dial_h:mousemove_cb(a)
   lbl_h.title = a
   return iup.DEFAULT
end

function dial_h:button_press_cb(a)
   lbl_h.bgcolor = "255 0 0"
   return iup.DEFAULT
end

function dial_h:button_release_cb(a)
   lbl_h.bgcolor = nil
   return iup.DEFAULT
end

dlg = iup.dialog
{
  iup.hbox
  {
    iup.fill{},
    iup.vbox
    {
      iup.fill{},
      iup.frame
      {
        iup.vbox
        {
          iup.hbox
          {
             iup.fill{},
             dial_v,
             iup.fill{}
          } ,
          iup.hbox
          {
             iup.fill{},
             lbl_v,
             iup.fill{}
          }
        }
      },
      iup.fill{},
      iup.frame
      {
        iup.vbox
        { 
          iup.hbox
          {
             iup.fill{},
             dial_h,
             iup.fill{}
          } ,
          iup.hbox
          {
             iup.fill{},
             lbl_h,
             iup.fill{}
          } ,
        } 
      },
      iup.fill{},
    },
    iup.fill{}
  }; title="IupDial"
}

dlg:showxy(iup.CENTER,iup.CENTER)


function idle_cb()
  local value = gauge.value
  value = value + 0.0001;
  if value > 1.0 then
    value = 0.0
  end
  gauge.value = value
  return iup.DEFAULT
end

gauge = iup.gauge{}
gauge.size = "QUARTERxEIGHTH"
gauge.show_text = "YES"

dlg = iup.dialog{gauge; title = "IupGauge"}

-- Registers idle callback
iup.SetIdle(idle_cb)

dlg:showxy(iup.CENTER, iup.CENTER)
--
-- IupGetColor Example in IupLua 
--
-- Creates a predefined color selection dialog which returns the
-- selected color in the RGB format.
--

r, g, b = iup.GetColor(100, 100, 255, 255, 255)
if (r) then
  print("r="..r.." g="..g.." b="..b)               
end
-- IupGetParam Example in IupLua 
-- Shows a dialog with all possible fields. 

iup.SetLanguage("ENGLISH")

function param_action(dialog, param_index)
  if (param_index == -1) then
    print("OK")
  elseif (param_index == -2) then
    print("Map")
  elseif (param_index == -3) then
    print("Cancel")
  else
    local param = iup.GetParamParam(dialog, param_index)
    print("PARAM"..param_index.." = "..param.value)
  end
  return 1
end

-- set initial values
pboolean = 1
pinteger = 3456
preal = 3.543
pinteger2 = 192
preal2 = 0.5
pangle = 90
pstring = "string text"
plist = 2
pstring2 = "second text\nsecond line"
  
ret, pboolean, pinteger, preal, pinteger2, preal2, pangle, pstring, plist, pstring2 = 
      iup.GetParam("Title", param_action,
                  "Boolean: %b\n"..
                  "Integer: %i\n"..
                  "Real 1: %r\n"..
                  "Sep1 %t\n"..
                  "Integer: %i[0,255]\n"..
                  "Real 2: %r[-1.5,1.5]\n"..
                  "Sep2 %t\n"..
                  "Angle: %a[0,360]\n"..
                  "String: %s\n"..
                  "List: %l|item1|item2|item3|\n"..
                  "Sep3 %t\n"..
                  "Multiline: %m\n",
                  pboolean, pinteger, preal, pinteger2, preal2, pangle, pstring, plist, pstring2)
if (ret == 0) then
  return
end

iup.Message("IupGetParam",
            "Boolean Value: "..pboolean.."\n"..
            "Integer: "..pinteger.."\n"..
            "Real 1: "..preal.."\n"..
            "Integer: "..pinteger2.."\n"..
            "Real 2: "..preal2.."\n"..
            "Angle: "..pangle.."\n"..
            "String: "..pstring.."\n"..
            "List Index: "..plist.."\n"..
            "String: "..pstring2)
-- Example IupGLCanvas in Lua 
-- Creates a OpenGL canvas and draws a line in it. 
-- This example uses gllua binding of OpenGL to Lua.
 
cv = iup.glcanvas{buffer="DOUBLE", rastersize = "300x300"}

function cv:action(x, y)
  iup.GLMakeCurrent(self)
  --glClearColor(1.0, 1.0, 1.0, 1.0)
  --glClear(GL_COLOR_BUFFER_BIT)
  --glClear(GL_DEPTH_BUFFER_BIT)
  --glMatrixMode( GL_PROJECTION )
  --glViewport(0, 0, 300, 300)
  --glLoadIdentity()
  --glBegin( GL_LINES ) 
  --glColor(1.0, 0.0, 0.0)
  --glVertex(0.0, 0.0)
  --glVertex(10.0, 10.0)
  --glEnd()
  iup.GLSwapBuffers(self)
  return iup.DEFAULT
end

dg = iup.dialog{cv; title="IupGLCanvas Example"}

function cv:k_any(c)
  if c == iup.K_q then
    return iup.CLOSE
  else
    return iup.DEFAULT
  end
end


dg:show()

canvas = iup.glcanvas{buffer="DOUBLE", rastersize = "640x480"}

function canvas:resize_cb(width, height)
  iup.GLMakeCurrent(self)

  gl.Viewport(0, 0, width, height)

  gl.MatrixMode('PROJECTION')
  gl.LoadIdentity()

  gl.MatrixMode('MODELVIEW')
  gl.LoadIdentity()

end

function canvas:action()
  iup.GLMakeCurrent(self)

  gl.MatrixMode("PROJECTION")
  gl.LoadIdentity()
  gl.Ortho(0, 1, 1, 0, -1.0, 1.0)
  gl.MatrixMode("MODELVIEW")
  gl.LoadIdentity()
  gl.PushMatrix()
  gl.Translate(0.25,0.5, 0)
  gl.Scale(0.2, 0.2, 1)

  gl.BlendFunc("SRC_ALPHA", "ONE_MINUS_SRC_ALPHA")

  gl.ClearColor(0,0,0,1)
  gl.Clear("DEPTH_BUFFER_BIT,COLOR_BUFFER_BIT")
  gl.Enable("BLEND")

  -- draw rectangle
  gl.Color( {1, 1, 0, 0.8} )
  gl.Rect(-1,-1,1,1)
  
  --------------------------------------------------------
  -- Create List That Draws the Circle
  --------------------------------------------------------

  planet = 1
  orbit = 2
  pi = 

  gl.NewList(planet, "COMPILE")
    gl.Begin("POLYGON")
      for i=0, 100 do
        cosine = math.cos(i * 2 * math.pi/100.0)
        sine   = math.sin(i * 2 * math.pi/100.0)
        gl.Vertex(cosine,sine)
      end
    gl.End()
  gl.EndList()

  gl.NewList(orbit, "COMPILE")
    gl.Begin("LINE_LOOP")
      for i=0, 100 do
        cosine = math.cos(i * 2 * math.pi/100.0)
        sine   = math.sin(i * 2 * math.pi/100.0)
        gl.Vertex(cosine, sine)
      end
    gl.End()
  gl.EndList()

  --------------------------------------------------------

  gl.Color( {0, 0.5, 0, 0.8} )
  gl.CallList(planet)

  gl.Color( {0, 0, 0, 1} )
  lists = { orbit }
  gl.CallLists(lists)

  gl.EnableClientState ("VERTEX_ARRAY")
  
  vertices  = { {-3^(1/2)/2, 1/2}, {3^(1/2)/2, 1/2}, {0, -1}, {-3^(1/2)/2, -1/2}, {3^(1/2)/2, -1/2}, {0, 1} }
    
  gl.VertexPointer  (vertices)
  
  -- draw first triangle
  gl.Color( {0, 0, 1, 0.5} )

  gl.Begin("TRIANGLES")
    gl.ArrayElement (0)
    gl.ArrayElement (1)
    gl.ArrayElement (2)
  gl.End()

  -- draw second triangle
  gl.Color( {1, 0, 0, 0.5} )
  gl.VertexPointer  (vertices)
  gl.DrawArrays("TRIANGLES", 3, 3)

  -- draw triangles outline
  gl.Color(1,1,1,1)
  elements = { 0, 1, 2}   gl.DrawElements("LINE_LOOP", elements)
  elements = { 3, 4, 5}   gl.DrawElements("LINE_LOOP", elements)

  gl.DisableClientState ("VERTEX_ARRAY")

  gl.PopMatrix()
  gl.Translate(0.75,0.5, 0)
  gl.Scale(0.2, 0.2, 1)

  ----------------------------------------------------------------------------

  gl.BlendFunc("SRC_ALPHA", "ONE_MINUS_SRC_ALPHA")

  -- draw rectangle
  gl.Color( {1, 1, 0, 0.8} )
  
  gl.Begin("QUADS")
    gl.Vertex(-1,-1)
    gl.Vertex( 1,-1)
    gl.Vertex( 1, 1)
    gl.Vertex(-1, 1)
  gl.End()
  -------------------------------
  gl.Color( {0, 0.5, 0, 0.8} )
  gl.Begin("POLYGON")
    for i=0, 100 do
      cosine = math.cos(i * 2 * math.pi/100.0)
      sine   = math.sin(i * 2 * math.pi/100.0)
      gl.Vertex(cosine,sine)
    end
  gl.End()

  gl.Color( {0, 0, 0, 1} )
  gl.Begin("LINE_LOOP")
    for i=0, 100 do
      cosine = math.cos(i * 2 * math.pi/100.0)
      sine   = math.sin(i * 2 * math.pi/100.0)
      gl.Vertex(cosine, sine)
    end
  gl.End()

  -- draw first triangle
  gl.Color( {0, 0, 1, 0.5} )
  gl.Begin("TRIANGLES")
    gl.Vertex (vertices[1])
    gl.Vertex (vertices[2])
    gl.Vertex (vertices[3])
  gl.End()
  -- draw second triangle
  gl.Color( {1, 0, 0, 0.5} )
  gl.Begin("TRIANGLES")
    gl.Vertex (vertices[4])
    gl.Vertex (vertices[5])
    gl.Vertex (vertices[6])
  gl.End()
  -- draw triangles outline
  gl.Color(1,1,1,1)
  gl.Begin("LINE_LOOP")
    gl.Vertex (vertices[1])
    gl.Vertex (vertices[2])
    gl.Vertex (vertices[3])
  gl.End()
  gl.Begin("LINE_LOOP")
    gl.Vertex (vertices[4])
    gl.Vertex (vertices[5])
    gl.Vertex (vertices[6])
  gl.End()

  iup.GLSwapBuffers(self)
  gl.Flush()

end

dialog = iup.dialog{canvas; title="Lua GL Test Application"}
dialog:show()
-- IupMask Example in Lua
-- Creates an IupText that accepts only numbers.

txt = iup.text{}
iup.maskSet(txt, "/d*", 0, 1) ;
dg = iup.dialog{txt}
dg:show()mat= iup.matrix{numlin=3, numcol=3}
mat:setcell(1,1,"Only numbers")
iup.maskMatSet(mat, "/d*", 0, 1, 1, 1) ;
dg = iup.dialog{mat}
dg:show()

mat = iup.matrix {numcol=5, numlin=3,numcol_visible=5, numlin_visible=3, widthdef=34}
mat.resizematrix = "YES"
mat:setcell(0,0,"Inflation")
mat:setcell(1,0,"Medicine")
mat:setcell(2,0,"Food")
mat:setcell(3,0,"Energy")
mat:setcell(0,1,"January 2000")
mat:setcell(0,2,"February 2000")
mat:setcell(1,1,"5.6")
mat:setcell(2,1,"2.2")
mat:setcell(3,1,"7.2")
mat:setcell(1,2,"4.6")
mat:setcell(2,2,"1.3")
mat:setcell(3,2,"1.4")
dlg = iup.dialog{iup.vbox{mat; margin="10x10"}}
dlg:showxy(iup.CENTER, iup.CENTER)
matrix = iup.matrix
{
    numlin=3,
    numcol=3,
    numcol_visible=3,
    height0=10,
    widthdef=30,
    scrollbar="VERTICAL",
}

data = {
        {"1:1", "1:2", "1:3"}, 
        {"2:1", "2:2", "2:3"}, 
        {"3:1", "3:2", "3:3"}, 
       }

function matrix:value_cb(l, c) 
  if l == 0 or c == 0 then
    return "title"
  end
  return data[l][c]
end

function matrix:value_edit_cb(l, c, newvalue)
  data[l][c] = newvalue
end

dlg=iup.dialog{matrix; title="IupMatrix in Callback Mode" }
dlg:show()

bt = iup.button{title="Test"}
bt.expand = "YES"
box = iup.sbox{bt}
box.direction = "SOUTH"
box.color = "0 0 255"

ml = iup.multiline{}
ml.expand = "YES"
vbox = iup.vbox{box, ml}

lb = iup.label{title="Label"}
lb.expand = "YES"
dg = iup.dialog{iup.hbox{vbox, lb}}
dg:show()
--IupSpeech Example in Lua

label = iuplabel{title="Possible commands are defined in xml1.xml"}
text = iuptext {size="200"}

function reco(self, msg)
  text.value = msg
end

sk = iupspeech{action=reco, grammar="xml1.xml", say="xml1 loaded"}

dg = iupdialog{iupvbox{label, text}; title = "IupSpeech Test"}
dg:show()
-- Creates boxes
vboxA = iup.vbox{iup.label{title="TABS AAA"}, iup.button{title="AAA"}}
vboxB = iup.vbox{iup.label{title="TABS BBB"}, iup.button{title="BBB"}}

-- Sets titles of the vboxes
vboxA.tabtitle = "AAAAAA"
vboxB.tabtitle = "BBBBBB"

-- Creates tabs 
tabs = iup.tabs{vboxA, vboxB}

-- Creates dialog
dlg = iup.dialog{tabs; title="Test IupTabs", size="200x80"}

-- Shows dialog in the center of the screen
dlg:showxy(iup.CENTER, iup.CENTER)-- IupTree Example in IupLua 
-- Creates a tree with some branches and leaves. 
-- Two callbacks are registered: one deletes marked nodes when the Del key 
-- is pressed, and the other, called when the right mouse button is pressed, 
-- opens a menu with options. 

tree = iup.tree{}

-- Creates rename dialog
ok     = iup.button{title = "OK",size="EIGHTH"}
cancel = iup.button{title = "Cancel",size="EIGHTH"}

text   = iup.text{border="YES",expand="YES"}
dlg_rename = iup.dialog{iup.vbox{text,iup.hbox{ok,cancel}}; 
   defaultenter=ok,
   defaultesc=cancel,
   title="Enter node's name",
   size="QUARTER",
   startfocus=text}

-- Creates menu displayed when the right mouse button is pressed
addleaf = iup.item {title = "Add Leaf"}
addbranch = iup.item {title = "Add Branch"}
renamenode = iup.item {title = "Rename Node"}
menu = iup.menu{addleaf, addbranch, renamenode}

-- Callback of the right mouse button click
function tree:rightclick_cb(id)
  tree.value = id
  menu:popup(iup.MOUSEPOS,iup.MOUSEPOS)
  return iup.DEFAULT
end

-- Callback called when a node will be renamed
function tree:renamenode_cb(id)
  text.value = tree.name

  dlg_rename:popup(iup.CENTER, iup.CENTER)
  iup.SetFocus(tree)
  
  return iup.DEFAULT
end

-- Callback called when the rename operation is cancelled
function cancel:action()
  return iup.CLOSE
end

-- Callback called when the rename operation is confirmed
function ok:action()
  tree.name = text.value

  return iup.CLOSE
end

function tree:k_any(c)
  if c == 339 then tree.delnode = "MARKED" end
  return iup.DEFAULT
end

-- Callback called when a leaf is added
function addleaf:action()
  tree.addleaf = ""
  tree.redraw = "YES"
  return iup.DEFAULT
end

-- Callback called when a branch is added
function addbranch:action()
  tree.addbranch = ""
  tree.redraw = "YES"
  return iup.DEFAULT
end

-- Callback called when a branch will be renamed
function renamenode:action()
  tree:renamenode_cb(tree.value)
  tree.redraw = "YES"
  return iup.DEFAULT
end

function init_tree_atributes()
  tree.font = "COURIER_NORMAL_10"
  tree.name = "Figures"
  tree.addbranch = "3D"
  tree.addbranch = "2D"
  tree.addbranch1 = "parallelogram"
  tree.addleaf2 = "diamond"
  tree.addleaf2 = "square"
  tree.addbranch1 = "triangle"
  tree.addleaf2 = "scalenus"
  tree.addleaf2 = "isoceles"
  tree.value = "6"
  tree.ctrl = "YES"
  tree.shift = "YES"
  tree.addexpanded = "NO"
  tree.redraw = "YES"
end

dlg = iup.dialog{tree; title = "IupTree", size = "QUARTERxTHIRD"} 
dlg:showxy(iup.CENTER,iup.CENTER)
init_tree_atributes()--IupTree Example in IupLua
--Creates a tree with some branches and leaves. Uses a Lua Table to define the IupTree structure.

tree = iup.tree{}
dlg = iup.dialog{tree ; title = "TableTree result", size = "200x200"}
dlg:showxy(iup.CENTER,iup.CENTER)

t = {
  {
    "Horse",
    "Whale";
    branchname = "Mammals"
  },
  {
    "Shrimp",
    "Lobster";
    branchname = "Crustaceans"
  };
  branchname = "Animals"
}
iup.TreeSetValue(tree, t)

tree.redraw = "YES"
-- IupTree Example in IupLua 
-- Creates a tree with some branches and leaves. 
-- Two callbacks are registered: one deletes marked nodes when the Del key 
-- is pressed, and the other, called when the right mouse button is pressed, 
-- opens a menu with options. 


tree = iup.tree{}


function tree:showrename_cb(id)
  print("SHOWRENAME")
  return iup.DEFAULT
end
-- Callback called when a node will be renamed
function tree:renamenode_cb(id)
  print("RENAMENODE")
  return iup.DEFAULT
end


function tree:k_any(c)
  if c == 316 then tree.delnode = "MARKED" end
  return iup.DEFAULT
end


function init_tree_atributes()
  tree.font = "COURIER_NORMAL_10"
  tree.name = "Figures"
  tree.addbranch = "3D"
  tree.addbranch = "2D"
  tree.addbranch1 = "parallelogram"
  tree.addleaf2 = "diamond"
  tree.addleaf2 = "square"
  tree.addbranch1 = "triangle"
  tree.addleaf2 = "scalenus"
  tree.addleaf2 = "isoceles"
  tree.value = "6"
  tree.ctrl = "YES"
  tree.shift = "YES"
  tree.addexpanded = "NO"
  tree.redraw = "YES"
  tree.showrename = "NO"
end


dlg = iup.dialog{tree; title = "IupTree", size = "QUARTERxTHIRD"} 
dlg:showxy(iup.CENTER,iup.CENTER)
init_tree_atributes()-- IupVal Example in IupLua 
-- Creates two Valuator controls, exemplifying the two possible types. 
-- When manipulating the Valuator, the label's value changes.

if not string then
  string = {}
  string.format = format
end

function fbuttonpress(self)
  if(self.type == "VERTICAL") then
    lbl_v.fgcolor = "255 0 0"
  else
    lbl_h.fgcolor = "255 0 0"
  end
  return iup.DEFAULT
end

function fbuttonrelease(self)
  if(self.type == "VERTICAL") then
    lbl_v.fgcolor = "0 0 0"
  else
    lbl_h.fgcolor = "0 0 0"
  end
  return iup.DEFAULT
end

function fmousemove(self, val)
  local buffer = "iup.VALUE="..string.format('%.2f', val)
  if (self.type == "VERTICAL") then
    lbl_v.title=buffer
  else
    lbl_h.title=buffer
  end
  return iup.DEFAULT
end

val_v = iup.val{"VERTICAL"; min=0, max=1,	value="0.3", 
    mousemove_cb=fmousemove,
		button_press_cb=fbuttonpress,
		button_release_cb=fbuttonrelease
}

lbl_v = iup.label{title="VALUE=   ", size=70, type="1"}

val_h = iup.val{"HORIZONTAL"; min=0, max=1,	value=0,	
    mousemove_cb=fmousemove,
		button_press_cb=fbuttonpress,
		button_release_cb=fbuttonrelease
}

lbl_h = iup.label{title="VALUE=   ", size=70, type="2"}

dlg_val = iup.dialog
{
	iup.hbox
	{
		iup.frame
		{
			iup.vbox
			{
				val_v,
				lbl_v
			}
		},
		iup.frame
		{
			iup.vbox
			{
				val_h,
				lbl_h
			}
		}
	};
	title="Valuator Test"
}

dlg_val:show()

-- IupAlarm Example in IupLua 
-- Shows a dialog similar to the one shown when you exit a program 
-- without saving. 

b = iup.Alarm("IupAlarm Example", "File not saved! Save it now?" ,"Yes" ,"No" ,"Cancel")
  
-- Shows a message for each selected button
if b == 1 then 
  iup.Message("Save file", "File saved sucessfully - leaving program")
elseif b == 2 then 
  iup.Message("Save file", "File not saved - leaving program anyway")
elseif b == 3 then 
  iup.Message("Save file", "Operation canceled") 
end-- IupFileDlg Example in IupLua 
-- Shows a typical file-saving dialog. 

-- Creates a file dialog and sets its type, title, filter and filter info
filedlg = iup.filedlg{dialogtype = "SAVE", title = "File save", 
                      filter = "*.bmp", filterinfo = "Bitmap files",
                      directory="c:\\windows"} 

-- Shows file dialog in the center of the screen
filedlg:popup (iup.ANYWHERE, iup.ANYWHERE)

-- Gets file dialog status
status = filedlg.status

if status == "1" then 
  iup.Message("New file",filedlg.value)
elseif status == "0" then 
  iup.Message("File already exists", filedlg.value)
elseif status == "-1" then 
  iup.Message("IupFileDlg","Operation canceled")
end-- IupGetFile Example in IupLua 
-- Shows a typical file-selection dialog. 

iup.SetLanguage("ENGLISH")
f, err = iup.GetFile("*.txt")
if err == 1 then 
  iup.Message("New file", f)
elseif err == 0 then 
  iup.Message("File already exists", f)	    
elseif err == -1 then 
  iup.Message("IupFileDlg", "Operation canceled")
elseif err == -2 then 
  iup.Message("IupFileDlg", "Allocation errr")
elseif err == -3 then 
  iup.Message("IupFileDlg", "Invalid parameter")
end-- IupListDialog Example in IupLua 
-- Shows a color-selection dialog. 

iup.SetLanguage("ENGLISH")
size = 8 
marks = { 0,0,0,0,1,1,0,0 }
options = {"Blue", "Red", "Green", "Yellow", "Black", "White", "Gray", "Brown"} 
	  
error = iup.ListDialog(2,"Color selection",size,options,0,16,5,marks);

if error == -1 then 
  iup.Message("IupListDialog", "Operation canceled")
else
  local selection = ""
  local i = 1
	while i ~= size+1 do
    if marks[i] ~= 0 then
      selection = selection .. options[i] .. "\n"
    end
    i = i + 1
  end
  if selection == "" then
    iup.Message("IupListDialog","No option selected")
  else
    iup.Message("Selected options",selection)
  end
end-- IupMessage Example in IupLua 
-- Shows a dialog with the message: “Click the button”. 

iup.Message ("IupMessage", "Press the button")-- IupScanf Example in IupLua 
-- Shows a dialog with three fields to be filled. 
--   One receives a string, the other receives a real number and 
--   the last receives an integer number. 
-- Note: In Lua, the function does not return the number of successfully read characters. 

iup.SetLanguage("ENGLISH")
local integer = 12
local real = 1e-3
local text ="This is a vector of characters"
local fmt = "IupScanf\nText:%300.40%s\nReal:%20.10%g\nInteger:%20.10%d\n"

text, real, integer = iup.Scanf (fmt, text, real, integer)

if text then
  local string = "Text: "..text.."\nReal: "..real.."\nInteger: "..integer
  iup.Message("IupScanf", string)
else
  iup.Message("IupScanf", "Operation canceled");
end
-- Creates four buttons. The first uses images, the second turns the first
-- on and off, the third exits the application and the last does nothing

-- defines released button image
img_release = iup.image {
      {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
      {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2},
      {1,1,3,3,3,3,3,3,3,3,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,3,3,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,3,3,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,3,3,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,3,3,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,4,4,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,4,4,4,4,3,3,3,2,2},
      {1,1,3,3,3,3,3,4,4,4,4,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,4,4,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,3,3,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,3,3,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,3,3,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,3,3,3,3,3,3,2,2},
      {1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
      {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2};
      colors = { "215 215 215", "40 40 40", "30 50 210", "240 0 0" }
}

-- defines pressed button image
img_press = iup.image {
      {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
      {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2},
      {1,1,3,3,3,3,3,3,3,3,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,3,3,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,3,3,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,3,3,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,4,4,3,3,3,3,3,2,2},
      {1,1,3,3,3,3,4,4,4,4,3,3,3,3,2,2},
      {1,1,3,3,3,3,4,4,4,4,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,4,4,3,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,3,3,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,3,3,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,3,3,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,3,3,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,3,3,3,3,3,3,2,2},
      {1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
      {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2};
      colors = { "40 40 40", "215 215 215", "0 20 180", "210 0 0" }
}

-- defines deactivated button image
img_inactive = iup.image {
      {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
      {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2},
      {1,1,3,3,3,3,3,3,3,3,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,3,3,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,3,3,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,3,3,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,3,3,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,4,4,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,4,4,4,4,3,3,3,2,2},
      {1,1,3,3,3,3,3,4,4,4,4,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,4,4,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,3,3,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,3,3,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,3,3,3,3,3,3,2,2},
      {1,1,3,3,3,3,3,3,3,3,3,3,3,3,2,2},
      {1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2},
      {2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2};
      colors = { "215 215 215", "40 40 40", "100 100 100", "200 200 200" }
}

-- creates a text box
text = iup.text{ readonly = "YES", SIZE = "EIGHTH" }

-- creates a button with image
btn_image = iup.button{ title = "Button with image", image = img_release, impress = img_press, iminactive = img_inactive }

-- creates a button
btn_big = iup.button{ title = "Big useless button", size = "EIGHTHxEIGHTH" }

-- creates a button entitled Exit
btn_exit = iup.button{ title = "Exit" }

-- creates a button entitled Activate
btn_on_off = iup.button{ title = "Activate" }

-- creates a dialog and sets dialog's title and turns off resize, menubox, maximize and minimize
dlg = iup.dialog{ iup.vbox{ iup.hbox{ iup.fill{}, btn_image, btn_on_off, btn_exit, iup.fill{} }, text, btn_big }; title = "IupButton", resize = "NO", menubox = "NO", maxbox = "NO", minbox = "NO" }

-- callback called when activate button is activated
function btn_on_off:action()
  if btn_image.active == "YES" then
    btn_image.active = "NO"
  else
    btn_image.active = "YES"
  end

  return iup.DEFAULT
end

-- callback called when the button is pressed or released
function btn_image:button( b, e )
  if( b == iup.BUTTON1 ) then
    if( e == 1 ) then
    -- botão pressionado
      text.value = "Red button pressed"
    else           
    -- botão solto 
      text.value = "Red button released"
    end
  end
  return iup.DEFAULT
end

-- callback called when the exit button is activated
function btn_exit:action()
  dlg:hide()
end

-- shows dialog
dlg:showxy( iup.CENTER, iup.CENTER)--IupCanvas Example in IupLua 

cv       = iup.canvas {size="300x100", xmin=0, xmax=99, posx=0, dx=10}
dg       = iup.dialog{iup.frame{cv}; title="IupCanvas"}

function cv:motion_cb(x, y, r)
  print(x, y, r)
  return iup.DEFAULT
end

dg:showxy(iup.CENTER, iup.CENTER)
--IupDialog Example in IupLua
--Creates a simple dialog.

vbox = iup.vbox { iup.label {title="Label"}, iup.button { title="Test" } }
dlg = iup.dialog{vbox; title="Dialog"}
dlg:show()

tecgraf = iup.image{
   { 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, },
   { 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 02, 05, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, },
   { 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 04, 05, 05, 05, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, },
   { 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 11, 05, 05, 05, 05, 12, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, },
   { 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 10, 06, 05, 03, 05, 05, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, },
   { 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 07, 05, 01, 01, 03, 05, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, },
   { 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 07, 05, 01, 01, 03, 05, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, },
   { 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 02, 09, 09, 01, 01, 03, 07, 06, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, },
   { 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 07, 06, 01, 01, 01, 01, 02, 07, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, },
   { 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 07, 06, 01, 01, 01, 01, 04, 07, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, },
   { 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 07, 06, 01, 01, 01, 01, 04, 07, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, },
   { 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 11, 02, 07, 05, 04, 04, 04, 04, 04, 04, 11, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, },
   { 01, 01, 01, 01, 01, 01, 07, 04, 04, 04, 06, 03, 03, 07, 05, 05, 07, 07, 04, 04, 04, 04, 10, 10, 10, 10, 10, 01, 01, 01, 01, 01, },
   { 01, 01, 01, 01, 04, 04, 04, 09, 09, 06, 05, 04, 08, 07, 05, 01, 01, 01, 01, 07, 05, 06, 03, 03, 03, 03, 04, 10, 07, 09, 01, 01, },
   { 01, 01, 01, 04, 04, 06, 06, 08, 01, 01, 01, 01, 01, 10, 05, 01, 01, 01, 01, 10, 06, 01, 01, 01, 01, 01, 03, 03, 07, 07, 07, 01, },
   { 01, 01, 02, 04, 04, 05, 01, 01, 01, 01, 01, 01, 01, 04, 05, 01, 01, 01, 01, 07, 09, 01, 01, 01, 01, 01, 01, 01, 07, 07, 05, 01, },
   { 01, 01, 01, 03, 04, 04, 04, 01, 01, 01, 01, 01, 01, 04, 05, 01, 01, 01, 01, 07, 06, 01, 01, 01, 01, 01, 07, 07, 07, 09, 07, 01, },
   { 01, 01, 01, 01, 03, 03, 03, 04, 10, 10, 10, 11, 01, 04, 05, 01, 01, 01, 01, 05, 06, 15, 05, 07, 07, 07, 09, 06, 05, 05, 01, 01, },
   { 01, 01, 01, 01, 01, 01, 03, 03, 03, 03, 03, 02, 04, 07, 05, 05, 05, 05, 06, 09, 14, 14, 06, 05, 05, 05, 07, 12, 01, 01, 01, 01, },
   { 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 06, 03, 03, 02, 02, 02, 04, 04, 02, 02, 10, 16, 01, 01, 01, 01, 01, 01, 01, 01, 01, },
   { 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 02, 05, 01, 01, 01, 01, 06, 07, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, },
   { 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 02, 05, 01, 01, 01, 01, 06, 07, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, },
   { 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 02, 05, 01, 01, 01, 01, 06, 07, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, },
   { 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 03, 07, 09, 01, 01, 04, 09, 05, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, },
   { 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 12, 03, 05, 01, 01, 05, 07, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, },
   { 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 03, 05, 01, 01, 07, 07, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, },
   { 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 03, 05, 05, 04, 07, 07, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, },
   { 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 09, 03, 05, 07, 07, 13, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, },
   { 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 03, 07, 07, 07, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, },
   { 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 03, 04, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, },
   { 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, },
   { 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01, 01  };
   colors = {
      "BGCOLOR",
      "079 086 099",
      "040 045 053",
      "104 113 129",
      "136 147 170",
      "155 164 179",
      "121 136 167",
      "239 239 243",
      "176 190 214",
      "127 133 143",
      "207 209 214",
      "247 255 255",
      "244 247 249",
      "212 217 225",
      "215 226 241",
      "231 237 245" 
   },
}

dg = iup.dialog{iup.label{title="Tray example"}; title="Tray", 
          tray = "YES", traytip =  "This is a tip at tray", trayimage = tecgraf}
dg:show()

dg.hidetaskbar = "YES"

dg.trayclick_cb = function(self, b, press, dclick)
  if b == 1 and press then 
    item_show = iup.item {title = "Show", action = function() dg:show() end}
    item_exit = iup.item {title = "Exit", action = function() dg.tray = "NO" dg:hide() end}
    menu = iup.menu{item_show, item_exit}
    menu:popup(iup.MOUSEPOS, iup.MOUSEPOS)
  end
  return iup.DEFAULT
end
-- IupFill Example in IupLua 
-- Uses the Fill element to horizontally centralize a button and to 
-- justify it to the left and right.

-- Creates frame with left aligned button
frame_left = iup.frame
{
  iup.hbox
  {
    iup.button{ title = "Ok" },
    iup.fill{},
  }; title = "Left aligned" -- Sets frame's title
}

-- Creates frame with centered button
frame_center = iup.frame
{
  iup.hbox
  {
    iup.fill{},
    iup.button{ title = "Ok" },
    iup.fill{},
  } ; title = "Centered" -- Sets frame's title
}

-- Creates frame with right aligned button 
frame_right = iup.frame
{
  iup.hbox
  {
    iup.fill {},
    iup.button { title = "Ok" },
      
  } ; title = "Right aligned" -- Sets frame's title
}

-- Creates dialog with these three frames 
dialog = iup.dialog 
{
  iup.vbox{frame_left, frame_center, frame_right,}; 
    size = 120, title = "IupFill"
}

-- Shows dialog in the center of the screen
dialog:showxy(iup.CENTER, iup.CENTER)-- IupFrame Example in IupLua 
-- Draws a frame around a button. Note that FGCOLOR is added to the frame but 
-- it is inherited by the button. 

-- Creates frame with a label
frame = iup.frame
          {
            iup.hbox
            {
              iup.fill{},
              iup.label{title="IupFrame Test"},
              iup.fill{},
              NULL
            }
          } ;

-- Sets label's attributes 
frame.fgcolor = "255 0 0"
frame.size    = EIGHTHxEIGHTH
frame.title   = "This is the frame"
frame.margin  = "10x10"

-- Creates dialog  
dialog = iup.dialog{frame};

-- Sets dialog's title 
dialog.title = "IupFrame"

dialog:showxy(iup.CENTER,iup.CENTER) -- Shows dialog in the center of the screen -- IupHbox Example in IupLua 
-- Creates a dialog with buttons placed side by side, with the purpose 
-- of showing the organization possibilities of elements inside an hbox. 
-- The ALIGNMENT attribute is explored in all its possibilities to obtain 
-- the given effect. 

fr1 = iup.frame
{
	iup.hbox
	{
		iup.fill{},
		iup.button{title="1", size="30x30"},
		iup.button{title="2", size="30x40"},
		iup.button{title="3", size="30x50"},
		iup.fill{};
		alignment = "ATOP"
	};
	title = "Alignment = ATOP"
}

fr2 = iup.frame
{
	iup.hbox
	{
		iup.fill{},
		iup.button{title="1", size="30x30", action=""},
		iup.button{title="2", size="30x40", action=""},
		iup.button{title="3", size="30x50", action=""},
		iup.fill{};
		alignment = "ACENTER"
	};
	title = "Alignment = ACENTER"
}

fr3 = iup.frame
{
	iup.hbox
	{
		iup.fill{},
		iup.button{title="1", size="30x30", action=""},
		iup.button{title="2", size="30x40", action=""},
		iup.button{title="3", size="30x50", action=""},
		iup.fill{};
		alignment = "ABOTTOM"
	};
	title = "Alignment = ABOTTOM"
}

dlg = iup.dialog
{
	iup.frame
	{
		iup.vbox
		{
			fr1,
			fr2,
			fr3
		}; title="HBOX",
	};
  title="Alignment",
  size=140
}
	
dlg:show()-- IupImage Example in IupLua 
-- Creates a button, a label, a toggle and a radio using an image. 
-- Uses an image for the cursor as well.

-- Defines an "X" image 
img_x = iup.image{
  { 1,2,3,3,3,3,3,3,3,2,1 }, 
  { 2,1,2,3,3,3,3,3,2,1,2 }, 
  { 3,2,1,2,3,3,3,2,1,2,3 }, 
  { 3,3,2,1,2,3,2,1,2,3,3 }, 
  { 3,3,3,2,1,2,1,2,3,3,3 }, 
  { 3,3,3,3,2,1,2,3,3,3,3 },  
  { 3,3,3,2,1,2,1,2,3,3,3 }, 
  { 3,3,2,1,2,3,2,1,2,3,3 }, 
  { 3,2,1,2,3,3,3,2,1,2,3 }, 
  { 2,1,2,3,3,3,3,3,2,1,2 }, 
  { 1,2,3,3,3,3,3,3,3,2,1 }
  -- Sets "X" image colors
  ; colors = { "0 1 0", "255 0 0", "255 255 0" }
}

-- Defines a cursor image
img_cursor = iup.image{
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,1,1,1,1,2,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,1,1,1,1,2,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,1,1,1,1,1,2,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,2,1,1,1,1,1,1,2,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,2,1,1,1,1,1,2,2,2,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,2,1,1,1,1,1,2,0,0,2,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,2,1,1,1,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 },
  { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 }
  -- Sets cursor image colors
  ; colors = { "255 0 0", "128 0 0" }, hotspot = "21:10" 
}

-- Creates a button entitled "Dummy" and associates image img_x to it
btn = iup.button{ title = "", image = img_x }

-- Creates a label entitled "Dummy" and associates image img_x to it
lbl = iup.label{ title = "", image = img_x }

-- Creates toggle entitled "Dummy" and associates image img_x to it
tgl = iup.toggle{ title = "", image = img_x }

-- Creates two toggles entitled "Dummy" and associates image img_x to them
tgl_radio_1 = iup.toggle{ title = "", image = img_x }
tgl_radio_2 = iup.toggle{ title = "", image = img_x }

-- Creates label showing image size
lbl_size = iup.label{ title = '"X" image width = '..img_x.width..'; "X" image height = '..img_x.height } 
  
-- Creates frames around the elements 
frm_btn = iup.frame{btn; title="button", size="EIGHTHxEIGHTH"}
frm_lbl = iup.frame{lbl; title="label" , size="EIGHTHxEIGHTH"}
frm_tgl = iup.frame{tgl; title="toggle", size="EIGHTHxEIGHTH"}

frm_tgl_radio = iup.frame{ 
                            iup.radio{ 
                               iup.vbox
                               { 
                                   tgl_radio_1, 
                                   tgl_radio_2 
                               } 
                            }; 
                            title="radio", size="EIGHTHxEIGHTH"
                          }

-- Creates dialog dlg with an hbox containing a button, a label, and a toggle 
dlg = iup.dialog
      {
        iup.vbox
        {
          iup.hbox{frm_btn, frm_lbl, frm_tgl, frm_tgl_radio},
          iup.fill{},
          iup.hbox{iup.fill{}, lbl_size, iup.fill{}} 
        }; title = "IupImage Example", size = "HALFxQUARTER", 
        cursor = img_cursor
      } 

-- Shows dialog in the center of the screen 
dlg:showxy(iup.CENTER, iup.CENTER)
text = iup.text {value = "This is an empty text"}

item_save = iup.item {title = "Save\tCtrl+S", key = "K_cS", active = "NO"}
item_autosave = iup.item {title = "Auto Save", key = "K_a", value = "ON"}
item_exit = iup.item {title = "Exit", key = "K_x"}

menu_file = iup.menu {item_save, item_autosave, item_exit}

submenu_file = iup.submenu{menu_file; title = "File"}

menu = iup.menu {submenu_file}
                                
dlg = iup.dialog{text; title ="IupItem", menu = menu}

dlg:showxy(iup.CENTER, iup.CENTER)

function item_autosave:action()
  if item_autosave.value == "ON" then
    iup.Message("Auto Save", "OFF")
    item_autosave.value = "OFF"
  else
    iup.Message("Auto Save", "ON")
    item_autosave.value = "ON"
  end
  
  return iup.DEFAULT 
end

function item_exit:action()
-- return iup.CLOSE
  dlg:hide()
end
-- IupLabel Example in IupLua 
-- Creates three labels, one using all attributes except for image, other 
-- with normal text and the last one with an image.. 

-- Defines a star image
img_star = iup.image {
  { 1,1,1,1,1,1,2,1,1,1,1,1,1 },
  { 1,1,1,1,1,1,2,1,1,1,1,1,1 },
  { 1,1,1,1,1,2,2,2,1,1,1,1,1 },
  { 1,1,1,1,1,2,2,2,1,1,1,1,1 },
  { 1,1,2,2,2,2,2,2,2,2,2,1,1 },
  { 2,2,2,2,2,2,2,2,2,2,2,2,2 },
  { 1,1,1,2,2,2,2,2,2,2,1,1,1 },
  { 1,1,1,1,2,2,2,2,2,1,1,1,1 },
  { 1,1,1,1,2,2,2,2,2,1,1,1,1 }, 
  { 1,1,1,2,2,1,1,2,2,2,1,1,1 },
  { 1,1,2,2,1,1,1,1,1,2,2,1,1 },
  { 1,2,2,1,1,1,1,1,1,1,2,2,1 },
  { 2,2,1,1,1,1,1,1,1,1,1,2,2 }
  -- Sets star image colors
  ; colors = { "0 0 0", "0 198 0" } 
}

-- Creates a label and sets all the attributes of label lbl, except for image
lbl = iup.label { title = "This label has the following attributes set:\nBGCOLOR = 255 255 0\nFGCOLOR = 0 0 255\nFONT = COURIER_NORMAL_14\nSIZE = HALFxQUARTER\nTITLE = All text contained here\nALIGNMENT = ACENTER\n", bgcolor = "255 255 0", fgcolor = "0 0 255", font = "COURIER_NORMAL_14", size = "HALFxQUARTER", alignment = "ACENTER" }
  
-- Creates a label to explain that the label on the right has an image
lbl_explain = iup.label { title = "The label on the right has the image of a star" }

-- Creates a label whose title is not important, cause it will have an image
lbl_star = iup.label { title = "Does not matter", image = img_star }

-- Creates dialog with these three labels
dlg = iup.dialog { iup.vbox { lbl, iup.hbox { lbl_explain, lbl_star } }
      ; title = "IupLabel Example" }

-- Shows dialog in the center of the screen 
dlg:showxy ( iup.CENTER, iup.CENTER )-- IupList Example in IupLua 
-- Creates a dialog with three frames, each one containing a list. The first is a simple list, the second one is a multiple list and the last one is a drop-down list. The second list has a callback associated. 

-- Creates a list and sets items, initial item and size
list = iup.list {"Gold", "Silver", "Bronze", "None"
       ; value = 4, size = "EIGHTHxEIGHTH"}

-- Creates frame with simple list and sets its title
frm_medal = iup.frame {list ; title = "Best medal"}
  
-- Creates a list and sets its items, multiple selection, initial items and size
list_multiple = iup.list {"100m dash", "Long jump", "Javelin throw", "110m hurdlers", "Hammer throw", "High jump"
                ; multiple="YES", value="+--+--", size="EIGHTHxEIGHTH"}

-- Creates frame with multiple list and sets its title
frm_sport = iup.frame {list_multiple
            ; title = "Competed in"}

-- Creates a list and sets its items, dropdown and amount of visible items 
list_dropdown = iup.list {"Less than US$ 1000", "US$ 2000", "US$ 5000", "US$ 10000", "US$ 20000", "US$ 50000", "More than US$ 100000"
                ; dropdown="YES", visible_items=5}
  
-- Creates frame with dropdown list and sets its title
frm_prize = iup.frame {list_dropdown
            ; title = "Prizes won"}

-- Creates a dialog with the the frames with three lists and sets its title
dlg = iup.dialog {iup.hbox {frm_medal, frm_sport, frm_prize}
      ; title = "IupList Example"}

-- Shows dialog in the center of the screen
dlg:showxy(iup.CENTER, iup.CENTER)

function list_multiple:action(t, i, v)
  if v == 0 then 
    state = "deselected" 
  else 
    state = "selected" 
  end
  iup.Message("Competed in", "Item "..i.." - "..t.." - "..state)
  return iup.DEFAULT
end-- IupMenu Example in IupLua 
-- Creates a dialog with a menu with two submenus. 

-- Creates a text, sets its value and turns on text readonly mode 
text = iup.text {readonly = "YES", value = "Selecting show or hide will affect this text"}

-- Creates items, sets its shortcut keys and deactivates edit item
item_show = iup.item {title = "Show", key = "K_S"}
item_hide = iup.item {title = "Hide\tCtrl+H", key = "K_H"}
item_edit = iup.item {title = "Edit", key = "K_E", active = "NO"}
item_exit = iup.item {title = "Exit", key = "K_x"}

function item_show:action()
  text.visible = "YES"
  return iup.DEFAULT
end

function item_hide:action()
  text.visible = "NO"
  return iup.DEFAULT
end

function item_exit:action()
  return iup.CLOSE
end

-- Creates two menus
menu_file = iup.menu {item_exit}
menu_text = iup.menu {item_show, item_hide, item_edit}

-- Creates two submenus
submenu_file = iup.submenu {menu_file; title = "File"}
submenu_text = iup.submenu {menu_text; title = "Text"}

-- Creates main menu with two submenus
menu = iup.menu {submenu_file, submenu_text}
                                
-- Creates dialog with a text, sets its title and associates a menu to it 
dlg = iup.dialog{text; title="IupMenu Example", menu=menu}

-- Shows dialog in the center of the screen 
dlg:showxy(iup.CENTER,iup.CENTER)


l = iup.list{dropdown="YES"} 

iup.SetAttribute(l, "1", "HELVETICA_NORMAL_8") 
iup.SetAttribute(l, "2", "COURIER_NORMAL_8") 
iup.SetAttribute(l, "3", "TIMES_NORMAL_8") 
iup.SetAttribute(l, "4", "HELVETICA_ITALIC_8") 
iup.SetAttribute(l, "5", "COURIER_ITALIC_8") 
iup.SetAttribute(l, "6", "TIMES_ITALIC_8") 
iup.SetAttribute(l, "7", "HELVETICA_BOLD_8") 
iup.SetAttribute(l, "8", "COURIER_BOLD_8") 
iup.SetAttribute(l, "9", "TIMES_BOLD_8") 
iup.SetAttribute(l, "10", "HELVETICA_NORMAL_10") 
iup.SetAttribute(l, "11", "COURIER_NORMAL_10") 
iup.SetAttribute(l, "12", "TIMES_NORMAL_10") 
iup.SetAttribute(l, "13", "HELVETICA_ITALIC_10") 
iup.SetAttribute(l, "14", "COURIER_ITALIC_10") 
iup.SetAttribute(l, "15", "TIMES_ITALIC_10") 
iup.SetAttribute(l, "16", "HELVETICA_BOLD_10") 
iup.SetAttribute(l, "17", "COURIER_BOLD_10") 
iup.SetAttribute(l, "18", "TIMES_BOLD_10") 
iup.SetAttribute(l, "19", "HELVETICA_NORMAL_12") 
iup.SetAttribute(l, "20", "COURIER_NORMAL_12") 
iup.SetAttribute(l, "21", "TIMES_NORMAL_12") 
iup.SetAttribute(l, "22", "HELVETICA_ITALIC_12") 
iup.SetAttribute(l, "23", "COURIER_ITALIC_12") 
iup.SetAttribute(l, "24", "TIMES_ITALIC_12") 
iup.SetAttribute(l, "25", "HELVETICA_BOLD_12") 
iup.SetAttribute(l, "26", "COURIER_BOLD_12") 
iup.SetAttribute(l, "27", "TIMES_BOLD_12") 
iup.SetAttribute(l, "28", "HELVETICA_NORMAL_14") 
iup.SetAttribute(l, "29", "COURIER_NORMAL_14") 
iup.SetAttribute(l, "30", "TIMES_NORMAL_14") 
iup.SetAttribute(l, "31", "HELVETICA_ITALIC_14") 
iup.SetAttribute(l, "32", "COURIER_ITALIC_14") 
iup.SetAttribute(l, "33", "TIMES_ITALIC_14") 
iup.SetAttribute(l, "34", "HELVETICA_BOLD_14") 
iup.SetAttribute(l, "35", "COURIER_BOLD_14") 
iup.SetAttribute(l, "36", "TIMES_BOLD_14") 

dg = iup.dialog{l} 
dg.title = "title" 

dg2 = nil 

l.action = function(self, t, i ,v) 

  if dg2 then 
    iup.Hide(dg2) 
  end 

  if v == 1 then 
    ml = iup.multiline{} 
    ml.size = "200x200" 
    ml.value = "1234\nmmmmm\niiiii" 

    ml.font = t 

    dg2 = iup.dialog{ml} 
    dg2.title = t 
    dg2:show() 
    iup.SetFocus(l) 
  end 
end 

dg:show() 
--  IupMultiline Simple Example in IupLua 
--  Shows a multiline that ignores the treatment of the DEL key, canceling its effect. 

ml = iup.multiline{expand="YES", value="I ignore the DEL key!", border="YES"}

ml.action = function(self, c, after)
   if c == iup.K_DEL then
     return iup.IGNORE
  else
    return iup.DEFAULT;
  end
end

dlg = iup.dialog{ml; title="IupMultiline", size="QUARTERxQUARTER"}
dlg:show()-- IupRadio Example in IupLua 
-- Creates a dialog for the user to select his/her gender. 
-- In this case, the radio element is essential to prevent the user from 
-- selecting both options. 

male = iup.toggle{title="Male"}
female = iup.toggle{title="Female"}
exclusive = iup.radio
{
  iup.vbox
  {
    male,
    female
  };
  value=female,
  tip="Two state button - Exclusive - RADIO"
}

frame = iup.frame{exclusive; title="Gender"}

dialog = iup.dialog
{
  iup.hbox
  {
    iup.fill{},
    frame,
    iup.fill{}
  };
  title="IupRadio",
  size=140,
  resize="NO",
  minbox="NO",
  maxbox="NO"
}

dialog:show()-- IupSeparator Example in IupLua 
-- Creates a dialog with a menu and some items. 
-- A IupSeparator was used to separate the menu items. 

-- Creates a text, sets its value and turns on text readonly mode 
text = iup.text {value = "This text is here only to compose", expand = "YES"}

-- Creates six items
item_new = iup.item {title = "New"}
item_open = iup.item {title = "Open"}
item_close = iup.item {title = "Close"}
item_pagesetup = iup.item {title = "Page Setup"}
item_print = iup.item {title = "Print"}
item_exit = iup.item {title = "Exit", action="return iup.CLOSE"}

-- Creates file menus
menu_file = iup.menu {item_new, item_open, item_close, iup.separator{}, item_pagesetup, item_print, iup.separator{}, item_exit }

-- Creates file submenus
submenu_file = iup.submenu {menu_file; title="File"}

-- Creates main menu with file submenu
menu = iup.menu {submenu_file}
                                
-- Creates dialog with a text, sets its title and associates a menu to it 
dlg = iup.dialog {text
      ; title ="IupSeparator Example", menu = menu, size = "QUARTERxEIGHTH"}

-- Shows dialog in the center of the screen 
dlg:showxy(iup.CENTER,iup.CENTER)-- IupSubmenu Example in IupLua 
-- Creates a dialog with a menu with three submenus. One of the submenus has a submenu, which has another submenu. 

-- Creates a text, sets its value and turns on text readonly mode 
text = iup.text {value = "This text is here only to compose", expand = "YES"}

-- Creates items of menu file
item_new = iup.item {title = "New"}
item_open = iup.item {title = "Open"}
item_close = iup.item {title = "Close"}
item_exit = iup.item {title = "Exit"}

-- Creates items of menu edit
item_copy = iup.item {title = "Copy"}
item_paste = iup.item {title = "Paste"}

-- Creates items for menu triangle
item_equilateral = iup.item {title = "Equilateral"}
item_isoceles = iup.item {title = "Isoceles"}
item_scalenus = iup.item {title = "Scalenus"}

-- Creates menu triangle
menu_triangle = iup.menu {item_equilateral, item_isoceles, item_scalenus}

-- Creates submenu triangle
submenu_triangle = iup.submenu {menu_triangle; title = "Triangle"}

-- Creates items of menu create
item_line = iup.item {title = "Line"}
item_circle = iup.item {title = "Circle"}

-- Creates menu create
menu_create = iup.menu {item_line, item_circle, submenu_triangle}

-- Creates submenu create
submenu_create = iup.submenu {menu_create; title = "Create"}

-- Creates items of menu help
item_help = iup.item {title = "Help"}

-- Creates menus of the main menu
menu_file = iup.menu {item_new, item_open, item_close, iup.separator{}, item_exit }
menu_edit = iup.menu {item_copy, item_paste, iup.separator{}, submenu_create}
menu_help = iup.menu {item_help}

-- Creates submenus of the main menu
submenu_file = iup.submenu {menu_file; title = "File"}
submenu_edit = iup.submenu {menu_edit; title = "Edit"}
submenu_help = iup.submenu {menu_help; title = "Help"}

-- Creates main menu with file submenu
menu = iup.menu {submenu_file, submenu_edit, submenu_help}
                                
-- Creates dialog with a text, sets its title and associates a menu to it 
dlg = iup.dialog {text
      ; title ="IupSubmenu Example", menu = menu, size = "QUARTERxEIGHTH"}

-- Shows dialog in the center of the screen 
dlg:showxy (iup.CENTER,iup.CENTER)

function item_help:action ()
  iup.Message ("Warning", "Only Help and Exit items performs an operation")
  return iup.DEFAULT
end

function item_exit:action ()
  return iup.CLOSE
end-- IupText Example in IupLua 
-- Allows the user to execute a Lua command

text = iup.text{value = "Write a text; press Ctrl-Q to exit"}

function text:action(c)
  if c == iup.K_cQ then 
    return iup.CLOSE 
  end
  return iup.DEFAULT
end

dlg = iup.dialog{text; title="IupText"}

dlg:showxy(iup.CENTER, iup.CENTER)
iup.SetFocus(text)
-- IupTimer Example in Lua

timer1 = iup.timer{time=100}
timer2 = iup.timer{time=2000}

function timer1:action_cb()
  print("timer 1 called")
  return iup.DEFAULT
end

function timer2:action_cb()
  print("timer 2 called")
  return iup.CLOSE
end

-- can only be set after the time is created
timer1.run = "YES"
timer2.run = "YES"

dg = iup.dialog{iup.label{title="Timer example"}}
dg:show()
-- IupToggle Example in IupLua 
-- Creates 9 toggles: 
--   the first one has an image and an associated callback; 
--   the second has an image and is deactivated; 
--   the third is regular; 
--   the fourth has its foreground color changed; 
--   the fifth has its background color changed; 
--   the sixth has its foreground and background colors changed; 
--   the seventh is deactivated; 
--   the eight has its font changed; 
--   the ninth has its size changed. 

img1 = iup.image{
       {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
       {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
       {1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1},
       {1,1,1,1,1,1,2,2,1,1,1,1,1,1,1,1},
       {1,1,1,1,1,2,1,2,1,1,1,1,1,1,1,1},
       {1,1,1,1,2,1,1,2,1,1,1,1,1,1,1,1},
       {1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1},
       {1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1},
       {1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1},
       {1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1},
       {1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1},
       {1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1},
       {1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1},
       {1,1,1,2,2,2,2,2,2,2,2,2,1,1,1,1},
       {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
       {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};
       colors = {"255 255 255", "0 192 0"}
}

img2 = iup.image{
       {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
       {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
       {1,1,1,1,2,2,2,2,2,2,1,1,1,1,1,1},
       {1,1,1,2,1,1,1,1,1,1,2,1,1,1,1,1},
       {1,1,1,1,1,1,1,1,1,1,2,1,1,1,1,1},
       {1,1,1,1,1,1,1,1,1,1,2,1,1,1,1,1},
       {1,1,1,1,1,1,1,1,1,1,2,1,1,1,1,1},
       {1,1,1,1,1,1,1,1,1,2,1,1,1,1,1,1},
       {1,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1},
       {1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1},
       {1,1,1,1,1,1,2,1,1,1,1,1,1,1,1,1},
       {1,1,1,1,1,2,1,1,1,1,1,1,1,1,1,1},
       {1,1,1,1,2,1,1,1,1,1,1,1,1,1,1,1},
       {1,1,1,2,2,2,2,2,2,2,2,2,1,1,1,1},
       {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
       {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1};
       colors = {"255 255 255", "0 192 0"}
}

toggle1 = iup.toggle{title = "", image = img1}
toggle2 = iup.toggle{title = "deactivated toggle with image", image = img2, active="NO"}
toggle3 = iup.toggle{title = "regular toggle"}
toggle4 = iup.toggle{title = "toggle with blue foreground color", fgcolor = BLUE }
toggle5 = iup.toggle{title = "toggle with red background color", bgcolor = RED }
toggle6 = iup.toggle{title = "toggle with black backgrounf color and green foreground color", fgcolor = GREEN, bgcolor = BLACK }
toggle7 = iup.toggle{title = "deactivated toggle", active = "NO" }
toggle8 = iup.toggle{title = "toggle with Courier 14 Bold font", font = "COURIER_BOLD_14" }
toggle9 = iup.toggle{title = "toggle with size EIGHTxEIGHT", size = "EIGHTHxEIGHTH" }

function toggle1:action(v)
   if v == 1 then estado = "pressed" else estado = "released" end
   iup.Message("Toggle 1",estado)
end

box = iup.vbox{ 
                 toggle1,
                 toggle2,
                 toggle3,
                 toggle4,
                 toggle5,
                 toggle6,
                 toggle7,
                 toggle8,
                 toggle9
               }
                
toggles = iup.radio{box; expand="YES"}
dlg = iup.dialog{toggles; title = "IupToggle", margin="5x5", gap="5", resize="NO"}
dlg:showxy(iup.CENTER, iup.CENTER)-- IupVbox Example in IupLua 
-- Creates a dialog with buttons placed one above the other, showing 
-- the organization possibilities of the elements inside a vbox. 
-- The ALIGNMENT attribute is explored in all its possibilities to obtain 
-- the effects. The attributes GAP, MARGIN and SIZE are also tested. 

-- Creates frame 1
frm_1 = iup.frame
{
  iup.hbox
  {
    iup.fill {},
    iup.vbox
    {
      iup.button {title = "1", size = "20x30", action = ""},
      iup.button {title = "2", size = "30x30", action = ""},
      iup.button {title = "3", size = "40x30", action = ""} ;
      -- Sets alignment and gap of vbox
      alignment = "ALEFT", gap = 10
    },
    iup.fill {}
  } ;
  -- Sets title of frame 1
  title = "ALIGNMENT = ALEFT, GAP = 10"
}

-- Creates frame 2
frm_2 = iup.frame
{
  iup.hbox
  {
    iup.fill {},
    iup.vbox
    {
      iup.button {title = "1", size = "20x30", action = ""},
      iup.button {title = "2", size = "30x30", action = ""},
      iup.button {title = "3", size = "40x30", action = ""} ;
      -- Sets alignment and margin of vbox
      alignment = "ACENTER",
    },
    iup.fill {}
  } ;
  -- Sets title of frame 1
  title = "ALIGNMENT = ACENTER"
}

-- Creates frame 3
frm_3 = iup.frame
{
  iup.hbox
  {
    iup.fill {},
    iup.vbox
    {
      iup.button {title = "1", size = "20x30", action = ""},
      iup.button {title = "2", size = "30x30", action = ""},
      iup.button {title = "3", size = "40x30", action = ""} ;
      -- Sets alignment and size of vbox
      alignment = "ARIGHT"
    },
    iup.fill {}
  } ;
  -- Sets title of frame 3
  title = "ALIGNMENT = ARIGHT"
}

dlg = iup.dialog
{
  iup.vbox
  {
    frm_1,
    frm_2,
    frm_3
  } ;
  title = "IupVbox Example", size = "QUARTER"
}

-- Shows dialog in the center of the screen
dlg:showxy (iup.CENTER, iup.CENTER)-- IupZbox Example in IupLua 
-- An application of a zbox could be a program requesting several entries from the user according to a previous selection. In this example, a list of possible layouts ,each one consisting of an element, is presented, and according to the selected option the dialog below the list is changed. 

fill = iup.fill {}
text = iup.text {value = "Enter your text here", expand = "YES"}
lbl  = iup.label {title = "This element is a label"}
btn  = iup.button {title = "This button does nothing"}
zbox = iup.zbox
{
  fill,
  text,
  lbl,
  btn ;
  alignment = "ACENTER", value=text
}

list = iup.list { "fill", "text", "lbl", "btn"; value="2"}
ilist = {fill, text, lbl, btn}

function list:action (t, o, selected)
  if selected == 1 then
    -- Sets the value of the zbox to the selected element 
    zbox.value=ilist[o]
  end
  
  return iup.DEFAULT
end

frm = iup.frame
{
  iup.hbox
  {
    iup.fill{},
    list,
    iup.fill{}
  } ;
  title = "Select an element"
}

dlg = iup.dialog
{
  iup.vbox
  {
    frm,
    zbox
  } ;
  size = "QUARTER",
  title = "IupZbox Example"
}

dlg:showxy (0, 0)
--[[
JSON4Lua example script.
Demonstrates the simple functionality of the json module.
]]--
json = require('json')


-- Object to JSON encode
test = {
  one='first',two='second',three={2,3,5}
}

jsonTest = json.encode(test)

print('JSON encoded test is: ' .. jsonTest)

-- Now JSON decode the json string
result = json.decode(jsonTest)

print ("The decoded table result:")
table.foreach(result,print)
print ("The decoded table result.three")
table.foreach(result.three, print)
--
-- jsonrpc.lua
-- Installed in a CGILua webserver environment (with necessary CGI Lua 5.0 patch)
--
require ('json.rpcserver')

-- The Lua class that is to serve JSON RPC requests
local myServer = {
  echo = function (msg) return msg end,
  average = function(...)
    local total=0
    local count=0
    for i=1, table.getn(arg) do
      total = total + arg[i]
      count = count + 1
    end
    return { average= total/count, sum = total, n=count }
  end
}

json.rpcserver.serve(myServer)--[[
Some basic tests for JSON4Lua.
]]--

--- Compares two tables for being data-identical.
function compareData(a,b)
  if (type(a)=='string' or type(a)=='number' or type(a)=='boolean' or type(a)=='nil') then return a==b end
  -- After basic data types, we're only interested in tables
  if (type(a)~='table') then return true end
  -- Check that a has everything b has
  for k,v in pairs(b) do
    if (not compareData( a[k], v ) ) then return false end
  end
  for k,v in pairs(a) do
    if (not compareData( v, b[k] ) ) then return false end
  end
  return true
end

---
-- Checks that our compareData function works properly
function testCompareData()
  s = "name"
  r = "name"
  assert(compareData(s,r))
  assert(not compareData('fred',s))
  assert(not compareData(nil, s))
  assert(not compareData("123",123))
  assert(not compareData(false, nil))
  assert(compareData(true, true))
  assert(compareData({1,2,3},{1,2,3}))
  assert(compareData({'one',2,'three'},{'one',2,'three'}))
  assert(not compareData({'one',2,4},{4,2,'one'}))
  assert(compareData({one='ichi',two='nichi',three='san'}, {three='san',two='nichi',one='ichi'}))
  s = { one={1,2,3}, two={one='hitotsu',two='futatsu',three='mitsu'} } 
  assert(compareData(s,s))
  t = { one={1,2,3}, two={one='een',two='twee',three='drie'} } 
  assert(not compareData(s,t))
end

testCompareData()
  
--
--
-- Performs some perfunctory tests on JSON module
function testJSON4Lua()
  json = require('json')
  
  if nil then
  -- Test encodeString
  s = [["\"
]]
  r = json._encodeString(s)
  assert(r=='\\"\\\\\\"\\n')
  s = [["""\\\"]]
  r = json._encodeString(s)
  assert(r==[[\"\"\"\\\\\\\"]])
  
  end 
  
  -- Test encode for basic strings (complicated strings)
  s = [[Hello, Lua!]]
  r = json.encode(s)
  assert(r=='"Hello, Lua!"')
  s = [["\"
]]
  r = json.encode(s)
  assert(r=='\"\\"\\\\\\"\\n\"')
  s = [["""\\\"]]
  r = json.encode(s)
  assert(r==[["\"\"\"\\\\\\\""]])
  
  -- Test encode for numeric values
  s = 23
  r = json.encode(s)
  assert(r=='23')
  s=48.123
  r = json.encode(s)
  assert(r=='48.123')
  
  -- Test encode for boolean values
  assert(json.encode(true)=='true')
  assert(json.encode(false)=='false')
  assert(json.encode(nil)=='null')

  -- Test encode for arrays
  s = {1,2,3}
  r = json.encode(s)
  assert(r=="[1,2,3]")
  s = {9,9,9}
  r = json.encode(s)
  assert(r=="[9,9,9]")
  
  -- Complex array test
  s = { 2, 'joe', false, nil, 'hi' }
  r = json.encode(s)
  assert(r=='[2,"joe",false,null,"hi"]')
  
  -- Test encode for tables
  s = {Name='Craig',email='craig@lateral.co.za',age=35}
  r = json.encode(s)
  -- NB: This test can fail because of order: need to test further once
  -- decoding is supported.
  assert(r==[[{"age":35,"Name":"Craig","email":"craig@lateral.co.za"}]])
  
  -- Test decode_scanWhitespace
  if nil then
  s = "   \n   \r   \t   "
  e = json._decode_scanWhitespace(s,1)
  assert(e==string.len(s)+1)
  s = " \n\r\t4"
  assert(json._decode_scanWhitespace(s,1)==5)
  
  -- Test decode_scanString
  s = [["Test"]]
  r,e = json._decode_scanString(s,1)
  assert(r=='Test' and e==7)
  s = [["This\nis a \"test"]]
  r = json._decode_scanString(s,1)
  assert(r=="This\nis a \"test")
  
  -- Test decode_scanNumber
  s = [[354]]
  r,e = json._decode_scanNumber(s,1)
  assert(r==354 and e==4)
  s = [[ 4565.23 AND OTHER THINGS ]]
  r,e = json._decode_scanNumber(s,2)
  assert(r==4565.23 and e==9)
  s = [[ -23.22 and ]]
  r,e = json._decode_scanNumber(s,2)
  assert(r==-23.22 and e==8)
 
  -- Test decode_scanConstant
  s = "true"
  r,e = json._decode_scanConstant(s,1)
  assert(r==true and e==5)
  s = "  false  "
  r,e = json._decode_scanConstant(s,3)
  assert(r==false and e==8)
  s = "1null6"
  r,e = json._decode_scanConstant(s,2)
  assert(r==nil and e==6)
  
  -- Test decode_scanArray
  s = "[1,2,3]"
  r,e = json._decode_scanArray(s,1)
  assert(compareData(r,{1,2,3}))
  s = [[[  1 ,   3  ,5 , "Fred" , true, false, null, -23 ] ]]
  r,e = json._decode_scanArray(s,1)
  assert(compareData(r, {1,3,5,'Fred',true,false,nil,-23} ) )
  s = "[3,5,null,7,9]"
  r,e = json._decode_scanArray(s,1)
  assert(compareData(r, {3,5,nil,7,9}))
  s = "[3,5,null,7,9,null,null]"
  r,e = json._decode_scanArray(s,1)
  assert(compareData(r, {3,5,nil,7,9,nil,nil}))
  
  end
  
  -- Test decode_scanObject
  s = [[ {"one":1, "two":2, "three":"three", "four":true} ]]
  r,e = json.decode(s)
  assert(compareData(r,{one=1,two=2,three='three',four=true}))
  s = [[ { "one" : { "first":1,"second":2,"third":3}, "two":2, "three":false } ]]
  r,e = json.decode(s)
  assert(compareData(r, {one={first=1,second=2,third=3},two=2,three=false}))
  s = [[ { "primes" : [2,3,5,7,9], "user":{"name":"craig","age":35,"programs_lua":true},
    "lua_is_great":true } ]]
  r,e = json.decode(s)
  assert(compareData(r, {primes={2,3,5,7,9},user={name='craig',age=35,programs_lua=true},lua_is_great=true}))
  
  -- Test json.null management
  t = { 1,2,json.null,4 }
  assert( json.encode(t)=="[1,2,null,4]" )
  t = {x=json.null }
  r = json.encode(t)
  assert( json.encode(t) == '{"x":null}' )
  
  -- Test comment decoding
  s = [[ /* A comment
            that spans
            a few lines
         */
         "test"
      ]]
  r,e = json.decode(s)
  assert(r=='test',"Comment decoding failed")
end

testJSON4Lua()

print("JSON4Lua tests completed successfully")--[[
  Some Time Trails for the JSON4Lua package
]]--


require('json')
require('os')
require('table')

local t1 = os.clock()
local jstr
local v
for i=1,100 do
  local t = {}
  for j=1,500 do
    table.insert(t,j)
  end
  for j=1,500 do
    table.insert(t,"VALUE")
  end
  jstr = json.encode(t)
  v = json.decode(jstr)
  --print(json.encode(t))
end

for i = 1,100 do
  local t = {}
  for j=1,500 do
    local m= math.mod(j,3)
    if (m==0) then
      t['a'..j] = true
    elseif m==1 then 
      t['a'..j] = json.null
    else
      t['a'..j] = j
    end
  end
  jstr = json.encode(t)
  v = json.decode(jstr)
end

print (jstr)
--print(type(t1))
local t2 = os.clock()

print ("Elapsed time=" .. os.difftime(t2,t1) .. "s")-----------------------------------------------------------------------------
-- JSON4Lua: JSON encoding / decoding support for the Lua language.
-- json Module.
-- Author: Craig Mason-Jones
-- Homepage: http://json.luaforge.net/
-- Version: 0.9.20
-- This module is released under the The GNU General Public License (GPL).
-- Please see LICENCE.txt for details.
--
-- USAGE:
-- This module exposes two functions:
--   encode(o)
--     Returns the table / string / boolean / number / nil / json.null value as a JSON-encoded string.
--   decode(json_string)
--     Returns a Lua object populated with the data encoded in the JSON string json_string.
--
-- REQUIREMENTS:
--   compat-5.1 if using Lua 5.0
--
-- CHANGELOG
--   0.9.20 Introduction of local Lua functions for private functions (removed _ function prefix). 
--          Fixed Lua 5.1 compatibility issues.
--   		Introduced json.null to have null values in associative arrays.
--          encode() performance improvement (more than 50%) through table.concat rather than ..
--          Introduced decode ability to ignore /**/ comments in the JSON string.
--   0.9.10 Fix to array encoding / decoding to correctly manage nil/null values in arrays.
-----------------------------------------------------------------------------

-----------------------------------------------------------------------------
-- Imports and dependencies
-----------------------------------------------------------------------------
local math = require('math')
local string = require("string")
local table = require("table")

local base = _G

-----------------------------------------------------------------------------
-- Module declaration
-----------------------------------------------------------------------------
module("json")

-- Public functions

-- Private functions
local decode_scanArray
local decode_scanComment
local decode_scanConstant
local decode_scanNumber
local decode_scanObject
local decode_scanString
local decode_scanWhitespace
local encodeString
local isArray
local isEncodable

-----------------------------------------------------------------------------
-- PUBLIC FUNCTIONS
-----------------------------------------------------------------------------
--- Encodes an arbitrary Lua object / variable.
-- @param v The Lua object / variable to be JSON encoded.
-- @return String containing the JSON encoding in internal Lua string format (i.e. not unicode)
function encode (v)
  -- Handle nil values
  if v==nil then
    return "null"
  end
  
  local vtype = base.type(v)  

  -- Handle strings
  if vtype=='string' then    
    return '"' .. encodeString(v) .. '"'	    -- Need to handle encoding in string
  end
  
  -- Handle booleans
  if vtype=='number' or vtype=='boolean' then
    return base.tostring(v)
  end
  
  -- Handle tables
  if vtype=='table' then
    local rval = {}
    -- Consider arrays separately
    local bArray, maxCount = isArray(v)
    if bArray then
      for i = 1,maxCount do
        table.insert(rval, encode(v[i]))
      end
    else	-- An object, not an array
      for i,j in base.pairs(v) do
        if isEncodable(i) and isEncodable(j) then
          table.insert(rval, '"' .. encodeString(i) .. '":' .. encode(j))
        end
      end
    end
    if bArray then
      return '[' .. table.concat(rval,',') ..']'
    else
      return '{' .. table.concat(rval,',') .. '}'
    end
  end
  
  -- Handle null values
  if vtype=='function' and v==null then
    return 'null'
  end
  
  base.assert(false,'encode attempt to encode unsupported type ' .. vtype .. ':' .. base.tostring(v))
end


--- Decodes a JSON string and returns the decoded value as a Lua data structure / value.
-- @param s The string to scan.
-- @param [startPos] Optional starting position where the JSON string is located. Defaults to 1.
-- @param Lua object, number The object that was scanned, as a Lua table / string / number / boolean or nil,
-- and the position of the first character after
-- the scanned JSON object.
function decode(s, startPos)
  startPos = startPos and startPos or 1
  startPos = decode_scanWhitespace(s,startPos)
  base.assert(startPos<=string.len(s), 'Unterminated JSON encoded object found at position in [' .. s .. ']')
  local curChar = string.sub(s,startPos,startPos)
  -- Object
  if curChar=='{' then
    return decode_scanObject(s,startPos)
  end
  -- Array
  if curChar=='[' then
    return decode_scanArray(s,startPos)
  end
  -- Number
  if string.find("+-0123456789.e", curChar, 1, true) then
    return decode_scanNumber(s,startPos)
  end
  -- String
  if curChar==[["]] or curChar==[[']] then
    return decode_scanString(s,startPos)
  end
  if string.sub(s,startPos,startPos+1)=='/*' then
    return decode(s, decode_scanComment(s,startPos))
  end
  -- Otherwise, it must be a constant
  return decode_scanConstant(s,startPos)
end

--- The null function allows one to specify a null value in an associative array (which is otherwise
-- discarded if you set the value with 'nil' in Lua. Simply set t = { first=json.null }
function null()
  return null -- so json.null() will also return null ;-)
end
-----------------------------------------------------------------------------
-- Internal, PRIVATE functions.
-- Following a Python-like convention, I have prefixed all these 'PRIVATE'
-- functions with an underscore.
-----------------------------------------------------------------------------

--- Scans an array from JSON into a Lua object
-- startPos begins at the start of the array.
-- Returns the array and the next starting position
-- @param s The string being scanned.
-- @param startPos The starting position for the scan.
-- @return table, int The scanned array as a table, and the position of the next character to scan.
function decode_scanArray(s,startPos)
  local array = {}	-- The return value
  local stringLen = string.len(s)
  base.assert(string.sub(s,startPos,startPos)=='[','decode_scanArray called but array does not start at position ' .. startPos .. ' in string:\n'..s )
  startPos = startPos + 1
  -- Infinite loop for array elements
  repeat
    startPos = decode_scanWhitespace(s,startPos)
    base.assert(startPos<=stringLen,'JSON String ended unexpectedly scanning array.')
    local curChar = string.sub(s,startPos,startPos)
    if (curChar==']') then
      return array, startPos+1
    end
    if (curChar==',') then
      startPos = decode_scanWhitespace(s,startPos+1)
    end
    base.assert(startPos<=stringLen, 'JSON String ended unexpectedly scanning array.')
    object, startPos = decode(s,startPos)
    table.insert(array,object)
  until false
end

--- Scans a comment and discards the comment.
-- Returns the position of the next character following the comment.
-- @param string s The JSON string to scan.
-- @param int startPos The starting position of the comment
function decode_scanComment(s, startPos)
  base.assert( string.sub(s,startPos,startPos+1)=='/*', "decode_scanComment called but comment does not start at position " .. startPos)
  local endPos = string.find(s,'*/',startPos+2)
  base.assert(endPos~=nil, "Unterminated comment in string at " .. startPos)
  return endPos+2  
end

--- Scans for given constants: true, false or null
-- Returns the appropriate Lua type, and the position of the next character to read.
-- @param s The string being scanned.
-- @param startPos The position in the string at which to start scanning.
-- @return object, int The object (true, false or nil) and the position at which the next character should be 
-- scanned.
function decode_scanConstant(s, startPos)
  local consts = { ["true"] = true, ["false"] = false, ["null"] = nil }
  local constNames = {"true","false","null"}

  for i,k in base.pairs(constNames) do
    --print ("[" .. string.sub(s,startPos, startPos + string.len(k) -1) .."]", k)
    if string.sub(s,startPos, startPos + string.len(k) -1 )==k then
      return consts[k], startPos + string.len(k)
    end
  end
  base.assert(nil, 'Failed to scan constant from string ' .. s .. ' at starting position ' .. startPos)
end

--- Scans a number from the JSON encoded string.
-- (in fact, also is able to scan numeric +- eqns, which is not
-- in the JSON spec.)
-- Returns the number, and the position of the next character
-- after the number.
-- @param s The string being scanned.
-- @param startPos The position at which to start scanning.
-- @return number, int The extracted number and the position of the next character to scan.
function decode_scanNumber(s,startPos)
  local endPos = startPos+1
  local stringLen = string.len(s)
  local acceptableChars = "+-0123456789.e"
  while (string.find(acceptableChars, string.sub(s,endPos,endPos), 1, true)
	and endPos<=stringLen
	) do
    endPos = endPos + 1
  end
  local stringValue = 'return ' .. string.sub(s,startPos, endPos-1)
  local stringEval = base.loadstring(stringValue)
  base.assert(stringEval, 'Failed to scan number [ ' .. stringValue .. '] in JSON string at position ' .. startPos .. ' : ' .. endPos)
  return stringEval(), endPos
end

--- Scans a JSON object into a Lua object.
-- startPos begins at the start of the object.
-- Returns the object and the next starting position.
-- @param s The string being scanned.
-- @param startPos The starting position of the scan.
-- @return table, int The scanned object as a table and the position of the next character to scan.
function decode_scanObject(s,startPos)
  local object = {}
  local stringLen = string.len(s)
  local key, value
  base.assert(string.sub(s,startPos,startPos)=='{','decode_scanObject called but object does not start at position ' .. startPos .. ' in string:\n' .. s)
  startPos = startPos + 1
  repeat
    startPos = decode_scanWhitespace(s,startPos)
    base.assert(startPos<=stringLen, 'JSON string ended unexpectedly while scanning object.')
    local curChar = string.sub(s,startPos,startPos)
    if (curChar=='}') then
      return object,startPos+1
    end
    if (curChar==',') then
      startPos = decode_scanWhitespace(s,startPos+1)
    end
    base.assert(startPos<=stringLen, 'JSON string ended unexpectedly scanning object.')
    -- Scan the key
    key, startPos = decode(s,startPos)
    base.assert(startPos<=stringLen, 'JSON string ended unexpectedly searching for value of key ' .. key)
    startPos = decode_scanWhitespace(s,startPos)
    base.assert(startPos<=stringLen, 'JSON string ended unexpectedly searching for value of key ' .. key)
    base.assert(string.sub(s,startPos,startPos)==':','JSON object key-value assignment mal-formed at ' .. startPos)
    startPos = decode_scanWhitespace(s,startPos+1)
    base.assert(startPos<=stringLen, 'JSON string ended unexpectedly searching for value of key ' .. key)
    value, startPos = decode(s,startPos)
    object[key]=value
  until false	-- infinite loop while key-value pairs are found
end

--- Scans a JSON string from the opening inverted comma or single quote to the
-- end of the string.
-- Returns the string extracted as a Lua string,
-- and the position of the next non-string character
-- (after the closing inverted comma or single quote).
-- @param s The string being scanned.
-- @param startPos The starting position of the scan.
-- @return string, int The extracted string as a Lua string, and the next character to parse.
function decode_scanString(s,startPos)
  base.assert(startPos, 'decode_scanString(..) called without start position')
  local startChar = string.sub(s,startPos,startPos)
  base.assert(startChar==[[']] or startChar==[["]],'decode_scanString called for a non-string')
  local escaped = false
  local endPos = startPos + 1
  local bEnded = false
  local stringLen = string.len(s)
  repeat
    local curChar = string.sub(s,endPos,endPos)
    if not escaped then	
      if curChar==[[\]] then
        escaped = true
      else
        bEnded = curChar==startChar
      end
    else
      -- If we're escaped, we accept the current character come what may
      escaped = false
    end
    endPos = endPos + 1
    base.assert(endPos <= stringLen+1, "String decoding failed: unterminated string at position " .. endPos)
  until bEnded
  local stringValue = 'return ' .. string.sub(s, startPos, endPos-1)
  local stringEval = base.loadstring(stringValue)
  base.assert(stringEval, 'Failed to load string [ ' .. stringValue .. '] in JSON4Lua.decode_scanString at position ' .. startPos .. ' : ' .. endPos)
  return stringEval(), endPos  
end

--- Scans a JSON string skipping all whitespace from the current start position.
-- Returns the position of the first non-whitespace character, or nil if the whole end of string is reached.
-- @param s The string being scanned
-- @param startPos The starting position where we should begin removing whitespace.
-- @return int The first position where non-whitespace was encountered, or string.len(s)+1 if the end of string
-- was reached.
function decode_scanWhitespace(s,startPos)
  local whitespace=" \n\r\t"
  local stringLen = string.len(s)
  while ( string.find(whitespace, string.sub(s,startPos,startPos), 1, true)  and startPos <= stringLen) do
    startPos = startPos + 1
  end
  return startPos
end

--- Encodes a string to be JSON-compatible.
-- This just involves back-quoting inverted commas, back-quotes and newlines, I think ;-)
-- @param s The string to return as a JSON encoded (i.e. backquoted string)
-- @return The string appropriately escaped.
function encodeString(s)
  s = string.gsub(s,'\\','\\\\')
  s = string.gsub(s,'"','\\"')
  s = string.gsub(s,"'","\\'")
  s = string.gsub(s,'\n','\\n')
  s = string.gsub(s,'\t','\\t')
  return s 
end

-- Determines whether the given Lua type is an array or a table / dictionary.
-- We consider any table an array if it has indexes 1..n for its n items, and no
-- other data in the table.
-- I think this method is currently a little 'flaky', but can't think of a good way around it yet...
-- @param t The table to evaluate as an array
-- @return boolean, number True if the table can be represented as an array, false otherwise. If true,
-- the second returned value is the maximum
-- number of indexed elements in the array. 
function isArray(t)
  -- Next we count all the elements, ensuring that any non-indexed elements are not-encodable 
  -- (with the possible exception of 'n')
  local maxIndex = 0
  for k,v in base.pairs(t) do
    if (base.type(k)=='number' and math.floor(k)==k and 1<=k) then	-- k,v is an indexed pair
      if (not isEncodable(v)) then return false end	-- All array elements must be encodable
      maxIndex = math.max(maxIndex,k)
    else
      if (k=='n') then
        if v ~= table.getn(t) then return false end  -- False if n does not hold the number of elements
      else -- Else of (k=='n')
        if isEncodable(v) then return false end
      end  -- End of (k~='n')
    end -- End of k,v not an indexed pair
  end  -- End of loop across all pairs
  return true, maxIndex
end

--- Determines whether the given Lua object / table / variable can be JSON encoded. The only
-- types that are JSON encodable are: string, boolean, number, nil, table and json.null.
-- In this implementation, all other types are ignored.
-- @param o The object to examine.
-- @return boolean True if the object should be JSON encoded, false if it should be ignored.
function isEncodable(o)
  local t = base.type(o)
  return (t=='string' or t=='boolean' or t=='number' or t=='nil' or t=='table') or (t=='function' and o==null) 
end

-----------------------------------------------------------------------------
-- JSONRPC4Lua: JSON RPC client calls over http for the Lua language.
-- json.rpc Module. 
-- Author: Craig Mason-Jones
-- Homepage: http://json.luaforge.net/
-- Version: 0.9.10
-- This module is released under the The GNU General Public License (GPL).
-- Please see LICENCE.txt for details.
--
-- USAGE:
-- This module exposes two functions:
--   proxy( 'url')
--     Returns a proxy object for calling the JSON RPC Service at the given url.
--   call ( 'url', 'method', ...)
--     Calls the JSON RPC server at the given url, invokes the appropriate method, and
--     passes the remaining parameters. Returns the result and the error. If the result is nil, an error
--     should be there (or the system returned a null). If an error is there, the result should be nil.
--
-- REQUIREMENTS:
--  Lua socket 2.0 (http://www.cs.princeton.edu/~diego/professional/luasocket/)
--  json (The JSON4Lua package with which it is bundled)
--  compat-5.1 if using Lua 5.0.
-----------------------------------------------------------------------------

module('json.rpc')

-----------------------------------------------------------------------------
-- Imports and dependencies
-----------------------------------------------------------------------------
local json = require('json')
local http = require("socket.http")

-----------------------------------------------------------------------------
-- PUBLIC functions
-----------------------------------------------------------------------------

--- Creates an RPC Proxy object for the given Url of a JSON-RPC server.
-- @param url The URL for the JSON RPC Server.
-- @return Object on which JSON-RPC remote methods can be called.
-- EXAMPLE Usage:
--   local jsolait = json.rpc.proxy('http://jsolait.net/testj.py')
--   print(jsolait.echo('This is a test of the echo method!'))
--   print(jsolait.args2String('first','second','third'))
--   table.foreachi( jsolait.args2Array(5,4,3,2,1), print)
function proxy(url)
  local serverProxy = {}
  local proxyMeta = {
    __index = function(t, key) 
      return function(...)
        return json.rpc.call(url, key, unpack(arg))
      end
    end
  }
  setmetatable(serverProxy, proxyMeta)
  return serverProxy
end

--- Calls a JSON RPC method on a remote server.
-- Returns a boolean true if the call succeeded, false otherwise.
-- On success, the second returned parameter is the decoded
-- JSON object from the server.
-- On http failure, returns nil and an error message.
-- On success, returns the result and nil.
-- @param url The url of the JSON RPC server.
-- @param method The method being called.
-- @param ... Parameters to pass to the method.
-- @return result, error The JSON RPC result and error. One or the other should be nil. If both
-- are nil, this means that the result of the RPC call was nil.
-- EXAMPLE Usage:
--   print(json.rpc.call('http://jsolait.net/testj.py','echo','This string will be returned'))
function call(url, method, ...)
  assert(method,'method param is nil to call')
  local JSONRequestArray = {
    id="httpRequest",
    ["method"]=method,
    params = arg
  }
  local httpResponse, result , code
  local jsonRequest = json.encode(JSONRequestArray)
  -- We use the sophisticated http.request form (with ltn12 sources and sinks) so that
  -- we can set the content-type to text/plain. While this shouldn't strictly-speaking be true,
  -- it seems a good idea (Xavante won't work w/out a content-type header, although a patch
  -- is needed to Xavante to make it work with text/plain)
  local ltn12 = require('ltn12')
  local resultChunks = {}
  httpResponse, code = http.request(
    { ['url'] = url,
      sink = ltn12.sink.table(resultChunks),
      method = 'POST',
      headers = { ['content-type']='text/plain', ['content-length']=string.len(jsonRequest) },
      source = ltn12.source.string(jsonRequest)
    }
  )
  httpResponse = table.concat(resultChunks)
  -- Check the http response code
  if (code~=200) then
    return nil, "HTTP ERROR: " .. code
  end
  -- And decode the httpResponse and check the JSON RPC result code
  result = json.decode( httpResponse )
  if result.result then
    return result.result, nil
  else
    return nil, result.error
  end
end
-----------------------------------------------------------------------------
-- JSONRPC4Lua: JSON RPC server for exposing Lua objects as JSON RPC callable
-- objects via http.
-- json.rpcserver Module. 
-- Author: Craig Mason-Jones
-- Homepage: http://json.luaforge.net/
-- Version: 0.9.10
-- This module is released under the The GNU General Public License (GPL).
-- Please see LICENCE.txt for details.
--
-- USAGE:
-- This module exposes one function:
--   server(luaClass, packReturn)
--     Manages incoming JSON RPC request forwarding the method call to the given
--     object. If packReturn is true, multiple return values are packed into an 
--     array on return.
--
-- IMPORTANT NOTES:
--   1. This version ought really not be 0.9.10, since this particular part of the 
--      JSONRPC4Lua package is very first-draft. However, the JSON4Lua package with which
--      it comes is quite solid, so there you have it :-)
--   2. This has only been tested with Xavante webserver, with which it works 
--      if you patch CGILua to accept 'text/plain' content type. See doc\cgilua_patch.html
--      for details.
----------------------------------------------------------------------------

module ('json.rpcserver')

---
-- Implements a JSON RPC Server wrapping for luaClass, exposing each of luaClass's
-- methods as JSON RPC callable methods.
-- @param luaClass The JSON RPC class to expose.
-- @param packReturn If true, the server will automatically wrap any
-- multiple-value returns into an array. Single returns remain single returns. If
-- false, when a function returns multiple values, only the first of these values will
-- be returned.
--
function serve(luaClass, packReturn)
  cgilua.contentheader('text','plain')
  require('cgilua')
  require ('json')
  local postData = ""
  
  if not cgilua.servervariable('CONTENT_LENGTH') then
    cgilua.put("Please access JSON Request using HTTP POST Request")
    return 0
  else
    postData = cgi[1]	-- SAPI.Request.getpostdata()  --[[{ "id":1, "method":"echo","params":["Hi there"]}]]  --
  end
  -- @TODO Catch an error condition on decoding the data
  local jsonRequest = json.decode(postData)
  local jsonResponse = {}
  jsonResponse.id = jsonRequest.id
  local method = luaClass[ jsonRequest.method ]

  if not method then
	jsonResponse.error = 'Method ' .. jsonRequest.method .. ' does not exist at this server.'
  else
    local callResult = { pcall( method, unpack( jsonRequest.params ) ) }
    if callResult[1] then	-- Function call successfull
      table.remove(callResult,1)
      if packReturn and table.getn(callResult)>1 then
        jsonResponse.result = callResult
      else
        jsonResponse.result = unpack(callResult)	-- NB: Does not support multiple argument returns
      end
    else
      jsonResponse.error = callResult[2]
    end
  end 
  
  -- Output the result
  -- TODO: How to be sure that the result and error tags are there even when they are nil in Lua?
  -- Can force them by hand... ?
  cgilua.contentheader('text','plain')
  cgilua.put( json.encode( jsonResponse ) )
end

--[[
	Auctioneer Advanced
	Version: <%version%> (<%codename%>)
	Revision: $Id: CoreMain.lua 2233 2007-09-25 03:57:33Z norganna $
	URL: http://auctioneeraddon.com/

	This is an addon for World of Warcraft that adds statistical history to the auction data that is collected
	when the auction is scanned, so that you can easily determine what price
	you will be able to sell an item for at auction or at a vendor whenever you
	mouse-over an item in the game

	License:
		This program is free software; you can redistribute it and/or
		modify it under the terms of the GNU General Public License
		as published by the Free Software Foundation; either version 2
		of the License, or (at your option) any later version.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program(see GPL.txt); if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

	Note:
		This AddOn's source code is specifically designed to work with
		World of Warcraft's interpreted AddOn system.
		You have an implicit licence to use this AddOn with these facilities
		since that is its designated purpose as per:
		http://www.fsf.org/licensing/licenses/gpl-faq.html#InterpreterIncompat
]]


--[[
	See CoreAPI.lua for a description of the modules API
]]

if (not AucAdvanced) then AucAdvanced = {} end
if (not AucAdvancedData) then AucAdvancedData = {} end
if (not AucAdvancedLocal) then AucAdvancedLocal = {} end
if (not AucAdvancedConfig) then AucAdvancedConfig = {} end

AucAdvanced.Version="<%version%>";
if (AucAdvanced.Version == "<".."%version%>") then
	AucAdvanced.Version = "5.0.DEV";
end

local private = {}

-- For our modular stats system, each stats engine should add their
-- subclass to AucAdvanced.Modules.<type>.<name> and store their data into their own
-- data table in AucAdvancedData.Stats.<type><name>
if (not AucAdvanced.Modules) then AucAdvanced.Modules = {Stat={},Util={},Filter={}} end
if (not AucAdvancedData.Stats) then AucAdvancedData.Stats = {} end
if (not AucAdvancedLocal.Stats) then AucAdvancedLocal.Stats = {} end

function private.TooltipHook(vars, ret, frame, name, hyperlink, quality, quantity, cost, additional)
	if EnhTooltip.LinkType(hyperlink) ~= "item" then
		return -- Auctioneer hooks into item tooltips only
	end

	-- Check to see if we need to force load scandata
	local getter = AucAdvanced.Settings.GetSetting
	if (getter("scandata.tooltip.display") and getter("scandata.force")) then
		AucAdvanced.Scan.GetImage()
	end

	for system, systemMods in pairs(AucAdvanced.Modules) do
		for engine, engineLib in pairs(systemMods) do
			if (engineLib.Processor) then engineLib.Processor("tooltip", frame, name, hyperlink, quality, quantity, cost, additional) end
		end
	end
end

function private.HookAH()
	hooksecurefunc("AuctionFrameBrowse_Update", AucAdvanced.API.ListUpdate)
	for system, systemMods in pairs(AucAdvanced.Modules) do
		for engine, engineLib in pairs(systemMods) do
			if (engineLib.Processor) then
				engineLib.Processor("auctionui")
			end
		end
	end
end

function private.OnLoad(addon)
	addon = addon:lower()

	-- Check if the actual addon itself is loading
	if (addon == "auc-advanced") then
		Stubby.RegisterAddOnHook("Blizzard_AuctionUi", "Auc-Advanced", private.HookAH)
		Stubby.RegisterFunctionHook("EnhTooltip.AddTooltip", 600, private.TooltipHook)
		for pos, module in ipairs(AucAdvanced.EmbeddedModules) do
			-- These embedded modules have also just been loaded
			private.OnLoad(module)
		end
	end

	-- Notify the actual module if it exists
	local auc, sys, eng = strsplit("-", addon)
	if (auc == "auc" and sys and eng) then
		for system, systemMods in pairs(AucAdvanced.Modules) do
			if (sys == system:lower()) then
				for engine, engineLib in pairs(systemMods) do
					if (eng == engine:lower() and engineLib.OnLoad) then
						engineLib.OnLoad(addon)
					end
				end
			end
		end
	end

	-- Check all modules' load triggers and pass event to processors
	for system, systemMods in pairs(AucAdvanced.Modules) do
		for engine, engineLib in pairs(systemMods) do
			if (engineLib.LoadTriggers and engineLib.LoadTriggers[addon]) then
				if (engineLib.OnLoad) then
					engineLib.OnLoad(addon)
				end
			end
			if (engineLib.Processor and auc == "auc" and sys and eng) then
				engineLib.Processor("load", addon)
			end
		end
	end
end

function private.OnUnload()
	for system, systemMods in pairs(AucAdvanced.Modules) do
		for engine, engineLib in pairs(systemMods) do
			if (engineLib.OnUnload) then
				engineLib.OnUnload()
			end
		end
	end
end

private.Schedule = {}
function private.OnEvent(...)
	local event, arg = select(2, ...)
	if (event == "ADDON_LOADED") then
		local addon = string.lower(arg)
		if (addon:sub(1,4) == "auc-") then
			private.OnLoad(addon)
		end
	elseif (event == "AUCTION_HOUSE_SHOW") then
		-- Do Nothing for now
	elseif (event == "AUCTION_HOUSE_CLOSED") then
		AucAdvanced.Scan.Interrupt()
	elseif (event == "PLAYER_LOGOUT") then
		AucAdvanced.Scan.Commit(true)
		private.OnUnload()
	elseif event == "UNIT_INVENTORY_CHANGED"
	or event == "ITEM_LOCK_CHANGED"
	or event == "CURSOR_UPDATE"
	or event == "BAG_UPDATE"
	then
		private.Schedule["inventory"] = GetTime() + 0.15
	end
end

function private.OnUpdate(...)
	if event == "inventory" then
		AucAdvanced.Post.AlertBagsChanged()
	end

	local now = GetTime()
	for event, time in pairs(private.Schedule) do
		if time > now then
			for system, systemMods in pairs(AucAdvanced.Modules) do
				for engine, engineLib in pairs(systemMods) do
					if engineLib.Processor then
						engineLib.Processor(event, time)
					end
				end
			end
		end
		private.Schedule[event] = nil
	end
end

private.Frame = CreateFrame("Frame")
private.Frame:RegisterEvent("ADDON_LOADED")
private.Frame:RegisterEvent("AUCTION_HOUSE_SHOW")
private.Frame:RegisterEvent("AUCTION_HOUSE_CLOSED")
private.Frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
private.Frame:RegisterEvent("ITEM_LOCK_CHANGED")
private.Frame:RegisterEvent("CURSOR_UPDATE")
private.Frame:RegisterEvent("BAG_UPDATE")
private.Frame:RegisterEvent("PLAYER_LOGOUT")
private.Frame:SetScript("OnEvent", private.OnEvent)
private.Frame:SetScript("OnUpdate", private.OnUpdate)

-- Auctioneer's debug functions
AucAdvanced.Debug = {}
local addonName = "Auctioneer" -- the addon's name as it will be displayed in
                               -- the debug messages
-------------------------------------------------------------------------------
-- Prints the specified message to nLog.
--
-- syntax:
--    errorCode, message = debugPrint([message][, category][, title][, errorCode][, level])
--
-- parameters:
--    message   - (string) the error message
--                nil, no error message specified
--    category  - (string) the category of the debug message
--                nil, no category specified
--    title     - (string) the title for the debug message
--                nil, no title specified
--    errorCode - (number) the error code
--                nil, no error code specified
--    level     - (string) nLog message level
--                         Any nLog.levels string is valid.
--                nil, no level specified
--
-- returns:
--    errorCode - (number) errorCode, if one is specified
--                nil, otherwise
--    message   - (string) message, if one is specified
--                nil, otherwise
-------------------------------------------------------------------------------
function AucAdvanced.Debug.DebugPrint(message, category, title, errorCode, level)
	return DebugLib.DebugPrint(addonName, message, category, title, errorCode, level)
end

-------------------------------------------------------------------------------
-- Used to make sure that conditions are met within functions.
-- If test is false, the error message will be written to nLog and the user's
-- default chat channel.
--
-- syntax:
--    assertion = assert(test, message)
--
-- parameters:
--    test    - (any)     false/nil, if the assertion failed
--                        anything else, otherwise
--    message - (string)  the message which will be output to the user
--
-- returns:
--    assertion - (boolean) true, if the test passed
--                          false, otherwise
-------------------------------------------------------------------------------
function AucAdvanced.Debug.Assert(test, message)
	return DebugLib.Assert(addonName, test, message)
end


