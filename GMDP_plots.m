#! /usr/bin/env octave

################################################################################
## File: GMDP_plots.m
## Version: 1.4
## Purpose: Plot US bioeconomy data from 1980 to 2012.
## License: GNU General Public License, version 3
## Copyright (C) 2014-2015 Rob Carlson
## Copyright (C) 2015 Rik Wehbring
################################################################################

################################################################################
## Initialization
################################################################################

## Clean up workspace
close all           # close all plot windows
clear -x do_print   # clear all local variables except do_print
clear -g            # clear all global variables

## Variable controls whether printing occurs.
## On-screen positioning is different from print position and is also affected
if (! exist ("do_print", "var"))
  do_print = true;
endif

################################################################################
## Embedded data for plots
######################################################################
# GDMP data is CSV format in 4 columns: year, crops, biologics, industrial bio
## NaN = No Data Available
## Source: FIXME: add reference to paper.

GMDP = [
1979 , 0     , 0    , 0
1980 , 0     , NaN  , NaN
1981 , 0     , NaN  , NaN
1982 , 0     , NaN  , NaN
1983 , 0     , NaN  , NaN
1984 , 0     , NaN  , NaN
1985 , 0     , NaN  , NaN
1986 , 0     , NaN  , NaN
1987 , 0     , NaN  , NaN
1988 , 0     , NaN  , NaN
1989 , 0     , NaN  , NaN
1990 , 0     , NaN  , NaN
1991 , 0     , NaN  , NaN
1992 , 0     , NaN  , NaN
1993 , 0     , NaN  , NaN
1994 , 0     , NaN  , NaN
1995 , 0     , NaN  , NaN
1996 , NaN   , NaN  , NaN
1997 , NaN   , NaN  , NaN
1998 , NaN   , NaN  , NaN
1999 , NaN   , NaN  , NaN
2000 , 15.9  , NaN  , NaN
2001 , 18.0  , NaN  , NaN
2002 , 24.0  , NaN  , NaN
2003 , 31.6  , NaN  , 26.0
2004 , 34.4  , NaN  , NaN
2005 , 35.6  , NaN  , 31
2006 , 47.3  , 48.2 , NaN
2007 , 75.6  , 57.5 , NaN
2008 , 77.2  , 63.5 , 48.0
2009 , 82.0  , 70.2 , NaN
2010 , 110.4 , 71.8 , 71.7
2011 , 121.8 , 79.9 , NaN
2012 , 128.3 , 91.0 , 104.5
];

## Adjustment to 2012 industrial biotech revenues to account for final
## value add to consumers.  2012 revenues are B2B (wholesale) which misses
## value to consumers (essentially retail margins).
margin = 0;   # 0 = No Adjustment
GMDP(GMDP(:,1) == 2012, 4) *= (1 + margin);

######################################################################
## US GDP data (in billions)
## Source: US Dept. of Commerce, http://bea.gov/national/xls/gdplev.xls,
## retrieved on 12/24/15.
## Difference of .01% in 2012 GDP from original paper due to revision by BEA.
US_GDP = [
1979 , 2632.1
1980 , 2862.5
1981 , 3211.0
1982 , 3345.0
1983 , 3638.1
1984 , 4040.7
1985 , 4346.7
1986 , 4590.2
1987 , 4870.2
1988 , 5252.6
1989 , 5657.7
1990 , 5979.6
1991 , 6174.0
1992 , 6539.3
1993 , 6878.7
1994 , 7308.8
1995 , 7664.1
1996 , 8100.2
1997 , 8608.5
1998 , 9089.2
1999 , 9660.6
2000 , 10284.8
2001 , 10621.8
2002 , 10977.5
2003 , 11510.7
2004 , 12274.9
2005 , 13093.7
2006 , 13855.9
2007 , 14477.6
2008 , 14718.6
2009 , 14418.7
2010 , 14964.4
2011 , 15517.9
2012 , 16155.3
];

################################################################################
## Transform raw data
################################################################################

## Break out data table into more readable variable names
years = GMDP(:,1);
crops = GMDP(:,2);
biologics = GMDP(:,3);
indust = GMDP(:,4);

years80 = years(years >= 1980);      # remove 1979 from labels used on plots

