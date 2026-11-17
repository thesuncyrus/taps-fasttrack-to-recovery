"""Render verified aggregate results; never synthesize predictions from metrics."""
from pathlib import Path
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import pandas as pd
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'results/figures';OUT.mkdir(parents=True,exist_ok=True)
plt.rcParams.update({'font.family':'DejaVu Sans','font.size':11,'svg.fonttype':'none',
 'axes.spines.top':False,'axes.spines.right':False,'figure.facecolor':'#faf9f6','axes.facecolor':'#faf9f6'})
def save(fig,name):
 fig.tight_layout(pad=2)
 fig.savefig(OUT/name,bbox_inches='tight',metadata={'Creator':'Chau Nguyen research portfolio; verified data'})
 plt.close(fig)

d=pd.read_csv(ROOT/'results/poster-model-comparison.csv')
fig,ax=plt.subplots(figsize=(9,5))
colors=['#aab3a3','#aab3a3','#b79e7b','#b79e7b','#28645b','#28645b']
bars=ax.barh(d.approach+' · '+d.model,d.kaggle_score,color=colors)
ax.bar_label(bars,fmt='%.3f',padding=5);ax.set(xlim=(0,1),xlabel='Kaggle score reported in the project poster',title='TAPS · comparison of selected models\nSelected model variants from the project poster')
save(fig,'comparison.svg')
