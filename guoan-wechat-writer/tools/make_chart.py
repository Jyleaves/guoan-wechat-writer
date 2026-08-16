# -*- coding: utf-8 -*-
"""九万里体文章配图生成：仅使用事实核查表中已核实的数字。"""
import os
try:
    import matplotlib
except ImportError:
    print('缺少依赖：请先安装 matplotlib（pip install matplotlib）。未安装时请跳过自动图表，改用半自动配图方案清单。')
    raise SystemExit(1)
matplotlib.use('Agg')
from matplotlib import font_manager
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch

font_manager.fontManager.addfont(r'C:\Windows\Fonts\msyh.ttc')
plt.rcParams['font.sans-serif'] = ['Microsoft YaHei']
plt.rcParams['axes.unicode_minus'] = False

NAVY = '#1f3864'
RED = '#b02a2a'
GRAY = '#595959'
CARD = '#f5f6f8'
OUT = os.environ.get('NEWSWRITER_OUT', r'outputs\images')

# ---------- 图1：关键数据卡片 ----------
fig, ax = plt.subplots(figsize=(10, 5.2), dpi=150)
ax.axis('off')
ax.set_xlim(0, 10)
ax.set_ylim(0, 5.2)
fig.suptitle('日本加息"风暴眼"：关键数据一览', fontsize=17, fontweight='bold', color=NAVY, y=0.97)

cards = [
    ('日本央行政策利率', '1.0%', '7月底会议维持'),
    ('通胀水平', '逼近2%', '目标门槛'),
    ('日元对美元汇率', '159~160', '8月再度走弱'),
    ('10年期国债收益率', '2.85%', '8月12日一周高位'),
    ('最新预算案规模', '122万亿', '日元，创历史纪录'),
]
n = len(cards)
w, gap, x0 = 1.78, 0.14, 0.18
for i, (label, value, note) in enumerate(cards):
    x = x0 + i * (w + gap)
    card = FancyBboxPatch((x, 1.05), w, 2.6, boxstyle='round,pad=0.05,rounding_size=0.08',
                          linewidth=1.1, edgecolor='#c9ced6', facecolor=CARD)
    ax.add_patch(card)
    ax.text(x + w/2, 3.0, value, ha='center', va='center', fontsize=15.5, fontweight='bold', color=RED)
    ax.text(x + w/2, 2.28, label, ha='center', va='center', fontsize=11.5, color=NAVY)
    ax.text(x + w/2, 1.55, note, ha='center', va='center', fontsize=9.5, color=GRAY)

ax.text(0.18, 0.55, '数据来源：日本央行、证券时报、共同社、47news、金十数据等公开报道，截至2026年8月13日',
        fontsize=9, color=GRAY)
fig.savefig(OUT + r'\jiaru-jp-keydata.png', bbox_inches='tight', facecolor='white')
plt.close(fig)

# ---------- 图2：风险传导链示意图 ----------
fig, ax = plt.subplots(figsize=(10, 4.6), dpi=150)
ax.axis('off')
ax.set_xlim(0, 10)
ax.set_ylim(0, 4.6)
fig.suptitle('日本版"特拉斯时刻"风险传导链（示意图）', fontsize=15, fontweight='bold', color=NAVY, y=0.97)

chain = [
    ('高市政府"大撒钱"\n122万亿日元预算案', '#b02a2a'),
    ('央行"鹰声缭绕"\n或9月加息', '#1f3864'),
    ('国债收益率上行\n10年期升至2.85%', '#7a4a9e'),
    ('财政付息负担\n持续攀升', '#c07a2e'),
    ('市场担忧\n"特拉斯时刻"重演', '#3a7d44'),
]
positions = [0.25, 2.3, 4.35, 6.4, 8.45]
bw, bh = 1.95, 1.9
for (text, color), x in zip(chain, positions):
    box = FancyBboxPatch((x, 1.5), bw, bh, boxstyle='round,pad=0.06,rounding_size=0.12',
                         linewidth=1.4, edgecolor=color, facecolor='white')
    ax.add_patch(box)
    ax.text(x + bw/2, 1.5 + bh/2, text, ha='center', va='center', fontsize=11.5, color=color, fontweight='bold')
    if x > 0.3:
        ax.add_patch(FancyArrowPatch((x - 0.06, 2.45), (x + 0.06, 2.45),
                                     arrowstyle='-|>', mutation_scale=20, color='#595959', linewidth=1.6))
ax.text(5.0, 1.05, '旁路变量：美日联合干预汇市（美元对日元一度"狂泻"800点，效果迅速消退）',
        ha='center', fontsize=10, color=GRAY)
ax.text(0.25, 0.45, '示意图内容全部来自事实核查表已核实数据；箭头表示市场传导逻辑，不代表官方结论',
        fontsize=9, color=GRAY)
fig.savefig(OUT + r'\jiaru-jp-flowchart.png', bbox_inches='tight', facecolor='white')
plt.close(fig)
print('done: 2 charts generated')