## Create indices which point to valid data only.
idxb = (biologics >= 0);
idxi = (indust >= 0);
idxc = (crops >= 0);

## Interpolation method uses a Pointwise Cubic Hermite Interpolating Polynomial.
## The result has continuous 0th and 1st derivatives and preserves the shape
## of the data.  This is preferable to a spline with continuous second
## derivatives because of the discontinous boundary conditions (no data < 1980,
## no data > present).
method = "pchip";

Iindust = interp1 (years(idxi), indust(idxi), years, method);
Ibiologics = interp1 (years(idxb), biologics(idxb), years, method);
Icrops = interp1 (years(idxc), crops(idxc), years, method);

Itotal = Ibiologics + Iindust + Icrops;  # total interpolated revenue

################################################################################
## Set up default plot behavior
################################################################################

## Select a toolkit for plotting
graphics_toolkit gnuplot

## Use Arial as it is reasonably available on most platforms
default_font = "Arial";
set (0, "DefaultAxesFontName", default_font,
        "DefaultTextFontName", default_font);

default_fontsz = 14;
set (0, "DefaultAxesFontSize", default_fontsz,
        "DefaultTextFontSize", default_fontsz);

################################################################################
## GMDP revenue by sector and year
## Combined plot with bar chart (true data) and area plot (interpolation).
################################################################################

Irev = [Icrops, Ibiologics, Iindust];
Irev(years < 1980, :) = [];                 # remove 1979 null data

figure ();
ha = area (years80, Irev);
set (ha(1), "facecolor", [.7, 1, .7]);      # color of crops
set (ha(2), "facecolor", [1, .7, .7]);      # color of biologics
set (ha(3), "facecolor", [.5, .6, 1]);      # color of industrial

hold on;   # keep plot, and add bars to it

## Include a spacer in the data to be plotted (3rd column) which is used to
## "lift" industry data in the cases where no biologics data exists.

rev = [crops, biologics, zeros(size (biologics)), indust];
rev(years < 1980, :) = [];                  # remove 1979 null data

## Spacer for years with no data uses NaN (no display)
idx = isnan (rev(:,2)) & isnan (rev(:,4));
rev(idx, 3) = NaN;

## Create a spacer for years with industry data, but no biologics data
idx = isnan (rev(:,2)) & ! isnan (rev(:,4));
rev(idx, 3) = Irev(idx, 2);
rev(idx, 2) = 0;

## Crop data prior to 1995 is, by definition, 0.
## However, use NaN (no display) rather than 0 which creates hairline objects.
rev(years <= 1995, 1) = NaN;

hb = bar (years80, rev, "stacked");

############################################################
## Format plot

ymax = ceil (max (sum (Irev,2)) / 100) * 100;    # max y rounded to next 100
axis ([years80(1), years80(end)+1, 0, ymax]);    # axis limits
set (gca, "ygrid", "on");                        # turn on horiz. grid lines
set (gca, "tickdir", "out");                     # xticks point out of plot box

set (hb(1), "facecolor", [0 1 0]);               # color of crops
set (hb(2), "facecolor", [1 0 0]);               # color of biologics
                                                 # make spacer invisible
set (hb(3), "facecolor", "none", "edgecolor", "none", "linestyle", "none");
set (hb(4), "facecolor", [0 0 1]);               # color of industrial

ylabel ("USD Billions");
title (sprintf ("Estimated U.S. Biotech Revenues %d-%d", years(2), years(end)),
       "fontweight", "bold");

if (! do_print)
  ## Legend is upside down due to bug in Octave/gnuplot interface.
  [hleg, hobj] = legend ("Crops", "Biologics", "Industrial",
                         "location", "northwest");
  set (hleg, "fontsize", default_fontsz - 3);
endif

########################################
## Rotate year labels to 45 degrees.

## Set ticks to correct values to have graphics system calculate position.
set (gca, "xtick", years80);
xticklabel = get (gca, "xticklabel");

## Get position of X-axis label (may not be present)
hxl = get (gca, "xlabel");
xlabelposition = get (hxl, "position");

## Disable current xtick labeling
set (gca, "xticklabel", "");

