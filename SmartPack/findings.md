# PM Review: SmartPack Preset Items & Scenarios

## Executive Summary

After a comprehensive PM review and subsequent revamp, the preset system now covers **17 tags** across 3 groups with **~120 items**. Coverage has improved from 6/10 to **7.5/10** for general-purpose use, with base items expanded, mainstream activities added, and structural issues fixed.

**Current Assessment: 7.5/10 for general-purpose coverage, 8.5/10 for adventure/outdoor niche.**

---

## 1. SCENARIO COVERAGE ANALYSIS

### 1.1 Current 17 Tags (post-revamp)

#### Activities (10 tags)

| Tag | Icon | Items | Status |
|-----|------|-------|--------|
| Running / 跑步 | figure.run | 6 | Unchanged |
| Climbing / 攀岩 | figure.climbing | 7 | +1 (速干衣裤) |
| Diving / 潜水 | fish | 5 | Icon updated |
| Camping / 露营 | tent | 8 | Unchanged |
| Trail Running / 越野 | mountain.2 | 12 | +2 (登山杖, 速干衣裤), icon updated |
| Photography / 摄影 | camera | 8 | Unchanged |
| Motorcycle Tour / 摩旅 | motorcycle | 5 | Renamed 头盔→摩托车头盔 |
| Skiing / 滑雪 | figure.skiing.downhill | 8 | +1 (滑雪手套), icon updated |
| Beach / 海滩 | beach.umbrella | 6 | +1 (遮阳帽) |
| **Gym / 健身** | dumbbell | 4 | **NEW** |

#### Occasions (2 tags)

| Tag | Icon | Items | Status |
|-----|------|-------|--------|
| Party / 宴会 | wineglass | 4 | Renamed items, 发胶 now male-only |
| Business Meeting / 商务会议 | briefcase | 7 | Removed 演示翻页笔, 发胶 now male-only |

#### Configs (5 tags)

| Tag | Icon | Items | Status |
|-----|------|-------|--------|
| International Travel / 国际旅行 | globe | 8 | Removed 身体乳, icon updated |
| With Kids / 带娃 | figure.child | 6 | Unchanged |
| With Pet / 带宠物 | pawprint | 6 | Unchanged |
| Self Drive / 自驾 | car | 3 | **Moved from Occasion→Config**, trimmed to 3 items |
| **Long-haul Flight / 长途飞行** | airplane.cloud | 4 | **NEW** |

---

### 1.2 Remaining Missing Scenarios

#### HIGH-PRIORITY (should add next)

| Proposed Tag | Group | Why | Est. Users% |
|---|---|---|---|
| **Cycling / 骑行** | Activity | Hugely popular in China and globally | 15-20% |
| **Fishing / 钓鱼** | Activity | Extremely popular in China | 10-15% |
| **Wedding / 婚礼** | Occasion | One of the most common "special trip" reasons | 10-15% |

#### MEDIUM-PRIORITY (nice to have)

| Proposed Tag | Group | Why |
|---|---|---|
| **Golf / 高尔夫** | Activity | Significant niche, especially for business travelers |
| **Surfing / 冲浪** | Activity | Growing rapidly, distinct from diving/beach |
| **Music Festival / 音乐节** | Occasion | Very popular among younger demographics |
| **Hot Spring / 温泉** | Activity | Extremely popular in China, Japan, Korea |
| **With Elderly / 带老人** | Config | Different from kids -- medication, mobility aids, comfort items |

---

## 2. ITEM COMPLETENESS REVIEW

### 2.1 Base Items (18 common + 2 male + 8 female = 28 total)

**Improvements made:**
- Added 舒适步行鞋 / Comfortable Walking Shoe (base_clo_006)
- Added 背包 / DayPack (base_clo_007)
- Renamed 数据线→充电数据线, 充电宝→移动充, Top→Tops
- Consolidated female items (removed 护发素, 面膜 -- overlapped with 护肤品)
- Renamed 配饰→首饰/配饰

**Still potentially missing (lower priority):**
- 雨伞 (Umbrella) -- universal need
- 常备药品 (Basic Medicine) -- only in international config currently
- 拖鞋 (Slippers) -- common packing item in China

### 2.2 Gender-Specific Items

| Gender | Items | Assessment |
|--------|-------|-----------|
| Male | 2 (razor, hair gel) | Still sparse, but hair gel now correctly scoped (male-only in occasions too) |
| Female | 8 (was 10, consolidated) | Cleaner -- removed overlapping items |

### 2.3 Per-Tag Item Review (post-revamp)

#### Resolved Issues
- **Beach:** Added 遮阳帽 (Sun Hat) -- was missing
- **Skiing:** Added 滑雪手套 (Ski Gloves) -- was a critical omission
- **Trail Running:** Added 登山杖 (Trekking Poles), 速干衣裤 -- now 12 items, very comprehensive
- **Climbing:** Added 速干衣裤, renamed 头盔→攀岩头盔 to avoid dedup collision with motorcycle
- **Motorcycle:** Renamed 头盔→摩托车头盔 for disambiguation

