# GMDP_plot_vX.m plots US bioeconomy data from 1980 to 2040
#
# Rob Carlson, 15 July 2014, Seattle, WA
#

#addpath /Users/robertcarlson/Documents/Bioeconomy/GMDP/GMDP_plot_code

graphics_toolkit gnuplot

close all
clear all

# plot flags: if flag > 0, then run code to generate plot
roughplot = -1;     # initial revenue plot
barchart1 = -1;     # rough stacked bar chart displaying by sector revenue data
interpplot = -1;    # rough initial plot of interpolations
totrate = -1;       # initial plot displaying total revenue growth rate
indivrate = 1;      # plot of by sector annual growth rates
piechart = -1;      # try out octave pie chart for most recent year revenue
expcomp = -1;       # compare revenue growth to exponential
revproj = -1;       # calculate and plot revenue projections out to 2040 with 5%, 10%, 15% growth

# data source flags: if flag > 0, then choose this data source
useGMDPfile = -1;    # use file containing data
useEmbeddata = 1;  # use data embedded in this octave file

###################
# Data in GDMP1 is 4 columns: year, biologics, industrial bio, crops
#
# Data in "GMDP1.txt" is padded with "-1" in all blanks
#   to enable Octave to figure out size of matrix
# 
# Octave needs .CSV (tab delimited text) with file extension removed
#   (may have to do this in "info" pane for file)
#
# Octave needs "Unix" line breaks and Western (MacOS) encoding
#

#load GMDP3;         # load GMDP data from file as specified above

margin = 0;

GMDP2 = [
1979	0	0	0
1980	-1	-1	0
1981	-1	-1	0
1982	-1	-1	0
1983	-1	-1	0
1984	-1	-1	0
1985	-1	-1	0
1986	-1	-1	0
1987	-1	-1	0
1988	-1	-1	0
1989	-1	-1	0
1990	-1	-1	0
1991	-1	-1	0
1992	-1	-1	0
1993	-1	-1	0
1994	-1	-1	0
1995	-1	-1	-1
1996	-1	-1	-1
1997	-1	-1	-1
1998	-1	-1	-1
1999	-1	-1	-1
2000	-1	-1	15.9
2001	-1	-1	18
2002	-1	-1	24
2003	-1	26	31.6
2004	-1	-1	34.4
2005	-1	31	35.6
2006	48.2	-1	47.3
2007	57.5	-1	75.6
2008	63.5	48	77.2
2009	70.2	-1	82
2010	71.8	71.7	110.4
2011	79.9	-1	121.8
2012	91	104.5*(1+margin)	128.3
# 2013  101 104.5*(1.15)  101
];

if (useGMDPfile > 0)
  data = GMDP1;
endif

if (useEmbeddata > 0)
  data = GMDP2;
endif 

#data2 = GMDP2; # GMDP2 has actual 0 for 0 instead of place holder -1

years = (data(:,1));
data0 = data;                 # data0 will be an array with the -1 place holders replaced by 0
biologics = (data(:,2));
indust = (data(:,3));
crops = (data(:,4));

[duration,nocats] = size(data); # get the dimensions data, including duration of time series and number of categories

span = ([1:duration]);

i=1;                          # replace -1's in data with 0's to enable accurate arithematic on columns
while (i <= duration)
  if (data0(i,2) < 0)
    (data0(i,2)) = 0;
  endif
  if (data0(i,3) < 0)
    (data0(i,3)) = 0;
  endif
  if (data0(i,4) < 0)
    (data0(i,4)) = 0;
  endif
  i++;
endwhile 

biologics0 = data0(:,2);       # put biologics revenues in array biologics0
indust0 = data0(:,3);          # put industrial revenues in indust0
crops0 = data0(:,4);           # put crop revenues in crops0

end_yr = max(years);                    # get parameters of time series for plots and interpolation
beg_yr = min(years);
beg_span = min(span);
end_span = max(span);

# use expression as index to create pointers to != -1 data
# then use indices to create interpolations only using extant data (pointed to by indices) on full year range

idxb = (biologics != -1);
idxi = (indust != -1);
idxc = (crops != -1);

# examine fit to data for only those years in which all components are known
#totdata = [data(idxi,1), biologics(idxi) + crops(idxi) + indust(idxi)]; # use index of indust != unknown to create array of years and total revenus

