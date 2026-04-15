# Chrono Rift — Game Design Document

## Tổng quan dự án

| | |
|---|---|
| **Tên game** | Chrono Rift (tên tạm) |
| **Thể loại** | 2.5D Isometric · Adventure + Farming + Base-building |
| **Engine** | Godot 4.x · GDScript |
| **Platform** | Web (HTML5 export) |
| **Scope** | Singleplayer · Solo dev |
| **Target** | Prototype playable trong 3 tháng · MVP trong 6 tháng |

---

## Mục tiêu cốt lõi

> Xây dựng một game isometric kết hợp khám phá / chiến đấu với farming và base-building, lấy cơ chế **Chrono Rift (Mảnh vỡ thời gian)** làm trung tâm gameplay — vừa là vũ khí chiến đấu, vừa là công cụ sản xuất, vừa là "bảo hiểm sinh mạng" khi người chơi chết.

---

## Cơ chế Chrono Rift

Chrono Rift là vật phẩm trung tâm của toàn bộ game.

### Trong chiến đấu
- Quay ngược thời gian 3 giây (tránh đòn chí mạng)
- Làm chậm quái vật trong vùng AoE
- Tăng tốc độ di chuyển / tấn công bản thân

### Trong farming
- Tua nhanh thời gian — cây cối thu hoạch ngay lập tức
- Thú nuôi trưởng thành tức thì

### Khi chết
- Nhân vật chết → hồi sinh tại Hub, đồ rớt thành **Time Echo** tại điểm chết
- Cách 1 (miễn phí, rủi ro): chạy bộ ra nhặt — chết lần 2 thì mất vĩnh viễn
- Cách 2 (tốn Chrono Rift): dùng **Bàn Thờ Thời Gian** tại Hub để hút đồ về ngay

### Crafting
- 100 **Bụi thời gian** (rớt khi đánh quái) → craft 1 Chrono Rift nhỏ

---

## Hệ thống nguyên tố

```
Đất > Nước > Lửa > Ánh sáng > Bóng tối > Đất
```

**Phong** không đứng riêng — dùng để khuếch đại (AoE) hoặc tăng tốc kỹ năng:
- Kiếm Lửa + Khảm Phong → lốc lửa bay xa
- Phép Nước hồi máu + Khảm Phong → cơn mưa hồi máu diện rộng tức thì

---

## Nhân vật & Lớp nhân vật

| Role | Vũ khí | Phong cách |
|---|---|---|
| Cung thủ | Cung, Nỏ | Tầm xa, kiting |
| Đấu sĩ | Kiếm, Rìu, Giáo | Cận chiến, sinh tồn |
| Pháp sư | Gậy, Orb | AoE, khống chế |
| Sát thủ | Dao găm kép, Vuốt | Tốc độ, tàng hình, bạo kích |
| Chronomancer | Nỏ cơ học, Flintlock | Bẫy, Chrono Rift combo |
| Triệu hồi sư | Roi, Grimoire | Thú cưng chiến đấu, Beastmaster |

---

## Vùng đất (Biomes)

| Biome | Hệ nguyên tố | Quái vật đặc trưng |
|---|---|---|
| Bình nguyên | Trung tính | Slime, Lợn rừng, Goblin |
| Đầm lầy | Đất / Bóng tối | Cây ăn thịt, Bùn quái |
| Đảo / Biển | Nước | Merfolk, Cua khổng lồ, Rùa ma thuật |
| Sa mạc | Lửa / Đất | Bọ cạp, Sandworm, Xác ướp |
| Thiên đường | Ánh sáng | Thiên thần sa ngã, Golem mây |
| Hang động | Bóng tối | Nhện khổng lồ, Tinh linh bóng tối |
| **Chrono Zone** | Thời gian | Quái biến dạng thời gian · **Boss chính** |

---

## Tài nguyên

### Khai thác ngoài map
- Gỗ, Đá, Quặng (Đồng → Sắt → Vàng), Sợi gai

### Nông nghiệp
- Hạt giống, Thịt, Lông thú, Sữa / Trứng quái vật

### Đặc biệt
- **Tinh thể nguyên tố** — rớt từ quái cùng hệ (Lõi Lửa từ Slime Lửa)
- **Bụi thời gian** — rớt khi đánh quái bất kỳ · 100 bụi = 1 Chrono Rift

