import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.mlab as mlab
import matplotlib.colors
import seaborn as sns
import numpy as np
import scipy.interpolate
import matplotlib.gridspec as gridspec


dfline = pd.read_excel('agegrp_proportions.xlsx',engine='openpyxl')
df = pd.read_csv("/content/age-date-index.csv",parse_dates=['Date'], dayfirst=True)
dfl = pd.read_csv("ann2.csv",usecols = ['dt_conf','cat_4'])

categ = ['Imported Domestic','Imported International','Local Traced','Local Untraced']

#Preprocessing data for 100% stacked bar graph
dn = {}
for d in dfl['dt_conf'].unique():
  a = dfl[dfl['dt_conf']==d].groupby('cat_4').count()
  sum=[]
  for i in categ:
    try:
      sum.append(a['dt_conf'][i])
    except:
      sum.append(0)
    ms = a['dt_conf'].sum()

  dn[d]={'Imported Domestic':sum[0]*100/ms,'Imported International':sum[1]*100/ms,'Local Traced':sum[2]*100/ms,'Local Untraced':sum[3]*100/ms}

dfnew = pd.DataFrame(dn).T

arr = []
for cats in categ:
  arr.append(dfnew[cats].tolist())


label=[]
for i in [k*20 for k in range(7)]:
  q = list(df[df['index']==i].index)
  label.append(df.loc[q[0],'Date'].strftime("%d %b"))

#Plotting
x = df['index']
y = df['Age']

fig = plt.figure(figsize=(40,35 ))
gs = gridspec.GridSpec(10, 7)

ax_main = plt.subplot(gs[1:3, :2])
ax_xDist = plt.subplot(gs[0, :2],sharex=ax_main)
ax_xlower = plt.subplot(gs[3:5,:2],sharex=ax_main)


scat = ax_main.hist2d(df['index'], df['Age'], (250, 200), cmap=plt.get_cmap('jet'),norm=matplotlib.colors.LogNorm())

ax_main.set(xlabel="Date", ylabel="Age")
ax_main.set_xticklabels(label)
ax_main.yaxis.tick_right()
ax_main.yaxis.set_label_position("right")


ax_xDist.hist(x,bins=100,align='mid')
ax_xDist.set(ylabel='Daily incidence')
ax_xDist.yaxis.get_major_ticks()[0].label1.set_visible(False)
ax_xDist.set_yscale('log', nonposy='clip')
ax_xDist.yaxis.tick_right()
ax_xDist.yaxis.set_label_position("right")

dates = dfnew.index.tolist() 
f = range(0,len(dates))
width=1

imdo = ax_xlower.bar(f, arr[0],width=width,color='#2374AB') #import domestic
iminter = ax_xlower.bar(f, arr[1], bottom=arr[0],width=width,color='#F6AF65') #import inter
loctr = ax_xlower.bar(f, arr[2], bottom=[i+j for i,j in zip(arr[0], arr[1])],width=width,color='#7CE577') #local traced
locuntr = ax_xlower.bar(f, arr[3], bottom=[i+j+k for i,j,k in zip(arr[0], arr[1],arr[2])],width=width,color='#984447') #local untraced

ax_xlower.legend([imdo,iminter,loctr,locuntr],categ,bbox_to_anchor=(1.15, 0.8), loc='upper left')
ax_xlower.yaxis.set_label_position("right")
ax_xlower.set(ylabel="Proportion of cases by origin (%)")
ax_xlower.yaxis.tick_right()

box = ax_main.get_position()
ax_main.set_position([box.x0, box.y0, box.width, box.height])

axColor = plt.axes([box.x0-0.03, box.y0, 0.008, box.height])
axline = plt.axes([(box.x0+ box.width)*1.09, box.y0, 0.069, box.height])

num=0
for column in dfline.drop('Agegrp', axis=1):
  num+=1  
  axline.plot(dfline[column], dfline['Agegrp'], marker='', linewidth=1, alpha=0.9, label=column)

axline.set(xlabel='Proportion of cases or deaths or population (%)')
axline.legend(prop={'size': 9})

cbar = plt.colorbar(scat[3], cax=axColor)
cbar.set_label("Daily incidence", horizontalalignment='left',rotation=90,labelpad = -70,y=0.4)
axColor.yaxis.set_ticks_position('left')

plt.savefig("age_vs_date_multiplot.png",dpi=300,bbox_inches='tight')
plt.show()