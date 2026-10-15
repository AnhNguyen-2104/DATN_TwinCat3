# DỰ ÁN DATN TWINCAT 3 & MITSUBISHI PLC-Q (GLUE TRACKING)

## QUY TẮC BẮT BUỘC (CONTRACT LAW)

Mọi agent làm việc trong repository này BẮT BUỘC luôn đọc trước 2 file tài liệu hợp đồng:
1. `D:/VC/Session2_Contract_For_Session1.md` (Hợp đồng giao diện trực tiếp giữa Session 1 TwinCAT 3 và Session 2 PLC-Q)
2. `D:/VC/Glue_Tracking_System_Specs.md` (Đặc tả kỹ thuật và kế hoạch hệ thống tổng thể)

### VAI TRÒ HỆ THỐNG
- **Session 1 (TwinCAT 3 - Master)**:
  - Xử lý ảnh Camera, tính toán 4 đỉnh phôi 40x40mm theo góc xoay θ.
  - Đọc Encoder Crevis ST-5114 (Slot 12 Byte 0..1), tính quãng trôi và vận tốc mượt.
  - Tính tọa độ đón đầu thời gian thực, quy đổi sang đơn vị QD75 ($0.1\ \mu\text{m}$ và $0.01\text{ mm/min}$).
  - Gửi khối dữ liệu `D100..D114` qua MC Protocol cổng `5010`.
  - Bật `M1000 = TRUE` (Start) và chờ PLC-Q hoàn thành `M1001 = TRUE`.
- **Session 2 (Mitsubishi PLC Q06UDEH + QD75D4 - Slave Gantry)**:
  - Nhận `D100..D114` nạp vào 3 Point nội suy tuyến tính 3 trục.
  - Phát xung chạy Point 1 bay tiếp cận, Point 2 trượt đồng tốc X và xả keo 30ms qua van `Y20`, Point 3 rút Z an toàn.
  - Hoàn tất Point 3 thì bật `M1001 = TRUE` báo TwinCAT.

### BẢNG TÍN HIỆU BẮT TAY (HANDSHAKE)
- `M1000`: `Cmd_Start_Vertex` (TwinCAT ghi `TRUE` để chạy 1 đỉnh, hạ `FALSE` khi nhận `M1001`).
- `M1001`: `Ack_Vertex_Done` (PLC-Q bật `TRUE` khi xong đỉnh, tự hạ `FALSE` khi `M1000 = FALSE`).
- `M102`: `Robot_Busy` (PLC-Q bật khi đang chạy Point 1..3).
- `M103`: `Robot_In_Position` (PLC-Q bật khi trục vào vị trí an toàn).
- `M104`: `Robot_Alarm` (PLC-Q bật khi QD75 lỗi hoặc vi phạm biên).
- `M105`: `Cmd_Cycle_Reset` (Lệnh dừng khẩn cấp từ TwinCAT / HMI).
- **CẤM TUYỆT ĐỐI**: Không bao giờ dùng `M100` và `M101` cho Tracking (tránh xung đột với logic Homing trục trong PLC-Q).

### QUY ĐỔI ĐƠN VỊ QD75D4
- Vị trí: $1\text{ mm} = 10000$ đơn vị ($0.1\ \mu\text{m}$, kiểu DINT 32-bit).
- Vận tốc: $1\text{ mm/s} = 6000$ đơn vị ($0.01\text{ mm/min}$, kiểu DINT 32-bit).
- Port Ethernet: Cố định `5010`. CẤM dùng `5000..5009`.
