phải sử dụng theo đúng mô hình mvvm
ví dụ luồng hoạt động chuẩn:
User Interaction: Người dùng nhấn nút trên View.

Action: View gọi một hàm trong ViewModel.

Data Fetching: ViewModel yêu cầu Model cung cấp dữ liệu.

Update State: Sau khi nhận dữ liệu, ViewModel xử lý logic và cập nhật trạng thái mới.

Notify: ViewModel thông báo sự thay đổi.

Rebuild: View nhận thông báo và cập nhật lại giao diện dựa trên dữ liệu mới.
## 🏋️ Module Workout: Cần thực hiện

### 📅 Lịch tập & CRUD
- [x] UI: View lịch theo dạng Tab (Thứ 2 -> CN).

### ⏱️ Trong buổi tập (In-session)
- [x] Logic: Auto-timer khi tick hoàn thành set.
- [x] UI: Hiển thị 1RM và Volume của bài tập ngay lúc nhập.
- [x] Feature: Ghi chú nhanh (Exercise notes).

### 📈 Tracking & Analytics
- [x] DB: Lưu lịch sử tạ theo thời gian (Hive).
- [x] Chart: Biểu đồ tăng tiến Volume theo tuần cho từng nhóm cơ.
- [x] Feature: Hệ thống Badge/Achievement khi phá kỷ lục (PR).

### 📋 Cấu trúc buổi tập (Data Structure)
- **Buổi tập (Session):** Tên buổi, Thứ trong tuần (Tab View).
- **Bài tập (Exercise):** Tên bài, ghi chú bài tập.
- **Hiệp tập (Set):**
    khi ở mục thứ trong tuần (tab view)  ấn vào có thể xem qua những bài sẽ tập (/new: có thể ấn vào bìa tập và xem thông tin về số reps, weight, set của những lần tập trước đó, đó, có sơ đồ đường biến thiên mức tăng tạ( có dữ liệu trong hive(tạo dữ liệu mẫu), hiển thị dữ liệu từ tháng trước đến nay, mỗi tuần sẽ có 2 lần vì trong 1 tuần sẽ tập 2 lần bài đó))
    thêm chức năng chỉnh sửa , nếu bình thường số cân nặng sẽ cố định, số lần thực hiện cho phép nhập để theo dõi (mặc định sẽ là số lần thực hiện của lần tập trước đó).
    //chức năng chỉnh sửa ngày tập
    
    khi ấn sửa để vào chế độ chỉnh sửa sẽ cho phép thêm bài tập mới trong một ngày tập (thay vì thêm bằng cách thêm wg ở dưới thì hãy thêm bằng cách mở cửa sổ), sửa tên bàichỉnh  mức tạ, số set, sửa thời gian nghỉ, thêm nút xóa ngày tập trên appbar bên phải
    chuyển chức năng sửa ra ngoài ngày tập, khi ấn vào sẽ cho phép chỉnh sửa tất cả các set trong ngày tập, khi tập sẽ không thể chỉnh sửa gì nữa trừ nhập số lần thực hiện
    khi tích hoàn thành sẽ làm mờ set đó và không cho phép chỉnh sửa nữa.
    khi ấn start để bắt đầu tập luyện sẽ không cho phép chỉnh sửa gì nữa trừ nhập số lần thực hiện
    thêm chức năng ghi chú cho từng bài tập
    thêm chức năng thêm bài tập khi ở chế độ chỉnh sửa, khi ở chỉnh sửa sẽ không thể đánh tích và không có rest timer, không có hoàn thành bài
    // khi tập luyện
    khi thời gian nghỉ kết thúc mới được đánh tích hoàn thành set tiếp theo
    khi chưa đánh tích hết các bài thì button hoàn thành buổi tập sẽ mờ đi
    - [x] Nhập số cân nặng (Weight).
    - [x] Nhập số lần thực hiện (Reps).
    - [x] Tích chọn hoàn thành -> Kích hoạt Rest Timer tự động.
    - [x] Cho phép thêm hiệp mới (Add Set) ngay trong lúc tập.
ở cuối có nút hoàn thành buổi tập, khi ấn vào sẽ lưu lại lịch sử tập luyện.



## 🏋️ Module Habit: Đã thực hiện ✅

- [x] Màn hình chính: Chứa các habit trong ngày, có thanh tiến độ % hoàn thành.
- [x] Tính kỷ luật: Tích hoàn thành là khóa, không cho chỉnh sửa trong ngày.
- [x] Thống kê: Biểu đồ cột theo dõi 7 ngày gần nhất.
- [x] Lịch sử: Xem chi tiết số lần hoàn thành của từng thói quen.

    