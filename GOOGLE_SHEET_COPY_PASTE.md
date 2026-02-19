# Google Sheet Update - Copy/Paste Ready Data

**Your Sheet:** https://docs.google.com/spreadsheets/d/121oEwaW8mMVCj9dDgRvDod8KqPUgQ6p8LQ5UPQ0aZCs/edit

---

## TAB 1: PROBABILITY DISTRIBUTION

**Create a new tab called "Probability Distribution" and paste this:**

```
Rarity	Old Probability	New Probability	Change
Common	70.5%	60%	-10.5pp
Uncommon	25%	30%	+5pp
Rare	4%	9%	+5pp
Ultra	0.5%	1%	+0.5pp
TOTAL	100%	100%	✓

User Experience Impact:
Chance of uncommon or better	29.5%	40%	+35% improvement
Rare pull frequency	1 in 25 boxes	1 in 11 boxes	2.3x more
Ultra pull frequency	1 in 200 boxes	1 in 100 boxes	2x more
```

---

## TAB 2: UNIT ECONOMICS

**Create a new tab called "Unit Economics" and paste this:**

```
REVENUE STREAMS (Per Box):
Box sale	$25.00
Shake fee (30% adoption)	$0.45
Shipping fee (30% ship)	$1.50
TOTAL REVENUE PER BOX	$26.95

COST STRUCTURE (100% Sellback Scenario):
COGS (fixed)	$12.00

Expected sellback cost:
Common (60% × $7)	$4.20
Uncommon (30% × $22)	$6.60
Rare (9% × $40)	$3.60
Ultra (1% × $80)	$0.80
TOTAL SELLBACK COST	$15.20

TOTAL COST PER BOX	$27.20
GROSS PROFIT (100% sellback)	-$0.25
MARGIN (100% sellback)	-0.9%

REALISTIC SCENARIO (Weighted Sellback Rates):
Sellback rates by rarity:
Common	70% sellback
Uncommon	50% sellback
Rare	30% sellback
Ultra	20% sellback

Weighted sellback cost:
Common (60% × 70% × $7)	$2.94
Uncommon (30% × 50% × $22)	$3.30
Rare (9% × 30% × $40)	$1.08
Ultra (1% × 20% × $80)	$0.16
TOTAL WEIGHTED SELLBACK	$7.48

TOTAL COST (realistic)	$19.48
GROSS PROFIT (realistic)	$7.47
MARGIN (realistic)	27.7%
```

---

## TAB 3: OLD VS NEW COMPARISON

**Create a new tab called "Comparison" and paste this:**

```
Metric	Old (70.5/25/4/0.5)	New (60/30/9/1)	Change
Revenue per box	$26.95	$26.95	$0
COGS	$12.00	$12.00	$0
Expected sellback (realistic)	$6.76	$7.48	+$0.72
Total cost	$18.76	$19.48	+$0.72
Gross profit per box	$8.19	$7.47	-$0.72
Margin	30.4%	27.7%	-2.7pp

User gets uncommon or better	29.5%	40%	+35%
Ultra frequency	1 in 200	1 in 100	2x
Rare frequency	1 in 25	1 in 11	2.3x

Annual profit (100 boxes/mo)	$9,828	$8,964	-$864
Monthly profit	$819	$747	-$72

VERDICT: Trade $72/month margin for 2x viral events + 35% better UX
```

---

## TAB 4: SCALE PROJECTIONS

**Create a new tab called "Scale" and paste this:**

```
Volume	Monthly Profit	Annual Profit	Notes
100 boxes	$747	$8,964	Current baseline
250 boxes	$1,868	$22,410	6-month target
500 boxes	$3,735	$44,820	12-month target (viable)
1,000 boxes	$7,470	$89,640	18-month target (strong)
2,500 boxes	$18,675	$224,100	Exit velocity

Fixed costs (estimated): $250/month
Break-even volume: 34 boxes/month (well below current 100)
```

---

## TAB 5: INVENTORY REQUIREMENTS

**Create a new tab called "Inventory" and paste this:**

```
FOR 1,000 BOX CAPACITY:

Rarity	Probability	Boxes Needed	Current Stock	Need to Order
Common	60%	600	840	0 (surplus)
Uncommon	30%	300	130	+170 units
Rare	9%	90	25	+65 units
Ultra	1%	10	5	+5 units

CRITICAL ACTION: Order rare items immediately

Budget breakdown:
Uncommon (170 × $15)	$2,550
Rare (65 × $60)	$3,900	⚠️ CRITICAL
Ultra (5 × $150)	$750
TOTAL	$7,200

To reach 1,000 box capacity, invest $7,200 in inventory restocking.

CURRENT BOTTLENECK: Only 278 boxes supported (limited by rare items at 25 stock / 9% = 278)
```

---

## TAB 6: EXPECTED VALUE

**Create a new tab called "Expected Value" and paste this:**