#td1 = polyfit(totdata(:,1), totdata(:,2), 2);     # fit polynomial to data
#fd1 = polyval(td1, years);                        # evaluate polynomial across full year range
#figure (14)
#b = plot(totdata(:,1), totdata(:,2), ".", years, fd1);

method = "cubic";                                               # cubic preferable here because of boundary conditions (no data earlier than 1980 or later than most recent)
Iindust = interp1 (years(idxi), indust(idxi), years, method);
Ibiologics = interp1 (years(idxb), biologics(idxb), years, method);
Icrops = interp1 (years(idxc), crops(idxc), years, method);
total = Ibiologics + Icrops + Iindust;                          # total interpolated revenues
years1 = years(2:end);
years1(end+1:end+2) = [2013 2014];

Itotal = Ibiologics + Iindust + Icrops;  # total revenue
revint = int32(Itotal);                  # integer revenue value for plot axes

# rough plot of interpolations
if (interpplot > 0)
figure (4)
plot (years, Iindust)
hold on
plot (years, Ibiologics, 'x')
plot (years, Icrops, 'o')
endif
###########################

##############
############## begin plot of interpolations (area) and data (bars)
figure (5)                                  # combined bar (data) and area (interpolation) chart 
h = figure (5);
y = horzcat (Icrops, Ibiologics , Iindust);  # concatenate columns into matrix
y = y(2:end,:);                             # remove 1979 null data
years80 = years(2:end);                       # remove 1979

z = area(years80, y);                         # stacked, shaded area plot of revenue interpolations
set (z(2), "facecolor", [1 .7 .7])          # shade of crops
set (z(1), "facecolor", [.7 1 .7])          # shade of biologics
set (z(3), "facecolor", [.5 .6 1])          # shade of industrial

hold on

It1 = polyfit(data(:,1), Itotal, 5);        # fit polynomial to check if growth well described by exponential
Itd = polyval(It1, years80);
#plot(years80, Itd, "linewidth", 5);

# create array of "spacebiobars" in biologics for years of no data, then make invisible, to lift crops and indust bars off y-axis

spacebiobars = biologics0;
spacebiobars(:,:) = 0;        # fill with zeros
spacebiobars(idxb != 1) = Ibiologics (idxb != 1);

revarray = [crops0, spacebiobars, biologics0, indust0];         # revarray is an array of revenue data
h = [NaN NaN NaN NaN; NaN NaN NaN NaN];                  # pad array with blanks to facilitate plotting
revarray = vertcat(revarray, h);
revarray = revarray(2:end,:);                     # remove 1979 data

foobar = bar (years1, revarray, "stacked");       # foobar is a stacked bar array of revenues
# axis ("tight")
axis ([1980 2014 0 400])
set (gca, 'ygrid', "on")
set (gca, 'fontname', 'helvetica')                          # turn on horiz grid lines. presently no way to alter appearance

set (foobar(2), "facecolor", "none", "edgecolor", "none", "linestyle", "none") # make spacebiobars invisible
set (foobar(3), "facecolor", [1 0 0])                 # set colors of bars
set (foobar(1), "facecolor", [0 1 0])
set (foobar(4), "facecolor", [0 0 1])

# hled = legend ("Biologics", "Crops", "Industrial", "location", "northwest")   # presently poor control of legend in Octave
# set (hled, 'fontsize', 14) 

barchartfontsize = 14;
set (gca, 'fontsize', (barchartfontsize-1));

xticklabel = num2str (years1);
set (gca, 'xticklabel', xticklabel);

## get position of current xtick labels
h = get(gca,'xlabel');
xlabelstring = get(h,'string');
xlabelposition = get(h,'position');

## construct position of new xtick labels
yposition = xlabelposition(2) + 8;
yposition = repmat(yposition, length(years1), 1);

## disable current xtick labels
set (gca, "xticklabel", "");
 
## set up new xtick labels and rotate
hnew = text(years1, yposition, xticklabel);
set (hnew,'rotation',45,'horizontalalignment','right', 'fontname', 'helvetica', "fontsize", barchartfontsize);
set (gca, "tickdir", "out")                     # set xticks to point out of rather than into plot
set (gca, 'xtick', [min(years1) : 1 : max(years1)])
set (gca, 'position', [0.08 0.13 0.90 0.84]);   # scale plot size to fit in window
                                                # by pinning position of lower left and upper right corners of plot
                                                # at [xlowerleft, ylowerleft, xupperright, yupperright]
