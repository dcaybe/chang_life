# Đặc Tả Cấu Trúc Dữ Liệu & Kịch Bản Tương Tác Chi Tiết
## Ứng dụng Change Life — Theo dõi sức khỏe & tập luyện cá nhân

> **Phiên bản:** 1.0  
> **Dự án:** Change Life — Ứng dụng di động Flutter  
> **Lưu trữ:** Thư mục dự án cá nhân tại Trung tâm hỗ trợ phát triển KHKT

---

## Mục lục

1. [UC1: Đăng nhập / Đăng ký](#uc1-đăng-nhập--đăng-ký)
2. [UC2: Quản lý hồ sơ thể trạng](#uc2-quản-lý-hồ-sơ-thể-trạng)
3. [UC3: Quản lý nhật ký tập luyện](#uc3-quản-lý-nhật-ký-tập-luyện)
4. [UC4: Theo dõi thói quen sức khỏe](#uc4-theo-dõi-thói-quen-sức-khỏe)
5. [UC5: Quản lý chế độ dinh dưỡng](#uc5-quản-lý-chế-độ-dinh-dưỡng)
6. [UC6: Lưu trữ dữ liệu cục bộ](#uc6-lưu-trữ-dữ-liệu-cục-bộ)
7. [UC7: Truy vấn CSDL thực phẩm](#uc7-truy-vấn-csdl-thực-phẩm)
8. [UC8: Sao lưu / Khôi phục dữ liệu](#uc8-sao-lưu--khôi-phục-dữ-liệu)
9. [UC9: Truy vấn CSDL bài tập](#uc9-truy-vấn-csdl-bài-tập)
10. [Đặc tả cấu trúc dữ liệu tổng hợp](#đặc-tả-cấu-trúc-dữ-liệu-tổng-hợp)

---

## UC1: Đăng nhập / Đăng ký

| Thành phần | Nội dung |
|---|---|
| **Tên UC** | UC1: Đăng nhập / Đăng ký |
| **Tác nhân** | Người dùng, Supabase Server |
| **Mục tiêu** | Người dùng xác thực danh tính để truy cập hệ thống |
| **Điều kiện tiên quyết** | Ứng dụng đã được cài đặt, có kết nối mạng |
| **Điều kiện sau** | Người dùng được cấp phiên đăng nhập, chuyển đến màn hình chính |

**Luồng sự kiện chính:**

| Bước | Tác nhân | Mô tả |
|:----:|----------|-------|
| 1 | Người dùng | Mở ứng dụng, chọn "Đăng ký" hoặc "Đăng nhập" |
| 2 | Người dùng | Nhập email và mật khẩu |
| 3 | Hệ thống | Gửi thông tin xác thực tới Supabase Auth |
| 4 | Supabase | Xác minh thông tin, trả về token phiên đăng nhập |
| 5 | Hệ thống | Lưu token vào bộ nhớ cục bộ, chuyển đến màn hình chính |

**Luồng thay thế:**

- **AF1 — Sai thông tin đăng nhập:** Supabase trả về lỗi → Hiển thị thông báo "Email hoặc mật khẩu không chính xác"
- **AF2 — Mất kết nối mạng:** Hiển thị thông báo "Vui lòng kiểm tra kết nối mạng"
- **AF3 — Email đã tồn tại:** Khi đăng ký → Hiển thị "Email đã được sử dụng"

---

## UC2: Quản lý hồ sơ thể trạng

| Thành phần | Nội dung |
|---|---|
| **Tên UC** | UC2: Quản lý hồ sơ thể trạng |
| **Tác nhân** | Người dùng, Hệ thống |
| **Mục tiêu** | Cập nhật thông tin cá nhân phục vụ tính toán dinh dưỡng và theo dõi tiến trình |
| **Điều kiện tiên quyết** | Người dùng đã đăng nhập |
| **Điều kiện sau** | Thông tin thể trạng được lưu vào Hive |

**Luồng sự kiện chính:**

| Bước | Tác nhân | Mô tả |
|:----:|----------|-------|
| 1 | Người dùng | Mở màn hình Hồ sơ / Cài đặt |
| 2 | Người dùng | Nhập hoặc cập nhật: tên, chiều cao (cm), cân nặng (kg), tuổi, giới tính |
| 3 | Hệ thống | Validate dữ liệu đầu vào |
| 4 | Hệ thống | Lưu từng trường vào Hive settingsBox |
| 5 | Hệ thống | Hiển thị thông báo cập nhật thành công |

**Cấu trúc dữ liệu:**

| Trường | Kiểu | Mặc định | Hive Key |
|--------|------|----------|----------|
| Tên người dùng | String | "Guest" | user_name |
| Chiều cao | double | 170.0 | height |
| Cân nặng | double | 65.0 | weight |
| Tuổi | int | 25 | age |
| Giới tính | String | "Male" | gender |

---

## UC3: Quản lý nhật ký tập luyện

| Thành phần | Nội dung |
|---|---|
| **Tên UC** | UC3: Quản lý nhật ký tập luyện |
| **Tác nhân** | Người dùng, Hệ thống, ExerciseDB API |
| **Mục tiêu** | Ghi chép thông số nâng tạ thực tế hằng ngày để theo dõi tiến trình sức mạnh |
| **Điều kiện tiên quyết** | Đã đăng nhập, đang ở giao diện tập luyện, có ít nhất một kế hoạch tập hoặc sẵn sàng tạo mới |
| **Điều kiện sau** | Dữ liệu buổi tập được ghi nhận vào Hive, các chỉ số 1RM và Total Volume được tính toán tự động, kỷ lục cá nhân được phát hiện và đánh dấu, biểu đồ tiến trình được cập nhật |

**Luồng sự kiện chính:**

| Bước | Tác nhân | Mô tả |
|:----:|----------|-------|
| 1 | Người dùng | Chọn kế hoạch tập từ lịch tập theo ngày trong tuần. Hoặc tạo buổi tập mới |
| 2 | Hệ thống | Khởi tạo phiên tập bằng cách clone template sang session mới, reset trạng thái tất cả set về chưa hoàn thành |
| 3 | Người dùng | Duyệt danh sách bài tập. Có thể thêm bài tập mới từ ExerciseDB API hoặc nhập thủ công |
| 4 | Người dùng | Nhập thông số cho từng hiệp: Khối lượng tạ (kg) và Số lần lặp lại (reps) |
| 5 | Người dùng | Tick hoàn thành từng hiệp. Hệ thống tự động kích hoạt bộ đếm thời gian nghỉ, mặc định 60 giây |
| 6 | Hệ thống | Tự động tính 1RM theo công thức Epley, Total Volume, và kiểm tra kỷ lục cá nhân |
| 7 | Người dùng | Nhấn nút "Hoàn thành buổi tập" |
| 8 | Hệ thống | Ghi nhận thời gian hoàn thành, lưu vào Hive, cập nhật biểu đồ, hiển thị thông báo thành công |

**Luồng thay thế:**

- **AF1 — Mất kết nối khi truy vấn ExerciseDB (bước 3):** Thông báo "Không có kết nối mạng" → Cho phép nhập thủ công → Quay về bước 4
- **AF2 — Nhập thiếu dữ liệu (bước 4):** Hiệp đó không tính vào Volume/1RM, không block luồng, có thể cập nhật lại
- **AF3 — Hủy buổi tập:** Hiển thị dialog xác nhận → Reset trạng thái, không lưu dữ liệu

**Công thức tính toán:**

| Chỉ số | Công thức |
|--------|-----------|
| 1RM Epley | 1RM = weight × (1 + reps/30) |
| Total Volume | Volume = Σ(weight × reps) cho các set hoàn thành |
| PR Detection | weight > maxWeight hoặc 1RM > max1RM so với lịch sử |

**Cấu trúc dữ liệu:**

```
WorkoutSession
├── id: String
├── name: String
├── dayOfWeek: int (1=Thứ 2, 7=CN)
├── dateCompleted: DateTime?
└── exerciseLogs: List<ExerciseLog>
    ├── exercise: Exercise
    │   ├── id: String
    │   ├── name: String
    │   └── targetMuscle: String
    ├── sets: List<WorkoutSet>
    │   ├── weight: double (kg)
    │   ├── reps: int
    │   ├── isCompleted: bool
    │   └── isPR: bool?
    ├── notes: String
    └── restSeconds: int? (mặc định 60)
```

---

## UC4: Theo dõi thói quen sức khỏe

| Thành phần | Nội dung |
|---|---|
| **Tên UC** | UC4: Theo dõi thói quen sức khỏe |
| **Tác nhân** | Người dùng, Hệ thống |
| **Mục tiêu** | Thiết lập và check-in thói quen sức khỏe hàng ngày để xây dựng kỷ luật |
| **Điều kiện tiên quyết** | Đã đăng nhập, đang ở giao diện theo dõi thói quen |
| **Điều kiện sau** | Trạng thái thói quen được cập nhật và lưu vào Hive |

**Luồng sự kiện chính:**

| Bước | Tác nhân | Mô tả |
|:----:|----------|-------|
| 1 | Người dùng | Mở màn hình Thói quen |
| 2 | Hệ thống | Hiển thị danh sách thói quen với trạng thái check-in của ngày hiện tại |
| 3 | Người dùng | Tick hoàn thành thói quen trong ngày |
| 4 | Hệ thống | Ghi nhận ngày hoàn thành vào danh sách completedDays, lưu vào Hive |
| 5 | Hệ thống | Cập nhật giao diện — hiển thị streak và trạng thái |

**Luồng thay thế:**

- **AF1 — Thêm thói quen mới:** Người dùng nhập tên → Hệ thống tạo Habit mới với ID duy nhất → Lưu Hive
- **AF2 — Xóa thói quen:** Chọn xóa → Dialog xác nhận → Xóa khỏi Hive
- **AF3 — Bỏ check-in (Undo):** Tick lại thói quen đã hoàn thành → Xóa ngày khỏi completedDays

**Cấu trúc dữ liệu:**

```
Habit
├── id: String
├── name: String
├── isDone: bool
├── completedDays: List<String> (VD: ["2026-06-13", "2026-06-12"])
└── colorValue: int?
```

---

## UC5: Quản lý chế độ dinh dưỡng

| Thành phần | Nội dung |
|---|---|
| **Tên UC** | UC5: Quản lý chế độ dinh dưỡng |
| **Tác nhân** | Người dùng, Hệ thống, Supabase Server |
| **Mục tiêu** | Lập kế hoạch bữa ăn theo mục tiêu calories/macros dựa trên thể trạng cá nhân |
| **Điều kiện tiên quyết** | Đã đăng nhập, đã có hồ sơ thể trạng |
| **Điều kiện sau** | Meal plan được tạo và lưu vào Hive, chỉ số dinh dưỡng được cập nhật |

**Luồng sự kiện chính:**

| Bước | Tác nhân | Mô tả |
|:----:|----------|-------|
| 1 | Người dùng | Mở màn hình Dinh dưỡng, chọn "Tạo kế hoạch ăn" |
| 2 | Người dùng | Nhập thông số: tuổi, chiều cao, cân nặng, giới tính, mục tiêu, mức vận động, thực phẩm yêu thích, số bữa/ngày, số ngày |
| 3 | Hệ thống | Tính BMR theo công thức Mifflin-St Jeor, nhân hệ số vận động → TDEE, điều chỉnh theo mục tiêu |
| 4 | Hệ thống | Tính phân bổ macros: Protein = 2.2 × cân nặng, Fat = 25% calories, Carb = phần còn lại |
| 5 | Hệ thống | Truy vấn CSDL thực phẩm, tính toán khối lượng thực phẩm theo macros |
| 6 | Hệ thống | Sinh meal plan cho từng ngày với xoay vòng thực phẩm |
| 7 | Hệ thống | Lưu meal plan vào Hive, cập nhật chỉ số dinh dưỡng vào settingsBox |
| 8 | Hệ thống | Hiển thị kế hoạch ăn với chi tiết macros từng bữa |

**Luồng thay thế:**

- **AF1 — Chỉnh sửa bữa ăn:** Người dùng chọn bữa → Sửa nội dung → Lưu lại Hive
- **AF2 — Chưa có hồ sơ thể trạng:** Yêu cầu nhập trực tiếp trên form tạo kế hoạch

**Công thức tính toán:**

| Chỉ số | Công thức |
|--------|-----------|
| BMR Nam | 10 × weight + 6.25 × height - 5 × age + 5 |
| BMR Nữ | 10 × weight + 6.25 × height - 5 × age - 161 |
| TDEE | BMR × hệ số vận động (1.2 ~ 1.9) |
| Calories | TDEE ± 500 (tùy mục tiêu giảm cân/tăng cơ) |

**Cấu trúc dữ liệu:**

```
MealPlan
├── day: String (VD: "Thứ 2", "Ngày 1")
├── breakfast: String
├── lunch: String
├── snack: String
├── dinner: String
└── lateNight: String

Food
├── id: String
├── name: String
├── calories: int
└── image: String
```

---

## UC6: Lưu trữ dữ liệu cục bộ

| Thành phần | Nội dung |
|---|---|
| **Tên UC** | UC6: Lưu trữ dữ liệu cục bộ |
| **Tác nhân** | Hệ thống |
| **Mục tiêu** | Lưu trữ toàn bộ dữ liệu offline bằng Hive Flutter |
| **Điều kiện tiên quyết** | Ứng dụng đã khởi tạo Hive thành công |
| **Điều kiện sau** | Dữ liệu được persist vào file hệ thống |

**Danh sách Hive Box:**

| Box | Kiểu | TypeId | Dữ liệu |
|-----|------|--------|----------|
| settingsBox | Box | — | Cài đặt, hồ sơ thể trạng, token, theme, nutrition config |
| workoutBox | Box\<WorkoutSession\> | 3 | Template và lịch sử buổi tập |
| habitBox | Box\<Habit\> | 1 | Danh sách thói quen |
| foodBox | Box\<Food\> | 2 | Cache danh sách thực phẩm |
| nutritionBox | Box\<MealPlan\> | 7 | Kế hoạch bữa ăn |
| goalBox | Box\<Goal\> | 0 | Mục tiêu cá nhân |

---

## UC7: Truy vấn CSDL thực phẩm

| Thành phần | Nội dung |
|---|---|
| **Tên UC** | UC7: Truy vấn CSDL thực phẩm |
| **Tác nhân** | Hệ thống, Supabase Server |
| **Mục tiêu** | Cung cấp dữ liệu thực phẩm chính xác cho module dinh dưỡng |
| **Điều kiện tiên quyết** | Có kết nối mạng |
| **Điều kiện sau** | Danh sách thực phẩm được trả về và cache cục bộ |

**Luồng sự kiện chính:**

| Bước | Tác nhân | Mô tả |
|:----:|----------|-------|
| 1 | Hệ thống | Gửi request tới Supabase PostgreSQL |
| 2 | Supabase | Trả về danh sách thực phẩm kèm thông tin dinh dưỡng |
| 3 | Hệ thống | Cache dữ liệu vào Hive foodBox |
| 4 | Hệ thống | Trả dữ liệu cho module dinh dưỡng sử dụng |

**Luồng thay thế:**

- **AF1 — Mất kết nối:** Sử dụng dữ liệu từ cache cục bộ hoặc CSDL tĩnh tích hợp sẵn

---

## UC8: Sao lưu / Khôi phục dữ liệu

| Thành phần | Nội dung |
|---|---|
| **Tên UC** | UC8: Sao lưu / Khôi phục dữ liệu |
| **Tác nhân** | Người dùng, Hệ thống, Supabase Server |
| **Mục tiêu** | Backup dữ liệu lên cloud và restore khi đổi máy |
| **Điều kiện tiên quyết** | Đã đăng nhập, có kết nối mạng |
| **Điều kiện sau** | Dữ liệu được đồng bộ giữa thiết bị và cloud |

**Luồng sự kiện chính — Sao lưu:**

| Bước | Tác nhân | Mô tả |
|:----:|----------|-------|
| 1 | Người dùng | Chọn "Sao lưu dữ liệu" trong Cài đặt |
| 2 | Hệ thống | Đọc toàn bộ dữ liệu từ các Hive Box |
| 3 | Hệ thống | Serialize dữ liệu thành JSON |
| 4 | Hệ thống | Upload lên Supabase Storage |
| 5 | Hệ thống | Hiển thị thông báo "Sao lưu thành công" |

**Luồng sự kiện chính — Khôi phục:**

| Bước | Tác nhân | Mô tả |
|:----:|----------|-------|
| 1 | Người dùng | Chọn "Khôi phục dữ liệu" trong Cài đặt |
| 2 | Hệ thống | Tải file backup từ Supabase Storage |
| 3 | Hệ thống | Deserialize JSON, ghi đè vào các Hive Box |
| 4 | Hệ thống | Reload toàn bộ ViewModel, hiển thị "Khôi phục thành công" |

**Luồng thay thế:**

- **AF1 — Chưa có bản sao lưu:** Hiển thị "Không tìm thấy dữ liệu sao lưu"
- **AF2 — Mất kết nối:** Hiển thị "Vui lòng kiểm tra kết nối mạng"

---

## UC9: Truy vấn CSDL bài tập

| Thành phần | Nội dung |
|---|---|
| **Tên UC** | UC9: Truy vấn CSDL bài tập |
| **Tác nhân** | Hệ thống, ExerciseDB API |
| **Mục tiêu** | Cung cấp danh sách bài tập kèm hướng dẫn cho module tập luyện |
| **Điều kiện tiên quyết** | Có kết nối mạng |
| **Điều kiện sau** | Danh sách bài tập với GIF hướng dẫn được hiển thị |

**Luồng sự kiện chính:**

| Bước | Tác nhân | Mô tả |
|:----:|----------|-------|
| 1 | Hệ thống | Gửi request tới ExerciseDB API |
| 2 | ExerciseDB | Trả về danh sách bài tập: tên, GIF, nhóm cơ, thiết bị |
| 3 | Hệ thống | Hiển thị danh sách cho người dùng lọc/chọn |
| 4 | Người dùng | Chọn bài tập → Thêm vào phiên tập hiện tại |

**Luồng thay thế:**

- **AF1 — Mất kết nối:** Cho phép nhập thủ công tên bài tập và nhóm cơ

---

## Đặc tả cấu trúc dữ liệu tổng hợp

### Sơ đồ quan hệ các thực thể

```
┌─────────────────┐     ┌──────────────────┐
│   Goal          │     │   SubGoal        │
├─────────────────┤     ├──────────────────┤
│ id: String      │ 1─* │ id: String       │
│ title: String   │     │ title: String    │
│ description     │     │ isCompleted:bool │
│ deadline: Date  │     └──────────────────┘
│ subGoals: List  │
│ progress: double│
│ remainingDays   │
└─────────────────┘

┌─────────────────┐     ┌──────────────────┐     ┌──────────────┐
│ WorkoutSession  │     │  ExerciseLog     │     │  WorkoutSet  │
├─────────────────┤     ├──────────────────┤     ├──────────────┤
│ id: String      │ 1─* │ exercise: Exer.  │ 1─* │ weight:double│
│ name: String    │     │ sets: List       │     │ reps: int    │
│ dayOfWeek: int  │     │ notes: String    │     │ isCompleted  │
│ exerciseLogs    │     │ restSeconds: int │     │ isPR: bool?  │
│ dateCompleted?  │     │ highest1RM       │     └──────────────┘
│ isCompleted     │     │ totalVolume      │
└─────────────────┘     └──────────────────┘
                              │ 1
                              │
                        ┌──────────────┐
                        │   Exercise   │
                        ├──────────────┤
                        │ id: String   │
                        │ name: String │
                        │ targetMuscle │
                        └──────────────┘

┌─────────────────┐     ┌──────────────────┐     ┌──────────────┐
│    Habit        │     │   MealPlan       │     │    Food      │
├─────────────────┤     ├──────────────────┤     ├──────────────┤
│ id: String      │     │ day: String      │     │ id: String   │
│ name: String    │     │ breakfast: String│     │ name: String │
│ isDone: bool    │     │ lunch: String    │     │ calories: int│
│ completedDays   │     │ snack: String    │     │ image: String│
│ colorValue: int?│     │ dinner: String   │     └──────────────┘
└─────────────────┘     │ lateNight: String│
                        └──────────────────┘
```

### Bảng tổng hợp Hive TypeId

| TypeId | Model | Hive Box | Module |
|:------:|-------|----------|--------|
| 0 | Goal | goalBox | Mục tiêu |
| 1 | Habit | habitBox | Thói quen |
| 2 | Food | foodBox | Dinh dưỡng |
| 3 | WorkoutSession | workoutBox | Tập luyện |
| 4 | Exercise | — | Tập luyện |
| 5 | WorkoutSet | — | Tập luyện |
| 6 | ExerciseLog | — | Tập luyện |
| 7 | MealPlan | nutritionBox | Dinh dưỡng |
| 8 | SubGoal | — | Mục tiêu |

---

> **Ghi chú:** Tài liệu này được tạo tự động từ mã nguồn dự án Change Life và phản ánh đúng cấu trúc dữ liệu cùng luồng nghiệp vụ hiện tại của hệ thống. Mọi thay đổi trong mã nguồn cần được cập nhật tương ứng vào tài liệu này.