---

## Công trình Hub (Base Building)

| Công trình | Chức năng |
|---|---|
| Lò rèn thời gian | Chế tạo vũ khí từ quặng + tinh thể nguyên tố |
| Bàn khảm nạm | Ép nguyên tố Phong vào vũ khí / kỹ năng |
| Máy lọc thời gian | Chuyển Bụi thời gian → Chrono Rift |
| Bàn Thờ Thời Gian | Dùng Chrono Rift để lấy lại đồ sau khi chết |
| Ruộng ma thuật | Trồng cây, nâng cấp chống thời tiết |
| Chuồng thú | Nuôi quái vật, thu hoạch nguyên liệu đặc biệt |
| Tháp dịch chuyển | Fast travel giữa các Biome |

---

## Vòng lặp gameplay (Core Loop)

```
Chuẩn bị tại Hub
  → Thu hoạch, nấu ăn (buff), chế tạo vũ khí
      ↓
Khám phá Biome
  → Chặt cây, đào quặng, đánh quái, thu Bụi thời gian
      ↓
Rủi ro / Quyết định
  → Càng đi xa quái càng mạnh, HP cạn dần
  → Đi tiếp hay quay về?
      ↓
Sự cố: Chết
  → Đồ rớt thành Time Echo
  → Dùng Chrono Rift lấy lại (an toàn) hay chạy bộ ra (rủi ro)?
      ↓
Nâng cấp
  → Rèn vũ khí xịn hơn, khảm Phong, mở rộng Hub
      ↓
Quay lại từ đầu ↑
```

---

## Hệ thống chiến đấu

- Vũ khí cận chiến: có **cooldown bar** — spam click = sát thương thấp, đánh đúng nhịp = tối đa
- Vũ khí tầm xa: **hold to charge** — giữ lâu hơn = bay xa hơn, mạnh hơn
- Tương tác môi trường: dụ quái rơi vào bẫy địa hình (đầm độc, hố, tảng đá)

---

## Chăn nuôi

- Bắt quái ngoài tự nhiên hoặc lượm trứng → đem về Chuồng thú → ấp / nuôi lớn
- Thu hoạch nguyên liệu đặc biệt: Lông tàng hình, Vảy chống lửa...
- Thú lớn dùng làm **Mount** (đi qua địa hình đặc biệt) hoặc **Pet** chiến đấu

---

## Tech Stack

| Hạng mục | Công nghệ |
|---|---|
| Engine | Godot 4.x |
| Ngôn ngữ | GDScript |
| Đồ họa | Pixel Art · Isometric · Asset từ Kenney.nl / Itch.io |
| Âm thanh | OpenGameArt · Freesound.org |
| Version control | Git + GitHub |
| Hosting | Itch.io (HTML5 export) |
| AI support | Claude Sonnet 4.5 via Kiro |

---

## Thứ tự build hệ thống

```
[1] Player di chuyển trên TileMap isometric
[2] Camera follow + Y-Sort
[3] StateMachine cho quái vật (idle → chase → attack)
[4] Combat cơ bản (HP, damage, cooldown)
[5] Inventory + Item data system
[6] Chrono Rift mechanic (slow, rewind, speed)
[7] Death & Time Echo mechanic
[8] Farming system (trồng, thu hoạch)
[9] Base building (đặt công trình)
[10] Thêm Biome + quái mới
[11] UI hoàn thiện (HUD, menu, inventory)
[12] Save / Load system
[13] HTML5 export + test browser
```

---

## Milestone

| Milestone | Mục tiêu | Thời gian ước tính |
|---|---|---|
| M1 | Player di chuyển + 1 con quái đơn giản | Tuần 1–2 |
| M2 | Combat + Chrono Rift MVP | Tuần 3–5 |
| M3 | Inventory + Death mechanic | Tuần 6–8 |
| M4 | Farming + Base building cơ bản | Tuần 9–14 |
| M5 | Prototype hoàn chỉnh (Biome 1 + 2) | Tuần 15–20 |
| M6 | UI + Save/Load + HTML5 export | Tuần 21–24 |

---

*Tài liệu này là nguồn sự thật duy nhất (single source of truth) cho toàn bộ dự án. Mọi quyết định thiết kế đều tham chiếu về đây.*
