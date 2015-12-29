################################################################################
## File: GMDP_plots.m 
## Version: 1.3
## Purpose: Plot US bioeconomy data from 1980 to 2040.
## License: FIXME: You should specify the License and License Version
## Copyright (C) 2014-2015 Rob Carlson
################################################################################

## Clean up workspace
close all
clear all

################################################################################
## Embedded data for plots
######################################################################
# GDMP data is CSV format in 4 columns: year, biologics, industrial bio, crops
## FIXME: Why not shuffle columns so that the original data also
##        appears in the same way that the script always uses it?
##        Column 1 = crops, Column 2 = biologics, Column 3 = industrial
## NaN = No Data Available 
## Source: FIXME: add source or reference to your paper.

GMDP = [
1979 , 0    , 0     , 0
1980 , NaN  , NaN   , 0
1981 , NaN  , NaN   , 0
1982 , NaN  , NaN   , 0
1983 , NaN  , NaN   , 0
1984 , NaN  , NaN   , 0
1985 , NaN  , NaN   , 0
1986 , NaN  , NaN   , 0
1987 , NaN  , NaN   , 0
1988 , NaN  , NaN   , 0
1989 , NaN  , NaN   , 0
1990 , NaN  , NaN   , 0
1991 , NaN  , NaN   , 0
1992 , NaN  , NaN   , 0
1993 , NaN  , NaN   , 0
1994 , NaN  , NaN   , 0
1995 , NaN  , NaN   , 0
1996 , NaN  , NaN   , NaN
1997 , NaN  , NaN   , NaN
1998 , NaN  , NaN   , NaN
1999 , NaN  , NaN   , NaN
2000 , NaN  , NaN   , 15.9
2001 , NaN  , NaN   , 18.0
2002 , NaN  , NaN   , 24.0
2003 , NaN  , 26.0  , 31.6
2004 , NaN  , NaN   , 34.4
2005 , NaN  , 31    , 35.6
2006 , 48.2 , NaN   , 47.3
2007 , 57.5 , NaN   , 75.6
2008 , 63.5 , 48.0  , 77.2
2009 , 70.2 , NaN   , 82.0
2010 , 71.8 , 71.7  , 110.4
2011 , 79.9 , NaN   , 121.8
2012 , 91.0 , 104.5 , 128.3
## FIXME: This looks like projecting, rather than raw data.
##        I would delete this, or at the very least make it explicit,
##        as I did below, about which data is sampled and which is derived.
## 2013  101 104.5*(1.15)  101
];

## FIXME: Do you need this anymore?
## Explicit adjustment to 2012 industrial biotech revenues
margin = 0;
GMDP(GMDP(:,1) == 2012, 3) *= (1 + margin);

######################################################################
## US GDP data (in billions)
## Source: US Dept. of Commerce, FIXME: web link? Retrieved ?
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
2012 , 16163.2
## FIXME: 2012 GDP was 16155.3 from the spreadsheet I downloaded (http://bea.gov/national/xls/gdplev.xls) on 12/24/15.  They may have updated their figures.
];

################################################################################
## Transform raw data 
################################################################################

## Break out data table into more readable variable names
years = GMDP(:,1);
biologics = GMDP(:,2);
indust = GMDP(:,3);
crops = GMDP(:,4);

years80 = years(years >= 1980);      # remove 1979 from labels used on plots

## Create indices which point to valid data only.
idxb = (biologics >= 0);
idxi = (indust >= 0);
idxc = (crops >= 0);

## Interpolation method uses a Pointwise Cubic Hermite Interpolating Polynomial.
## The result has continuous 0th and 1st derivatives and preserves the shape
## of the data.  This is preferable to a spline with continuous second
## derivatives because of the boundary conditions (no data < 1980,
## no data > present).
method = "pchip";

Iindust = interp1 (years(idxi), indust(idxi), years, method);
Ibiologics = interp1 (years(idxb), biologics(idxb), years, method);
Icrops = interp1 (years(idxc), crops(idxc), years, method);

Itotal = Ibiologics + Iindust + Icrops;  # total revenue

################################################################################
## Set up default plot behavior
################################################################################

## Select a toolkit for plotting
graphics_toolkit gnuplot

## Use Helvetica as it is reasonably available on most platforms
default_font = "Helvetica";
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
set (ha(1), "facecolor", [.7, 1, .7]);      # shade of crops
set (ha(2), "facecolor", [1, .7, .7]);      # shade of biologics
set (ha(3), "facecolor", [.5, .6, 1]);      # shade of industrial

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
axis ([years80(1), years80(end)+1, 0, ymax]);
set (gca, "ygrid", "on");                        # turn on horiz grid lines.
## set xticks to point out of plot box
set (gca, "tickdir", "out");

set (hb(1), "facecolor", [0 1 0]);               # set color of crops
set (hb(2), "facecolor", [1 0 0]);               # set color of biologics
                                                 # make spacer invisible