H = 5.5; W = 10;
set(gcf,'PaperUnits','inches')
set(gcf,'PaperSize',[H,W])
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperPosition',[0,0,W,H])

print -color foobarplot.eps
#print -color foobarplot.png 
print -color foobarplot.svg

######### end plot of interpolations and data
##############################################


########### begin calculation of revenue projections
extra_end = 2024;                         # how far out should projections go?
temp = ((max(years80)):extra_end)';         # set temporary x-axis exension out to end year
xtra_years = vertcat (years80, temp);       # add extension to years of data set
xtra_years = xtra_years';
[xtra, foo] = size(temp);

rate15 = .15;
rate10 = .10;
rate5 = .05;
init = 350;

rev_proj15 = (init*((1 + rate15).^(0:xtra-1)))';    # use scalar raised to vector (0:xtra) in exponent to create vector 
                                                    # (cont) of revenue projections; start at 0 to get init val of 2012 revs
rev_proj10 = (init*((1 + rate10).^(0:xtra-1)))';    # etc
rev_proj5 = (init*((1 + rate5).^(0:xtra-1)))';      # etc                                              
                                                  
############ end calculation of revenue projections

# begin rough plot of revenues
if (roughplot > 0)
  figure(1)                     # create rough plot with raw by sector revenue data

  plot (years80, biologics, "s", "markersize", 6)
  axis ([beg_yr, 2015, 0, max(indust)*1.1]) 

  hold on

  plot (years80, indust, "o", "markersize", 6)
  plot (years80, crops, "x", "markersize", 6)
endif
# end rough plot of revenues

# begin initial version of barchart
if (barchart1 > 0)                                   # stacked bar chart displaying by sector revenue data
  figure(2)
  
  #revax = axis ([beg_yr, 2015, 0, max(revint)])
  revarray = [biologics0, crops0, indust0];         # revarray is an array of revenues
  foobar = bar (years80, revarray, "stacked");        # foobar is a stacked array of revenues
 #axis ("tight")
  set (foobar(1), "facecolor", "r")                 # set colors of bars
  set (foobar(2), "facecolor", "g")
  set (foobar(3), "facecolor", "b")
  #set (foobar, axis([beg_yr, (end_yr+1), 0, max(revint)]))

  ## init demo plot, derived from http://lists.gnu.org/archive/html/help-octave/2009-07/msg00273.html
  #xtick=[1 2 3 4];
  #set (gca,'xtick',years80);
  xticklabel = num2str (years80);
  set (gca, 'xticklabel', xticklabel);

  ## get position of current xtick labels
  h = get(gca,'xlabel');
  xlabelstring = get(h,'string');
  xlabelposition = get(h,'position');

  ## construct position of new xtick labels
  yposition = xlabelposition(2) + 8;
  yposition = repmat(yposition, length(years80), 1);

  ## disable current xtick labels
  set(gca, "xticklabel", "");
  
  ## set up new xtick labels and rotate
  hnew = text(years80, yposition, xticklabel);
  set(hnew,'rotation',45,'horizontalalignment','right');
  set (gca, 'position', [0.05 0.08 0.92 0.88]); # scale plot size to fit in window
                                                # by pinning position of lower left and upper right corners of plot
                                                # at [xlowerleft, ylowerleft, xupperright, yupperright] from the window boundaries
endif
# end initial version of bar chart

################## begin growth rate calculations
total = Ibiologics + Icrops + Iindust;          # calculate interpolated total revenue and growth rate
delt = diff (y);                                # calculate yr-yr differece of revenues for rate
klady = size (years80);                           # get year length of data set
ym = years80 (2:klady(1));                      # create year array w/o last year for rate
tm = (y(1:(klady(1)-1),:));                     # tm is array of same length as delt since y is horzcat of interpolated revenue

idt = (tm != 0);                                # create array of pointers to non-zero values of tm
rate = 100 * delt;                              # create rate array from delt (too large here; div below by annual total to get %)

rate(idt) ./= tm(idt);                          # divide element by element to get %

if (totrate > 0)                                # plot displaying total revenue growth rate
  figure (6)
  plot (ym, rate)
endif

kladz = size(ym);

first = (kladz(1)-11);
last = (kladz(1));
# end growth rate calculations