## Calculate Y position of new xtick labels
spacer = ifelse (do_print, 0, .03 * ylim ()(2));
yposition = repmat (xlabelposition(2) + spacer, [numel(years80), 1]);

## Create new labels as text objects and rotate
ht = text (years80, yposition, xticklabel);
set (ht, "rotation", 45, "horizontalalignment", "right");

############################################################
## Print plot
H = 5.5; W = 10;

if (do_print)
  set (gcf, "PaperUnits", "inches");
  set (gcf, "PaperSize", [H, W]);
  set (gcf, "PaperOrientation", "portrait");
  set (gcf, "PaperPosition", [0, 0, W, H]);

  print -color GMDP.svg
else
  set (gcf, "units", "inches");
  figpos = get (gcf, "position");
  set (gcf, "position", [figpos(1:2), W, H]);
  axespos = get (gca, "position");
  axespos += [0, +.01, 0, -.02];
  set (gca, "position", axespos);
endif

################################################################################
## GMDP sector growth rate
## Line chart of annual growth rate per sector combined with aggregate.
################################################################################

Irev = [Icrops, Ibiologics, Iindust];

sector_g_rate = diff (Irev) ./ Irev(1:end-1, :);
total_g_rate = diff (Itotal) ./ Itotal(1:end-1);

## Time series data only really begins in 2000 with crop data.
idx = (years80 > 2000);

figure ();
h = plot (years80(idx), [sector_g_rate(idx,:), total_g_rate(idx)],
          ".-", "markersize", 8, "linewidth", 1.5);

############################################################
## Format plot

set (h(1), "color", "g");       # color of crops
set (h(2), "color", "r");       # color of biologics
set (h(3), "color", "b");       # color of indust
set (h(4), "color", "k");       # color of aggregate growth rate

fontsz = default_fontsz - 4;    # Inset plot uses smaller font
set (gca, "fontsize", fontsz);

## max y rounded to next .1
ymax = ceil (max (sector_g_rate(idx,:)(:) + 0.1) * 10) / 10;
axis ([2001, years80(end), 0, ymax]);

set (gca, "ytick", 0:0.1:ymax);
yticklabels = {};
for i = 0:10:100*ymax
  yticklabels(end+1) = sprintf ("%d%%", i);
endfor
set (gca, "yticklabel", yticklabels);

title ("Subsector Annual Growth Rate", "fontsize", fontsz+1);

if (! do_print)
  hleg = legend ("Crops", "Biologics", "Industrial", "Aggregate",
                 "location", "northeastoutside");
  set (hleg, "fontsize", fontsz+1);
endif

########################################
## Rotate year labels to 45 degrees.

## Get existing labels
xtick = [2002:2:2012];
set (gca, "xtick", xtick);
xticklabel = get (gca, "xticklabel");

## Get position of X-axis label (may not be present)
hxl = get (gca, "xlabel");
xlabelposition = get (hxl, "position");

## Disable current xtick labeling
set (gca, "xticklabel", "");

## Calculate Y position of new xtick labels
spacer = ifelse (do_print, -0.05 * ylim ()(2), 0);
yposition = repmat (xlabelposition(2) + spacer, [numel(xticklabel), 1]);

## Create new labels as text objects and rotate
ht = text (xtick, yposition, xticklabel);
set (ht, "rotation", 45, "horizontalalignment", "center", "fontsize", fontsz);

############################################################
## Print plot

if (do_print)
  H = 3; W = 3.5;
  set (gcf, "PaperUnits", "inches");
  set (gcf, "PaperSize", [H, W]);
  set (gcf, "PaperOrientation", "portrait");
  set (gcf, "PaperPosition", [0, 0, W, H]);

  print -color SectorGrowthRate.svg
endif

################################################################################
## Absolute annual GDP & GMDP revenue growth.
## Bar chart showing absolute amounts (USD Billions) of revenue growth per year
## for GDP & GMDP.
################################################################################

GDP = US_GDP(:, 2);
GDP_growth = diff (GDP);

GMDP_growth = diff (Itotal);

figure ();
subplot (2, 1, 2);
hb = bar (years80, [GMDP_growth, GDP_growth], "grouped");

############################################################
## Format plot

set (hb(1), "facecolor", [0 0 0]);         # GMDP is black
set (hb(2), "facecolor", [.7 .7 .7]);      # GDP is gray

