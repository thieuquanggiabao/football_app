# 🏟️ Football Live Streaming App (Flutter)

## 1. Tổng quan dự án
Đây là một ứng dụng di động (Mobile App) hỗ trợ xem bóng đá trực tiếp, theo dõi tin tức thể thao, lịch thi đấu, bảng xếp hạng và tham gia bình luận các trận đấu. Trọng tâm của ứng dụng là chức năng **Premium Subscription**, cho phép người dùng tùy chọn trải nghiệm xem bóng đá không giới hạn theo từng giải đấu hoặc tất cả các giải đấu thông qua hệ thống thanh toán tự động (thanh toán chuyển khoản VietQR).

Đối tượng mục tiêu là các tín đồ yêu thích bóng đá dùng thiết bị di động, mong muốn có một ứng dụng hoạt động mượt mà, cộng đồng fan văn minh và trải nghiệm VIP cao cấp với chi phí linh hoạt.

## 2. Kiến trúc hệ thống
Hệ thống được thiết kế theo mô hình Client-Server kết hợp Backend-as-a-Service, chia làm 3 thành phần chính:

- **Frontend (Mobile Client):** Xây dựng bằng Flutter, sử dụng kiến trúc State Management (Provider). Giao tiếp với Supabase để thực hiện các luồng xác thực (Auth), đọc/ghi dữ liệu công khai (Data/Realtime), và gọi tới Node.js Backend cho các giao dịch cần tính bảo mật cao.
- **Backend (Node.js/Express):** Đóng vai trò là Middleware xử lý thanh toán, được triển khai trên nền tảng **Render**. Nhiệm vụ chính là sinh ra mã thanh toán PayOS và cung cấp một webhook tĩnh để nhận thông báo (Callback) từ cổng thanh toán PayOS sau khi người dùng quét mã.
- **Database & Auth (Supabase):** Quản lý định danh người dùng qua Supabase Auth, lưu trữ dữ liệu chính trên PostgreSQL (có áp dụng Row Level Security - RLS). Sử dụng Database Triggers để tự động hóa xử lý logic giữa các bảng dữ liệu.
- **Payment Gateway:** Tích hợp **PayOS** (hỗ trợ sinh mã QR VietQR chuẩn) cho luồng thanh toán chuyển khoản của người dùng Việt.

## 3. Công nghệ sử dụng
### Frontend (Mobile App)
* **Framework:** Flutter (SDK `^3.10.7`)
* **State Management:** Provider (`^6.1.5`)
* **Local Storage / Media:** Image Picker, Cached Network Image, Cloudinary (Lưu trữ hình ảnh phụ)
* **Khác:** `timeago`, `flutter_local_notifications` (thông báo), `shimmer` (hiệu ứng tải).

### Backend & Database
* **Database / Backend-as-a-Service:** Supabase (`supabase_flutter ^2.12.0`), PostgreSQL.
* **Payment Middleware:** Node.js, Express.js (Deploy trên Render).
* **Payment Gateway:** PayOS.

## 4. Cấu trúc thư mục
Cấu trúc mã nguồn Frontend (`lib/`) được chia thành các module độc lập theo miền dữ liệu (Feature/Layer based):

```text
lib/
├── core/         # Chứa biến cục bộ nền tảng (constants), themes, configs, định nghĩa Notification
├── models/       # Định nghĩa Data models/Entities (Comment, Match, News, Team, User Profile)
├── repositories/ # Tầng truy cập dữ liệu (APIs, Supabase queries, Payment service) 
├── screens/      # Các màn hình chính (MainScreen, LivePlayer, Login, Premium Plan, News, v.v.)
├── services/     # Tầng business logic và tiện ích nội bộ (ProfileService...)
├── widgets/      # Các UI Components tái sử dụng (CommentSection, MatchCard, NewsCard, ReactionButton)
└── main.dart     # Entry point, khởi tạo Supabase, định nghĩa Routing & ThemeProvider
```

## 5. Luồng hoạt động chính
* **Luồng Xác thực & Quản lý User:**
  User Đăng ký/Đăng nhập qua Supabase Auth. Khi một user được tạo mới, hệ thống kích hoạt **Trigger tự động** trên PostgreSQL để sinh ra một bản ghi hồ sơ tương ứng tại bảng `public.profiles`.