#### Remaining Per-Tag Suggestions
- **Camping:** Still missing 炊具/餐具 (Cooking Set), 垃圾袋 (Trash Bags)
- **Diving:** Missing 潜水证 (Dive Certification Card)
- **With Kids:** Still only covers infants (ages 0-2)
- **International Travel:** Could add 旅行保险单 (Travel Insurance), consider renaming SIM卡→SIM卡/eSIM

---

## 3. STRUCTURAL & UX ISSUES

### 3.1 Category Assignment -- PARTIALLY FIXED

| Item | Status | Notes |
|------|--------|-------|
| 墨镜 (Sunglasses) | FIXED | Moved to .clothing |
| 驱蚊水 (Mosquito Repellent) | FIXED | Moved to .toiletries |
| 急救毯 (Emergency Blanket) | Not fixed | Still in .sports, user chose to keep |

### 3.2 English Translation -- FIXED

| Item | Status | Notes |
|------|--------|-------|
| "Data&Charing Cable" typo | FIXED | Now "Data & Charging Cable" |
| Standardized naming | FIXED | "Quick-Dry Clothing" used consistently, singular shoe forms |
| 皮鞋/高跟鞋 | FIXED | Now "Dress Shoes/High Heels" |
| 配饰 | FIXED | Now "Jewelry/Accessories" |

### 3.3 Deduplication Edge Cases -- FIXED

| Issue | Status | Resolution |
|-------|--------|------------|
| 头灯 vs 强光头灯 | FIXED | Both now use "头灯/Headlamp" -- dedup merges correctly |
| 发胶 in party/business for females | FIXED | occ_party_004 and occ_biz_004 now genderSpecific: .male |
| 头盔 collision (climbing vs motorcycle) | FIXED | Renamed to 攀岩头盔 and 摩托车头盔 |

### 3.4 Tag Group Design -- FIXED

| Issue | Status | Resolution |
|-------|--------|------------|
| Self Drive in Occasion group | FIXED | Moved to Config group |
| Activity group overwhelming (now 10 tags) | Open | Monitor UI -- may need sub-grouping in future |

---

## 4. PRIORITIZED RECOMMENDATIONS (Updated)

### DONE (this session)
- ~~Fix typo "Data&Charing Cable"~~ DONE
- ~~Add "Gym / 健身" tag~~ DONE
- ~~Add "Long-haul Flight / 长途飞行" config~~ DONE
- ~~Add ski gloves to skiing~~ DONE
- ~~Move Self Drive to Config~~ DONE
- ~~Fix dedup edge cases (headlamp, hair gel, helmet naming)~~ DONE
- ~~Recategorize sunglasses, mosquito repellent~~ DONE
- ~~Add base items (walking shoe, daypack)~~ DONE
- ~~Add sun hat to beach~~ DONE
- ~~Add trekking poles to trail running~~ DONE
- ~~Standardize English naming~~ DONE
- ~~Consolidate overlapping female items~~ DONE

### P1 -- Next Priority
1. **Add "Cycling / 骑行" tag** -- popular activity
2. **Add "Fishing / 钓鱼" tag** -- very popular in China
3. **Add "Wedding / 婚礼" occasion** -- common special trip
4. **Expand "With Kids" for ages 3-12** -- currently infants only

### P2 -- Future
5. Add surfing, golf, music festival, hot spring tags
6. Add "With Elderly / 带老人" config
7. Consider seasonal/weather-based item suggestions
8. Add item quantity suggestions based on trip duration
9. Consider "Popular combinations" preset bundles

---

## 5. COMPETITIVE BENCHMARK (Updated)

| Scenario | Coverage | Notes |
|----------|----------|-------|
| City sightseeing / 城市观光 | Partial | Base items now include walking shoe + daypack, but no dedicated tag |
| Business travel | GOOD | ✅ |
| Beach vacation | GOOD | ✅ +sun hat |
| Outdoor/adventure | EXCELLENT | ✅✅ +gym, enhanced trail/ski/climbing |
| Family travel | PARTIAL | ⚠️ Kids tag still infants-only |
| Winter/cold weather | GOOD | ✅ Skiing now has gloves |
| Long-haul travel | GOOD | ✅ NEW config tag |
| Gym/fitness travel | GOOD | ✅ NEW activity tag |

---

## Summary

**What was fixed:**
- 12 recommendations implemented in one session
- Base items expanded from 16→18 (walking shoe, daypack)
- 2 new tags added (gym, long-haul flight)
- Self Drive moved to correct group
- All dedup edge cases resolved
- English naming standardized
- Category misassignments corrected
- Female items consolidated (10→8, removed overlaps)
- Multiple tag item lists enhanced (skiing, beach, trail, climbing)
- Icon updates for better visual clarity (skiing, diving, international, long flight)

**What remains:**
- No dedicated cycling, fishing, or wedding tags yet
- With Kids still infants-only
- Some base items still debatable (umbrella, medicine, slippers)
- Activity group at 10 tags -- may need UI sub-grouping

**Bottom Line:** The preset system is now significantly more balanced. The addition of gym and long-haul flight fills two of the biggest mainstream gaps. Base items with walking shoe and daypack make the default list more useful for casual travelers. The remaining gaps (cycling, fishing, wedding) are lower priority and can be addressed iteratively.