############# begin GMDP and GDP growth comparison ###########
# US_GDP_1980_2012 is taken directly from US DOC "current year" GDP data
# 

load US_GDP_1980_2012;
GDP = US_GDP_1980_2012;
GDPg = diff (US_GDP_1980_2012);
GMDPg = diff (total);

figure (9)

deltbar = bar(years80, horzcat(GMDPg, GDPg), "grouped"); # plot GMDP growth and GDP growth
axis ([1980 2013 -400 900])
set (deltbar(2), "facecolor", [.7 .7 .7])
set (deltbar(1), "facecolor", [0 0 0])
set (gca, 'fontname', 'helvetica', "fontsize", 14);

## set new year lables rotated 90 deg
  xticklabel = num2str (years80);
  set (gca, 'xticklabel', xticklabel);

  ## get position of current xtick labels
  h = get(gca,'xlabel');
  xlabelstring = get(h,'string');
  xlabelposition = get(h,'position');

  ## construct position of new xtick labels
  yposition = xlabelposition(2) + 425;
  yposition = repmat(yposition, length(years80), 1);

  ## disable current xtick labels
  set(gca, "xticklabel", "");
  
  ## set up new xtick labels and rotate
  hnew = text(years80, yposition, xticklabel);
  set(hnew,'rotation',90,'horizontalalignment','right', 'fontname', 'helvetica', 'fontsize', 14);
  set (gca, 'position', [0.11 0.08 0.88 0.88]);
  
  H = 3.5; W = 10;
  set(gcf,'PaperUnits','inches')
  set(gcf,'PaperSize',[H,W])
  set(gcf,'PaperOrientation','portrait');
  set(gcf,'PaperPosition',[0,0,W,H])

print -color GDPvsGMDP.svg
print -color GDPvsGMDP.eps
#print -color GDPvsGMDP.png  
  
# plot fraction of GDP due to GMDP

GMfract = (GMDPg ./ GDPg).*100;

r3 = polyfit(years80, GMfract, 3);      # generate fit to GMfract for later fit to data

# skip anomolous years (due to poor GDP growth during Great Recession)
#GMfract(29, :) = NaN;                # skip 2008
GMfract(30, :) = NaN;                 # skip 2009

tGDPf = total(2:end,:)./GDP(2:end,:); # GMDP as fraction of GDP from 1980 onward

figure (10)                           # plot GMDP growth as a % of GDP growth
fracbar = plot (years80, GMfract, 'color', 'r', ".-", "markersize", 8, "linewidth", 3,
 years80, 100.*tGDPf, "color", "b", ".-", "linewidth", 3, "markersize", 8);
axis ([1980 2013 0 (max(int32(GMfract)) +1)]);
# axis ([1980 2013 0 8]);

set (gca, 'fontname', 'helvetica', "fontsize", 14);
# set new y labels
# axis ("manual");
# ylim ([0, 8])
# set (gca, 'fontsize', 14);
set (gca,'yTick', 0:1:15);
set (gca, 'yticklabel', {"0%", "1%", "2%", "3%", "4%", "5%", "6%", "7%", "8%", "9%", "10%", "11%", "12%", "13%", "14%", "15%"});  

## set new year lables rotated 90 deg
  xticklabel = num2str (years80);
  set (gca, 'xticklabel', xticklabel);

  ## get position of current xtick labels
  set (gca, 'xTick', min(years80):1:max(years80));
  h = get(gca,'xlabel');
  xlabelstring = get(h,'string');
  xlabelposition = get(h,'position');

  ## construct position of new xtick labels
  yposition = xlabelposition(2);
  yposition = repmat(yposition, length(years80), 1);

  ## disable current xtick labels
  set(gca, "xticklabel", "");
  
  ## set up new xtick labels and rotate
  hnew = text(years80, yposition, xticklabel);
  set (hnew,'rotation',90,'horizontalalignment','right', 'fontname', 'helvetica', 'fontsize', 14);
  set (gca, 'position', [0.07 0.19 0.92 0.78]);
  
H = 3; W = 9.5;
set(gcf,'PaperUnits','inches')
set(gcf,'PaperSize',[H,W])
set(gcf,'PaperOrientation','portrait');
set(gcf,'PaperPosition',[0,0,W,H])

print -color GMfracplot.svg
print -color GMfracplot.eps
#print -color GMfracplot.png 

# end growth comparison