axis ([years80(1)-1, years80(end)+1, -400, 900]);

set (gca, "xtick", years80);

htitle = title ("Annual Growth in U.S. GDP and U.S. Biotech Revenues", ...
                "fontweight", "bold");
ylabel ("USD Billions");
hleg = legend ("Biotech growth", "GDP growth", "location", "northwest");
set (hleg, "fontsize", default_fontsz - 3);

########################################
## Rotate year labels to 90 degrees.

## Create label text
xticklabel = get (gca, "xticklabel");

## Disable current xtick labeling
set (gca, "xticklabel", "");

## Calculate Y position of new xtick labels (which is inside plot)
limits = ylim ();
spacer = -.02 * (limits(2) - limits(1));
yposition = repmat (spacer, [length(years80), 1]);

## Create new labels as text objects and rotate
ht = text (years80, yposition, xticklabel);
set (ht, "rotation", 90, "horizontalalignment", "right");

## Move subplot down to fit better in window
axespos = get (gca, "position");
if (do_print)
  axespos(2) -= .05;
else
  axespos += [0, -.08, 0, +.05];
endif
set (gca, "position", axespos);

################################################################################
## GMDP fraction of GDP growth and GMDP contribution to GDP
################################################################################

GMDP_frac_GDP = (Itotal(2:end) ./ GDP(2:end)) * 100;

GMDP_frac_GDP_growth = (GMDP_growth ./ GDP_growth) * 100;

## Skip anomolous year of 2009 with negative GDP growth during Great Recession
idx = find (GDP_growth < 0);
GMDP_frac_GDP_growth(idx) = NaN;

subplot (2, 1, 1);
h = plot (years80, GMDP_frac_GDP_growth,
          "color", "r", ".-", "markersize", 8, "linewidth", 3,
          years80, GMDP_frac_GDP,
          "color", "b", ".-", "markersize", 8, "linewidth", 3);

############################################################
## Format plot
ymax = ceil (max (GMDP_frac_GDP_growth)) + 1;
axis ([years80(1)-1 years80(end)+1 0 ymax]);

set (gca, "xtick", years80);
set (gca, "ytick", 0:1:ymax);

yticklabels = {};
for i = 0:1:ymax
  yticklabels(end+1) = sprintf ("%d%%", i);
endfor
set (gca, "yticklabel", yticklabels);

title ("Estimated Biotech Revenue Contribution to U.S. GDP and GDP Growth",
       "fontweight", "bold");
hleg = legend ("Contribution of annual biotech growth to annual GDP growth",
               "Contribution of biotech revenues to GDP",
               "location", "northwest");
set (hleg, "fontsize", default_fontsz - 3);

########################################
## Add text note for anomolous year
ht = text (years80(idx), mean (GMDP_frac_GDP_growth([idx-1, idx+1])),
           sprintf ("**%d", years80(idx)),
           "horizontalalignment", "center", "rotation", 90);

########################################
## Rotate year labels to 90 degrees.

## Set labels to correct values to have graphics system calculate position.
xticklabel = get (gca, "xticklabel");

## Get position of X-axis label (may not be present)
hxl = get (gca, "xlabel");
xlabelposition = get (hxl, "position");

## Disable current xtick labeling
set (gca, "xticklabel", "");

## Calculate Y position of new xtick labels
spacer = .11 * ylim ()(2);
yposition = repmat (xlabelposition(2) + spacer, [numel(years80), 1]);

## Create new labels as text objects and rotate
ht = text (years80, yposition, xticklabel);
set (ht, "rotation", 90, "horizontalalignment", "right");

############################################################
## Print plot
H = 6.5; W = 10;

if (do_print)
  set (gcf, "PaperUnits", "inches");
  set (gcf, "PaperSize", [H, W]);
  set (gcf, "PaperOrientation", "portrait");
  set (gcf, "PaperPosition", [0, 0, W, H]);

  print -color GMDPfracGDP.svg
else
  set (gcf, "units", "inches");
  figpos = get (gcf, "position");
  set (gcf, "position", [figpos(1:2), W, H]);
  pause (0.01), refresh;   # Hack to get window redrawn
endif