set (hb(3), "facecolor", "none", "edgecolor", "none", "linestyle", "none");
set (hb(4), "facecolor", [0 0 1]);               # set color of indust

## FIXME: It would be helpful to add X,Y axis labels, as well as plot title.
##        Even if, as in the publication version, some of the text is deleted.
## ylabel ("USD Billions");
## title (sprintf ("Estimated U.S. Biotech Revenues %d-%d", years(2), years(end)));
## hleg = legend ("Crops", "Biologics", "Industrial", "location", "northwest");
## set (hleg, "fontsize", default_fontsz) 

########################################
## Rotate year labels to 45 degrees.

## Set labels to correct values to have graphics system calculate position.
xticklabel = num2str (years80);
set (gca, "xticklabel", xticklabel);
set (gca, "xtick", years80);

## Get position of X-axis label (may not be present)
hxl = get (gca, "xlabel");
xlabelposition = get (hxl, "position");

## Disable current xtick labeling
set (gca, "xticklabel", "");
 
## Calculate Y position of new xtick labels
spacer = .03 * ylim ()(2);
yposition = repmat (xlabelposition(2) + spacer, [numel(years80), 1]);

## Create new labels as text objects and rotate
ht = text (years80, yposition, xticklabel);
set (ht, "rotation", 45, "horizontalalignment", "right");,

## Scale plot size to fit in window
## by pinning position of lower left and upper right corners of plot
## at [xlowerleft, ylowerleft, xupperright, yupperright]
## FIXME: The explanation in the comment is wrong.  Position is
##        [xlowerleft, ylowerleft, width, height].
##        The current setting seems to unnecessarily push the plot to the right
set (gca, "position", [0.08 0.13 0.90 0.84]);
                                                
############################################################
## Print plot 

H = 5.5; W = 10;
set (gcf, "PaperUnits", "inches");
set (gcf, "PaperSize", [H, W]);
set (gcf, "PaperOrientation", "portrait");
set (gcf, "PaperPosition", [0, 0, W, H]);

print -color GMDP.svg
print -color GMDP.eps

################################################################################
## GMDP sector growth rate
## Line chart of annual growth rate per sector combined with aggregate.
################################################################################

Irev = [Icrops, Ibiologics, Iindust];

## FIXME: Examine this carefully before signing off on the calculation.
## As an example, this calculates growth = (1980 - 1979) / 1979.
## This seems appropriate because 1980 = (1 + growth) * 1979.
sector_g_rate = diff (Irev) ./ Irev(1:end-1, :);
total_g_rate = diff (Itotal) ./ Itotal(1:end-1);

## Time series data really only begins in 2000 with crop data.
idx = (years80 > 2000);

figure ();
h = plot (years80(idx), [sector_g_rate(idx,:), total_g_rate(idx)],
          ".-", "markersize", 8, "linewidth", 3);

############################################################
## Format plot 

set (h(1), "color", "g");       # set color of crops
set (h(2), "color", "r");       # set color of biologics
set (h(3), "color", "b");       # set color of indust
set (h(4), "color", "k");       # set color of aggregate growth rate

set (gca, "fontsize", 10);

## max y rounded to next .1
ymax = ceil (max (sector_g_rate(idx,:)(:) + 0.1) * 10) / 10;
axis ([2001, years80(end), 0, ymax]);

set (gca, "ytick", 0:0.1:ymax);
yticklabels = {};
for i = 0:10:100*ymax
  yticklabels(end+1) = sprintf ("%d%%", i);
endfor
set (gca, "yticklabel", yticklabels);

########################################
## Rotate year labels to 45 degrees.

## Get existing labels
xtick = get (gca, "xtick");
xticklabel = get (gca, "xticklabel");

## Get position of X-axis label (may not be present)
hxl = get (gca, "xlabel");
xlabelposition = get (hxl, "position");

## Disable current xtick labeling
set (gca, "xticklabel", "");
 
## Calculate Y position of new xtick labels
spacer = .012 * ylim ()(2);
yposition = repmat (xlabelposition(2) + spacer, [numel(xticklabel), 1]);

## Create new labels as text objects and rotate
ht = text (xtick, yposition, xticklabel);
set (ht, "rotation", 45, "horizontalalignment", "center", "fontsize", 10);

## Reposition plot within page
## FIXME: is it necessary to move this plot quite so much to the right?
##        Given that is is exported as svg and then moved to its final
##        location it would seem more natural to adjust only the yposition
##        to accommodate the rotated text object labels.
set (gca, "position", [0.20 0.15 .7 .8]);

############################################################
## Print plot 

H = 2; W = 2.5;
set (gcf, "PaperUnits", "inches");
set (gcf, "PaperSize", [H, W]);
set (gcf, "PaperOrientation", "portrait");
set (gcf, "PaperPosition", [0, 0, W, H]);