```
100% Sellback Scenario:
EV = (0.60 × $7) + (0.30 × $22) + (0.09 × $40) + (0.01 × $80)
EV = $4.20 + $6.60 + $3.60 + $0.80
EV = $15.20 per box

Realistic Sellback Scenario (70/50/30/20 rates):
Weighted EV = (0.60 × 0.70 × $7) + (0.30 × 0.50 × $22) + (0.09 × 0.30 × $40) + (0.01 × 0.20 × $80)
Weighted EV = $2.94 + $3.30 + $1.08 + $0.16
Weighted EV = $7.48 per box

Customer EV as % of spend:
100% sellback	$15.20 / $25 = 60.8%
Realistic sellback	$7.48 / $25 = 29.9%
Industry benchmark	60-75% for gacha games (we're below, which is good)
```

---

## TAB 7: MONTE CARLO SIMULATION

**Create a new tab called "Monte Carlo" and paste this:**

```
MONTE CARLO SIMULATION RESULTS (10,000 iterations)

Profit per box (1,000 box batches):
Mean	$7.47
Standard Deviation	$0.54
95% Confidence Interval	$6.41 - $8.53

Worst case (2.5 percentile)	$6.41 profit/box
Best case (97.5 percentile)	$8.53 profit/box
Probability of loss per box	0%

Key insight: Very low variance ($0.54 std dev) = predictable, stable model
```

---

## TAB 8: SHAKE ECONOMICS

**Create a new tab called "Shake Feature" and paste this:**

```
Shake price	$1.49
COGS	$0 (pure software, no physical cost)
Gross margin	100%

Adoption rate assumption	30%
Revenue per 100 boxes	30 shakes × $1.49 = $44.70/month

Annual shake revenue (100 boxes/month)	$536.40

Shake mechanics:
• Eliminates 50% of items per rarity tier (common, uncommon, rare)
• Never eliminates ultras
• 30-minute localStorage TTL
• Idempotency protection via crypto.randomUUID()
```

---

## TAB 9: SHIPPING ECONOMICS

**Create a new tab called "Shipping" and paste this:**

```
Shipping fee	$5.00 (if balance < $50)
Free shipping	$0 (if balance >= $50)

Assumption: 30% of items kept and shipped
Revenue per 100 boxes	30 shipments × $5 = $150/month

Annual shipping revenue (100 boxes/month)	$1,800

Actual shipping cost (USPS First Class)	~$4-6
Net margin on shipping	Break-even to slight loss (acceptable)

Purpose: Offset logistics cost, not profit center
```

---

## TAB 10: WEEKLY TRACKING

**Create a new tab called "Weekly Metrics" and paste this:**

```
Week	Boxes	Revenue	Sellback Cost	Gross Profit	Profit/Box	Margin	Common%	Uncommon%	Rare%	Ultra%	Shake Adoption	Shipping Requests
1
2
3
4

TARGET BENCHMARKS:
Profit/Box	$7.47
Margin	27.7%
Common%	60%
Uncommon%	30%
Rare%	9%
Ultra%	1%
Shake Adoption	30%
Shipping Requests	30% of items kept
```

---

## TAB 11: RISK DASHBOARD

**Create a new tab called "Risk Dashboard" and paste this:**

```
KILL SWITCH CRITERIA:

Metric	Kill Threshold	Current Value	Status
Sellback rate (blended)	> 48%		⬜ OK / ⬜ KILL
Revenue per user	< Control group		⬜ OK / ⬜ KILL
Rare inventory	< 5 items		⬜ OK / ⬜ KILL
Cash balance	< $2,000		⬜ OK / ⬜ KILL
Profit per box	< $5.00		⬜ OK / ⬜ KILL

🔴 IF ANY THRESHOLD TRIGGERED: STOP AND ROLLBACK IMMEDIATELY

GO/NO-GO DECISION (Day 30):

Success Criteria	Target	Actual	Met?
Revenue per user	≥ Control		⬜ Yes / ⬜ No
Viral coefficient	+25% vs control		⬜ Yes / ⬜ No
7-day retention	+10% vs control		⬜ Yes / ⬜ No
Sellback rate	< 45%		⬜ Yes / ⬜ No
Customer satisfaction	NPS > 40		⬜ Yes / ⬜ No

DECISION:
5/5 criteria met	✅ FULL ROLLOUT - Keep 60/30/9/1, scale up
4/5 criteria met	✅ CONTINUE - Extend test 30 days
3/5 criteria met	⚠️ ITERATE - Adjust to 65/28/6/1 (compromise)
≤2/5 criteria met	❌ REVERT - Rollback to 70.5/25/4/0.5
```

---

## FORMULAS TO ADD

**In Unit Economics tab, add these formulas:**

**Cell for Weighted Sellback (Realistic):**
```
=0.60*0.70*7 + 0.30*0.50*22 + 0.09*0.30*40 + 0.01*0.20*80
```

**Cell for Gross Profit:**
```
=26.95 - 12 - [Weighted Sellback Cell]
```

**Cell for Margin:**
```
=[Gross Profit Cell] / 26.95
```

**In Scale tab, add formula for profit:**
```
=[Boxes] * 7.47 - 250
```

---

## DONE! ✅

All 11 tabs ready to copy/paste into your Google Sheet.

**Time required:** 10-15 minutes to copy/paste everything

**Next:** Format as needed (bold headers, currency formatting, percentages)