###################################
# begin plot of by sector annual growth rates
if (indivrate > 0)                              # plot displaying by sector growth rate
  figure (7)
  klad = plot (ym((first:last),:), horzcat(rate((first:last),:), 100.*GMDPg(first:last)./(total(first+1:last+1))), ".-", "markersize", 8, "linewidth", 3);  # plot rate from 2000 to 2011
  set (gca, 'fontname', 'helvetica') 
  set (klad(2), "color", "r")                                       # set colors of lines
  set (klad(1), "color", "g")
  set (klad(3), "color", "b")
  set (klad(4), "color", "k")
  axis ("tight")
  axis ("manual");
  ylim ([0, 70])
  set (gca, 'fontsize', 10);
  set (gca, 'yticklabel', {"0%", "10%", "20%", "30%", "40%", "50%", "60%", "70%"});
  get (gca, 'position'); 
  set (gca, 'position', [0.20 0.15 .7 .8]);
  
  H = 2; W = 2.5;
  set(gcf,'PaperUnits','inches')
  set(gcf,'PaperSize',[H,W])
  set(gcf,'PaperOrientation','portrait');
  set(gcf,'PaperPosition',[0,0,W,H])

print -color bysectorrate.svg
print -color bysectorrate.eps
#print -color bysectorrate.png
  
 endif
# end plot of by sector growth rate
###################################

# create US GDP comparison
usgdp2012 = 16000;  # in US trillions
us2012rate = .04;   # may be optmistic given long term trend: http://ablog.typepad.com/keytrendsinglobalisation/2011/01/slowing_of_the_us_economy.html

gdpproj = (usgdp2012*((1 + us2012rate).^(1:xtra)))';
gdpfrac15 = 100*(rev_proj15./gdpproj);
gdpfrac10 = 100*(rev_proj10./gdpproj);
gdpfrac5 = 100*(rev_proj5./gdpproj);
gdpfractot = horzcat (gdpfrac15, gdpfrac10, gdpfrac5);

if (revproj > 0)
# begin plot of GMDP revenue projections
figure(8)
#plot (temp, 100*(rev_proj15./gdpproj));
# [hax, H1, H2] = plotyy (temp, rev_proj15, temp, gdpfrac);
# hax = plot (temp, rev_proj15, temp, rev_proj10, temp, rev_proj5)
plot (temp, rev_proj15, "color", "black", "linewidth", 2)
set (gca, 'fontname', 'helvetica') 
axis ("manual");
ylim ([0, 2000])
hold on
#delete (H2)
plot (temp, rev_proj10, "color", "black", "linestyle", "--", "linewidth", 2);
plot (temp, rev_proj5, "color", "black", "linestyle", ":", "linewidth", 2);
set (gca, 'fontsize', 12);
endif

z = horzcat(rev_proj15, rev_proj10, rev_proj5);

if (piechart > 0)
# try a pie chart of revenues from most recent year

  figure (11)

  slices = [biologics(end) crops0(end) indust0(end)];
  labels = [cellstr(num2str(biologics(end))) cellstr(num2str(crops0(end))) cellstr(num2str(indust0(end)))];
  h = pie (slices, labels, [.1 .1 .1]);
  set (gca, 'fontname', 'helvetica', 'fontsize', 20)
  set (h(1), "facecolor", "r")                                       # set colors of slices
  set (h(2), "facecolor", "g")
  set (h(3), "facecolor", "b")
endif

if (expcomp > 0)
###################
### visual check of exponential fits to % of GDP and Itotal

q3 = polyfit(years80, tGDPf, 3);

y3 = polyval(q3, years80);
z3 = polyval(r3, years80);

y4 = log(y3(2:end));
y5 = polyfit(years80(2:end), y4, 1);

y6 = (exp(y5(2)))*exp((y5(1)*years80(2:end)));
y6 = vertcat(0, y6);

figure (14)
plot (years80, tGDPf, ".", years, y6)
title ("comparison of % of GDP with exponential")
# legend ({"data", "3rd"})

#figure (13)
# plotyy (years, GMfract, years, 100.*tGDPf)

litot = log(Itotal(2:end));
rate = polyfit(years80, litot, 1);
guess = (exp(rate(2)))*exp(rate(1).*years80);

figure(15)
plot(years80, Itotal(2:end), ".", years80, guess)
title("comparison of total revenues with exponential")

##################
endif