print -color SectorGrowthRate.svg
print -color SectorGrowthRate.eps
  
################################################################################
## Absolute annual GDP & GMDP revenue growth.
## Bar chart showing absolute amounts (USD Billions) of revenue growth per year
## for GDP & GMDP.
################################################################################

GDP = US_GDP(:, 2);
GDP_growth = diff (GDP);

GMDP_growth = diff (Itotal);

figure ();
hb = bar (years80, [GMDP_growth, GDP_growth], "grouped");

############################################################
## Format plot 

set (hb(1), "facecolor", [0 0 0]);         # GMDP is black
set (hb(2), "facecolor", [.7 .7 .7]);      # GDP is gray

## FIXME: You could set the xlimits to be the ones below + [-1 +1 0 0]
##        if you want to give yourself some room on the left and right
##        of the plot.
axis ([years80(1) years80(end) -400 900]);

set (gca, "xtick", years80);

########################################
## Rotate year labels to 90 degrees.

## Create label text
xticklabel = num2str (years80);

## Disable current xtick labeling
set (gca, "xticklabel", "");
 
## Calculate Y position of new xtick labels (which is inside plot)
limits = ylim ();
spacer = -.02 * (limits(2) - limits(1));
yposition = repmat (spacer, [length(years80), 1]);

## Create new labels as text objects and rotate
ht = text (years80, yposition, xticklabel);
set (ht, "rotation", 90, "horizontalalignment", "right");

## Scale plot size to fit in window
## FIXME: Is this really necessary?  In this case, the labels are already
##        positioned inside the axis object so there shouldn't be a reason
##        to move the axis object relative to the figure.
set (gca, "position", [0.11 0.08 0.88 0.88]);
  
############################################################
## Print plot 

H = 3.5; W = 10;
set (gcf, "PaperUnits", "inches");
set (gcf, "PaperSize", [H, W]);
set (gcf, "PaperOrientation", "portrait");
set (gcf, "PaperPosition", [0, 0, W, H]);

print -color GDPvsGMDP.svg
print -color GDPvsGMDP.eps

################################################################################
## GMDP fraction of GDP growth and GMDP contribution to GDP
################################################################################

GMDP_frac_GDP = (Itotal(2:end) ./ GDP(2:end)) * 100;

GMDP_frac_GDP_growth = (GMDP_growth ./ GDP_growth) * 100;

## Skip anomolous year of 2009 with negative GDP growth during Great Recession 
idx = find (GDP_growth < 0);
GMDP_frac_GDP_growth(idx) = NaN;

figure ();
h = plot (years80, GMDP_frac_GDP_growth,
          "color", "r", ".-", "markersize", 8, "linewidth", 3,
          years80, GMDP_frac_GDP,
          "color", "b", ".-", "markersize", 8, "linewidth", 3);

############################################################
## Format plot 

ymax = ceil (max (GMDP_frac_GDP_growth)) + 1;
axis ([years80(1) years80(end) 0 ymax]);

set (gca, "xtick", years80);
set (gca, "ytick", 0:1:ymax);

yticklabels = {};
for i = 0:1:ymax
  yticklabels(end+1) = sprintf ("%d%%", i);
endfor
set (gca, "yticklabel", yticklabels);  

########################################
## Add text note for anomolous year
ht = text (years80(idx), mean (GMDP_frac_GDP_growth([idx-1, idx+1])),
           sprintf ("**%d", years80(idx)),
           "horizontalalignment", "center", "rotation", 90);

########################################
## Rotate year labels to 90 degrees.

## Set labels to correct values to have graphics system calculate position.
xticklabel = num2str (years80);
set (gca, "xticklabel", xticklabel);

## Get position of X-axis label (may not be present)
hxl = get (gca, "xlabel");
xlabelposition = get (hxl, "position");

## Disable current xtick labeling
set (gca, "xticklabel", "");

## Calculate Y position of new xtick labels
spacer = .05 * ylim ()(2);
yposition = repmat (xlabelposition(2) + spacer, [numel(years80), 1]);

## Create new labels as text objects and rotate
ht = text (years80, yposition, xticklabel);
set (ht, "rotation", 90, "horizontalalignment", "right");

## FIXME: If you want to have the same size plot as the one above then
##        you should set the width (3) to be the same as the plot above.
set (gca, "position", [0.07 0.19 0.92 0.78]);
  
############################################################
## Print plot 
## FIXME: This is using a different print size than the plot above it.
##        If you want things to line up then you should be using the width
##        property of the axis position property.
H = 3; W = 9.5;
set (gcf, "PaperUnits", "inches");
set (gcf, "PaperSize", [H, W]);
set (gcf, "PaperOrientation", "portrait");
set (gcf, "PaperPosition", [0, 0, W, H]);

print -color GMDPfracGDP.svg
print -color GMDPfracGDP.eps