* **Luồng Nâng cấp Premium (Thanh toán):**
  1. User truy cập tính năng mua gói cước (Gói giải đấu đơn lẻ hoặc All-in `SUPER_PRO`).
  2. Mobile App gọi đến Node.js Backend tạo Request thanh toán.
  3. Node.js gọi tới API PayOS => Trả mã QR về cho Mobile App hiển thị.
  4. Người dùng sử dụng App ngân hàng để quét QR thanh toán.
  5. PayOS xác nhận tiền vào, gửi Webhook tới Node.js Backend.
  6. Backend kiểm tra tính hợp lệ và cập nhật trạng thái hóa đơn tại bảng `public.transactions`.
  7. Backend cập nhật quyền lợi (upsert records) ở bảng `public.profiles` (`is_premium`, `plan_code`, `unlocked_leagues`, `expire_date`).
  8. Mobile App đồng bộ trạng thái mới của user và mở khóa cho xem bóng đá.
* **Luồng Tương tác bài đăng:**
  User đọc tin tức/xem trận đấu có thể thêm bình luận. Tính năng được bổ sung nút Reaction (Thích/Không Thích) bằng thiết kế Optimistic UI (cập nhật UI ngay lập tức) và gọi ngầm tới Supabase dưới backend.

## 6. Các quyết định thiết kế quan trọng
* **Chuẩn hóa Thông tin định danh:** Việc lưu profile thay vì nhồi nhét vào `user_metadata` của bảng `auth.users` đóng vai trò quan trọng:
  - Cung cấp tính toàn vẹn dữ liệu cho định danh thành viên. Thiết kế riêng bảng `public.profiles` chứa `unlocked_leagues` (kiểu chuỗi array `text[]`) cho phép việc query (VD: Tìm giải mã `['PL']`) cực kỳ dễ dàng trên Postgres.
  - Tách bạch cấu trúc bảng thanh toán thành `public.transactions` để lưu vết đầy đủ thay vì chỉ ghi đè một trường hạn bảo hành, đảm bảo minh bạch tài chính.
* **Kiến trúc Middleware cho Thanh Toán:** Dùng một Node.js server nhỏ làm trung gian lấy Payload + hứng Webhook từ PayOS thay vì gọi trực tiếp từ App -> Đảm bảo App hoàn toàn không cần lưu giữ Secret Keys của PayOS, tránh rủi ro bảo mật ở môi trường Mobile.
* **Thông tin Gói cước (Cập nhật mới):** Có 5 gói cước chính. Hạn sử dụng các gói đã được nâng lên **1 Năm** thay vì 30 ngày. Đặc biệt có gói **SUPER_PRO** bao trọn mọi giải đấu (`['PL', 'PD', 'BL1', 'SA', 'FL1']`).

## 7. Trạng thái hiện tại
1. [Hoàn thành] Xây dựng khung ứng dụng, giao diện, theme (Sáng/Tối) và routing.
2. [Hoàn thành] Cấu trúc Database kiểu mới (Tách `profiles` và `transactions`), chạy trigger tự động cho User Profile.
3. [Hoàn thành] Chức năng Up hình ảnh sử dụng Storage thông minh qua Cloudinary.
4. [Hoàn thành] Chức năng tạo link thanh toán, Webhook đồng bộ vào Database và logic cấp quyền sử dụng.
5. [Đang chạy] Hệ thống Reaction cho Comment (Khắc phục Constraint validation của CSDL từ fix Like/Dislike).

## 8. Điểm cần lưu ý / Known issues
* **Bảo mật RLS trên bảng `transactions` và `profiles`:** Cẩn thận giới hạn quyền, User không được tự ý ghi trực tiếp trạng thái `is_premium` qua Flutter SDK. Chỉ Admin Service Role ở môi trường Backend Node.js mới có quyền duyệt hóa đơn cập nhật.
* **Tính Idempotent của Webhook PayOS:** Webhook có thể gọi lại nhiều lần từ hệ thống mạng nên Node.js cần phải check trạng thái `pending` của transaction trước khi xác nhận tiền nhằm tránh cộng dồn thời gian Premium ảo hạn mức.
* **Notifications (iOS):** App đang cài cắm `flutter_local_notifications` nên cần đảm bảo request permission minh bạch bên nền tảng iOS mỗi khi kích hoạt build release. Cần cấu trúc chứng chỉ chuẩn (APNs).
* Bổ sung tính Missing Constraint DB đối với biến Reaction trong comment, chỉ cho phép enum: `['like','dislike']`.
